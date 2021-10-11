
module tb;
	reg clk=0, reset=0;
	reg [31:0] idata, drdata;
	wire [31:0] iaddr, daddr, dwdata, rd_in;
	wire [3:0] dwe;
	reg [21:0] id=0;

	cpu C (clk, reset, iaddr, idata, daddr, drdata, dwdata, dwe);
	
	always #5 clk <= ~clk;

	initial 				#100 $finish;


	always@(posedge clk)
	begin

			if (id==0)
			begin
				idata <= 32'h1f040413;
				id <= id+1;
				$display("HI");
			end

			else if (id==1)
			begin
				idata <= 32'h3422B3;//518113;
			end
		drdata <= -1;
		$display($time, "  hi %b, %b, %d", iaddr, dwe, rd_in);
	end


endmodule
//111111101000 01000 010 01110 0000011



