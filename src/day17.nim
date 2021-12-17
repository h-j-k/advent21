import sequtils
import strscans

func isPathIn(initial: (int, int), xMin: int, xMax: int, yMin: int, yMax: int): bool =
  var
    v = initial
    points = @[(x: 0, y: 0)]
  while (points[^1].x <= xMax and points[^1].y >= yMin):
    points.add (x: points[^1].x + v[0], y: points[^1].y + v[1])
    v = ((if v[0] > 0: v[0] - 1 elif v[0] < 0: v[0] + 1 else: v[0]), v[1] - 1)
  points.anyIt(it.x in xMin .. xMax and it.y in yMin .. yMax)

func part1*(input: string): int =
  let (_, xMin, xMax, yMin, yMax) = input.scanTuple("target area: x=$i..$i, y=$i..$i")
  (yMin * (yMin + 1)) div 2

func part2*(input: string): int =
  let (_, xMin, xMax, yMin, yMax) = input.scanTuple("target area: x=$i..$i, y=$i..$i")
  (1 .. xMax).foldl(a + (yMin .. yMin.abs).countIt((b, it).isPathIn(xMin, xMax, yMin, yMax)), 0)
