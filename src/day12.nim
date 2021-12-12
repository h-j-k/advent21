import sequtils
import std/[deques, sets]
import strutils
import sugar
import tables

func isBigCave(name: string): bool = name.items.toSeq.foldl(a and b.isUpperAscii, true)

func toMap(input: seq[string]): Table[string, seq[string]] =
  for line in input:
    let (x, y) = (line.split("-")[0], line.split("-")[1])
    if y != "start": result.mgetOrPut(x, newSeq[string]()).add(y)
    if x != "start": result.mgetOrPut(y, newSeq[string]()).add(x)

func process(input: seq[string], extraTest: (CountTable[string]) -> bool): int =
  let caves = input.toMap
  func explore(last: string, lastSeen: CountTable[string]): int =
    if last == "end": 1 else:
      var seen = lastSeen
      if not last.isBigCave: seen.inc(last)
      caves[last].filter(v => v.isBigCave or v notin seen or seen.extraTest).foldl(a + b.explore(seen), 0)
  "start".explore(initCountTable[string]())

func part1*(input: seq[string]): int = input.process(seen => false)

func part2*(input: seq[string]): int = input.process(seen => seen.values.toSeq.foldl(a + b, 0) == seen.len)
