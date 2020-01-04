module decoder (
	index,
	decoded_data
	);

	// PARAMETERS
	parameter BITS = 32;
	parameter WIDTH = $clog2(BITS);

	// INPUT
	input logic [BITS-1:0] index;

	// OUTPUT
	output logic [BITS-1:0] decoded_data;

	integer ii=0;

	logic [BITS-1:0] trancated_index;

	always @*
	begin

		decoded_data = 0;

		// mask the input
		trancated_index = index & ((1 << WIDTH) -1);

		for (ii=0; ii < BITS; ii=ii+1)
		begin
			if (trancated_index == ii)
				decoded_data[BITS - 1 - ii] = 1;
		end

	end // always

endmodule
