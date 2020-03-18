#import semver
import re
import streams
import strutils
import ./semver

proc semrelcalc*(semverString: string, messages: Stream): string =
  # Calculate messages
  var major = false
  var minor = false
  var patch = false

  var message = ""
  while messages.readLine(message):
    if message =~ re"^BREAKING CHANGE":
      major = true
    elif message =~ re"^feat":
      minor = true
    elif message =~ re"^fix":
      patch = true
    elif message =~ re"^chore":
      patch = true
    elif message =~ re"^doc":
      patch = true
    else:
      continue

  # Increment a semver
  var semver = semverString.parse
  if major and semver.major != 0:
    semver.major += 1
    semver.minor = 0
    semver.patch = 0
    semver.preRelease = @[]
    semver.metadata = @[]
  elif major and semver.major == 0:
    semver.minor += 1
    semver.patch = 0
    semver.preRelease = @[]
    semver.metadata = @[]
  elif minor:
    semver.minor += 1
    semver.patch = 0
    semver.preRelease = @[]
    semver.metadata = @[]
  elif patch:
    semver.patch += 1
    semver.preRelease = @[]
    semver.metadata = @[]

  # Stringify next semver
  $semver

proc semrelcalc*(semverString: string, messages: seq[string]): string =
  semrelcalc(semverString, newStringStream(messages.join("\n")))

when isMainModule:  # Preserve ability to `import api`/call from Nim
  import cligen
  import tail

  const version = "Vendor " & staticExec("cd .. && (nimble version | grep -v Executing)") &
                  "\nRevision " & staticExec("git rev-parse HEAD") &
                  "\nCompiled on " & staticExec("uname -v") &
                  "\nNimVersion " & NimVersion
  const name = staticExec("cd .. && (nimble name | grep -v Executing)")
  const doc = "  " & staticExec("cd .. && (nimble description | grep -v Executing)")
  const usage = "Usage:\n  $command $args\n\n${doc}\nOptions(opt-arg sep :|=|spc):\n$options"

  proc main(args: seq[string]): int =
    try:
      if args.len > 1:
        echo semrelcalc(args[0], args.tail(1))
      else:
        echo semrelcalc(args[0], newFileStream(stdin))
      return 0
    except:
      let msg = getCurrentExceptionMsg()
      stderr.writeLine(msg)
      return 1

  clCfg.version = version
  dispatch(main, cmdName = name, usage = usage, doc = doc, help={"args" : "<version> [<messages>...]"})
