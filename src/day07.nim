import sequtils
import sugar
import tables

func process(input: seq[int], movesFrom: (int) -> int): int =
  let positions = input.toCountTable
  result = int.high
  for target in 0 .. positions.keys.toSeq.foldl(a.max b, 0):
    result = result.min positions.pairs.toSeq.foldl(a + abs(target - b[0]).movesFrom * b[1], 0)

func part1*(input: seq[int]): int = input.process(n => n)

func part2*(input: seq[int]): int = input.process(n => (n * (n + 1)) div 2)
