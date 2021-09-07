.global _start
_start:
    # Load 'n' into a0 and call fib
    # Test 1
    li      a0,1  # Check n'th Fib number
    call    fib
    li      a5,1  # Expected result
    bne     a0,a5,.FINISH
    # Test 2
    li      a0,3  
    call    fib
    li      a5,2
    bne     a0,a5,.FINISH
    # Test 3
    li      a0,7  
    call    fib
    li      a5,13  
    bne     a0,a5,.FINISH
    # Test 4
    li      a0,9 
    call    fib
    li      a5,34  
    bne     a0,a5,.FINISH
    # Test 5
    li      a0,20 
    call    fib
    li      a5,6765 
    bne     a0,a5,.FINISH
    # Test 6
    li      a0,30
    call    fib
    li      a5,832040 
    bne     a0,a5,.FINISH
    # Finished tests
    li      a5,0  # All passed
.FINISH:
    mv      a0, a5
    li      a7, 93
    ecall

