//                               Assignment-3: Single Cycle Implementation of RV32I
// Filename        : ALU.v
// Description     : ALU with 10 fundamental operations chosen by ALU_sel and ALU_mode
// Author          : Surya Prasad S (EE19B121)
// Date			   : 7th October 2021

// The following module takes 4 inputs - ALU_sel, ALU_mode, operand1 and operand2 - and gives one output - result
// For RV32I, ALU_sel is based on the func3 value of arithmetic instructions and ALU_mode is based on func7 value of arithmetic instructions
// ALU_mode is also set high if ALU_sel corresponds to SLT or SLTU because it involves subtraction which is explained later
// To use the ALU for other instructions assign appropriate ALU_sel and ALU_mode values
`timescale 1ns/1ns 

module ALU (
	output [31:0] result,
	input [2:0] ALU_sel,
	input ALU_mode,
	input [31:0] operand1,
	input [31:0] operand2
);
	reg [31:0] result;
	wire [31:0] adder_output;
	myAdder m1(operand1, operand2, (ALU_mode | ((~ALU_sel[2])& ALU_sel[1])), adder_output);
	
	// The following always block will generate a combinational circuit if synthesised
	always@(*) begin
		case(ALU_sel)
		3'd0: result = adder_output; 							// 0 - ADD and SUB - Here addition or subtraction is decided by the mode
		3'd1: result = operand1 << operand2[4:0]; 				// 1 - SLL - Max shift which is possible is 32 bits hence only lower 5 bits have been mapped
		3'd2: result = {31'd0, (operand1[31]&(~operand2[31]) 
						| operand1[31]&adder_output[31] 
						| (~operand2[31]&adder_output[31]))}; 	// 2 - SLT - Adder module has been used and the appropriate result was got by using K-Maps
		3'd3: result = {31'd0, ((~operand1[31])&adder_output[31] 
						| operand2[31]&(~adder_output[31]))};	// 3 - SLTU - Adder module has been used and the appropriate result was got by using K-Maps
		3'd4: result = operand1 ^ operand2; 					// 4 - XOR
		3'd5: begin 											// 5 - SRL and SRA - Here also the mode determines the operation
			if (ALU_mode) result = operand1 >>> operand2[4:0];
			else result = operand1 >> operand2[4:0];
			end
		3'd6: result = operand1 | operand2; 					// 6 - OR
		3'd7: result = operand1 & operand2; 					// 7 - AND
		endcase
	end
endmodule

// Addition, subtraction and set less than instructions utilise the same adder module
// For subtraction we need the mode to be 1 hence set less than instructions also are hardwired to set the mode as 1
// The following module will generate separate adders for subtraction and addition but further optimisation can be done to use one adder.

module myAdder (in1, in2, mode, sum);
	input [31:0] in1, in2;
	input mode;
	output [31:0] sum;

	assign sum = mode? in1-in2:in1+in2;
endmodule

