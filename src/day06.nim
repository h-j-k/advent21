import sequtils
import tables

func next(fishes: CountTable[int]): CountTable[int] =
  for k, v in fishes:
    if k != 0: result.inc(k - 1, v) else:
      result.inc(6, v)
      result.inc(8, v)

func process(input: seq[int], target: int): int64 =
  (1 .. target).foldl(a.next, input.toCountTable).values.toSeq.foldl(a + b, 0)

func part1*(input: seq[int]): int64 = input.process 80

func part2*(input: seq[int]): int64 = input.process 256
