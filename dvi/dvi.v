`timescale 1ns / 1ps

module dvi (
	input clk,
	input clk5x,
	input rstn,
	input [7:0] r,
	input [7:0] g,
	input [7:0] b,
	input hsync,
	input vsync,
	input dena,
	output [3:0] tmds_p,
	output [3:0] tmds_n
);

/*********************

 TMDS DATA ENCODERS 

*********************/

// tmds encode pixel and control data
wire [9:0] tmds_data [2:0];

tmds_encoder encoder_0 (
	.clk (clk),
	.rstn (rstn),
	.de (dena),
	.ctrl ({vsync, hsync}),
	.din (b),
	.dout (tmds_data[0])
);

tmds_encoder encoder_1 (
	.clk (clk),
	.rstn (rstn),
	.de (dena),
	.ctrl (2'b00),
	.din (g),
	.dout (tmds_data[1])
);

tmds_encoder encoder_2 (
	.clk (clk),
	.rstn (rstn),
	.de (dena),
	.ctrl (2'b00),
	.din (r),
	.dout (tmds_data[2])
);

/*********************

 10:1 DDR SERIALIZERS 

*********************/

// 1:10 double data rate serializers
reg [2:0] serializer_counter;
reg [9:0] serializer_data_shift [2:0];

always @(posedge clk5x) begin
	if (!rstn) begin
		serializer_counter <= 4;
	end else begin
		serializer_data_shift[0] <= {2'b00, serializer_data_shift[0][9:2]};
		serializer_data_shift[1] <= {2'b00, serializer_data_shift[1][9:2]};
		serializer_data_shift[2] <= {2'b00, serializer_data_shift[2][9:2]};
		serializer_counter <= serializer_counter + 1;
		if (serializer_counter == 4) begin
			serializer_counter <= 0;
			serializer_data_shift[0] <= tmds_data[0];
			serializer_data_shift[1] <= tmds_data[1];
			serializer_data_shift[2] <= tmds_data[2];
		end
	end
end


/*************************

 DIFFERENTIAL DDR OUTPUTS

*************************/

// create differential double data rate outputs
wire [2:0] tmds_rising, tmds_falling, tmds_rising_inv, tmds_falling_inv;
wire tmds_clk, tmds_clk_inv;

// assign tmds_0
assign tmds_rising      [0] =  serializer_data_shift[0][0];
assign tmds_falling     [0] =  serializer_data_shift[0][1];
assign tmds_rising_inv  [0] = ~serializer_data_shift[0][0]; // TODO: do i need to run the non-inverted signals through a dummy lut to match the delay?
assign tmds_falling_inv [0] = ~serializer_data_shift[0][1]; // TODO: should i do longer traces? or is the intrapair skew within spec so no mod required?

// assign tmds_1
assign tmds_rising      [1] =  serializer_data_shift[1][0];
assign tmds_falling     [1] =  serializer_data_shift[1][1];
assign tmds_rising_inv  [1] = ~serializer_data_shift[1][0];
assign tmds_falling_inv [1] = ~serializer_data_shift[1][1];

// assign tmds_2
assign tmds_rising      [2] =  serializer_data_shift[2][0];
assign tmds_falling     [2] =  serializer_data_shift[2][1];
assign tmds_rising_inv  [2] = ~serializer_data_shift[2][0];
assign tmds_falling_inv [2] = ~serializer_data_shift[2][1];

// assign tmds_clk
assign tmds_clk     =  clk;
assign tmds_clk_inv = ~clk; // TODO: same here-is the intrapair skew ok?

// tmds channel 0 (blue + syncs) differential pair
SB_IO tmds_0_p (
	.PACKAGE_PIN (tmds_p[0]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising[0]),
	.D_OUT_1 (tmds_falling[0])
);
defparam tmds_0_p.PIN_TYPE = 6'b010010;

SB_IO tmds_0_n (
	.PACKAGE_PIN (tmds_n[0]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising_inv[0]),
	.D_OUT_1 (tmds_falling_inv[0])
);
defparam tmds_0_n.PIN_TYPE = 6'b010010;

// tmds channel 1 (green) differential pair
SB_IO tmds_1_p (
	.PACKAGE_PIN (tmds_p[1]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising[1]),
	.D_OUT_1 (tmds_falling[1])
);
defparam tmds_1_p.PIN_TYPE = 6'b010010;

SB_IO tmds_1_n (
	.PACKAGE_PIN (tmds_n[1]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising_inv[1]),
	.D_OUT_1 (tmds_falling_inv[1])
);
defparam tmds_1_n.PIN_TYPE = 6'b010010;

// tmds channel 2 (red) differential pair
SB_IO tmds_2_p (
	.PACKAGE_PIN (tmds_p[2]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising[2]),
	.D_OUT_1 (tmds_falling[2])
);
defparam tmds_2_p.PIN_TYPE = 6'b010010;

SB_IO tmds_2_n (
	.PACKAGE_PIN (tmds_n[2]),
	.CLOCK_ENABLE (1'b1), // TODO: remove later, only for simulation
	.OUTPUT_CLK (clk5x),
	.D_OUT_0 (tmds_rising_inv[2]),
	.D_OUT_1 (tmds_falling_inv[2])
);
defparam tmds_2_n.PIN_TYPE = 6'b010010;

// tmds clk differential pair
SB_IO tmds_clk_p (
	.PACKAGE_PIN (tmds_p[3]),
	.D_OUT_0 (tmds_clk)
);
defparam tmds_clk_p.PIN_TYPE = 6'b011010;

SB_IO tmds_clk_n (
	.PACKAGE_PIN (tmds_n[3]),
	.D_OUT_0 (tmds_clk_inv)
);
defparam tmds_clk_n.PIN_TYPE = 6'b011010;


endmodule

module tmds_encoder (
	input clk, rstn, de,
	input [1:0] ctrl,
	input [7:0] din,
	output reg [9:0] dout
);
	function [3:0] count_set_bits;
		input [9:0] bits;
		integer i;
		begin
			count_set_bits = 0;
			for (i = 0; i < 9; i = i+1)
				count_set_bits = count_set_bits + bits[i];
		end
	endfunction

	function [3:0] count_transitions;
		input [7:0] bits;
		integer i;
		begin
			count_transitions = 0;
			for (i = 0; i < 7; i = i+1)
				count_transitions = count_transitions + (bits[i] != bits[i+1]);
		end
	endfunction

	wire [7:0] din_xor;
	assign din_xor[0] = din[0];
	assign din_xor[1] = din[1] ^ din_xor[0];
	assign din_xor[2] = din[2] ^ din_xor[1];
	assign din_xor[3] = din[3] ^ din_xor[2];
	assign din_xor[4] = din[4] ^ din_xor[3];
	assign din_xor[5] = din[5] ^ din_xor[4];
	assign din_xor[6] = din[6] ^ din_xor[5];
	assign din_xor[7] = din[7] ^ din_xor[6];

	wire [7:0] din_xnor;
	assign din_xnor[0] = din[0];
	assign din_xnor[1] = din[1] ^~ din_xnor[0];
	assign din_xnor[2] = din[2] ^~ din_xnor[1];
	assign din_xnor[3] = din[3] ^~ din_xnor[2];
	assign din_xnor[4] = din[4] ^~ din_xnor[3];
	assign din_xnor[5] = din[5] ^~ din_xnor[4];
	assign din_xnor[6] = din[6] ^~ din_xnor[5];
	assign din_xnor[7] = din[7] ^~ din_xnor[6];

	reg signed [7:0] cnt;
	reg [9:0] dout_buf, dout_buf2, m;

	always @(posedge clk) begin
		if (!rstn) begin
			cnt <= 0;
		end else if (!de) begin
			cnt <= 0;
			case (ctrl)
				2'b00: dout_buf <= 10'b1101010100;
				2'b01: dout_buf <= 10'b0010101011;
				2'b10: dout_buf <= 10'b0101010100;
				2'b11: dout_buf <= 10'b1010101011;
			endcase
		end else begin
			m = count_transitions(din_xor) < count_transitions(din_xnor) ? {2'b01, din_xor} : {2'b00, din_xnor};
			if ((count_set_bits(m[7:0]) > 4) == (cnt > 0)) m = {1'b1, m[8], ~m[7:0]};
			cnt <= cnt + count_set_bits(m) - 5;
			dout_buf <= m;
		end

		// add two additional ff stages, give synthesis retime some slack to work with
		dout_buf2 <= dout_buf;
		dout <= dout_buf2;
	end
endmodule
