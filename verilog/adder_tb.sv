`timescale 1 ns / 1 ps
module adder_tb;

	// INPUT
	reg [15:0] x;
	reg [15:0] y;

	// OUTPUT
	wire [15:0] posit;

	adder #(16,3) dut (
		.x (x),
		.y (y),
		.posit (posit)
	);

	initial begin //tb

		// MOST TEST WILL BE SIMMETRYCAL TO SHOW COMMUTATIVITY

		// Infinity
		// Time = 0
		x = 16'b1000000000000000;
		y = 16'b1001110001001000;

		#5 // Time = 5
		x = 16'b1100001100011100;
		y = 16'b1000000000000000;

		#5 // Time = 10
		x = 16'b1000000000000000;
		y = 16'b1000000000000000;

		// Addition with 0 should do nothing

		#5 // Time = 15
		x = 16'b0011001100000111;
		y = 16'b0000000000000000;

		#5 // Time = 20
		x = 16'b0000000000000000;
		y = 16'b0011001100000111;
		
		// Addition with opposite

		#5 // Time = 25
		x = 16'b1100110011111001;
		y = 16'b0011001100000111;

		#5 // Time = 30
		x = 16'b0011001100000111;
		y = 16'b1100110011111001;
	
		// Some basic addition tests

		#5 // Time = 35
		// 1 + 1 = 2
		x = 16'b0100000000000000;	
		y = 16'b0100000000000000;

		#5 // Time = 40
		// 4 + 16 = 20
		x = 16'b0100100000000000;	
		y = 16'b0101000000000000;

		#5 // Time = 45
		// 16 + 4 = 20
		x = 16'b0101000000000000;	
		y = 16'b0100100000000000;

		#5 // Time = 50
		// First number should be unchanged, as second number is too small
		x = 16'b0111111110100000;	
		y = 16'b0100000000001000;

		#5 // Time = 55
		// Second number should be unchanged, as first number is too small
		x = 16'b0000000010000000;	
		y = 16'b0100100000000000;

		// Time for negative addition. HERE WE GO

		#5 // Time = 60
		// 2 - 1 = 1
		x = 16'b0100010000000000;	
		y = 16'b1100000000000000;

		#5 // Time = 65
		// -1 + 2 = 1
		x = 16'b1100000000000000;	
		y = 16'b0100010000000000;

		#5 // Time = 70
		// Big positive number, with small negative number
		x = 16'b0111111100000000;	
		y = 16'b1011111010000000;
		
		#5 // Time = 75
		x = 16'b1011111010000000;	
		y = 16'b0111111100000000;

		// Negative result, lord help me
		
		#5 // Time = 80

		// -1 + -1
		x = 16'b1100000000000000;	
		y = 16'b1100000000000000;

		#5 // Time = 85
		// -4 + -8 = -12
		x = 16'b1011100000000000;	
		y = 16'b1011010000000000;

		#5 // Time = 90
		// -8 + -4 = -12
		x = 16'b1011010000000000;
		y = 16'b1011100000000000;	

		#5 // Time = 95
		// -8 + 4 = -4
		x = 16'b1011010000000000;
		y = 16'b0100100000000000;	
		
		#5 // Time = 100
		// 4 - 8 = -4
		x = 16'b0100100000000000;
		y = 16'b1011010000000000;	

		#5 // Time = 105
		x = 16'b0111111001110110;
		y = 16'b0111111001001101;

		#5 // Time = 110
		x = 16'b1100000000000000;
		y = 16'b0100000000000100;

	end

	initial begin // monitor
		$monitor("Time = %3d\n\tx = %16b	y = %16b, posit = %16b\n", $time, x, y, posit);
	end

endmodule // adder_tb
