import sequtils

func flip*(values: seq[string]): seq[string] = toSeq(0 ..< values[0].len).mapIt(values.foldl(a & b[it], ""))

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
