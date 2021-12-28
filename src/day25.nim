import adventutils
import algorithm
import sequtils
import sugar
import tables

type Creature = tuple[facing: char, p: Point]

func findCreatures(grid: CharGrid, facing: char): seq[Creature] = collect:
  for y in 0 ..< grid.len:
    for x in 0 ..< grid[y].len: (if grid[(x, y)] == facing: (grid[(x, y)], (x, y)))

func cmp(a: Creature, b: Creature): int =
  if a.p.y < b.p.y: return -1 elif a.p.y > b.p.y: return 1
  if a.p.x < b.p.x: return -1 elif a.p.x > b.p.x: return 1 else: return 0

func updateFor(grid: CharGrid, facing: char): Table[Point, Point] =
  for creature in grid.findCreatures(facing).sorted(cmp):
    let (facing, p) = creature
    var (x, y) = p
    if facing == '>': x = (p.x + 1) mod grid[0].len elif facing == 'v': y = (p.y + 1) mod grid.len
    if grid[(x, y)] == '.': result[p] = (x, y)

func update(grid: CharGrid): CharGrid =
  result = grid
  for facing in ">v":
    for pFrom, pTo in result.updateFor(facing):
      result[pFrom.y][pFrom.x] = '.'
      result[pTo.y][pTo.x] = facing

func part1*(input: CharGrid): int =
  var
    last = input
    current = last.update
  result = 1
  while current != last:
    result.inc
    last = current
    current = last.update
