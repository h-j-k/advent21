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

func explore(caves: Table[string, seq[string]], revisits: int, last = "start", lastSeen = initCountTable[string]()): int =
  if last == "end": 1 else:
    var seen = lastSeen
    if not last.isBigCave: seen.inc(last)
    caves[last].filter(v => v.isBigCave or v notin seen or revisits > 0)
      .foldl(a + caves.explore((if b in seen: revisits - 1 else: revisits), b, seen), 0)

func part1*(input: seq[string]): int = input.toMap.explore 0

func part2*(input: seq[string]): int = input.toMap.explore 1
