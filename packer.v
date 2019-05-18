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
	input wire [BITS-1:0] frac;
	input wire [ES-1:0] exp;
	input wire signed [BITS-1:0] seed;

	// OUTPUT
	output wire [BITS-1:0] posit;

	// LOCAL VARS
	reg [BITS-1:0] temp_pos;	

	integer cur_bit;

	// vars for the seed
	reg sign_bit;
	reg [BITS-1:0] temp_seed;

	// vars for the exp
	reg [ES-1:0] exp_counter;

	// vars for the fraction
	reg [BITS-1:0] frac_counter;

	always @*
	begin

		// Although not that relevant, for consistency, we will use 0 for sign bit of posit
		temp_pos = 0;
		temp_pos[BITS - 1] = 0;

		// BUILD THE SEED
		
		// start at the second bit
		cur_bit = BITS - 2;
		
		if (seed >= 0)
		begin
			sign_bit = 1;
			temp_seed = seed + 1;
		end // if
		else
		begin
			temp_seed = -seed;
			sign_bit = 0;
		end // else

		while(temp_seed > 0)
		begin
			temp_pos[cur_bit] = sign_bit;
			cur_bit = cur_bit - 1;
			temp_seed = temp_seed - 1;
		end // while

		if (cur_bit >= 0)
		begin
			temp_pos[cur_bit] = !sign_bit;
			cur_bit = cur_bit - 1;
		end // if
		

		// BUILD THE EXP
		
		exp_counter = ES;
		while (exp_counter > 0 && cur_bit >= 0)
		begin
			temp_pos[cur_bit] = exp[exp_counter - 1];
			cur_bit = cur_bit - 1;
			exp_counter = exp_counter - 1;
		end // while

		// BUILD THE FRACTION

		frac_counter = BITS - 1;
		while (frac_counter >= 0 && cur_bit >= 0)
		begin
			temp_pos[cur_bit] = frac[frac_counter];
			cur_bit = cur_bit - 1;
			frac_counter = frac_counter - 1;
		end // while

	end // always
	
	assign posit = temp_pos;
endmodule // PACKER
