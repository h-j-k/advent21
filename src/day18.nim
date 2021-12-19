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

func `$`(sf: SfNumber): string =
  if (sf of Literal): $(Literal(sf).n) else: "[" & $sf.a & "," & $sf.b & "]"

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
  var r = false
  if sf.a of Literal:
    let aSplit = Literal(sf.a).splitLiteral
    r = aSplit.isSome
    if r: sf.a = aSplit.get
  else: r = split(sf.a)
  if not r:
    if sf.b of Literal:
      let bSplit = Literal(sf.b).splitLiteral
      r = bSplit.isSome
      if r: sf.b = bSplit.get
    else: r = split(sf.b)
  r

proc reduce*(sf: SfNumber): void = (while (sf.explode.isSome or sf.split): discard)

func `+`(a: SfNumber, b: SfNumber): SfNumber =
  result = SfNumber(a: a, b: b)
  result.reduce

func parse*(input: string): (SfNumber, int) =
  if input =~ re"^(\d+)":
    let literal = Literal(n: matches[0].parseInt)
    return (literal, matches[0].len)
  else:
    let
      (a, aOffset) = parse(input[1 .. ^1])
      (b, bOffset) = parse(input[aOffset + 2.. ^1])
    return (SfNumber(a: a, b: b), aOffset + bOffset + 3)

func part1*(input: seq[string]): int =
  let r = input[1 .. ^1].foldl(a + b.parse[0], input[0].parse[0])
  r.reduce
  return r.magnitude
