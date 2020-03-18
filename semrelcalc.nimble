# Package

const name    = "semrelcalc"
version       = "0.1.0"
author        = "Soichiro Shishido"
description   = "Version Calculator for Semantic Release. Calculate next version with current version and commit type list."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["semrelcalc"]



# Dependencies

requires "nim >= 1.0.6"
requires "cligen >= 0.9.43"

task name, "Output name":
  echo name

task version, "Output version":
  echo version

task description, "Output description":
  echo description

task dist, "Build distributions":
  exec "nimble build -d:release"

task coverage, "Generate code coverage report":
  echo "Generate code coverage report"
  exec "coco --target \"tests/**/*.nim\" --cov '!tests' --compiler=\"--hints:off -d:release\" "
