`timescale 1 ns / 1 ps
module left_shifter_tb;

	// INPUT
	reg [15:0] data;
	reg [15:0] bitmask;

	wire [15:0] shifted_data;

	left_shifter #(16) dut (
		.data	(data),
		.bitmask (bitmask),
		.shifted_data (shifted_data)
	);


	initial begin // Vars
		data = 16'd0;
		bitmask = 16'd0;

		// Tests only check positive posits, because the dut
		// does not take into account the sign bit
		
		// Basic sanity test
		#5 data = 16'b1111111111111111; // Time = 5
		bitmask = 16'b1000000000000000;

		#5 data = 16'b1111111111111111; // Time = 10
		bitmask = 16'b0100000000000000;

		#5 data = 16'b1111111111111111; // Time = 15
		bitmask = 16'b0010000000000000;
		
		// Seed takes all data
		#5 data = 16'b1111111111111111; // Time = 20
		bitmask = 16'b0001000000000000;
		#5 data = 16'b1111111111111111; // Time = 25
		bitmask = 16'b0000100000000000;
		
		// ES is not full
		#5 data = 16'b1111111111111111; // Time = 30
		bitmask = 16'b0000010000000000;
		#5 data = 16'b1111111111111111; // Time = 35
		bitmask = 16'b0000001000000000;
		
		// Es is full, now we can have fraction
		#5 data = 16'b1111111111111111; // Time = 40
		bitmask = 16'b0000000100000000;
		#5 data = 16'b1111111111111111; // Time = 45
		bitmask = 16'b0000000010000000;

		#5 data = 16'b1111111111111111; // Time = 50
		bitmask = 16'b0000000000000010;

		#5 data = 16'b1111111111111111; // Time = 55
		bitmask = 16'b0000000000000001;

	end // Vars
	
	initial begin // monitor
		$monitor("Time = %3d\n\tData = %16b   bitmask = %16b, shifted_data = %16b\n",
							$time, data, bitmask, shifted_data);
	end // monitor

endmodule
