module seed_lookup(
	data,
	shifted_data,
	seed, 
	);

	// PARAMETERS
	parameter BITS = 32;

	//INPUT
	input logic [BITS-1:0] data;

	// OUTPUT
	output logic signed [BITS-1:0] seed;
	output wire [BITS - 1:0] shifted_data;

	integer xor_result;
	integer include_bit_in_sum;
	integer previous_xor_result;
	integer ii=0;

	// Vars for the seed
	logic seed_bit;
	logic signed [BITS-1:0] leading_zero_vector;
	logic signed [BITS-1:0] temp_seed;
	logic signed [BITS-1:0] negative_seed;

	left_shifter #(BITS) ls (
		.data	(data),
		.bitmask (leading_zero_vector),
		.shifted_data (shifted_data)
	);

	always @*
	begin

		seed_bit = data[BITS-2];

		// starting at the third bit from the left
		leading_zero_vector = 0;

		// set all bits to be zero, beside the first flipped
		leading_zero_vector[BITS-3] = seed_bit ^ data[BITS-3];
		previous_xor_result = !leading_zero_vector[BITS-3];
		for (ii=4; ii < BITS; ii=ii+1)
		begin
			xor_result = seed_bit ^ data[BITS - ii];
			leading_zero_vector[BITS - ii] = xor_result & previous_xor_result;
			previous_xor_result = !xor_result & previous_xor_result;
		end

		// Count number of zero bits until first flipped
		temp_seed = 0;

		/*
		* we need to check whether all bits are zero, if so
		* we don't want to increase 'temp_seed' which counts
		* how many bits are zero before the first 1
		*/
		include_bit_in_sum = 0;
		for (ii=2; ii < BITS; ii=ii+1)
		begin
			include_bit_in_sum = include_bit_in_sum | leading_zero_vector[BITS - ii];
		end

		/* add the value of include_bit_in_sum until reaching first flipped */

		/*
		 * if 'bit 30' == 1, the absolute value of the resulting
		 * number is smaller by 1 than the resulting number in case
		 * 'bit 30' == 0. We avoid adding the first bit for 'bit 30' == 1
		 * to avoid substruction
		 */
		temp_seed = temp_seed + (!seed_bit & include_bit_in_sum);
		include_bit_in_sum = include_bit_in_sum & !leading_zero_vector[BITS - 3];
		for (ii=4; ii < BITS; ii=ii+1)
		begin
			temp_seed = temp_seed + include_bit_in_sum;
			include_bit_in_sum = include_bit_in_sum & !leading_zero_vector[BITS - ii];
		end

		negative_seed = -temp_seed;

		if (seed_bit == 0)
			seed = negative_seed;
		else
			seed = temp_seed;

		//shifted_data = leading_zero_vector;
	end // always

endmodule
