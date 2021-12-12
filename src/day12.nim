import sequtils
import std/[deques, sets]
import strutils
import sugar
import tables

func isBigCave(name: string): bool = name.items.toSeq.allIt(it.isUpperAscii)

func toMap(input: seq[string]): Table[string, HashSet[string]] =
  for line in input:
    let (x, y) = (line.split("-")[0], line.split("-")[1])
    result.mgetOrPut(x, initHashSet[string]()).incl(y)
  let copy = result
  for k, v in copy:
    for x in v:
      result.mgetOrPut(x, initHashSet[string]()).incl(k)

func part1*(input: seq[string]): int =
  let caves = input.toMap
  var deque = [("start", newSeq[string](), initHashSet[string]())].toDeque
  var paths = newSeq[seq[string]]()
  while deque.len > 0:
    let (current, path, seen) = deque.popFirst
    if current == "end": paths.add(path) else:
      for next in caves[current].toSeq.filter(v => v.isBigCave or v notin seen):
        deque.addLast((next, path & current, (if current.isBigCave: seen else: seen.union([current].toSet))))
  paths.len
