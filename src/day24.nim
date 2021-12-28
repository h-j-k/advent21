import deques
import sequtils
import strutils

type Segment = tuple[a, b, c: int]

func parse(input: seq[string]): seq[Segment] =
  for segment in input.distribute 14:
    let code = segment.mapIt(it.splitWhitespace)
    result.add (a: code[4][^1].parseInt, b: code[5][^1].parseInt, c: code[15][^1].parseInt)

func process(input: seq[string]): array[14, (int, int)] =
  let segments = input.parse
  var z = initDeque[int]()
  for i, segment in segments:
    if segment.a == 1: z.addLast i else:
      let
        j = z.popLast
        w = segment.b + segments[j].c
        s = [max(-1 * w, 0), max(w, 0)]
      for k, q in [i, j]: result[q] = (9 - s[k], 1 + s[1 - k])

func part1*(input: seq[string]): int64 = input.process.foldl(a * 10 + b[0], 0)

func part2*(input: seq[string]): int64 = input.process.foldl(a * 10 + b[1], 0)
