//                               Assignment-3: Single Cycle Implementation of RV32I
// Filename        : cpu.v
// Description     : Single cycle implementation of RISCV-32I
// Author          : Surya Prasad S (EE19B121)
// Date			   : 7th October 2021

// The following module takes 4 inputs - ALU_sel, ALU_mode, operand1 and operand2 - and gives one output - result
// For RV32I, ALU_sel is based on the func3 value of arithmetic instructions and ALU_mode is based on func7 value of arithmetic instructions
// ALU_mode is also set high if ALU_sel corresponds to SLT or SLTU because it involves subtraction which is explained later
// To use the ALU for other instructions assign appropriate ALU_sel and ALU_mode values

// Module cpu takes 4 inputs - idata, drdata, clk and reset - and gives 4 outputs - iaddr, daddr, dwdata and dwe
// The top module will take the address of the instruction to be fetched from cpu and gives it the instruction data via idata from the imem
// Similarly the top module also ensures the cpu module can read and write data corresponding to dmem
// The cpu module uses a set of control signals for most parts of the logic
// ALU has been used as much as possible for both arithmetic and non-arithmetic instructions and extra adders are also required for certain cases
`timescale 1ns/1ns 

module cpu (
    input clk, 
    input reset,
    output [31:0] iaddr,
    input [31:0] idata,
    output [31:0] daddr,
    input [31:0] drdata,
    output [31:0] dwdata,
    output [3:0] dwe
);
	// Output signals being redeclared as registers
	// Here only iaddr will be synthesised as a register
	// We require iaddr to be a physical register because to fetch the next instruction we need the value of the previous instruction
    reg [31:0] iaddr;			// In Microprocessor theory its also reffered as PC (Program Counter)
	reg [31:0] dwdata;			// Used only as a wire - Used to pass data to be written in the dmem
    reg [3:0]  dwe_input; 		// Used only as a wire - Assigned to dwe in the end


    // Control signals for the CPU
	// parameter variables have been used to increase readability
	parameter ALU_REG_SRC = 1'b0, ALU_IMM_SRC = 1'b1;
	parameter REG_WE = 1'b1;
	parameter PC_NEXT = 1'b0, PC_TARGET = 1'b1;
    reg ALU_src, Reg_Write, PC_src;


	// Wires declared as registers to be used to split each instruction into various parts
    reg [6:0] opcode;
	reg [7:0] func7;
	reg ALU_mode;	
    reg [2:0] func3, ALU_sel;
    reg [4:0] rs1, rs2, rd, shamt;
    reg [31:0] imm, imm1, imm2, imm3, imm4, imm5;
	reg [31:0] rd_in;
	reg [31:0] PC_target;


	// Wires to ALU module
    wire [31:0] ALU_operand1, ALU_operand2;
    wire [31:0] ALU_output;
    wire [31:0] rs1_value, rs2_value;


	// Wires to PC and required adders
    wire [31:0] iaddr_wire;
	wire [31:0] iaddr_add4, iaddr_addi;


	// Wire declared as a register and it is used for flagging any error
	// **Note**: It is not used to stop the simulation
	reg [2:0] error_flag = 0;

    // Module declarations
    ALU A (ALU_output, ALU_sel, ALU_mode, ALU_operand1, ALU_operand2);
    Regfile R (rs1_value, rs2_value, rs1, rs2, rd, rd_in, Reg_Write, clk, reset);

	// Control block of the CPU
	always@(*)
	begin
		// STAGE 1
		// Extracting the different parts of an instruction
		// Based on the opcode we shall use the appropriate parts
		opcode = idata[6:0];
		func7 = idata[31:25];
		func3 = idata[14:12];
		rs1 = idata[19:15];
		rs2 = idata[24:20];
		rd = idata[11:7];
		shamt = idata[24:20];

		// Different instructions use the immediate value differently 
		imm1 = {idata[31:12], 12'b0}; 						 // For instructions LUI and AUIPC
		imm2 = {{12{idata[31]}}, idata[19:12], idata[20], idata[30:21], {1'b0}};  // For instruction JAL
		imm3 = {{20{idata[31]}}, idata[31:20]}; 			 // For instructions JALR, LOAD types and ARITH with immediate types
		imm4 = {{20{idata[31]}}, idata[7], idata[30:25], idata[11:8], {1'b0}};	  // For instructions of type BRANCH
		imm5 = {{20{idata[31]}}, idata[31:25], idata[11:7]}; // For instructions of type STORE

		// Default initialisations to prevent latch-ups
		error_flag = 3'd0;

		dwdata = 32'd0;
		dwe_input = 4'b0;

		ALU_src = ALU_REG_SRC;
		Reg_Write = ~(REG_WE);
		PC_src = PC_NEXT;

		ALU_mode = 1'b0;
		ALU_sel = 3'd0;
		imm = 32'd0;
		rd_in = 32'd0;
		PC_target = 32'd0;


		// STAGE 2
		// Sending control signals appropriately
		// Certain datapaths which need to be set only for that particular opcode has also been set here
		// Certain bits are not required for the main operation but they are checked to be valid here
		case (opcode)
		7'b0110111: begin				// LUI instruction
			ALU_src = ALU_IMM_SRC;
			Reg_Write = REG_WE;
			PC_src = PC_NEXT;

			imm = imm1;
			rs1 = 5'd0;  			// Special requirement for LUI instruction so that the ALU output can be directly stored in the destination register
            ALU_sel = 3'd0;			// ALU is being set to addition
            ALU_mode = 1'b0;
			rd_in = ALU_output;
			end

		7'b0010111: begin				// AUIPC instruction
			Reg_Write = REG_WE;
			PC_src = PC_NEXT;

			imm = imm1;
			rd_in = iaddr_addi;
			end

		7'b1101111: begin				// JAL instruction
			Reg_Write = REG_WE;
			PC_src = PC_TARGET;

			imm = imm2;
			rd_in = iaddr_add4;		// Here we are not using the ALU because these connections already exist due to other instructions
			PC_target = iaddr_addi;
			end

		7'b1100111: begin				// JALR instruction
			ALU_src = ALU_IMM_SRC;
			Reg_Write = REG_WE;
			PC_src = PC_TARGET;
			
			imm = imm3;
			rd_in = iaddr_add4;
            ALU_sel = 3'd0;
            ALU_mode = 1'b0;
			PC_target = ALU_output & (32'hfffffffe);  // Essentially, we are setting the LSB to 0

			// Error checking
			if (func3 != 3'd0) error_flag = 3'd1;
			end

		7'b1100011: begin				// BRANCH instructions
			ALU_src = ALU_REG_SRC;
			Reg_Write = ~(REG_WE);

			imm = imm4;
			ALU_mode = 1'b1;
			PC_target = iaddr_addi;

			// Here since all the branch instructions are conditional we give the control signal's value based on the output
			// The parameters which are usually given to PC_src have the following values: PC_NEXT = 1'b0, PC_TARGET = 1'b1
			
			/* The following case block can be used as a reference for the simplified if block below it
			case(func3) 
			3'd0: begin ALU_sel = 3'd0; PC_src = (ALU_output == 0); end		// BEQ
			3'd1: begin ALU_sel = 3'd0; PC_src = (ALU_output != 0); end		// BNE
			3'd4: begin	ALU_sel = 3'd2; PC_src = (ALU_output != 0); end		// BLT
			3'd5: begin ALU_sel = 3'd2; PC_src = (ALU_output == 0); end		// BGE
			3'd6: begin ALU_sel = 3'd3; PC_src = (ALU_output != 0); end		// BLTU
			3'd7: begin ALU_sel = 3'd3; PC_src = (ALU_output == 0); end		// BGEU
			default: begin PC_src = PC_NEXT; error_flag = 3'd2; end  // Error case
			endcase*/

			// Simplified block of code
			// It can be noticed from previous that ALU_sel is of the MSB 2 bits and the rest of the logic were got by simple mapping
			ALU_sel = {1'b0, func3[2:1]};

			if (|func3[2:1]) PC_src = (~func3[0]) ^ (ALU_output == 0); 
			else PC_src = func3[0] ^ (ALU_output == 0);

			//Error checking
			if ( (func3==3'd2) || (func3==2'd3) ) error_flag = 3'd2;
			end

		7'b0000011: begin				// LOAD instructions
			ALU_src = ALU_IMM_SRC;
			Reg_Write = REG_WE;
			PC_src = PC_NEXT;

			imm = imm3;
			ALU_sel = 3'd0;
			ALU_mode = 1'b0;

			// Here based on func3 the type of load instruction is got
            case(func3)
            3'd0: rd_in = {{24{drdata[7]}}, drdata[7:0]};		// LB
            3'd1: rd_in = {{16{drdata[15]}}, drdata[15:0]};		// LH
            3'd2: rd_in = drdata;								// LW
            3'd4: rd_in = {24'b0, drdata[7:0]};					// LBU
            3'd5: rd_in = {16'b0, drdata[15:0]};				// LHU
			default: begin 		// Error case
				Reg_Write = ~(REG_WE);
				error_flag = 3'd3;
				end
            endcase
			end

		7'b0100011: begin				// STORE instructions 
			ALU_src = ALU_IMM_SRC;
			Reg_Write = ~(REG_WE);
			PC_src = PC_NEXT;

			imm = imm5;
			ALU_sel = 3'd0;
			ALU_mode = 1'b0;

			// Similar to previous opcode, here also func3 decides the type of store instruction
			case(func3)
			3'd0: begin			// SB
				case(imm5[1:0])
				2'd0: dwe_input = 4'b0001;
				2'd1: dwe_input = 4'b0010;
				2'd2: dwe_input = 4'b0100;
				2'd3: dwe_input = 4'b1000;
				endcase
				dwdata = {4{rs2_value[7:0]}};  //This is just to make it generalised for this particular case
				end
			3'd1: begin			// SH
				case(imm5[1:0])
				2'd0: begin dwe_input = 4'b0011; dwdata = {16'b0, rs2_value[15:0]};	end
				2'd2: begin	dwe_input = 4'b1100; dwdata = {rs2_value[15:0], 16'b0}; end
				default: begin 		// Error case
					error_flag = 3'd4;
					dwe_input = 4'b0;
					end
				endcase
				end
			3'd2: begin			// SW
				if (imm5[1:0]==0)
					begin dwe_input = 4'b1111; dwdata = rs2_value;	end
				else
					begin dwe_input = 4'b0;	error_flag = 3'd4; end
				end
			default: error_flag = 3'd5;	//Error case
			endcase
			end

		7'b0010011: begin				// Arithmetic with immediate type of instructions
			ALU_src = ALU_IMM_SRC;
			Reg_Write = REG_WE;
			PC_src = PC_NEXT;

			imm = imm3;
			ALU_sel = func3;
			ALU_mode = 1'b0;
			rd_in = ALU_output;
			end

		7'b0110011: begin				// Arithmetic without immediate type of instructions
			ALU_src = ALU_REG_SRC;
			Reg_Write = REG_WE;
			PC_src = PC_NEXT;

			rd_in = ALU_output;
			ALU_sel = func3;
			ALU_mode = func7[5];
			end

		7'b0: begin  					// Null instruction
			Reg_Write = ~(REG_WE);
			PC_src = PC_NEXT;
			end
		
		default: begin					// Incorrect opcode
			Reg_Write = ~(REG_WE);
			PC_src = PC_NEXT;

			error_flag = 3'd6;
			end
		endcase
	end


	// STAGE 3
	// This stage though not completely explicit involves writing back into registers, incrementing PC and assigning appropriate values based on control signals
	// All operations part of this stage are not present here and the register file is updated inside the module Regfile
	// We require two adders additionally to do the following additions
	assign iaddr_add4 = iaddr + 4;
	assign iaddr_addi = iaddr + imm;
	
	// Assigning next instruction address to PC based on control signal PC_src
    assign iaddr_wire = PC_src? PC_target : iaddr_add4;

	// ALU operands being assigned based on control signal ALU_src
    assign ALU_operand1 =  rs1_value;
    assign ALU_operand2 = ALU_src? imm : rs2_value;

	// Assigning outputs and blocking them in case reset is high
	assign daddr = (reset)? 32'bZ : ALU_output;
	assign dwe = (reset)? 32'bZ : dwe_input;
	integer j=0;
	// Always block to change PC
    always @(posedge clk) begin
        if (reset) begin
            iaddr <= 0;
        end 
        else begin 
            iaddr <= iaddr_wire;
            $display("Count = %d, Instruction = %h,funct3 = %d, dwdata = %d, wdwe = %d, Reset = %d", j, idata,func3,dwdata, dwe, reset); j=j+1;
			//Error identification
			case(error_flag)
			3'd0: ;
			3'd1: $display("Warning: Incorrect func3 for JALR instruction %h",       idata);
			3'd2: $display("Warning: Incorrect func3 for BRANCH instruction %h",     idata);
			3'd3: $display("Warning: Incorrect func3 for LOAD instruction %h",       idata);
			3'd4: $display("Warning: Invalid offset given for STORE instruction %h", idata);
			3'd5: $display("Warning: Incorrect func3 for STORE instruction %h",      idata);
			3'd6: $display("Warning: Incorrect opcode for instruction %h",           idata);
			//default: $display("Incorrect error flag detetected");
			endcase
        end
    end
endmodule
