import adventutils
import sequtils

func process(input: seq[int], window: int): int =
  input.withIndex.filterIt(it[0] > (window - 1))
      .foldl((input[b[0] - (window - 1)], a[1] + (if b[1] > a[0]: 1 else: 0)), (input[0], 0))[1]

func part1*(input: seq[int]): int = input.process 1

func part2*(input: seq[int]): int = input.process 3
