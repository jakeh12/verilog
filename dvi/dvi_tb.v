`timescale 1ns / 1ps

module dvi_tb;

reg clk5x = 0;
always #5 clk5x = ~clk5x;
reg clk = 0;
always #25 clk = ~clk;
reg [7:0] r = 0,g = 0,b = 0;
reg rstn = 0;
reg hsync = 0, vsync = 0, dena = 0;
wire [3:0] tmds_p;
wire [3:0] tmds_n;

dvi uut (
	.clk (clk),
	.clk5x (clk5x),
	.rstn (rstn),
	.r (r),
	.g (g),
	.b (b),
	.hsync (hsync),
	.vsync (vsync),
	.dena (dena),
	.tmds_p (tmds_p),
	.tmds_n (tmds_n)
);

initial begin
	$dumpfile("dvi_tb.vcd");
	$dumpvars;
end

initial begin
	repeat (4) @(posedge clk) begin rstn = 0; hsync = 0; vsync = 0; dena = 1; end
	repeat (4) @(posedge clk) rstn = 1;
	repeat (4) @(posedge clk) begin r = 10'b1111111111; g = 10'b0110101011; b = 10'b0110101011; end
	repeat (4) @(posedge clk) begin g = 10'b1111111111; b = 10'b0110101011; r = 10'b0110101011; end
	repeat (4) @(posedge clk) begin b = 10'b1111111111; r = 10'b0110101011; g = 10'b0110101011; end
	repeat (100) @(posedge clk);
	@(posedge clk) $finish;
end

endmodule

