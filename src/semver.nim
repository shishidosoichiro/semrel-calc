import re
import streams
import strformat
import strutils

type Semver* = ref object of RootObj
  major*: int
  minor*: int
  patch*: int
  preRelease*: seq[string]
  metadata*: seq[string]

type
  SemverParseError* = object of Exception

proc isInt(s: string): bool =
  try:
    discard s.parseInt()
    result = true
  except:
    discard

proc newSemver*(major, minor, patch: int, preRelease: seq[string] = @[], metadata: seq[string] = @[]): Semver =
  Semver(major: major, minor: minor, patch: patch, preRelease: preRelease, metadata: metadata)

proc parse*(semverString: string): Semver =
  let stream = newStringStream(semverString)
  var c: char
  var mode = "major version"
  var buffer = ""
  var major = 0
  var minor = 0
  var patch = 0
  var preRelease: seq[string] = @[]
  var metadata: seq[string] = @[]
  var pos = -1
  var leadingZero = false
  c = stream.readChar
  while true:
    pos += 1
    case mode
    of "major version":
      if c == '.':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        major = buffer.parseInt
        mode = "minor version"
        buffer = ""
        leadingZero = false
      elif c == '0' and buffer.len == 0:
        buffer.add(c)
        leadingZero = true
      elif c.isDigit:
        if leadingZero:
          raise newException(SemverParseError, &"leading zeros on {mode}. input = {semverString}, position = {$pos}")
        buffer.add(c)
      else:
        raise newException(SemverParseError, &"not a numeric character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
    of "minor version":
      if c == '.':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        minor = buffer.parseInt
        mode = "patch version"
        buffer = ""
        leadingZero = false
      elif c == '0' and buffer.len == 0:
        buffer.add(c)
        leadingZero = true
      elif c.isDigit:
        if leadingZero:
          raise newException(SemverParseError, &"leading zeros on {mode}. input = {semverString}, position = {$pos}")
        buffer.add(c)
      else:
        raise newException(SemverParseError, &"not a numeric character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
    of "patch version":
      if c == '-' or c == '\x00':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        patch = buffer.parseInt
        mode = "pre-release version"
        buffer = ""
        leadingZero = false
      elif c == '+':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        patch = buffer.parseInt
        mode = "metadata"
        buffer = ""
        leadingZero = false
      elif c == '0' and buffer.len == 0:
        buffer.add(c)
        leadingZero = true
      elif c.isDigit:
        if leadingZero:
          raise newException(SemverParseError, &"leading zeros on {mode}. input = {semverString}, position = {$pos}")
        buffer.add(c)
      else:
        raise newException(SemverParseError, &"not a numeric character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
    of "pre-release version":
      if c == '+' or c == '\x00':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        if buffer.isInt and buffer =~ re"^0.+":
          raise newException(SemverParseError, &"leading zeros on {mode}. input = {semverString}, position = {$pos}")
        preRelease.add(buffer)
        mode = "metadata"
        buffer = ""
      elif c == '.':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        if buffer.isInt and buffer =~ re"^0.+":
          raise newException(SemverParseError, &"leading zeros on {mode}. input = {semverString}, position = {$pos}")
        preRelease.add(buffer)
        buffer = ""
      elif c.isAlphaNumeric or c == '-':
        buffer.add(c)
      else:
        raise newException(SemverParseError, &"not alpha-numeric character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
    of "metadata":
      if c == '\x00':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        metadata.add(buffer)
        mode = "end"
        buffer = ""
      elif c == '.':
        if buffer.len == 0:
          raise newException(SemverParseError, &"invalid character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
        metadata.add(buffer)
        buffer = ""
      elif c.isAlphaNumeric or c == '-':
        buffer.add(c)
      else:
        raise newException(SemverParseError, &"not alpha-numeric character on {mode}. input = {semverString}, char = {$c}, position = {$pos}")
    if c == '\x00':
      break
    c = stream.readChar
  stream.close
  if mode == "major version":
    raise newException(SemverParseError, &"minor version is missing. input = {semverString}, char = {$c}, position = {$pos}")
  if mode == "minor version":
    raise newException(SemverParseError, &"patch version is missing. input = {semverString}, char = {$c}, position = {$pos}")
  newSemver(major, minor, patch, preRelease, metadata)

template v*(semverString: string): Semver =
  semverString.parse

proc toString*(semver: Semver): string =
  let preRelease =
    if semver.preRelease.len != 0:
      "-" & semver.preRelease.join(".")
    else:
      ""
  let metadata =
    if semver.metadata.len != 0:
      "+" & semver.metadata.join(".")
    else:
      ""
  &"{semver.major}.{semver.minor}.{semver.patch}{preRelease}{metadata}"

proc `$`*(semver: Semver): string =
  semver.toString

proc isPreRelease*(semver: Semver): bool = semver.preRelease.len > 0
proc isInitialDevelopment*(semver: Semver): bool = semver.major == 0
proc isPublicAPI*(semver: Semver): bool = semver.major == 1

proc comparePreReleaseIdentifier*(a, b: string): int =
  if not a.isInt and b.isInt: return 1
  elif a.isInt and not b.isInt: return -1
  elif a.isInt and b.isInt:
    if a.parseInt > b.parseInt: return 1
    elif a.parseInt < b.parseInt: return -1
  elif a > b: return 1
  elif a < b: return -1
  else: return 0

proc compare*(a, b: Semver): int =
  if a.major > b.major: return 1
  elif a.major < b.major: return -1
  elif a.minor > b.minor: return 1
  elif a.minor < b.minor: return -1
  elif a.patch > b.patch: return 1
  elif a.patch < b.patch: return -1
  elif a.preRelease.len == 0 and b.preRelease.len > 0 : return 1
  elif a.preRelease.len > 0 and b.preRelease.len == 0 : return -1
  elif a.preRelease.len > 0 and b.preRelease.len > 0:
    let max =
      if a.preRelease.len > b.preRelease.len:
        a.preRelease.len - 1
      else:
        b.preRelease.len - 1
    for i in 0..max:
      if i > a.preRelease.len - 1: return -1
      if i > b.preRelease.len - 1: return 1
      result = comparePreReleaseIdentifier(a.preRelease[i], b.preRelease[i])
      if result != 0: return result
    return 0
  else: return 0

proc isEqual*(a, b: Semver): bool = a.compare(b) == 0
proc isGreaterThan*(a, b: Semver): bool = a.compare(b) > 0
proc isLessThan(a, b: Semver): bool = a.compare(b) < 0
proc `==`*(a, b: Semver): bool = a.isEqual(b)
proc `!=`*(a, b: Semver): bool = not a.isEqual(b)
proc `>`*(a, b: Semver): bool = a.isGreaterThan(b)
proc `>=`*(a, b: Semver): bool = a.isGreaterThan(b) or a.isEqual(b)
proc `<`*(a, b: Semver): bool = a.isLessThan(b)
proc `<=`*(a, b: Semver): bool = a.isLessThan(b) or a.isEqual(b)
