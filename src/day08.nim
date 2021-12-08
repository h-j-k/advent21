import adventutils
import math
import std/[sets, setutils]
import sequtils
import strutils
import sugar
import tables

const unique = {2: 1, 3: 7, 4: 4, 7: 8}.toTable

func part1*(input: seq[string]): int =
  input.foldl(a + b.split(" | ")[1].splitWhitespace.mapIt(unique.keys.toSeq.count(it.len)).sum, 0)

func keyFor(lookup: Table[HashSet[char], int], value: int): HashSet[char] =
  for k, v in lookup:
    if v == value: return k

func toMapping(values: seq[HashSet[char]]): Table[HashSet[char], int] =
  for value in values.filter(v => unique.hasKey(v.len)):
    result[value] = unique[value.len]
  for value in values.filter(v => v.len == 6):
    if result.keyFor(4) < value: result[value] = 9
  for value in values.toHashSet - result.keys.toSeq.toHashSet:
    if result.keyFor(7) < value: result[value] = if value.len == 6: 0 else: 3
    elif value < result.keyFor(9): result[value] = 5
    else: result[value] = if value.len == 6: 6 else: 2

func process*(entry: string): int =
  let
    parts = entry.split(" | ").map(p => p.splitWhitespace.mapIt(it.items.toSeq.toHashSet))
    mapping = parts[0].toMapping
  parts[1].withIndex.foldl(a + mapping[b[1]] * (10 ^ (parts[1].len - b[0] - 1)), 0)

func part2*(input: seq[string]): int = input.foldl(a + b.process, 0)
