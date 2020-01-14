
module packer(
	frac,
	exp,
	seed,
	posit
	);

	// PARAMETERS
	parameter BITS = 32;
	parameter ES = 3;

	// INPUT
	input logic [BITS-1:0] frac;
	input logic [ES-1:0] exp;
	input logic signed [BITS-1:0] seed;

	// OUTPUT
	output wire [BITS-1:0] posit;

	// LOCAL VARS
	wire [BITS-1:0] temp_seed_seq;
	wire [BITS-1:0] shifted_exp_frac;
	wire [BITS-1:0] reverse_shifted_exp_frac;
	wire [ES-1:0] reversed_exp;
	wire [BITS-1:0] reversed_frac;

	logic [BITS-1:0] absolute_seed;
	logic [BITS-1:0] seed_seq;
	logic [BITS-1:0] seed_sign_bit;
	logic [BITS-1:0] temp_posit;

	integer i;
	integer xor_result;
	integer previous_xor_result;

	decoder #(BITS) seed_decoder (
		.index(absolute_seed),
		.decoded_data(temp_seed_seq)
	);

	/* Shift the exponent and fraction bits so that they come after
	* seed bits */
	left_shifter #(BITS) exp_shifter (
		// insert the data "backwards"
		.data({reversed_frac[BITS-1:ES], reversed_exp}),
		.bitmask(temp_seed_seq),
		.shifted_data(reverse_shifted_exp_frac[BITS-1:0])
	);

	// reverse the bit order of the exponent
	genvar j;
	for (j=0; j<ES; j=j+1)
		assign reversed_exp[j] = exp[ES-1 - j];

	// reverse the bit order of the fraction
	for (j=0; j<BITS; j=j+1)
		assign reversed_frac[j] = frac[BITS-1-j];

	// reverse order of the shifted exp_frac sequence
	for (j=0; j<BITS; j=j+1)
		assign shifted_exp_frac[j] = reverse_shifted_exp_frac[BITS - 1 - j];




	always @(seed) /* Get absolute value for seed */
	begin
		seed_sign_bit = seed[BITS -1];
		// negate the seed if it's negative
		for (i=BITS-1; i >= 0; i--)
			absolute_seed[i] = seed[i] ^ seed_sign_bit;
		absolute_seed = absolute_seed + seed_sign_bit;
	end

	always @(shifted_exp_frac) /* Change seed sequence to running 1's if seed > 0*/
	begin
		/* switch sequence digits (if seed > 0) */
		// !temp_seed_seq[BITS-1] is needed to avoid setting the
		// MSB if seed = 0
		seed_seq[BITS - 1] = !seed_sign_bit & !temp_seed_seq[BITS-1];
		previous_xor_result = !temp_seed_seq[BITS-1];
		for (i=BITS-1 - 1; i >= 0; i--)
		begin
			xor_result = !seed_sign_bit ^ temp_seed_seq[i];
			seed_seq[i] = xor_result & previous_xor_result;
			// if the sequence is formed by leadeing zeros, this would
			// leave the flipped bit 1
			seed_seq[i] = seed_seq[i] | (temp_seed_seq[i] & seed_sign_bit);
			previous_xor_result = xor_result & previous_xor_result;
		end

		temp_posit = shifted_exp_frac | seed_seq;
		if (seed_sign_bit == 0)
			// add '0' to seed sequence if it's negative
			temp_posit[BITS-1:0] = {1'b1, temp_posit[BITS-1:1]};
		else
			temp_posit = temp_posit;

		//$display("decoded seed = %32b, reversed_exp_frac = %32b , input_exp_frac = %32b", temp_seed_seq, reverse_shifted_exp_frac, {reversed_frac[BITS-1:ES], reversed_exp} );
	end // always (change seed sequence)

	// add zero sign bit
	assign posit = {1'b0, temp_posit[BITS-1:1]};
	//assign posit = temp_posit;
endmodule // PACKER
