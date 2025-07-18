#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: $0 <compiler> [specific_test]"
  echo "  compiler: gcc, clang, or tcc(not stable)"
  echo "  specific_test: Optional - Run only this test directory"
  exit 1
fi

COMPILER=$1
SPECIFIC_TEST=$2

if ! command -v $COMPILER > /dev/null 2>&1; then
  echo "Error: $COMPILER is not installed or not in PATH"
  exit 1
fi

TESTS="01-basic-build 02-custom-config 03-generic-flags 04-raylib-build 05-samurai-source-code 06-lua-source-code 07-raylib-source-code"

if [ "$COMPILER" = "tcc" ]; then
  echo "NOTE: Will skip 07-raylib-source-code test for TCC compiler"
fi

if [ ! -z "$SPECIFIC_TEST" ]; then
  found=0
  for test in $TESTS; do
    if [ "$test" = "$SPECIFIC_TEST" ]; then
      found=1
      break
    fi
  done

  if [ $found -eq 0 ]; then
    echo "Error: Test '$SPECIFIC_TEST' not found in test suite"
    exit 1
  fi

  TESTS="$SPECIFIC_TEST"
fi

for test in $TESTS; do
  if [ "$COMPILER" = "tcc" ] && [ "$test" = "07-raylib-source-code" ]; then
    echo "Skipping $test for TCC compiler"
    continue
  fi

  echo "Running test $test with $COMPILER..."

  if [ ! -d "./tests/$test" ]; then
    echo "Error: Test directory ./tests/$test not found"
    continue
  fi

  cd "./tests/$test" || continue

  rm -rf "build"
  rm -rf "custom-dir"
  rm -f "mate"
  $COMPILER mate.c -o mate
  ./mate

  result=$?
  if [ $result -ne 0 ]; then
    echo "❌ Test $test failed with $COMPILER (exit code: $result)"
    cd - > /dev/null
    exit 1
  else
    echo "✅ Test $test passed with $COMPILER"
  fi

  cd - > /dev/null
done

echo "All tests completed successfully with $COMPILER! 🎉"
