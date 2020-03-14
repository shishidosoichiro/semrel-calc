proc semrelcalc*(version: string, types: seq[string]): string =
  version & " - " & "1"

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
    echo semrelcalc(args[0], args.tail(1))
    return 0

  clCfg.version = version
  dispatch(main, cmdName = name, usage = usage, doc = doc, help={"args" : "<version> [<types>...]"})
