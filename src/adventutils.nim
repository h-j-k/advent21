import sequtils
import sugar
import tables

func chunkByEmptyLines*(input: seq[string]): seq[seq[string]] =
  let chunks = input.count("") + (if input[0] == "": 0 else: 1)
  input.distribute(chunks, false).map(c => c[1 ..< c.len])

func flip*(values: seq[string]): seq[string] = toSeq(0 ..< values[0].len).mapIt(values.foldl(a & b[it], ""))

func keyFor*[K, V](lookup: Table[K, V], value: V): K =
  for k, v in lookup:
    if v == value: return k

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
