import adventutils
import algorithm
import sequtils
import std/[deques, options]
import sugar
import tables

func process(line: string): (Option[char], Option[string]) =
  let pairs = { '(': ')', '[': ']', '{': '}', '<': '>'}.toTable
  var deque = initDeque[char]()
  for c in line.items:
    if pairs.hasKey(c): deque.addFirst(c) else:
      if deque.len == 0 or deque.peekFirst != pairs.keyFor(c):
        return (some(c), none[string]())
      deque.popFirst
  (none[char](), some(deque.foldl(a & pairs[b], "")))

func part1*(input: seq[string]): int =
  let points = { ')': 3, ']': 57, '}': 1197, '>': 25137 }.toTable
  input.foldl(a + b.process[0].map(v => points[v]).get(0), 0)

func part2*(input: seq[string]): int64 =
  let scores = collect:
    for line in input.mapIt(it.process[1]):
      if line.isSome: line.get.items.toSeq.foldl(5 * a + ")]}>".find(b) + 1, 0)
  scores.sorted[(scores.len - 1) div 2]
