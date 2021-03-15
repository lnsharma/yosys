
module \$__QLF_RAM16K (
	output [31:0] RDATA,
	input         RCLK, RE,
	input  [11:0] RADDR,
	input         WCLK, WE,
	input  [11:0] WADDR,
	input  [31:0] WDATA
);

	generate
			dual_port_ram #()
				 _TECHMAP_REPLACE_ (
				.d_out(RDATA),
				.clk (RCLK ),
				.ren   (RE   ),
				.raddr(RADDR),
				.wen   (WE   ),
				.waddr(WADDR),
				.d_in(WDATA)
				);
	endgenerate

endmodule


module \$__QLF_RAM16K_M0 (CLK2, CLK3, A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN);
	parameter [0:0] CLKPOL2 = 1;
	parameter [0:0] CLKPOL3 = 1;

	parameter [4095:0] INIT = 4096'bx;

	input CLK2;
	input CLK3;

	input [7:0] A1ADDR;
	output [31:0] A1DATA;
	input A1EN;

	input [7:0] B1ADDR;
	input [31:0] B1DATA;
	input [15:0] B1EN;

	wire [10:0] A1ADDR_11 = A1ADDR;
	wire [10:0] B1ADDR_11 = B1ADDR;

	\$__QLF_RAM16K #()
		 _TECHMAP_REPLACE_ (
		.RDATA(A1DATA),
		.RADDR(A1ADDR_11),
		.RCLK(CLK2),
		.RE(1'b1),
		.WDATA(B1DATA),
		.WADDR(B1ADDR_11),
		.WCLK(CLK3),
		.WE(1'b1)
	);
endmodule

// TODO: Test with corner case

module \$__QLF_RAM16K_M12 (CLK2, CLK3, A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN);
	parameter CFG_ABITS = 10;
	parameter CFG_DBITS = 16;

	parameter [0:0] CLKPOL2 = 1;
	parameter [0:0] CLKPOL3 = 1;

	parameter [4095:0] INIT = 4096'bx;

/*	localparam MODE =
		CFG_ABITS ==  9 ? 1 :
		CFG_ABITS == 10 ? 1 :
		CFG_ABITS == 11 ? 2 : 'bx;*/
	localparam MODE =
		CFG_ABITS == 10 ? 1 :
		CFG_ABITS == 11 ? 2 : 'bx;

	input CLK2;
	input CLK3;

	input [CFG_ABITS-1:0] A1ADDR;
	output [CFG_DBITS-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [CFG_DBITS-1:0] B1DATA;
	input B1EN;

	wire [10:0] A1ADDR_11 = A1ADDR;
	wire [10:0] B1ADDR_11 = B1ADDR;

	wire [15:0] A1DATA_16, B1DATA_16;

/*	generate
		if (MODE == 1) begin
			assign A1DATA = {A1DATA_16[14], A1DATA_16[12], A1DATA_16[10], A1DATA_16[ 8],
			                 A1DATA_16[ 6], A1DATA_16[ 4], A1DATA_16[ 2], A1DATA_16[ 0]};
			assign {B1DATA_16[14], B1DATA_16[12], B1DATA_16[10], B1DATA_16[ 8],
			        B1DATA_16[ 6], B1DATA_16[ 4], B1DATA_16[ 2], B1DATA_16[ 0]} = B1DATA;
		end
		if (MODE == 2) begin
			assign A1DATA = {A1DATA_16[13], A1DATA_16[9], A1DATA_16[5], A1DATA_16[1]};
			assign {B1DATA_16[13], B1DATA_16[9], B1DATA_16[5], B1DATA_16[1]} = B1DATA;
		end
		if (MODE == 3) begin
			assign A1DATA = {A1DATA_16[11], A1DATA_16[3]};
			assign {B1DATA_16[11], B1DATA_16[3]} = B1DATA;
		end
	endgenerate*/
	generate
		if (MODE == 1) begin
			assign A1DATA = {A1DATA_16[30], A1DATA_16[28], A1DATA_16[26], A1DATA_16[ 24],
			                 A1DATA_16[ 22], A1DATA_16[ 20], A1DATA_16[ 18], A1DATA_16[ 16],
					 A1DATA_16[14], A1DATA_16[12], A1DATA_16[10], A1DATA_16[ 8],
			                 A1DATA_16[ 6], A1DATA_16[ 4], A1DATA_16[ 2], A1DATA_16[ 0]};					
			assign {B1DATA_16[30], B1DATA_16[28], B1DATA_16[26], B1DATA_16[ 24],
			        B1DATA_16[ 22], B1DATA_16[ 20], B1DATA_16[ 18], B1DATA_16[ 16],
				B1DATA_16[14], B1DATA_16[12], B1DATA_16[10], B1DATA_16[ 8],
			        B1DATA_16[ 6], B1DATA_16[ 4], B1DATA_16[ 2], B1DATA_16[ 0]} = B1DATA;			
		end
		if (MODE == 2) begin
			assign A1DATA = {A1DATA_16[14], A1DATA_16[12], A1DATA_16[10], A1DATA_16[ 8],
			                 A1DATA_16[ 6], A1DATA_16[ 4], A1DATA_16[ 2], A1DATA_16[ 0]};
			assign {B1DATA_16[14], B1DATA_16[12], B1DATA_16[10], B1DATA_16[ 8],
			        B1DATA_16[ 6], B1DATA_16[ 4], B1DATA_16[ 2], B1DATA_16[ 0]} = B1DATA;
		end
	endgenerate

	\$__ICE40_RAM4K #()
		 _TECHMAP_REPLACE_ (
		.RDATA(A1DATA_16),
		.RADDR(A1ADDR_11),
		.RCLK(CLK2),
		.RE(1'b1),
		.WDATA(B1DATA_16),
		.WADDR(B1ADDR_11),
		.WCLK(CLK3),
		.WE(1'b1)
	);
endmodule

