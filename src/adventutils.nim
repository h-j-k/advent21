import sequtils
import sugar

func chunkByEmptyLines*(input: seq[string]): seq[seq[string]] =
  let chunks = input.count("") + (if input[0] == "": 0 else: 1)
  input.distribute(chunks, false).map(c => c[1 ..< c.len])

func flip*(values: seq[string]): seq[string] = toSeq(0 ..< values[0].len).mapIt(values.foldl(a & b[it], ""))

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
