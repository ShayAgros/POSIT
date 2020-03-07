module adder (
	x,
	y,
	posit
	);

	// PARAMETERS
	parameter BITS = 32;
	parameter ES = 3;

	// INPUT
	input logic signed [BITS-1:0] x;
	input logic signed [BITS-1:0] y;

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

	logic [BITS-1:0] final_posit;

	// Exponent vars
	logic signed [BITS-1:0] exp_sum_x;
	logic signed [BITS-1:0] exp_sum_y;
	logic signed [BITS-1:0] max_exp_sum;
	logic [BITS:0] shift_value;
	logic signed [BITS-1:0] shift_sum;
	logic [BITS-1:0] abs_shift_sum;
	logic shifted;
	logic signed [BITS+4:0] leading_zero_count; // Way more than actually needed

	// Fraction vars
	logic [BITS-1:0] frac_x_normal;
	logic [BITS-1:0] frac_y_normal;
	logic signed [BITS-1+5:0] frac_sum;
	logic [BITS-1+5:0] frac_normal;
	logic [BITS-1+5:0] temp_frac_x;
	logic [BITS-1+5:0] temp_frac_y;
	logic signed [BITS-1+5:0] big_fraction;
	logic signed [BITS-1+5:0] small_fraction;
	logic signed [BITS-1+5:0] signed_temp_frac_x;
	logic signed [BITS-1+5:0] signed_temp_frac_y;
	logic [BITS-1+5:0] temp_frac_normal;

	// Rounding vars
	logic guard;
	logic sticky;
	logic round;
	logic lsb;

	// FLAGS
	logic flag_infinity;
	logic flag_zero;	
	logic flag_zero_x;
	logic flag_zero_y;
	logic flag_overflow_frac;
	logic flag_overflow_exp;
	logic flag_overflow_seed;
	
	// Final packer vars
	logic final_sign;
	logic [BITS-1:0] temp_frac;
	logic [ES-1:0]	 temp_exp;
	logic [BITS-1:0] temp_seed;
	logic [BITS-1:0] temp_posit;

	// SUB-MODULES
	unpacker #(BITS, ES) unpack_x (
		.data	(positive_x),
		.seed	(seed_x),
		.exp	(exp_x),
		.frac	(frac_x)
	);

	unpacker #(BITS, ES) unpack_y (
		.data	(positive_y),
		.seed	(seed_y),
		.exp	(exp_y),
		.frac	(frac_y)
	);

	packer #(BITS, ES) pack (
		.frac	(temp_frac),
		.exp	(temp_exp),
		.seed	(temp_seed),
		.zero 	(flag_zero),
		.posit	(temp_posit)
	);

	seed_lookup #(BITS + 5, ES) clz ( // Count leading zeros
		.data 		 (temp_frac_normal),
		.shifted_data	 (    ), // Not actually needed
		.seed 		 (leading_zero_count)
	);

	always @* // BEFORE UNPACKING
	begin
		flag_zero = 0;
		flag_zero_x = (x == 0);
		flag_zero_y = (y == 0);
		flag_infinity = 0;
		
		// If x or y are negative we need to convert them to 2's complement
		positive_x = (x[BITS - 1]) ? -x : x;
		positive_y = (y[BITS - 1]) ? -y : y;

		// Check for infinite
		if (x[BITS-2:0] == 0)
		begin
			flag_infinity = flag_infinity | x[BITS - 1];
		end // if
		if (y[BITS-2:0] == 0)
		begin
			flag_infinity = flag_infinity | y[BITS - 1];
		end // if

		// Check for zero
		flag_zero = (x == -y);
	end // always

	always @* // AFTER UNPACKING
	begin
		// Find overall exp sum and max exp sum
		exp_sum_x = int'(seed_x << ES) + int'({1'b0,exp_x});
		exp_sum_y = int'(seed_y << ES) + int'({1'b0,exp_y});

		// Change the sign of the fractions if need be
		// We add 2 MSB bits for the hidden bit and sign, and 3 LSB bits for rounding purposes
		temp_frac_x = {2'b01, frac_x, 3'b0};		
		temp_frac_y = {2'b01, frac_y, 3'b0};

		// If different signs, adjust the fractions.
		//$display("x_bit = %b\t y_bit = %b", x[BITS-1], y[BITS-1]);
		if (x[BITS-1] ^ y[BITS-1])
		begin
			if (x[BITS-1] == 1)
			begin
				signed_temp_frac_x = -1 * temp_frac_x;
				signed_temp_frac_y = temp_frac_y;
			end
			else
			begin
				signed_temp_frac_x = temp_frac_x;
				signed_temp_frac_y = -1 * temp_frac_y;
			end
		end
		else
		begin 
			signed_temp_frac_x = temp_frac_x;
			signed_temp_frac_y = temp_frac_y;
		end // if

		// We need to find out which number is bigger
		// The final posit's sign will be the same as the larger of the two numbers.
		//$display("exp_sum_x = %d\t exp_sum_y = %d", int'(exp_sum_x), int'(exp_sum_y));
		if ((int'(exp_sum_x) > int'(exp_sum_y)) || ((exp_sum_x == exp_sum_y) && (frac_x > frac_y)))
		begin
			shift_value = int'(exp_sum_x) - int'(exp_sum_y);

			big_fraction = signed_temp_frac_x;
			small_fraction = signed_temp_frac_y;

			max_exp_sum = exp_sum_x;
			final_sign = x[BITS-1];
		end
		else
		begin
			shift_value = exp_sum_y - exp_sum_x;

			big_fraction = signed_temp_frac_y;
			small_fraction = signed_temp_frac_x;

			max_exp_sum = exp_sum_y;
			final_sign = y[BITS-1];
		end // if

  		//$display("seed_x = %16b\t seed_y = %16b", seed_x, seed_y);
		///$display("exp_x = %3b\t exp_y = %3b", exp_x, exp_y);
		//$display("exp_sum_x = %16b\t exp_sum_y = %16b\t max_exp_sum = %16b",exp_sum_x, exp_sum_y, max_exp_sum);
		//$display("temp_frac_x = %21b\t temp_frac_y = %21b", temp_frac_x, temp_frac_y);	
		//$display("signed_temp_frac_x = %21b\t signed_temp_frac_y = %21b", signed_temp_frac_x, signed_temp_frac_y);	
		//$display("big_fraction = %b\t small_fraction = %b", big_fraction, small_fraction);
		//$display("shift_value = %b", shift_value);
		frac_sum = big_fraction + (small_fraction >>> shift_value);

		//$display("frac_sum = %16b", frac_sum);

		// Now we need to normalize the fraction
		shifted = 0;
		// No overflow, positive result
		if (frac_sum[BITS-1+5] == 0)
		begin
			temp_frac_normal = frac_sum;
		end
		// If both are negative/positive, we get overflow, and fix it
		else if (!(x[BITS - 1] ^ y[BITS - 1]))
		begin
			temp_frac_normal = frac_sum >> 1;
			shifted = 1;
		end
		else
		// If one is positive and the other negative, then overflow is impossible
		// So the addition just gave us a negative result.
		begin
			temp_frac_normal = -frac_sum;
		end
		// Shift by leading zeros
		if (leading_zero_count < 0) // 0 leading seed is counted as a negative
		begin
			frac_normal = temp_frac_normal << (leading_zero_count * -1);
		end
		else
		begin
			frac_normal = temp_frac_normal;
		end // if

		shift_sum = max_exp_sum + shifted;
		if ((leading_zero_count) < 0)
		begin
			shift_sum += leading_zero_count;
		end // if

		abs_shift_sum = (shift_sum[BITS-1]) ? -shift_sum : shift_sum;
		
		//$display("leading_zero_count = %d", leading_zero_count);
		//$display("shifted = %b", shifted);
		//$display("shift_sum = %16b\t abs_shift_sum = %16b", shift_sum, abs_shift_sum);

		if (shift_sum[BITS-1] == 0)
		begin
			temp_exp = abs_shift_sum[ES-1:0];
			temp_seed = abs_shift_sum >> ES;
		end
		else
		begin
			temp_exp = shift_sum[ES-1:0];
			temp_seed = shift_sum >>> ES;
		end // if
		//$display("temp_frac_normal = %16b", temp_frac_normal);
		//$display("frac_normal = %16b", frac_normal);
		lsb    = frac_normal[3];
		guard  = frac_normal[2];
		round  = frac_normal[1];
		sticky = frac_normal[0];
		 // remove two upper bits we added before and the rounding bits after the LSB.
		temp_frac = frac_normal[BITS-1+5-2:3];
		//$display("temp_seed = %16b\t temp_exp = %3b", temp_seed, temp_exp);
		//$display("temp_frac = %16b", temp_frac);
		
	end // always

	always @* // AFTER PACKING
		// Now we check zero/infinity flags
	begin
		final_posit = temp_posit;
		// Rounding to nearest even
		if (((lsb & guard) | (guard & round)) | (guard & round | sticky))
			final_posit += 1;

		//$display("final_posit = %16b", final_posit);
		if (flag_infinity == 1 || flag_overflow_seed == 1)
			final_posit = {1'b1, (BITS-1)'('b0)};
		if (flag_zero_x == 1)
			final_posit = y;
		else if (flag_zero_y == 1)
			final_posit = x;
		//$display("final_posit = %16b", final_posit);
		if (final_sign == 1)
			final_posit *= -1;
	end // always

	assign posit = final_posit;

endmodule // adder
