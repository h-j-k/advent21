import adventutils
import sequtils

func process(window: int, values: seq[int]): int =
  withIndex(values)
      .filterIt(it[0] > (window - 1))
      .foldl((prev: values[b[0] - (window - 1)], count: a.count + (if b[1] > a.prev: 1 else: 0)), (prev: values[0], count: 0)).count

func part1*(values: seq[int]): int = process 1, values

func part2*(values: seq[int]): int = process 3, values
