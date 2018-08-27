module uart_rx_tb;

localparam integer BAUD_RATE = 9600;
localparam integer CLK_FREQ_HZ = 12000000;
localparam integer BAUD_PERIOD_CYCLES = CLK_FREQ_HZ / BAUD_RATE;

reg clk = 0;
initial #10 forever #5 clk = ~clk;

reg rx = 1;
wire [7:0] rx_data;
wire rx_data_valid;

uart_rx uut (
	.clk (clk),
	.rx (rx),
	.rx_data (rx_data),
	.rx_data_valid (rx_data_valid)
);

initial begin
	$dumpfile("uart_rx_tb.vcd");
	$dumpvars;
end

initial begin
	// start bit
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 0;
	// bit 0
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 1
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 2
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 0;
	// bit 3
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 4
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 5
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 6
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 7
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 8
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// bit 9
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk) rx = 1;
	// wait a little longer
	repeat (BAUD_PERIOD_CYCLES) @(posedge clk)  $finish;
end

endmodule

