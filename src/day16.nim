import sequtils
import strutils

type
  Packet = ref object of RootObj
    versionId, typeId: int

type
  LiteralPacket = ref object of Packet
    data: int64

type
  OperatorPacket = ref object of Packet
    lengthType, length: int
    subs: seq[Packet]

type ReadMode = enum Header, Literal, Operator

func process(parsed: string): (Packet, int) =
  var
    i = 0
    packet: Packet
    reads = @[ReadMode.Header]
  while i < parsed.len:
    if fromBin[int](parsed[i ..< parsed.len]) == 0: return (packet, i)
    case reads[^1]:
      of ReadMode.Header:
        let
          versionId = fromBin[int](parsed[i ..< i + 3])
          typeId = fromBin[int](parsed[i + 3 ..< i + 6])
        if typeId == 4:
          packet = LiteralPacket(versionId: versionId, typeId: typeId)
          i += 6
          reads.add ReadMode.Literal
        else:
          let
            lengthType = fromBin[int](parsed[i + 6 ..< i + 7])
            offset = if lengthType == 0: 15 else: 11
            length = fromBin[int](parsed[i + 7 ..< i + 7 + offset])
          packet = OperatorPacket(versionId: versionId, typeId: typeId, lengthType: lengthType, length: length)
          i += 7 + offset
          reads.add ReadMode.Operator
      of ReadMode.Literal:
        var rawData = newSeq[string]()
        while parsed[i] != '0':
          rawData.add parsed[i ..< i + 5]
          i += 5
        rawData.add parsed[i ..< i + 5]
        LiteralPacket(packet).data = fromBin[int](rawData.foldl(a & b[1 ..< b.len], ""))
        return (packet, i + 5)
      of ReadMode.Operator:
        let operatorPacket = OperatorPacket(packet)
        if operatorPacket.lengthType == 0:
          var leftover = operatorPacket.length
          while leftover > 0:
            let (packet, offset) = process(parsed[i ..< parsed.len])
            operatorPacket.subs.add packet
            leftover -= offset
            i += offset
        else:
          for _ in 1 .. operatorPacket.length:
            let (packet, offset) = process(parsed[i ..< parsed.len])
            operatorPacket.subs.add packet
            i += offset
        return (packet, i)
  (packet, i)

func parse(input: string): Packet = input.items.toSeq.foldl(a & fromHex[int]($b).toBin(4), "").process[0]

func sumVersions(packet: Packet): int =
  return if packet of LiteralPacket: LiteralPacket(packet).versionId
    elif packet of OperatorPacket: OperatorPacket(packet).subs.foldl(a + b.sumVersions, packet.versionId)
    else: 0

func part1*(input: string): int = input.parse.sumVersions

func eval(packet: Packet): int64 =
  return if packet of LiteralPacket: LiteralPacket(packet).data
      elif packet of OperatorPacket:
        let op = OperatorPacket(packet)
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
