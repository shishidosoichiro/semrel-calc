import unittest
import ./semver

suite "semver":
  test "newSemver should return Semver object":
    let semver = newSemver(1, 20, 300, @["45", "67"], @["89", "0a"])
    check semver.major == 1
    check semver.minor == 20
    check semver.patch == 300
    check semver.preRelease == @["45", "67"]
    check semver.metadata == @["89", "0a"]

  test "parse should return Semver object":
    check "1.20.300".parse == newSemver(1, 20, 300)
    check "1.20.300-4567.89+build.0a".parse == newSemver(1, 20, 300, @["4567", "89"], @["build", "0a"])
    check "1.20.300-rc.1".parse == newSemver(1, 20, 300, @["rc", "1"])
    check "1.20.300+456.78".parse == newSemver(1, 20, 300, metadata = @["456", "78"])

  test "SemverParseError":
    expect(SemverParseError): discard "001.1.1".parse
    expect(SemverParseError): discard "1.001.1".parse
    expect(SemverParseError): discard "1.1.001".parse
    expect(SemverParseError): discard "a.1.1".parse
    expect(SemverParseError): discard "1.a.1".parse
    expect(SemverParseError): discard "1.1.a".parse
    expect(SemverParseError): discard ".1.1".parse
    expect(SemverParseError): discard "1..1".parse
    expect(SemverParseError): discard "1.1.".parse
    expect(SemverParseError): discard "1.1.1-".parse
    expect(SemverParseError): discard "1.1.1-2.".parse
    expect(SemverParseError): discard "1.1.1-02".parse
    expect(SemverParseError): discard "1.1.1-+3".parse
    expect(SemverParseError): discard "1.1.1-2.+3".parse

  test "toString should return string":
    check newSemver(1, 20, 300).toString == "1.20.300"
    check newSemver(1, 20, 300, @["4567", "89"], @["build", "0a"]).toString == "1.20.300-4567.89+build.0a"
    check newSemver(1, 20, 300, @["rc", "1"]).toString == "1.20.300-rc.1"
    check newSemver(1, 20, 300, metadata = @["456", "78"]).toString == "1.20.300+456.78"

  test "comparePreReleaseIdentifier: identifiers consisting of only digits are compared numerically":
    check comparePreReleaseIdentifier("1", "1") == 0
    check comparePreReleaseIdentifier("2", "1") > 0
    check comparePreReleaseIdentifier("1", "2") < 0
    check comparePreReleaseIdentifier("12", "1") > 0
    check comparePreReleaseIdentifier("1", "12") < 0

  test "comparePreReleaseIdentifier: Numeric identifiers always have lower precedence than non-numeric identifiers":
    check comparePreReleaseIdentifier("a", "999") > 0
    check comparePreReleaseIdentifier("999", "a") < 0

  test "comparePreReleaseIdentifier: identifiers with letters or hyphens are compared lexically in ASCII sort order":
    check comparePreReleaseIdentifier("a", "a") == 0
    check comparePreReleaseIdentifier("1a", "12a") > 0
    check comparePreReleaseIdentifier("12a", "1a") < 0

  test "comparison operator":
    check v"1.20.300" == v"1.20.300"
    check v"1.20.300" > v"0.20.300"
    check v"1.20.300" > v"1.2.300"
    check v"1.20.300" > v"1.20.30"
    check v"1.20.300" > v"1.20.300-rc.1"
    check v"1.20.300-rc.1" > v"1.20.300-rc"
    check v"1.20.300-rc.2" > v"1.20.300-rc.1"
    check v"1.20.300-rc.1+456" == v"1.20.300-rc.1+45"
