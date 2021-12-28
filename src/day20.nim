import adventutils
import sequtils
import sets
import sugar

type ImageGrid = ref object
    bounds: Slice[int]
    parity: range[0..1]
    data: HashSet[Point]

func gridAndRules(input: seq[string]): (ImageGrid, seq[bool]) =
  let rules = input[0].mapIt(it == '#')
  var grid = ImageGrid(bounds: 0 .. 99)
  for y, line in input[2 .. ^1]:
    for x, c in line: (if c == '#': grid.data.incl (x, y))
  (grid, rules)

func aroundAndIt(p: Point): seq[Point] = collect:
  for dy in -1 .. 1:
    for dx in -1 .. 1: (x: dx + p.x, y: dy + p.y)

func next(grid: ImageGrid, rules: seq[bool]): ImageGrid =
  result = ImageGrid(bounds: grid.bounds.a - 1 .. grid.bounds.b + 1, parity: 1 - grid.parity)
  for a in result.bounds:
    for b in result.bounds:
      var i = 0
      for p in (a, b).aroundAndIt:
        let (x, y) = p
        if x in grid.bounds and y in grid.bounds: i = i * 2 + ((x, y) in grid.data).int
        else: i = i * 2 + grid.parity
      if rules[i]: result.data.incl (a, b)

func part1*(input: seq[string]): int =
  let (grid, rules) = input.gridAndRules
  (1 .. 2).foldl(a.next rules, grid).data.len

func part2*(input: seq[string]): int =
  let (grid, rules) = input.gridAndRules
  (1 .. 50).foldl(a.next rules, grid).data.len
