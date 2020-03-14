import unittest
import tail

suite "tail":
  test "should return tail":
    check @[1, 2, 3, 4, 5, 6, 7].tail(2) == @[3, 4, 5, 6, 7]
