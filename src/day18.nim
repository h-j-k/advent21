import re
import sequtils
import std/options
import strutils

type
  SfNumber = ref object of RootObj
    a: SfNumber
    b: SfNumber

type
  Literal = ref object of SfNumber
    n: int

func sf(n: int): Literal = Literal(n: n)

func magnitude(sf: SfNumber): int =
  if (sf of Literal): Literal(sf).n else: 3 * sf.a.magnitude + 2 * sf.b.magnitude

func explode(sf: SfNumber, level = 1): Option[(int, int)] =
  if sf of Literal: return none[(int, int)]()
  if level > 4 and sf.a of Literal and sf.b of Literal:
    return some((Literal(sf.a).n, Literal(sf.b).n))
  var
    x = sf.a.explode level + 1
    xA, xB: int
    isASide = true
  if x.isNone:
    x = sf.b.explode level + 1
    isASide = false
  if x.isNone: return x
  (xA, xB) = x.get
  if isASide:
    if level == 4: sf.a = 0.sf
    var t = sf.b
    while (not (t of Literal)): t = t.a
    if t of Literal:
      Literal(t).n += xB
      xB = 0
  else:
    if level == 4: sf.b = 0.sf
    var t = sf.a
    while (not (t of Literal)): t = t.b
    if t of Literal:
      Literal(t).n += xA
      xA = 0
  some((xA, xB))

func splitLiteral(literal: Literal): Option[SfNumber] =
  if literal.n >= 10: some(SfNumber(a: (literal.n div 2).sf, b: ((literal.n + 1) div 2).sf))
  else: none[SfNumber]()

func split(sf: SfNumber): bool =
  if sf of Literal: return false
  result = false
  if sf.a of Literal:
    let aSplit = Literal(sf.a).splitLiteral
    result = aSplit.isSome
    if result: sf.a = aSplit.get
  else: result = split(sf.a)
  if not result:
    if sf.b of Literal:
      let bSplit = Literal(sf.b).splitLiteral
      result = bSplit.isSome
      if result: sf.b = bSplit.get
    else: result = split(sf.b)

func `+`(a: SfNumber, b: SfNumber): SfNumber =
  result = SfNumber(a: a, b: b)
  while (result.explode.isSome or result.split): discard

func parse(input: string): (SfNumber, int) =
  if input =~ re"^(\d+)":
    let literal = Literal(n: matches[0].parseInt)
    return (literal, matches[0].len)
  else:
    let
      (a, aOffset) = parse(input[1 .. ^1])
      (b, bOffset) = parse(input[aOffset + 2.. ^1])
    return (SfNumber(a: a, b: b), aOffset + bOffset + 3)

func sf(number: string): SfNumber = number.parse[0]

func part1*(input: seq[string]): int = input[1 .. ^1].foldl(a + b.sf, input[0].sf).magnitude

func part2*(input: seq[string]): int =
  result = int.low
  for i, n in input[0 .. ^2]:
    result = input[i + 1 .. ^1].foldl(max([a, (n.sf + b.sf).magnitude, (b.sf + n.sf).magnitude]), result)
