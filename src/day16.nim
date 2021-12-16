import sequtils
import strutils
import sugar

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

func process(parsed: string, isSingleRead = false): (seq[Packet], int) =
  var
    i = 0
    packets = newSeq[Packet]()
    reads = @[ReadMode.Header]
  while (not(isSingleRead) or reads.len <= 2) and i < parsed.len:
    if fromBin[int](parsed[i ..< parsed.len]) == 0: return (packets, i)
    case reads[^1]:
      of ReadMode.Header:
        let
          versionId = fromBin[int](parsed[i ..< i + 3])
          typeId = fromBin[int](parsed[i + 3 ..< i + 6])
        if typeId == 4:
          packets.add LiteralPacket(versionId: versionId, typeId: typeId)
          i += 6
          reads.add ReadMode.Literal
        else:
          let
            lengthType = fromBin[int](parsed[i + 6 ..< i + 7])
            offset = if lengthType == 0: 15 else: 11
            length = fromBin[int](parsed[i + 7 ..< i + 7 + offset])
          packets.add OperatorPacket(versionId: versionId, typeId: typeId, lengthType: lengthType, length: length)
          i += 7 + offset
          reads.add ReadMode.Operator
      of ReadMode.Literal:
        var rawData = newSeq[string]()
        while parsed[i] != '0':
          rawData.add parsed[i ..< i + 5]
          i += 5
        rawData.add parsed[i ..< i + 5]
        i += 5
        LiteralPacket(packets[^1]).data = fromBin[int64](rawData.foldl(a & b[1 ..< b.len], ""))
        reads.add ReadMode.Header
      of ReadMode.Operator:
        let operatorPacket = OperatorPacket(packets[^1])
        if operatorPacket.lengthType == 0:
          var leftover = operatorPacket.length
          while leftover > 0:
            let (packets, offset) = process(parsed[i ..< parsed.len], true)
            operatorPacket.subs.add packets[0]
            leftover -= offset
            i += offset
        else:
          for _ in 1 .. operatorPacket.length:
            let (packets, offset) = process(parsed[i ..< parsed.len], true)
            operatorPacket.subs.add packets[0]
            i += offset
        reads.add ReadMode.Header
  (packets, i)

func sumVersions(packet: Packet): int =
  return if packet of LiteralPacket: LiteralPacket(packet).versionId
    elif packet of OperatorPacket: OperatorPacket(packet).subs.foldl(a + b.sumVersions, packet.versionId)
    else: 0

func part1*(input: string): int =
  let (packets, offset) = input.items.toSeq.foldl(a & fromHex[int]($b).toBin(4), "").process
  packets[0].sumVersions
