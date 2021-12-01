import sequtils
import strutils
import sugar

proc readIntLines*(path: string): seq[int] = path.readFile.splitLines.map(parseInt)

proc assertEquals*[T](actual: T, expected: T) =
  if actual != expected:
    echo "Expected ", expected, " but got ", actual
    assert false
  else:
    assert true
