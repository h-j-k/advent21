import testutils
import ../../src/day12

let input = "input/day12.txt".readStringLines

@[
"start-A",
"start-b",
"A-c",
"A-b",
"b-d",
"A-end",
"b-end"
].part1.assertEquals 10

input.part1.assertEquals 3369

# input.part2.assertEquals 0
