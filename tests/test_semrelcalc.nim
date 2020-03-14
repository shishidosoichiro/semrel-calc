import unittest
import semrelcalc

suite "semrelcalc":
  test "should return the same value, if input a value.":
    check semrelcalc("1.0.0", @["eee", "vefe"]) == "1.0.0"
