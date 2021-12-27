import adventutils
import algorithm
import heapqueue
import sets
import sequtils
import strutils
import sugar
import tables

const amphipods = { 'A': 3, 'B': 5, 'C': 7, 'D': 9 }.toTable

const costs = { 'A': 1, 'B': 10, 'C': 100, 'D': 1000 }.toTable

type Amphipod = tuple[a: char, p: Point]

type State = tuple[grid: CharGrid, energy: int]

func `in`(p: Point, grid: CharGrid): bool = p.x in 0 ..< grid[0].len and p.y in 0 ..< grid.len

func `+`*(grid: CharGrid, newValues: Table[Point, char]): CharGrid =
  result = grid
  for k, v in newValues:
    if k in grid: result[k.y][k.x] = v

func findAmphipods(grid: CharGrid): seq[Amphipod] = collect:
  for y in 0 ..< grid.len:
    for x in 0 ..< grid[y].len:
      let p = (x: x, y: y)
      if grid[p] in amphipods: (a: grid[p], p: p)

func onTarget(it: (char, int), grid: CharGrid): bool =
  let (a, i) = it
  (2 .. (grid.len - 2)).mapIt((x: i, y: it)).allIt(grid[it] == a)

func allClear(a: int, b: int, grid: CharGrid): bool =
  ((a.min b) .. (b.max a)).allIt(grid[(it, 1)] == '.')

func moves(amphipod: Amphipod, grid: CharGrid, middle: seq[int]): seq[Point] =
  let (a, p) = amphipod
  if p.y == 1:
    if (middle & @[middle.max + 1]).anyIt(grid[(amphipods[a], it)] notin [a, '.']): return newSeq[Point]()
    let
      y = (middle & @[middle.max + 1]).reversed.filterIt(grid[(amphipods[a], it)] == '.')[0]
      next = if p.x < amphipods[a]: p.x + 1 else: p.x - 1
    if grid[(amphipods[a], y)] == '.' and next.allClear(amphipods[a], grid):
      return @[(amphipods[a], y)]
    else:
      return newSeq[Point]()
  elif p.y in middle:
    if p.x == amphipods[a] and (p.y .. middle.max + 1).allIt(grid[(p.x, it)] == a):
      return newSeq[Point]()
    elif grid[(p.x, p.y - 1)] != '.':
      return newSeq[Point]()
    else:
      return [1, 2, 4, 6, 8, 10, 11].filterIt(p.x.allClear(it, grid)).mapIt((it, 1))
  else:
    if p.x == amphipods[a] or grid[(p.x, p.y - 1)] != '.': return newSeq[Point]() else:
      return [1, 2, 4, 6, 8, 10, 11].filterIt(p.x.allClear(it, grid)).mapIt((it, 1))

func toState(a: Amphipod, next: Point, state: State): State =
  (state.grid + { a.p: '.', next: a.a }.toTable, state.energy + costs[a.a] * (a.p - next))

func nextStates(state: State, middle: seq[int]): seq[State] =
  let (grid, energy) = state
  for a in grid.findAmphipods:
    for next in a.moves(grid, middle):
      result.add a.toState(next, state)

func `<`(a: State, b: State): bool = a.energy < b.energy

func process(grid: CharGrid, middle: seq[int]): int =
  var
    heapQueue = [(grid: grid, energy: 0)].toHeapQueue
    seen = initCountTable[CharGrid]()
  while heapQueue.len > 0:
    let state = heapQueue.pop
    if amphipods.pairs.toSeq.allIt(it.onTarget state.grid): return state.energy else:
      for next in state.nextStates(middle).filter(s => s.energy < seen.getOrDefault(s.grid, int.high)):
        seen[next.grid] = next.energy
        heapQueue.push next

func part1*(input: CharGrid): int = input.process(@[2])

func part2*(input: CharGrid): int =
  @[
    input[0 .. 2],
    @["  #D#C#B#A#  ", "  #D#B#A#C#  "].mapIt(it.items.toSeq),
    input[^2 .. ^1]
  ].foldl(a & b, newSeq[seq[char]]()).process(@[2, 3, 4])
