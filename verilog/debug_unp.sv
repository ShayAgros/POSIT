module unpacker(
	data,
	seed, 
	exp,
	frac
	);
	
	// PARAMETERS
	parameter BITS = 32;
	parameter ES = 3;
	
	//INPUT
	
	input wire [BITS-1:0] data;
	
	// OUTPUT
	output reg signed [BITS-1:0] seed;
	output wire [ES-1:0] exp;
	output wire [BITS-1:0] frac;
	
	integer cur_bit;
	integer counter;

	// Vars for the seed
	reg seed_bit;
	reg signed [BITS-1:0] temp_seed;
	
	// Vars for the exp
	reg [ES-1:0] temp_exp;

	// Vars for the frac
	reg [BITS-1:0] temp_frac;
	
	always @*
	begin
		// FIND THE SEED
		
		seed_bit = data[BITS-2];
		// Starting at the third bit from the left
		cur_bit = BITS - 3;
		temp_seed = 0;
		
		// start counting identical bits
		while (data[cur_bit] != !seed_bit && cur_bit >= 0)
		begin
 			$display("data is :%b\t cur_bit is %3d\t bit_val is %b\ttemp_seed is %3d\n",
						 data, cur_bit, data[cur_bit], temp_seed);
			temp_seed = temp_seed + 1;
			cur_bit = cur_bit - 1;
		end // while
		cur_bit = cur_bit - 1;
		
		// Seed has a -1 bias when counting '1' bits
		temp_seed = seed_bit ? temp_seed : -(temp_seed+1);
		
		seed = temp_seed;
		$display("Final seed is %d\n", seed);

		// FIND THE EXP
		
		// We can have as many as ES exp bits, as long as we dont reach
		// the end of the data.
		// In case we reach the end, we will pad the remaining bits with 0
		temp_exp = {ES{1'b0}};
		$display("Initial exp is %b\n", temp_exp);
		counter = 0;
		while (counter != ES && cur_bit >= 0)
		begin
			$display("temp_exp: %b\t, cur_bit is %2d\t, bit_val is %b\t counter is %d\n",
					 temp_exp, cur_bit, data[cur_bit], counter);
			temp_exp = (temp_exp << 1) + data[cur_bit];
			cur_bit = cur_bit - 1;
			counter = counter + 1;
		end // while
		
		// check whether we reached the end of data or ES
		if (counter != ES)
		begin
			temp_exp = temp_exp << (ES - counter);
		end // if
		$display("Final exp is %b\n", temp_exp);
		
		// FIND THE FRACTION
		temp_frac = {BITS{1'b0}};
		$display("Initial frac is %b\n", temp_frac);
		counter = 0;
		
		while (cur_bit >= 0)
		begin
			$display("temp_frac is %b\n", temp_frac);
			temp_frac = (temp_frac << 1) + data[cur_bit];
			cur_bit = cur_bit - 1;
			counter = counter + 1;
		end // while
		// push fraction to the MSB
		temp_frac = temp_frac << (BITS - counter);
		$display("Final frac is %b\n", temp_frac);
		
	end // always
		
	assign exp = temp_exp;
	assign frac = temp_frac;
	
endmodule
