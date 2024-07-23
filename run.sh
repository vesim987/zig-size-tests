#!/usr/bin/env bash

set -x

run() {
  rm -rf main.o zig-cache .zig-cache
  nix shell "github:mitchellh/zig-overlay#\"$1\"" --command zig build-exe -O $3 main.zig foo.c -target arm-freestanding-none -T rp2040.ld $2 
  llvm-objcopy -O binary main main-bin-$3-$1$2
  mv main main-$3-$1$2
}

rm -rf main-*
for opt in Debug ReleaseSmall ReleaseFast ReleaseSafe
do
  # run "0.9.0" "" $opt
  # mv main-$opt-0.9.0 main-$opt-0.9.0-fno-strip
  # run "0.10.0" "-fno-strip" $opt
  # run "0.11.0" "-fno-strip" $opt
  # run "0.12.0" "-fno-strip" $opt
  # run "0.13.0" "-fno-strip" $opt

  run "0.9.0" "--strip" $opt
  run "0.10.0" "" $opt
  run "0.11.0" "" $opt
  run "0.12.0" "" $opt
  run "0.13.0" "" $opt
done
ls -la main-*
