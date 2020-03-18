import unittest
import ./semver

suite "Semantic Versioning 2.0.0 spec":
  suite "A normal version number":
    # 1. A normal version number MUST take the form X.Y.Z where X, Y, and Z are
    # non-negative integers, and MUST NOT contain leading zeroes. X is the
    # major version, Y is the minor version, and Z is the patch version.
    # Each element MUST increase numerically. For instance: 1.9.0 -> 1.10.0 -> 1.11.0.
    test "A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.":
      check v"0.0.0" == newSemver(0, 0, 0)
      check v"1.1.1" == newSemver(1, 1, 1)
      expect(SemverParseError): discard "-1.1.1".parse
      expect(SemverParseError): discard "1.-1.1".parse
      expect(SemverParseError): discard "1.1.-1".parse
      expect(SemverParseError): discard "001.1.1".parse
      expect(SemverParseError): discard "1.001.1".parse
      expect(SemverParseError): discard "1.1.001".parse

    test "Each element MUST increase numerically. For instance: 1.9.0 -> 1.10.0 -> 1.11.0.":
      check v"1.9.0" < v"1.10.0"
      check v"1.10.0" < v"1.11.0"

  suite "A pre-release version":
    # 1. A pre-release version MAY be denoted by appending a hyphen and a
    # series of dot separated identifiers immediately following the patch
    # version. Identifiers MUST comprise only ASCII alphanumerics and hyphens
    # [0-9A-Za-z-]. Identifiers MUST NOT be empty. Numeric identifiers MUST
    # NOT include leading zeroes. Pre-release versions have a lower
    # precedence than the associated normal version. A pre-release version
    # indicates that the version is unstable and might not satisfy the
    # intended compatibility requirements as denoted by its associated
    # normal version. Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7,
    # 1.0.0-x.7.z.92, 1.0.0-x-y-z.--.
    test "A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version.":
      check v"1.1.1-alpha.beta" == newSemver(1, 1, 1, @["alpha", "beta"])

    test "Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].":
      check v"1.1.1-1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-" == newSemver(1, 1, 1, @["1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"])

    test "Identifiers MUST NOT be empty.":
      expect(SemverParseError): discard "1.1.1-alpha..beta".parse
      expect(SemverParseError): discard "1.1.1-alpha.".parse
      expect(SemverParseError): discard "1.1.1-.alpha".parse
      expect(SemverParseError): discard "1.1.1-".parse

    test "Numeric identifiers MUST NOT include leading zeroes.":
      expect(SemverParseError): discard "1.1.1-alpha.001".parse
      check v"1.0.0-alpha.001a" == newSemver(1, 0, 0, @["alpha", "001a"])
    test "Pre-release versions have a lower precedence than the associated normal version. ":
      check v"1.0.0-alpha" < v"1.0.0"

    test "Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92, 1.0.0-x-y-z.--":
      check v"1.0.0-alpha" == newSemver(1, 0, 0, @["alpha"])
      check v"1.0.0-alpha.1" == newSemver(1, 0, 0, @["alpha", "1"])
      check v"1.0.0-0.3.7" == newSemver(1, 0, 0, @["0", "3", "7"])
      check v"1.0.0-x.7.z.92" == newSemver(1, 0, 0, @["x", "7", "z", "92"])
      check v"1.0.0-x-y-z.--" == newSemver(1, 0, 0, @["x-y-z", "--"])

  suite "Build metadata":
    # 1. Build metadata MAY be denoted by appending a plus sign and a series of dot
    # separated identifiers immediately following the patch or pre-release version.
    # Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].
    # Identifiers MUST NOT be empty. Build metadata MUST be ignored when determining
    # version precedence. Thus two versions that differ only in the build metadata,
    # have the same precedence. Examples: 1.0.0-alpha+001, 1.0.0+20130313144700,
    # 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3----117B344092BD.
    test "Build metadata MAY be denoted by appending a plus sign and a series of dot separated identifiers immediately following the patch or pre-release version.":
      check v"1.0.0+123abc" == newSemver(1, 0, 0, @[], @["123abc"])
      check v"1.0.0-alpha+123abc" == newSemver(1, 0, 0, @["alpha"], @["123abc"])

    test "Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].":
      check v"1.0.0+1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-" == newSemver(1, 0, 0, @[], @["1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"])
      check v"1.0.0+-" == newSemver(1, 0, 0, @[], @["-"])
      check v"1.0.0+000-" == newSemver(1, 0, 0, @[], @["000-"])

    test "Identifiers MUST NOT be empty.":
      expect(SemverParseError): discard "1.1.1+alpha..beta".parse
      expect(SemverParseError): discard "1.1.1+alpha.".parse
      expect(SemverParseError): discard "1.1.1+.alpha".parse
      expect(SemverParseError): discard "1.1.1+".parse

    test "Build metadata MUST be ignored when determining version precedence. Thus two versions that differ only in the build metadata, have the same precedence. Examples: 1.0.0-alpha+001, 1.0.0+20130313144700, 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3----117B344092BD.":
      check v"1.0.0-alpha+001" == v"1.0.0-alpha+001"
      check v"1.0.0+20130313144700" == v"1.0.0+20130313144700"
      check v"1.0.0-beta+exp.sha.5114f85" == v"1.0.0-beta+exp.sha.5114f85"
      check v"1.0.0+21AF26D3----117B344092BD"== v"1.0.0+21AF26D3----117B344092BD"

  suite "Precedence":
    # 1. Precedence refers to how versions are compared to each other when ordered.
    # Precedence MUST be calculated by separating the version into major, minor, patch
    # and pre-release identifiers in that order (Build metadata does not figure
    # into precedence). Precedence is determined by the first difference when
    # comparing each of these identifiers from left to right as follows: Major, minor,
    # and patch versions are always compared numerically. Example: 1.0.0 < 2.0.0 <
    # 2.1.0 < 2.1.1. When major, minor, and patch are equal, a pre-release version has
    # lower precedence than a normal version. Example: 1.0.0-alpha < 1.0.0. Precedence
    # for two pre-release versions with the same major, minor, and patch version MUST
    # be determined by comparing each dot separated identifier from left to right
    # until a difference is found as follows: identifiers consisting of only digits
    # are compared numerically and identifiers with letters or hyphens are compared
    # lexically in ASCII sort order. Numeric identifiers always have lower precedence
    # than non-numeric identifiers. A larger set of pre-release fields has a higher
    # precedence than a smaller set, if all of the preceding identifiers are equal.
    # Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta <
    # 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
    test "Precedence is determined by the first difference when comparing each of these identifiers from left to right as follows: Major, minor, and patch versions are always compared numerically. Example: 1.0.0 < 2.0.0 <  2.1.0 < 2.1.1.":
      check v"1.0.0" < v"10.0.0"
      check v"1.1.0" < v"1.10.0"
      check v"1.1.1" < v"1.1.10"
      check v"1.0.0" < v"2.0.0"
      check v"2.0.0" < v"2.1.0"
      check v"2.1.0" < v"2.1.1"

    test "When major, minor, and patch are equal, a pre-release version has lower precedence than a normal version. Example: 1.0.0-alpha < 1.0.0.":
      check v"1.0.0-alpha" < v"1.0.0"

    test "Precedence for two pre-release versions with the same major, minor, and patch version MUST be determined by comparing each dot separated identifier from left to right until a difference is found as follows: identifiers consisting of only digits are compared numerically and identifiers with letters or hyphens are compared lexically in ASCII sort order. Numeric identifiers always have lower precedence than non-numeric identifiers. A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal. Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.":
      check v"1.0.0-alpha" < v"1.0.0-alpha.1"
      check v"1.0.0-alpha.1" < v"1.0.0-alpha.beta"
      check v"1.0.0-alpha.beta" < v"1.0.0-beta"
      check v"1.0.0-beta" < v"1.0.0-beta.2"
      check v"1.0.0-beta.2" < v"1.0.0-beta.11"
      check v"1.0.0-beta.11" < v"1.0.0-rc.1"
      check v"1.0.0-rc.1" < v"1.0.0"
