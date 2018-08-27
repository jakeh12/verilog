module top (
	input clk,
	input rx,
	output reg led
);

uart_rx uut (
	.clk (clk),
	.rx (rx),
	.rx_data_valid (led)
);

endmodule
