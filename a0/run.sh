echo "success" > .temp
if diff -wB output .temp > /dev/null 2>&1; then
    echo "PASSED"
else
    echo "FAILED"
fi
rm .temp