# Assignment 4

Implement Branch instructions

## Goals

- Implement all instructions of the RV32I set to make a single cycle CPU.

## Given

The goal of the single cycle CPU is to implement all instructions (except `FENCE`, `ECALL` and `EBREAK`) in the RV32I instruction set (pg. 130 of riscv-spec.pdf uploaded on Moodle).  For this, we will assume a simplified memory model, where data and instruction memory can be read in a single cycle (provide the address, and the memory responds with data in the same cycle), while allowing write at the next edge of the clock.  You are already provided with memory modules that behave as required, along with the following:

- Test bench with test cases including BRANCH instructions
    - Test bench will feed one input instruction per clock cycle
    - All registers are assumed initialized to 0 - this should be done in your code
- IMEM and DMEM are given as modules in the test bench.  You should not change them, but have to follow the read/write timing patterns from them.
- `cpu_tb.v` is the top test bench - the interface for your CPU code must match this.

## Details on the assignment

You need to implement code for the `cpu` module, that will read in the instructions and execute them. For this assignment, all functionality should be correct, so that the PC cannot be assumed to increment automatically by 4, and should be implemented correctly as per BRANCH instructions.

### Test cases

Test cases are given under the `test/` folder, with appropriate imem and dmem files.  Each imem file contains a set of instructions at the end that will dump all the register values into the first several locations in dmem.  The test bench will then read out these values from dmem and compare with expected results.

The file `dump.s` in the top folder also shows an example of assembly code that you can write to create your own test cases.  You can compile and disassemble as follows to generate the instruction codes.  Note that function calls need to be handled with care: the addresses for functions are not resolved till the Link step completes, so disassembled code will not look or work as expected.

```bash
$ riscv32-unknown-elf-gcc -c dump.s
$ riscv32-unknown-elf-objdump -d -Mnumeric,no-aliases dump.o
```

### Grading

This and the previous assignment (ALU + L/S) use the same test setup.  Therefore if you submit the same code for both that is perfectly fine.  However, if you have trouble implementing branching, you are advised to ensure that the Load/Store is correctly implemented so you get full credit for A3 before proceeding to A4.

## HowTo

Fork this repository (`EE2003-2021/a4`) into your namespace so that you can edit and push changes.

The `run.sh` script performs all the steps required to compile and test your code.  The `iverilog` compiler is used for running the verilog simulations.

**IMPORTANT**: do not rename files or create new files - otherwise the auto-grader will not recognize it.  Even if you change the `.drone.yml` file, the system will repeat the tests with different configuration files, and your changes will most likely not be recognized then.

Once you have confirmed that your code passes all the tests, commit all the changes, tag it for submission, and push to your repository.

## Date

Due Midnight, Sep 30, 2021
