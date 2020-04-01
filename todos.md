# Todos

## Code Coverage

memo

```sh
#!/bin/sh
rm -rf *.info html nimcache
nim --debugger:native --passC:--coverage --passL:--coverage c x
./x
lcov --remove test_semver_spec.info "lib/*" -o test_semver_spec.info # remove Nim system libs from coverage
genhtml -o html test_semver_spec.info


nimble test --debugger:native --passC:--coverage --passL:--coverage

rm -rf *.info html nimcache
nim --debugger:native --nimcache=nimcache --passC:--coverage --passL:--coverage c tests/test_semver_spec.nim
nim --debugger:native --nimcache=nimcache --passC:--coverage --passL:--coverage c tests/test_semver.nim
nim --debugger:native --nimcache=nimcache --passC:--coverage --passL:--coverage c tests/test_tail.nim
nim --debugger:native --nimcache=nimcache --passC:--coverage --passL:--coverage c tests/test_semrelcalc.nim


lcov --base-directory tests --directory ./nimcache --zerocounters -q
tests/test_semver_spec
tests/test_semver
tests/test_tail
tests/test_semrelcalc
lcov --base-directory tests --directory ./nimcache -c -o semrelcalc.info
lcov --remove semrelcalc.info "lib/*" -o test_semver_spec.info # remove Nim system libs from coverage
genhtml -o html test_semver_spec.info
```
