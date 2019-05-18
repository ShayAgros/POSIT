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

		// Seed takes all data

		#5  // Time = 5
		seed =  14;
		exp  =   7;
		frac =   4;


		#5 // Time = 10
		seed = -15;
		exp  =   7;
		frac =   4;

		// Not enough room for exp

		#5 // Time = 15
		seed =  -14;
		exp  =    7;
		frac =    0;
	
		#5 // Time = 20
		seed = 	 13;
		exp  =    0;
		frac =   -1;


		#5 // Time = 25
		seed = 	 11;
		exp  =    0;
		frac =   -1;

		// Now fill the fraction

		#5 // Time = 30
		seed =    9;
		exp  =    0;
		frac =   -1;
		
		#5 // Time = 35
		seed =   -5;
		exp  =    7;
		frac =    (16'b101 << 13);
		
		#5 // Time = 40
		seed =   -5;
		exp  =    5;
		frac =   (16'b0010101 << 9);

	end // tb

	initial begin // monitor
		$monitor("Time = %3d\n\tSeed = %3d   Exp = %3b   Frac = %16b  Posit = %16b\n",
					$time, seed, exp, frac, posit);
	end // monitor

endmodule // packer_tb
