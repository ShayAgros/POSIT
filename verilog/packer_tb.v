`timescale 1 ns / 1 ps
module packer_tb;
		
	// INPUT
	reg signed [15:0] seed;
	reg [2:0] exp;
	reg [15:0] frac;

	// OUTPUT
	wire [15:0] posit;

	packer #(16,3) dut (
		.posit 	(posit),
		.seed 	(seed),
		.exp 	(exp),
		.frac 	(frac)
	);

	/*
	initial begin
		$dumpfile("pkr_test.vcd");
		$dumpvars(0, packer);
	end // dump
	*/

	initial begin // tb		
		
		seed =   0;
		exp  =   0;
		frac =   0;

		// Basic sanity test

		#5 // Time = 5
		seed = 2;
		exp  = 3'b011;
		frac = 16'b1011010100000000;
		
		#5 // Time = 10
		seed = 0;
		exp  = 3'b101;
		frac = 16'b1011000101000000;

		#5 // Time = 15
		seed = -2;
		exp  = 3'b001;
		frac = 16'b0111101010000000;

		// Seed takes all the data

		#5 // Time = 20
		seed = 14;
		exp  = 3'b000;
		frac = 16'b0000000000000000;

		#5 // Time = 25
		seed = 0;
		exp  = 3'b000;
		frac = 16'b0000000000000000;

		//ES is not full

		#5 // Time = 30
		seed = 11;
		exp  = 3'b110;
		frac = 16'b0000000000000000;

		#5 // Time = 35
		seed = -13;
		exp  = 3'b100;
		frac = 16'b0000000000000000;

		// ES is full, now we can have fraction

		#5 // Time = 40
		seed = 4;
		exp  = 111;
		frac = 16'b0000010000000000;

		#5 // Time = 45
		seed = 1;
		exp  = 111;
		frac = 16'b1111001110000000;
	end // tb

	initial begin // monitor
		$monitor("Time = %3d\n\tSeed = %3d   Exp = %3b   Frac = %16b  Posit = %16b\n",
					$time, seed, exp, frac, posit);
	end // monitor

endmodule // packer_tb
