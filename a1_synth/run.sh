#!/bin/sh
#
# Compile and run the test bench

export DUT=seq_mult

[ -x "$(command -v iverilog)" ] || { echo "Install iverilog"; exit 1; }
[ -f $DUT.v ] || { echo "Make sure your code is named $DUT.v"; exit 1; }

echo "Compiling sources"
iverilog -DTESTFILE=\"test_in.dat\" -o "$DUT" "${DUT}_tb.v" "$DUT.v" 

./$DUT

cat << EOF

You should see a PASS message and all tests pass.
If any test reports as a FAIL, fix it before submitting.
Once all tests pass, commit the changes into your code,
and push the commit back to the server for evaluation.
EOF