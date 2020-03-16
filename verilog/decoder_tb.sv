`timescale 1 ns / 1 ps
module decoder_tb;
	// INPUT
	logic [15:0] data;

	// OUTPUT
	wire [15:0] decoded_data;

	integer ii=0;

	decoder #(16) dut (
		.index(data),
		.decoded_data(decoded_data)
	);

	initial begin

		data = 16'd0;

		for (ii=0; ii < 16; ii=ii+1)
		begin
			#5 data = ii;
		end
	end

	initial begin // monitor
		$monitor("Time = %3d\n\tData = %d   decoded_data= %16b\n",
							$time, data, decoded_data);
	end // monitor
endmodule
