import unittest
import semrelcalc

suite "semrelcalc":
  test "should return the same value, if input a value.":
    check semrelcalc("1.0.0", @["feat(*): add a feature", "fix(*): fix it"]) == "1.1.0"
