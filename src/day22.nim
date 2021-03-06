import sequtils
import strscans

type Cube = tuple[x1, x2, y1, y2, z1, z2: int]

type Step = tuple[isOn: bool, cube: Cube]

type Box = ref object
  cube: Cube
  toMinus: seq[Box]

func parse(step: string): Step =
  let (_, mode, x1, x2, y1, y2, z1, z2) = step.scanTuple "$w x=$i..$i,y=$i..$i,z=$i..$i"
  (mode == "on", (x1, x2 + 1, y1, y2 + 1, z1, z2 + 1))

func crop(a1: int, a2: int, b1: int, b2: int): (int, int) =
  return if a2 <= b1 or a1 >= b2: (0, 0) else: (max(a1, b1), min(a2, b2))

func crop(a: Cube, b: Cube): Cube =
  let
    (x1, x2) = crop(a.x1, a.x2, b.x1, b.x2)
    (y1, y2) = crop(a.y1, a.y2, b.y1, b.y2)
    (z1, z2) = crop(a.z1, a.z2, b.z1, b.z2)
  (x1, x2, y1, y2, z1, z2)

func isEmpty(cube: Cube): bool =
  let (x1, x2, y1, y2, z1, z2) = cube
  x2 <= x1 or y2 <= y1 or z2 <= z1

func volume(cube: Cube): int =
  let (x1, x2, y1, y2, z1, z2) = cube
  (x2 - x1) * (y2 - y1) * (z2 - z1)

func volume(box: Box): int = box.cube.volume - box.toMinus.foldl(a + b.volume, 0)

func `-`(box: Box, cube: Cube): Box =
  let cropped = cube.crop box.cube
  if cropped.isEmpty: return box
  else:
    let newBox = Box(cube: cropped, toMinus: newSeq[Box]())
    return Box(cube: box.cube, toMinus: (box.toMinus.mapIt(it - cropped).filterIt(it.volume > 0)) & newBox)

func process(steps: seq[Step], crop: Cube): int64 =
  var acc = newSeq[Box]()
  for step in steps:
    let
      (isOn, cube) = step
      cropped = if crop.isEmpty: cube else: cube.crop(crop)
    if cropped.isEmpty: continue
    var boxes = acc.mapIt(it - cropped)
    if isOn: acc = boxes & Box(cube: cube, toMinus: newSeq[Box]()) else: acc = boxes
  acc.foldl(a + b.volume, 0'i64)

func part1*(input: seq[string]): int64 = input.mapIt(it.parse).process (-50, 51, -50, 51, -50, 51)

func part2*(input: seq[string]): int64 = input.mapIt(it.parse).process (0, 0, 0, 0, 0, 0)
