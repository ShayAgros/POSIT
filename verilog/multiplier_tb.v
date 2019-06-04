`timescale 1 ns / 1 ps
module multiplier_tb;

	// INPUT 
	reg [15:0] x;
	reg [15:0] y;

	// OUTPUT
	wire [15:0] posit;

	multiplier #(16,3) dut (
		.x	(x),
		.y 	(y),
		.posit	(posit)
	);

	/*
	initial begin
		$dumpfile("mult_test.vcd");
		$dumpvars(0, multiplier);
	end // Dump
	*/

	initial begin // tb
		x = 0;
		y = 0;
		
		// Multiply by 0

		#5 // Time = 5; 
		x =   0;
		y =   16'b0110101011010101;

		#5 // Time = 10;
		x =   16'b1010110100010101;
		y =   0;
	
	end // tb
	

	initial begin // monitor
		$monitor("Time = %3d\n\tx = %16b   y = %16b, posit = %16b\n", $time, x, y, posit);
	end // monitor

endmodule // multiplier
