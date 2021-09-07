.global fib
fib:
    slti a1, a0, 3
    li a4, 1
    bne a1, a4, .func

.finish:
    mv a0, a1    # Return result in reg a0
    jr ra       # Return address was stored by original call
    
.func:
    li a1, 2
    li a2, 1
    addi a0, a0, -1
    slti a3, a0, 3
    beq a3, a4, .finish

.loop:
    add a1, a1, a2
    sub a2, a1, a2
    addi a0, a0, -1
    slti a3, a0, 3
    beq a3, a4, .finish
    bne a3, a4, .loop
