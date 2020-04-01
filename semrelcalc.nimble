# Package

packageName    = "semrelcalc"
version       = "0.1.0"
author        = "Soichiro Shishido"
description   = "Version Calculator for Semantic Release. Calculate next version with current version and commit type list."
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["semrelcalc"]

const cpu     = "amd64"
#const cpu     = "arm64"
const owner   = "shishidosoichiro"
const repo    = "semrelcalc"
const release_script_url = "https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447/raw/dbadd7d310ce8446de89c4ffdf1db0b400d0f6c3/upload-github-release-asset.sh"
const release_script     = "./dist/upload-github-release-asset.sh"


# Dependencies

requires "nim >= 1.0.6"
requires "cligen >= 0.9.43"

import os
import strformat

proc build(targetOs: string) =
  exec &"nimble build --os:{targetOs} --opt:size --cpu:{cpu} --d:release --d:platform_{buildOS}"

proc package(targetOs: string) =
  let archiveName = &"semrelcalc-{version}-{targetOs}-{cpu}"
  mkDir "dist" / archiveName
  exec &"cp -pr {binDir/packageName}* {\"dist\"/archiveName}"
  if targetOs == "windows":
    exec &"cd dist && zip -r {archiveName}.zip {archiveName}"
  else:
    exec &"cd dist && tar -zcf {archiveName}.tar.gz {archiveName}"

task name, "Output packageName":
  echo packageName

task version, "Output version":
  echo version

task description, "Output description":
  echo description

task all, "Package all":
  exec "nimble clean"
  exec "nimble macosx"
  exec "nimble clean"
  exec "nimble linux"
  exec "nimble clean"
  exec "nimble windows"

task macosx, "Build for MacOS":
  build "macosx"
  exec "nimble upx"
  package "macosx"

task linux, "Build for Linux":
  build "linux"
  exec "nimble upx"
  package "linux"

task windows, "Build for Windows":
  build "windows"
  exec "nimble upx"
  package "windows"

task upx, "Upx":
  exec &"upx --best {binDir/packageName}*"

task coverage, "Generate code coverage report":
  echo "Generate code coverage report"
  exec "coco --target \"tests/**/*.nim\" --cov '!tests' --compiler=\"--hints:off -d:release\" "

task clean, "Clean":
  exec "git clean -fdX -e '!.env'"

# After `. .env`
task release, "Release":
  let github_api_token = getEnv("GITHUB_API_TOKEN")
	mkDir "dist"
  let data = &"\{\\\"tag_name\\\": \\\"{version}\\\", \\\"target_commitish\\\": \\\"master\\\", \\\"name\\\": \\\"{version}\\\", \"body\": \"\", \"draft\": false, \"prerelease\": false\}"
	exec &"curl -X POST https://api.github.com/repos/{owner}/{repo}/releases -d \"{data}\" -H 'Content-Type:application/json' -H \"Authorization: token {github_api_token}\""

# After `. .env`
task releaseFiles, "Release":
  let github_api_token = getEnv("GITHUB_API_TOKEN")
	mkDir "dist"
	exec &"cd dist && curl --fail --location -O -s {release_script_url}"
	exec &"chmod u+x {release_script}"
	exec &"{release_script} github_api_token={github_api_token} owner={owner} repo={repo} tag={version} filename=./dist/semrelcalc-{version}-windows-amd64.zip"
	exec &"{release_script} github_api_token={github_api_token} owner={owner} repo={repo} tag={version} filename=./dist/semrelcalc-{version}-linux-amd64.tar.gz"
	exec &"{release_script} github_api_token={github_api_token} owner={owner} repo={repo} tag={version} filename=./dist/semrelcalc-{version}-macosx-amd64.tar.gz"
