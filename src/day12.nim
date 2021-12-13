import sequtils
import strutils
import sugar
import tables

func toMap(input: seq[string]): Table[string, seq[string]] =
  for line in input:
    let (x, y) = (line.split("-")[0], line.split("-")[1])
    if y != "start": result.mgetOrPut(x, @[]).add(y)
    if x != "start": result.mgetOrPut(y, @[]).add(x)

func explore(caves: Table[string, seq[string]], revisits: int, last = "start", lastSeen = initCountTable[string]()): int =
  if last == "end": 1 else:
    var seen = lastSeen
    if last[0].isLowerAscii: seen.inc(last)
    caves[last].filter(v => v[0].isUpperAscii or v notin seen or revisits > 0)
      .foldl(a + caves.explore((if b in seen: revisits - 1 else: revisits), b, seen), 0)

func part1*(input: seq[string]): int = input.toMap.explore 0

func part2*(input: seq[string]): int = input.toMap.explore 1
