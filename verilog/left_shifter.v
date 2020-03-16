module left_shifter(
	data,
	bitmask,
	shifted_data 
	);

	// PARAMETERS
	parameter BITS = 32;

	//INPUT
	input logic [BITS-1:0] data;
	input logic [BITS-1:0] bitmask;

	// OUTPUT
	output logic [BITS-1:0] shifted_data;

	logic [BITS-1:0] temp_shifted;

	integer ii;
	integer jj;

	always @*
	begin

	// Zero the output array
	temp_shifted = 0;

	for ( ii = BITS - 1; ii > 0 ; ii = ii - 1 )
	begin
		for (jj = ii - 1; jj >= 0 ; jj = jj -1)
		begin
		temp_shifted[ii] = temp_shifted[ii] | bitmask[jj + BITS - ii] & data[jj];
		end
	end

	shifted_data = temp_shifted;
	end // always

endmodule
