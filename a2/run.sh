#!/bin/bash
#
# Assumes that the RISC-V compiler has been installed and is in the path.
# If not, set the PATH variable properly before calling the script.
# The variable RVPK must also have been set to point to the Spike proxy kernel.


GCC=riscv32-unknown-elf-gcc
LD=riscv32-unknown-elf-ld
RVPK=/opt/tools/riscv/riscv32-unknown-elf/bin/pk
SP="spike $RVPK"

[ -x "$(command -v $GCC)" ] || { echo "You need to first set up the paths to the RISC-V compiler toolchain"; exit 1; }

echo "Please ensure that your final code to be tested is in the file fib.s"

echo "Compiling..."
$GCC -c fib.s 
$GCC -c runtest.s 

echo "Linking and creating executable"
$LD runtest.o fib.o -o fib 

echo "Running the test"
$SP ./fib 

r=$?
if [ $r != 0 ]; then
    echo "Some tests failed.  Please review your code and try again"
    exit $r
else
    echo "Your code passed the tests.  "
    echo "Once all tests pass, commit the changes into your code, and push the commit back to the server for evaluation."
fi 
