import memo
import sequtils
import strscans
import tables

func parse(input: string): (int, int) =
  let (_, player, start) = input.scanTuple "Player $i starting position: $i"
  (player, start)

func rollNext(lastRoll: int): seq[int] =
  var roll = lastRoll
  for _ in 1 .. 3:
    if roll == 100: roll = 0
    roll.inc
    result.add roll

func part1*(input: seq[string]): int =
  let players = input.mapIt(it.parse)
  var
    positions = initTable[int, int]()
    scores = initCountTable[int]()
    rounds = 0
    lastRoll = 0
  for i, pair in players: positions[i] = pair[1]
  while scores.values.toSeq.allIt(it < 1000):
    let
      player = rounds mod players.len
      rolls = lastRoll.rollNext
    lastRoll = rolls[^1]
    var position = rolls.foldl(a + b, positions[player]) mod 10
    if position == 0: position = 10
    positions[player] = position
    scores.inc(player, position)
    rounds.inc
  scores[rounds mod players.len] * (rounds * 3)

const rolls = {3: 1, 4: 3, 5: 6, 6: 7, 7: 6, 8: 3, 9: 1}

func countWins(p1: int, p2: int, s1: int, s2: int): array[2, int] {.memoized.} =
  if s1 >= 21 or s2 >= 21: return [(s1 >= 21).int, (s2 >= 21).int]
  for (roll, frequency) in rolls:
    let
      p = 1 + (p1 + roll - 1) mod 10
      w = countWins(p2, p, s2, s1 + p)
    result[0] += frequency * w[1]
    result[1] += frequency * w[0]

proc part2*(input: seq[string]): int64 =
  let players = input.mapIt(it.parse)
  countWins(players[0][1], players[1][1], 0, 0).max
