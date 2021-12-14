import adventutils
import sequtils
import strutils
import sugar

type Cell = ref object
  n: int
  bingo: bool

type Board = seq[seq[Cell]]

func called(board: Board, number: int) =
  for row in board: (for cell in row: (if cell.n == number: cell.bingo = true))

func bingoAndSumUnmarked(board: Board): int =
  if board.any(r => r.all(c => c.bingo)) or (0 ..< board.len).anyIt(board.all(r => r[it].bingo)):
    board.foldl(a & b).foldl(a + (if b.bingo: 0 else: b.n), 0)
  else:
    0

func part1*(input: seq[string]): int =
  let boards: seq[Board] = input[1 ..< input.len].splitByEmptyLines
      .map(b => b.map(r => r.splitWhitespace.map(c => Cell(n: c.parseInt, bingo: false))))
  for number in input[0].split(',').map(parseInt):
    for board in boards: board.called number
    let t = boards.foldl(a + b.bingoAndSumUnmarked, 0)
    if t > 0: return t * number

func part2*(input: seq[string]): int =
  var boards: seq[Board] = input[1 ..< input.len].splitByEmptyLines
        .map(b => b.map(r => r.splitWhitespace.map(c => Cell(n: c.parseInt, bingo: false))))
  for number in input[0].split(',').map(parseInt):
    for board in boards: board.called number
    let lastSum = boards[0].bingoAndSumUnmarked
    boards.keepIf(board => board.bingoAndSumUnmarked == 0)
    if boards.len == 0: return lastSum * number
