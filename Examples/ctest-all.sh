#!/bin/bash

set -e

CFG+=(
  cortexM0l
  cortexM0b
  cortexM3l
  cortexM3b
  cortexM4l
  cortexM4b
  cortexM4lf
  cortexM4bf
  cortexM7l
  cortexM7b
  cortexM7ls
  cortexM7bs
  cortexM7lf
  cortexM7bf
  ARMv8MBLl
  ARMv8MMLl
  ARMv8MMLldfsp
  ARMv8MMLldfdp
  ARMv81MMLld
  ARMv81MMLldfdp
)

# Run examples for all build configuration
for cfg in ${CFG[@]}; do
  echo "=============================================================================="
  echo "--- Testing build configuration: ${cfg}..."
  ctest --test-dir build --build-config ${cfg} $1
done

