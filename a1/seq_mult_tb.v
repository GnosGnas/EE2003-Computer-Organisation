// Description     : Sequential multiplier test bench
// Author          : Nitin Chandrachoodan <nitin@ee.iitm.ac.in>

// Automatic test bench
// Uses tasks to keep test code clean


`timescale 1ns/1ns
`define width 8
`define mult_width 2*`width
`define TESTFILE "test_in.dat"

module seq_mult_tb () ;
	reg signed [`width-1:0] a, b;
	reg 		    clk, reset;

	wire signed [`mult_width-1:0] p;
	wire 	       rdy;

	integer total, err;
	integer i, s, fp, numtests;

	// Golden reference - can be automatically generated in this case
	// otherwise store and read from a file
	wire signed [`mult_width-1:0] ans = a*b;

	// Device under test - always use named mapping of signals to ports
	seq_mult dut( .clk(clk),
		.reset(reset),
		.a(a),
		.b(b),
		.p(p),
		.rdy(rdy));

	// Set up 10ns clock
	always #5 clk = !clk;

	// A task to automatically run till the rdy signal comes back from DUT
	task apply_and_check;
		input [`width-1:0] ain;
		input [`width-1:0] bin;
		begin
			// Set the inputs
			a = ain;
			b = bin;
			// Reset the DUT for one clock cycle
			reset = 1;
			@(posedge clk);
			// Remove reset 
			#1 reset = 0;

			// Loop until the DUT indicates 'rdy'
			while (rdy == 0) begin
				@(posedge clk); // Wait for one clock cycle
			end
			if (p == ans) begin
				$display($time, " Passed %d * %d = %d", a, b, p);
			end else begin
				$display($time, " Fail %d * %d: %d instead of %d", a, b, p, ans);
				err = err + 1;
			end
			total = total + 1;
		end
	endtask // apply_and_check

	initial begin
		// Initialize the clock 
		clk = 1;
		// Counters to track progress
		total = 0;
		err = 0;

		// Get all inputs from file: 1st line has number of inputs
		fp = $fopen(`TESTFILE, "r");
		s = $fscanf(fp, "%d\n", numtests);
		// Sequences of values pumped through DUT 
		for (i=0; i<numtests; i=i+1) begin
			s = $fscanf(fp, "%d %d\n", a, b);
			apply_and_check(a, b);
		end
		apply_and_check(127, 127); //Extreme value which was tested and passed succesfully
		apply_and_check(-128, -128); //Extreme value which was tested and passed succesfully


		if (err > 0) begin
			$display("FAIL %d out of %d", err, total);
		end else begin
			$display("PASS %d tests", total);
		end
		$finish;
	end

endmodule // seq_mult_tb
