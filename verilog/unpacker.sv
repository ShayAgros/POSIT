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
	input logic [BITS-1:0] data;

	// OUTPUT
	output wire signed [BITS-1:0] seed;
	output wire [ES-1:0] exp;
	output wire [BITS-1:0] frac;

	wire [BITS - 1:0] shifted_data;

	// FIND THE SEED
	seed_lookup #(BITS) dut (
		.data	(data),
		.shifted_data (shifted_data),
		.seed	(seed)
	);

	assign exp = $signed(shifted_data[BITS -1 : BITS - ES]);
	assign frac[BITS-1 : ES] = $signed(shifted_data[BITS - ES - 1 : 0]);
	assign frac[ES-1:0] = 0;

endmodule
