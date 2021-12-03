import adventutils
import parseutils
import sequtils
import std/math
import strutils
import sugar

proc part1*(input: seq[string]): int =
  let gamma = fromBin[int](input.flip.foldl(if b.count("1") * 2 > input.len: a & "1" else: a & "0", ""))
  gamma * ((2 ^ input[0].len - 1) - gamma)

func process(input: seq[string], comparator: (int, int) -> bool): int =
  var
    position = 0
    copy = input
  while (copy.len > 1):
    let keep = if comparator(copy.countIt(it[position] == '1') * 2, copy.len): '1' else: '0'
    copy.keepIf(v => v[position] == keep)
    inc position
  fromBin[int](copy[0])

proc part2*(input: seq[string]): int =
  input.process((twiceOfOnes, size) => twiceOfOnes >= size) * input.process((twiceOfOnes, size) => twiceOfOnes < size)
