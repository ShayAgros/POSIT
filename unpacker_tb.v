`timescale 1 ns / 1 ps
module unpacker_tb;
	// INPUT
	reg [15:0] data;
	// OUTPUT
	wire signed [15:0] seed;
	wire [2:0] exp;
	wire [15:0] frac;
	
	unpacker #(16,3) dut (
		.data	(data),
		.seed	(seed),
		.exp	(exp),
		.frac	(frac)
	);
	
	/*
	initial begin
		$dumpfile("unp_test.vcd");
		$dumpvars(0, unpacker);
	end // Dump
	*/
	
	initial begin // Vars
		data = 16'd0;

		// Tests only check positive posits, because the dut
		// does not take into account the sign bit
		
		// Basic sanity test
		#5 data = 16'b0111001110110101; // Time = 5
		#5 data = 16'b0101011011000101; // Time = 10
		#5 data = 16'b0001001011110101; // Time = 15
		
		// Seed takes all data
		#5 data = 16'b0111111111111111; // Time = 20
		#5 data = 16'b0000000000000000; // Time = 25
		
		// ES is not full
		#5 data = 16'b0111111111111011; // Time = 30
		#5 data = 16'b0000000000000011; // Time = 35
		
		// Es is full, now we can have fraction
		#5 data = 16'b0111110111000001; // Time = 40
		#5 data = 16'b0110111111100111; // Time = 45
	end // Vars
	
	initial begin // monitor
		$monitor("Time = %3d\n\tData = %16b   Seed = %3d   Exp = %3b   Frac = %16b\n",
							$time, data, seed, exp, frac);
	end // monitor
	
endmodule
