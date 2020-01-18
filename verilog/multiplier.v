module multiplier (
	x,
	y,
	posit
	);

	// PARAMETERS
	parameter BITS = 32;
	parameter ES = 3;

	// INPUT
	input logic [BITS-1:0] x;
	input logic [BITS-1:0] y;

	// OUTPUT
	output wire [BITS-1:0] posit;

	// LOCAL VARS
	logic [BITS-1:0] positive_x;
	logic [BITS-1:0] positive_y;

	wire [BITS-1:0] seed_x;
	wire [BITS-1:0] seed_y;

	wire [ES-1:0] exp_x;
	wire [ES-1:0] exp_y;

	wire [BITS-1:0] frac_x;
	wire [BITS-1:0] frac_y;

	// A single bit should be added for overflow checking
	logic signed [BITS:0] temp_seed;
	logic [ES:0] temp_exp;

	// Flags we use
	logic flag_infinity;
	logic flag_zero;
	logic flag_overflow_frac;
	logic flag_overflow_exp;
	logic flag_overflow_seed;


	// We add the hidden bits to each fraction, so each fraction has BITS + 1 bits,
	// so the fraction needs 2*(BITS + 1) bits
	logic [2*BITS + 1:0] temp_frac;
	logic [BITS-1:0] final_posit;

	wire [BITS-1:0] temp_pos;
	logic sign_bit;

	// SUB-MODULES
	unpacker #(BITS, ES) unpack_x (
		.data 	(positive_x),
		.seed	(seed_x),
		.exp 	(exp_x),
		.frac	(frac_x)
	);

	unpacker #(BITS, ES) unpack_y (
		.data 	(positive_y),
		.seed	(seed_y),
		.exp 	(exp_y),
		.frac	(frac_y)
	);

	packer #(BITS, ES) pack (
		.seed	(temp_seed[BITS-1:0]),
		.exp	(temp_exp[ES-1:0]),
		.frac	(temp_frac[2*BITS-2:BITS-1]),
		.posit 	(temp_pos)
	);


	always @* // BEFORE UNPACKING
	begin
		flag_zero = 0;
		flag_infinity = 0;

		sign_bit = x[BITS - 1] ^ y[BITS - 1];

		// if x or y are negative we need to convert to 2's complement
		positive_x = (x[BITS - 1]) ? -x : x;
		positive_y = (y[BITS - 1]) ? -y : y;

		//$display("positive_x is %16b   positive_y is %16b\n", positive_x, positive_y);

		// Find infinite and zero flags
		if (x[BITS-2:0] == 0)
		begin
			flag_zero = flag_zero | ~x[BITS-1];
			flag_infinity = flag_infinity | x[BITS-1];
		end
		if (y[BITS-2:0] == 0)
		begin
			flag_zero = flag_zero | ~y[BITS-1];
			flag_infinity = flag_infinity | y[BITS-1];
		end

	end // always

	always @* // AFTER UNPACKING
	begin
		flag_overflow_frac = 0;
		flag_overflow_exp = 0;
		flag_overflow_seed = 0;

		// CALCULATE THE FRACTION

		// add hidden bit and multiply
		temp_frac = {1'b1, frac_x} * {1'b1,frac_y};


		//$display("frac_x is %16b   frac_y is %16b   temp_frac is %16b\n", frac_x, frac_y, temp_frac);


		// If need be, shift the fraction to fix the overflow
		flag_overflow_frac = temp_frac[2*BITS + 1];
		temp_frac[2*BITS + 1] = 0;

		// CALCULATE THE EXPONENT

		temp_exp = exp_x + exp_y + flag_overflow_frac;

		// $display("exp_x is %3b   exp_y is %3b   temp_exp is %4b\n", exp_x, exp_y, temp_exp);

		// Check for overflow
		flag_overflow_exp = temp_exp[ES];
		temp_exp[ES] = 0;

		// CALCULATE THE SEED

		temp_seed = seed_x + seed_y + flag_overflow_exp;
		flag_overflow_seed = temp_seed[ES];
		//$display("seed_x is %3b   seed_y is %3b   temp_seed is %4b\n", seed_x, seed_y, temp_seed);
		
		//$display("\ntemp_seed is %d   temp_exp is %3b   temp_frac is %16b\n", temp_seed, temp_exp, temp_frac);
		
	end // always

	always @* // AFTER PACKING
		// Now we check zero/infinity flags
	begin
		if (flag_zero == 1 || flag_infinity == 1 || flag_overflow_seed == 1)
		begin
			final_posit = 0;
			if (flag_zero != 1)
				final_posit[BITS-1] = 1;
		end // if
		else
			final_posit = (sign_bit) ? -temp_pos : temp_pos;

		//$display("final posit is %16b\n", final_posit);

	end // always

	assign posit = final_posit;


endmodule // multiplier
