import ../../src/adventutils
import sequtils
import strutils
import sugar

proc readStringLines*(path: string): seq[string] = path.readFile.splitLines

proc readIntGrid*(path: string): IntGrid = path.readStringLines.map(line => line.items.toSeq.mapIt(parseInt($it)))

proc readIntLines*(path: string): seq[int] = path.readStringLines.map(parseInt)

proc readIntCsvLine*(path: string): seq[int] = path.readStringLines[0].split(',').map(parseInt)

proc assertEquals*[T](actual: T, expected: T) =
  if actual != expected:
    echo "Expected ", expected, " but got ", actual
    assert false
  else:
    assert true
