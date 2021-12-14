import sequtils
import strscans
import tables

func process(polymer: CountTable[string], rules: Table[string, char]): CountTable[string] =
  for k, v in polymer:
    if k in rules: (for p in [k[0] & rules[k], rules[k] & k[1]]: result.inc(p, v)) else: result.inc(k, v)

func process(input: seq[string], times: int): int64 =
  let
    polymer = input[0]
    rules = input[2 ..< input.len].mapIt(it.scanTuple "$w -> $c").mapIt((it[1], it[2])).toTable
    counts = newCountTable[char]()
  var pairs = (1 .. times).foldl(a.process rules, polymer.zip(polymer[1 .. ^1]).mapIt(it[0] & it[1]).toCountTable)
  pairs.inc(polymer[0] & polymer[^1])
  for k, v in pairs: (for c in k.items: counts.inc(c, v))
  let (min, max) = counts.values.toSeq.foldl((min(a[0], b), max(a[1], b)), (int64.high, int64.low))
  (max - min) div 2

func part1*(input: seq[string]): int64 = input.process 10

func part2*(input: seq[string]): int64 = input.process 40
