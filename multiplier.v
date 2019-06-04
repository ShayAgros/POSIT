module multiplier(
	x,
	y,
	posit
	);

				// TODO: Add flag for infinite and zero
	// PARAMETERS
	parameter BITS = 32;
	parameter ES = 3;

	// INPUT
	input wire [BITS-1:0] x;
	input wire [BITS-1:0] y; 
	
	// OUTPUT
	output wire [BITS-1:0] posit;

	// local vars
	reg [BITS-1:0] temp_x;
	reg [BITS-1:0] temp_y;
	
	wire [BITS-1:0] seed_x;
	wire [BITS-1:0] seed_y;
	
	wire [ES-1:0] exp_x;
	wire [ES-1:0] exp_y;

	wire [BITS-1:0] frac_x;
	wire [BITS-1:0] frac_y;
	
	// A single bit should be added for overflow checking
	reg signed [BITS:0] temp_seed;
	reg [ES:0] temp_exp;

	// we add the hidden bits to each fraction, so each fraction has BITS + 1 bits,
	// so the multiplier has 2*(BITS + 1) bits
	reg [2*BITS + 1:0] temp_frac;
	
	wire [BITS-1:0] temp_pos;
	wire sign_bit;

	unpacker #(BITS, ES) unpack_x ( 	
		.data 	(temp_x),
		.seed	(seed_x),
		.exp 	(exp_x),
		.frac	(frac_x)
	);

	unpacker #(BITS, ES) unpack_y (
		.data 	(temp_y),
		.seed	(seed_y),
		.exp 	(exp_y),
		.frac	(frac_y)
	);

	packer #(BITS, ES) pack (
		.seed	(temp_seed[BITS-1:0]),
		.exp	(temp_exp[ES-1:0]),
		.frac	(temp_frac[2*BITS-1:BITS]),
		.posit 	(temp_pos)
	);
	
	assign sign_bit = x[BITS - 1] ^ y[BITS - 1]; 

	always @*  // BEFORE UNPACKING
	begin
		// if x or y are negative we need to convert to 2's complement
		temp_x = (x[BITS - 1]) ? -x : x;
		temp_y = (y[BITS - 1]) ? -y : y;
	end // always

	always @* // AFTER UNPACKING
	begin
		temp_frac = 0;
		temp_exp = 0;
		temp_seed = 0;

		// CALCULATE THE FRACTION
		
		// add hidden bit and multiply
		temp_frac = {1'b1, frac_x} * {1'b1,frac_y};

		$display("frac_x is %16b   frac_y is %16b\n", frac_x, frac_y);
		// check for overflow
		if (temp_frac[2*BITS + 1] == 1)
		begin
			// send overflow to exp
			temp_exp = temp_exp + 1;

			// normalize the fraction
			temp_frac[2*BITS + 1] = 0;
			temp_frac = temp_frac >> 1;
		end // if
		
		// if fraction is 0, no point in continuing.

		// CALCULATE THE EXPONENT
		
		temp_exp = temp_exp + exp_x + exp_y;

		// check for overflow
		if (temp_exp[BITS] == 1)
		begin
			temp_seed = temp_seed + 1;
			temp_exp[BITS] = 0;
		end // if
		
		// CALCULATE THE SEED
		// TODO: how to handle infinite and zero flag?

		temp_seed = temp_seed + seed_x + seed_y;

		$display("\ntemp_seed is %d   temp_exp is %3b   temp_frac is %16b\n", temp_seed, temp_exp, temp_frac);		
	end // always

	assign posit = (sign_bit) ? -temp_pos : temp_pos;

endmodule // multiplier
