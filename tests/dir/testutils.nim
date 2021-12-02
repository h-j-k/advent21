import sequtils
import strutils

proc readStringLines*(path: string): seq[string] = path.readFile.splitLines

proc readIntLines*(path: string): seq[int] = path.readStringLines.map(parseInt)

proc assertEquals*[T](actual: T, expected: T) =
  if actual != expected:
    echo "Expected ", expected, " but got ", actual
    assert false
  else:
    assert true
