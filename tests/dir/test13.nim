import testutils
import ../../src/day13

let input = "input/day13.txt".readStringLines

input.part1.assertEquals 745

input.part2.assertEquals @[
" 88  888  8  8   88 8888 888   88   88 ",
"8  8 8  8 8 8     8 8    8  8 8  8 8  8",
"8  8 888  88      8 888  888  8    8   ",
"8888 8  8 8 8     8 8    8  8 8 88 8   ",
"8  8 8  8 8 8  8  8 8    8  8 8  8 8  8",
"8  8 888  8  8  88  8    888   888  88 "
] # ABKJFBGC
