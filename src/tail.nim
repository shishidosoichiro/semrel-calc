proc tail*[T](s: openArray[T], first: int): seq[T] =
  result = newSeq[T](s.len - first)
  for i in first..s.high:
    result[i - first] = s[i]
