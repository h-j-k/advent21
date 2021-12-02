import sequtils
import strutils

type Instruction = tuple[direction: string, offset: int]

type Coordinate = tuple[x: int, y: int]

type CoordinateAim = tuple[x: int, y: int, aim: int]

func toInstruction(instruction: string): Instruction =
  let values = instruction.splitWhitespace
  (values[0], values[1].parseInt)

func mapper(c: Coordinate, instruction: Instruction): Coordinate =
  case instruction.direction:
    of "forward": return (c.x + instruction.offset, c.y)
    of "down": return (c.x, c.y + instruction.offset)
    of "up": return (c.x, c.y - instruction.offset)

func mapperAim(c: CoordinateAim, instruction: Instruction): CoordinateAim =
  case instruction.direction:
    of "forward": return (c.x + instruction.offset, c.y + c.aim * instruction.offset, c.aim)
    of "down": return (c.x, c.y, c.aim + instruction.offset)
    of "up": return (c.x, c.y, c.aim - instruction.offset)

func part1*(input: seq[string]): int =
  let c = input.map(toInstruction).foldl(a.mapper b, (x: 0, y: 0))
  c.x * c.y

func part2*(input: seq[string]): int =
  let c = input.map(toInstruction).foldl(a.mapperAim b, (x: 0, y: 0, aim: 0))
  c.x * c.y
