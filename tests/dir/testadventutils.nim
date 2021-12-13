import ../../src/adventutils
import tables
import testutils

const grid = @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]]

grid[(0, 0)].assertEquals 1
grid[(1, 0)].assertEquals 2
grid[(2, 0)].assertEquals 3
grid[(0, 1)].assertEquals 4
grid[(1, 1)].assertEquals 5
grid[(2, 1)].assertEquals 6
grid[(0, 2)].assertEquals 7
grid[(1, 2)].assertEquals 8
grid[(2, 2)].assertEquals 9

(1, 1).adjacents(grid, false).assertEquals @[(1, 0), (0, 1), (2, 1), (1, 2)]

(1, 1).adjacents(grid, true).assertEquals @[(0, 0), (1, 0), (2, 0), (0, 1), (2, 1), (0, 2), (1, 2), (2, 2)]

(grid + {(0, 0): 0}.toTable).assertEquals @[@[0, 2, 3], @[4, 5, 6], @[7, 8, 9]]
(grid + {(2, 2): 0}.toTable).assertEquals @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 0]]
(grid + {(3, 3): -1}.toTable).assertEquals @[@[1, 2, 3], @[4, 5, 6], @[7, 8, 9]]

@["12", "34"].flip.assertEquals @["13", "24"]

{'k': 'v'}.toTable.keyFor('v').assertEquals('k')

@["this", "is", "some", "", "text"].splitByEmptyLines.assertEquals @[@["this", "is", "some"], @["text"]]

@["this", "", "is", "some", "text"].splitByEmptyLines.assertEquals @[@["this"], @["is", "some", "text"]]

@["", "this is", "", "", "some text", ""].splitByEmptyLines.assertEquals @[@["this is"], @["some text"]]

@['a', 'b'].withIndex.assertEquals @[(0, 'a'), (1, 'b')]
