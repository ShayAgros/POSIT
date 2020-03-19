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

	initial begin // tb

		$dumpfile("multiplier_waveform.vcd");
		$dumpvars(0, dut);

		x = 0;
		y = 0;

		// Multiply by 0
		#5 // Time = 5;
		x =   0;
		y =   16'b0110101011010101;

		#5 // Time = 10;
		x =   16'b1010110100010101;
		y =   0;

		// Multiply by infinity
		#5 // Time = 15;
		x =   16'b1000000000000000;
		y =   16'b1000000000000000;

		#5 // Time = 20;
		x =   16'b1010110100010101;
		y =   16'b1000000000000000;

		#5 // Time = 25;
		x =   16'b1000000000000000;
		y =   16'b1010110100010101;

		// Multiply zero and infinity

		#5 // Time = 30
		x =   16'b1000000000000000;
		y =   0;

		#5 // Time = 35
		x =   0;
		y =   16'b1000000000000000;

		// Multiply by 1/-1
		#5 // Time = 40
		x =   16'b0100000000000000;
		y =   16'b1010110100010101;

		#5 // Time = 45
		x =   16'b1010110100010101;
		y =   16'b1100000000000000;
	
		// 1.5*1.5 = 2.25. Should activate frac overflow
		#5 // Time = 50
		x =   16'b0100001000000000;
		y =   16'b0100001000000000;

		// Overflow the posit
		#5 // Time = 55
		x =   16'b0111111111111111;
		y =   16'b0111111111111111;

		#5 // Time = 60
		x =   16'b0111100111011000;
		y =   16'b0111111001001101;

		#5 // Time = 65 
		x =   16'b0000101000000000;
		y =   16'b0100100000000000;

		#5 // Time = 70
		x = 0;
		y = 0;

	end // tb
	initial begin // monitor
		$monitor("Time = %3d\n\tx = %16b   y = %16b, posit = %16b\n", $time, x, y, posit);
	end // monitor

endmodule // multiplier
