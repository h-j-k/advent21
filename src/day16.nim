import sequtils
import strutils

type
  Packet = ref object of RootObj
    version, typeId: int

type
  Literal = ref object of Packet
    data: int64

type
  Operator = ref object of Packet
    subs: seq[Packet]

func process(parsed: string): (Packet, int) =
  let
    version = fromBin[int](parsed[0 ..< 3])
    typeId = fromBin[int](parsed[3 ..< 6])
  if typeId == 4:
    var i = 6
    var rawData = newSeq[string]()
    while parsed[i] != '0':
      rawData.add parsed[i ..< i + 5]
      i += 5
    let literal = Literal(version: version, typeId: typeId)
    literal.data = fromBin[int64]((rawData & parsed[i ..< i + 5]).foldl(a & b[1 ..< b.len], ""))
    return (literal, i + 5)
  else:
    let
      operator = Operator(version: version, typeId: typeId)
      lengthType = fromBin[int](parsed[6 ..< 7])
    var
      i = 7 + (if lengthType == 0: 15 else: 11)
      leftover = fromBin[int](parsed[7 ..< i])
    while leftover > 0:
      let (packet, offset) = parsed[i ..< parsed.len].process
      operator.subs.add packet
      i += offset
      leftover -= (if lengthType == 0: offset else: 1)
    return (operator, i)

func parse(input: string): Packet = input.items.toSeq.foldl(a & fromHex[int]($b).toBin(4), "").process[0]

func sumVersions(packet: Packet): int =
  return if packet of Literal: Literal(packet).version
    elif packet of Operator: Operator(packet).subs.foldl(a + b.sumVersions, packet.version)
    else: 0

func part1*(input: string): int = input.parse.sumVersions

func eval(packet: Packet): int64 =
  return if packet of Literal: Literal(packet).data
      elif packet of Operator:
        let op = Operator(packet)
        case op.typeId:
          of 0: op.subs.foldl(a + b.eval, 0'i64)
          of 1: op.subs.foldl(a * b.eval, 1'i64)
          of 2: op.subs.foldl(a.min b.eval, int64.high)
          of 3: op.subs.foldl(a.max b.eval, int64.low)
          of 5: (if op.subs[0].eval > op.subs[1].eval: 1 else: 0)
          of 6: (if op.subs[0].eval < op.subs[1].eval: 1 else: 0)
          of 7: (if op.subs[0].eval == op.subs[1].eval: 1 else: 0)
          else: 0
      else: 0

func part2*(input: string): int64 = input.parse.eval
