module uart_tx_tb;

localparam integer BAUD_RATE = 9600;
localparam integer CLK_FREQ_HZ = 12000000;
localparam integer BAUD_PERIOD_CYCLES = CLK_FREQ_HZ / BAUD_RATE;

reg clk = 0;
initial #10 forever #5 clk = ~clk;

wire tx;
reg [7:0] tx_data;
reg tx_data_valid;
wire transmitting;


uart_tx uut (
	.clk (clk),
	.tx_data (tx_data),
	.tx_data_valid (tx_data_valid),
	.tx (tx),
	.transmitting (transmitting)
);

initial begin
	$dumpfile("uart_tx_tb.vcd");
	$dumpvars;
end

initial begin

	repeat (10) @(posedge clk) tx_data = "H";
	repeat (10) @(posedge clk) tx_data_valid = 1;
	repeat (10) @(posedge clk) tx_data_valid = 0;
	// wait a little longer
	repeat (12*BAUD_PERIOD_CYCLES) @(posedge clk);
	repeat (10) @(posedge clk) $finish;
end

endmodule
