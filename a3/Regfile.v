//                               Assignment-3: Single Cycle Implementation of RV32I
// Filename        : Regfile.v
// Description     : Register file containing all the registers which can be accessed using the instruction set
// Author          : Surya Prasad S (EE19B121)
// Date			   : 7th October 2021

// The following module has inputs and outputs corresponding to registers for reading and registers for writing along with clock and reset
// 0th register has been hardwired to 0 and cannot be modified during execution
`timescale 1ns/1ns 

module Regfile(
	output [31:0] reg1_value,
	output [31:0] reg2_value,
	input [4:0] reg1_id,
	input [4:0] reg2_id,
	input [4:0] reg_write_id,
	input [31:0] reg_write_inp,
	input we,
	input clk,
	input reset
);
	reg [31:0] registers [31:0];		//32 32-bit registers

	wire flag;		                    // Flag to identify if register 0 is being modified
	assign flag = (reg_write_id == 32'b0);

	// Assigning for asynchronous read
	assign reg1_value = registers[reg1_id];
	assign reg2_value = registers[reg2_id];

integer i;
initial begin
    for(i=0; i<32; i=i+1) begin
        registers[i] = 32'd0;
    end
end

always @(posedge clk) begin
    if(~reset) begin
        if(we) begin
            if(flag) begin              // To prevent writing into register[0]
                registers[reg_write_id] <= 32'd0;
            end
            else begin
                registers[reg_write_id] <= reg_write_inp;
            end
        end
    end
    else begin
        for(i=0; i<32; i=i+1) begin
        registers[i] <= 32'd0;
        end
    end
end

endmodule
