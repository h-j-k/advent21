import sequtils
import sugar
import tables

func process(input: seq[int], movesFrom: (int) -> int): int =
  let positions = input.toCountTable
  result = high(int)
  for target in 0 .. positions.keys.toSeq.foldl(max(a, b), 0):
    result = min(result, positions.pairs.toSeq.foldl(a + movesFrom(abs(target - b[0])) * b[1], 0))

func part1*(input: seq[int]): int = input.process(n => n)

func part2*(input: seq[int]): int = input.process(n => (n * (n + 1)) div 2)
