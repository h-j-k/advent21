import sequtils

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
