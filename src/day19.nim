import adventutils
import algorithm
import math
import sequtils
import std/[deques, options, sets]
import strscans
import tables

type Point3D = tuple[x, y, z: int]

type Edge = tuple[a, b: Point3D]

type Scanner = ref object
  data: seq[Point3D]
  edges: seq[Edge]
  n: HashSet[int]

type Mapping = tuple[xTo, yTo, zTo: char]

type Delta = tuple[mx, my, mz, dx, dy, dz: int]

func length3(edge: Edge): (int, int, int) =
  let (a, b) = edge
  (abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))

func length(edge: Edge): int =
  let (dx, dy, dz) = edge.length3
  dx + dy + dz

func isWithin(edge: Edge): bool =
  let (dx, dy, dz) = edge.length3
  dx <= 1000 and dy <= 1000 and dz <= 1000

func toEdges(data: seq[Point3D]): seq[Edge] =
  for i, d in data[0 .. ^2]:
    result = result.concat data[i + 1 .. ^1]
      .filterIt((it, d).isWithin).foldl(a & @[(a: d, b: b)], newSeq[Edge]())

func toData(data: string): Point3D =
  let (_, x, y, z) = data.scanTuple("$i,$i,$i")
  (x, y, z)

func toData(data: seq[string]): Scanner =
  let
    (_, n) = data[0].scanTuple("--- scanner $i ---")
    data = data[1 .. ^1].foldl(a & b.toData, newSeq[Point3D]())
  Scanner(data: data, edges: data.toEdges, n: [n].toHashSet)

func delta(mapping: Mapping, edge: Edge, reference: Edge): Delta =
  let
    (xTo, yTo, zTo) = mapping
    (ea, eb) = (edge.a, edge.b)
    (ra, rb) = (reference.a, reference.b)
    (ex, ey, ez) = ((ea.x - eb.x), (ea.y - eb.y), (ea.z - eb.z))
    (rx, ry, rz) = ((ra.x - rb.x), (ra.y - rb.y), (ra.z - rb.z))
  var mx, my, mz, dx, dy, dz: int
  case xTo:
    of 'x':
      mx = (if ex == rx: 1 else: -1)
      dx = ra.x - mx * ea.x
    of 'y':
      mx = (if ex == ry: 1 else: -1)
      dx = ra.y - mx * ea.x
    of 'z':
      mx = (if ex == rz: 1 else: -1)
      dx = ra.z - mx * ea.x
    else: discard
  case yTo:
    of 'x':
      my = (if ey == rx: 1 else: -1)
      dy = ra.x - my * ea.y
    of 'y':
      my = (if ey == ry: 1 else: -1)
      dy = ra.y - my * ea.y
    of 'z':
      my = (if ey == rz: 1 else: -1)
      dy = ra.z - my * ea.y
    else: discard
  case zTo:
    of 'x':
      mz = (if ez == rx: 1 else: -1)
      dz = ra.x - mz * ea.z
    of 'y':
      mz = (if ez == ry: 1 else: -1)
      dz = ra.y - mz * ea.z
    of 'z':
      mz = (if ez == rz: 1 else: -1)
      dz = ra.z - mz * ea.z
    else: discard
  (mx, my, mz, dx, dy, dz)

func matches(e1, e2: Edge): Table[(Mapping, Delta), HashSet[Point3D]] =
  var mapping = none[Mapping]()
  let
    (de1x, de1y, de1z) = e1.length3
    (de2x, de2y, de2z) = e2.length3
  if de1x == de2x:
    if de1y == de2y and de1z == de2z: mapping = some((xTo: 'x', yTo: 'y', zTo: 'z'))
    elif de1y == de2z and de1z == de2y: mapping = some((xTo: 'x', yTo: 'z', zTo: 'y'))
  elif de1x == de2y:
    if de1y == de2x and de1z == de2z: mapping = some((xTo: 'y', yTo: 'x', zTo: 'z'))
    elif de1y == de2z and de1z == de2x: mapping = some((xTo: 'y', yTo: 'z', zTo: 'x'))
  elif de1x == de2z:
    if de1y == de2y and de1z == de2x: mapping = some((xTo: 'z', yTo: 'y', zTo: 'x'))
    elif de1y == de2x and de1z == de2y: mapping = some((xTo: 'z', yTo: 'x', zTo: 'y'))
  if mapping.isSome:
    let k = (mapping.get, delta(mapping.get, e1, e2))
    result[k] = (result.getOrDefault(k, initHashSet[Point3D]()) + [e1.a, e1.b].toHashSet)

func deltaRelativeTo(s1, s2: Scanner): Option[(Mapping, Delta)] =
  var mappings = initTable[(Mapping, Delta), HashSet[Point3D]]()
  for e1 in s1.edges:
    for e2 in s2.edges:
      for k, v in e1.matches(e2):
        mappings[k] = mappings.getOrDefault(k, initHashSet[Point3D]()) + v
  let candidates = mappings.pairs.toSeq.filterIt(it[1].len > 2).sortedByIt(-1 * it[1].len)
  return if candidates.len > 0: some(candidates[0][0]) else: none[(Mapping, Delta)]()

func offset(p: Point3D, mapping: Mapping, delta: Delta): Point3D =
  let
    (xTo, yTo, zTo) = mapping
    (mx, my, mz, dx, dy, dz) = delta
    nx = (p.x + mx * dx) * mx
    ny = (p.y + my * dy) * my
    nz = (p.z + mz * dz) * mz
  var x, y, z: int
  case xTo:
    of 'x': x = nx
    of 'y': y = nx
    of 'z': z = nx
    else: discard
  case yTo:
    of 'x': x = ny
    of 'y': y = ny
    of 'z': z = ny
    else: discard
  case zTo:
    of 'x': x = nz
    of 'y': y = nz
    of 'z': z = nz
    else: discard
  (x, y, z)

func toOffset(mapping: Mapping, delta: Delta): Point3D =
  let
    (xTo, yTo, zTo) = mapping
    (_, _, _, dx, dy, dz) = delta
  var x, y, z: int
  case xTo:
    of 'x': x = dx
    of 'y': y = dx
    of 'z': z = dx
    else: discard
  case yTo:
    of 'x': x = dy
    of 'y': y = dy
    of 'z': z = dy
    else: discard
  case zTo:
    of 'x': x = dz
    of 'y': y = dz
    of 'z': z = dz
    else: discard
  (x, y, z)

func `+`(sAcc, s: Scanner): (Scanner, Option[Point3D]) =
  if s.n.allIt(it in sAcc.n): return (sAcc, none[Point3D]())
  let r = s.deltaRelativeTo sAcc
  if r.isNone: return (sAcc, none[Point3D]())
  let
    (mapping, delta) = r.get
    newData = (sAcc.data & s.data.mapIt(it.offset(mapping, delta))).deduplicate
  (Scanner(data: newData, edges: newData.toEdges, n: (sAcc.n + s.n)), some(mapping.toOffset delta))

func process(input: seq[string]): (Scanner, seq[Point3D]) =
  let scanners = input.splitByEmptyLines.mapIt(it.toData)
  var
    combined = scanners[0]
    remaining = scanners[1 .. ^1].toDeque
    offsets = newSeq[Point3D]()
  while remaining.len > 0:
    let
      next = remaining.popFirst
      (updated, offset) = combined + next
    combined = updated
    if offset.isSome: offsets.add offset.get else: remaining.addLast next
  (combined, offsets)

func part1*(input: seq[string]): int = input.process[0].data.len

func part2*(input: seq[string]): int =
  let (_, offsets) = input.process
  result = 0
  for i, offset in offsets[0 .. ^2]:
    result = offsets[i + 1 .. ^1].foldl(a.max (offset, b).length, result)
