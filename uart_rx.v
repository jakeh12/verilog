module uart_rx (
	input clk,
	input rx,
	output reg [7:0] rx_data,
	output reg rx_data_valid
);

parameter integer BAUD_RATE = 9600;
parameter integer CLK_FREQ_HZ = 12000000;
localparam integer BAUD_PERIOD_CYCLES = CLK_FREQ_HZ / BAUD_RATE;

reg [$clog2(BAUD_PERIOD_CYCLES):0] cycle_count = 0;
reg [3:0] bit_count = 0;
reg receiving = 0;

initial begin
	rx_data = 0;
	rx_data_valid = 0;
end

always @(posedge clk) begin
	if (!receiving) begin
		// look for start bit (rx transition to low)
		if (!rx) begin
			// set cycle count to reach the center of the bit
			cycle_count <= BAUD_PERIOD_CYCLES / 2;
			bit_count <= 0;
			receiving <= 1;
			rx_data_valid <= 0;
		end
	end else begin
		if (cycle_count == BAUD_PERIOD_CYCLES) begin
			// reached center of the bit
			cycle_count <= 0;
			bit_count <= bit_count + 1;
			if (bit_count == 9) begin
				rx_data_valid <= 1;
				receiving <= 0;
			end else begin
				// shift bit into the data buffer
				rx_data <= {rx, rx_data[7:1]};
			end
		end else begin
			cycle_count <= cycle_count + 1;
		end
	end
end

endmodule

