//                              -*- Mode: Verilog -*-
// Filename        : seq_mult_part.v
// Description     : Sequential multiplier
// Author          : Surya Prasad S (EE19B121)

// The following code has been tested for all extreme values and is also synthesizable with 103 LUTs and 66 FFs being consumed of the FPGA (when directly synthesised with Vivado).
// Result of synthesis has been given in the folder in which this file is located and along with it the elaborated design has also been shown

//The logic I have used to reduce the size of multiplier is if input 'a' is negative then it is converted into positive value and negative of 'b' is extended and given to multiplicand.


`define width 32
`define ctrwidth 6
`define mult_width 2*`width

module seq_mult (
		 // Outputs
		 p, rdy, 
		 // Inputs
		 clk, reset, a, b
		 ) ;
	input clk, reset;
	input [`width-1:0] a, b;
	// *** Output declaration for 'p'
	output reg [`mult_width-1:0] p;
	output rdy;
   
	// *** Register declarations for p, multiplier, multiplicand
	reg rdy;
	reg [`ctrwidth-1:0] ctr;
	reg [`width-1:0] multiplier;
	reg [`mult_width-1:0] multiplicand;

	wire [`mult_width-1:0] mux_wire;

	assign mux_wire = (multiplier[ctr]) ? (multiplicand << ctr) : 0;

	//This function is used to return 2's complement. It also extends the input to double the size (as defined above)
	function automatic [`mult_width-1:0] negate;
		input [`width-1:0] x;
		begin
			if (x[`width-1])
				negate =  ~( {{(`mult_width-`width){b[`width-1]}}, b} - 1);
			else
				negate =  ~( {{(`mult_width-`width){b[`width-1]}}, b}) + 1;
		end
	endfunction

	always @(posedge clk)
		if (reset) 
		begin
			rdy <= 0;
			p <= 0;
			ctr <= 0;
			
			if (a[`width-1])
			begin
				multiplier <= ~(a-1);
				multiplicand <= negate(b);
			end

			else
			begin
				multiplier <= a;
				multiplicand <= {{(`mult_width-`width){b[`width-1]}}, b};
			end
		end 

		else
		begin 
			if (ctr < `width) 
			begin
			// *** Code for multiplication
				p <= p + mux_wire;
				ctr <= ctr+1;
			end 

			else 
			begin
				rdy <= 1; 		// Assert 'rdy' signal to indicate end of multiplication
			end
		end

endmodule // seqmult
