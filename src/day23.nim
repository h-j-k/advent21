import adventutils
import algorithm
import heapqueue
import sequtils
import tables

const cols = { 'A': 3, 'B': 5, 'C': 7, 'D': 9 }.toTable

const costs = { 'A': 1, 'B': 10, 'C': 100, 'D': 1000 }.toTable

type Amphipod = tuple[a: char, p: Point]

type State = tuple[grid: CharGrid, energy: int]

func findAmphipods(grid: CharGrid): seq[Amphipod] =
  for y in 0 ..< grid.len:
    for x in 0 ..< grid[y].len:
      if grid[(x, y)] in cols: result.add (grid[(x, y)], (x, y))

func isDone(grid: CharGrid): bool =
  for k, v in cols:
    if (2 .. (grid.len - 2)).anyIt(grid[(v, it)] != k): return false
  return true

func isHallwayClear(a: int, b: int, grid: CharGrid): bool =
  (a.min(b) .. a.max(b)).allIt(grid[(it, 1)] == '.')

func moves(amphipod: Amphipod, grid: CharGrid, rest: seq[int]): seq[Point] =
  let (a, p) = amphipod
  if p.y == 1:
    if rest.anyIt(grid[(cols[a], it)] notin [a, '.']): return @[]
    let
      x = if p.x < cols[a]: p.x + 1 else: p.x - 1
      y = rest.filterIt(grid[(cols[a], it)] == '.').max
    return @[(cols[a], y)].filterIt(x.isHallwayClear(cols[a], grid))
  if p.x == cols[a] and (p.y .. rest.max).allIt(grid[(p.x, it)] == a): return @[]
  return if grid[(p.x, p.y - 1)] != '.': @[] else:
    [1, 2, 4, 6, 8, 10, 11].filterIt(p.x.isHallwayClear(it, grid)).mapIt((it, 1))

func nextStates(state: State, rest: seq[int]): seq[State] =
  for a in state.grid.findAmphipods:
    for next in a.moves(state.grid, rest):
      var updated = state.grid
      updated[a.p.y][a.p.x] = '.'
      updated[next.y][next.x] = a.a
      result.add (updated, state.energy + costs[a.a] * (a.p - next))

func `<`(a: State, b: State): bool = a.energy < b.energy

func process(grid: CharGrid, rest: seq[int]): int =
  var
    heapQueue = [(grid: grid, energy: 0)].toHeapQueue
    seen = initCountTable[CharGrid]()
  while heapQueue.len > 0:
    let state = heapQueue.pop
    if state.grid.isDone: return state.energy
    for next in state.nextStates(rest):
      if next.energy < seen.getOrDefault(next.grid, int.high):
        seen[next.grid] = next.energy
        heapQueue.push next

func part1*(input: CharGrid): int = input.process @[2, 3]

func part2*(input: CharGrid): int =
  @[
    input[0 .. 2],
    @["  #D#C#B#A#  ", "  #D#B#A#C#  "].mapIt(it.items.toSeq),
    input[^2 .. ^1]
  ].foldl(a & b, newSeq[seq[char]]()).process @[2, 3, 4, 5]
