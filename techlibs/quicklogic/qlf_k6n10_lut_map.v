//TODO: Fix corner case where frac_lut6 fails to route when infered in mode n2_lut5

/*`ifndef NO_LUT
module \$lut (A, Y);
    parameter WIDTH = 0;
    parameter LUT = 0;

    (* force_downto *)
    input [WIDTH-1:0] A;
    output Y;

    generate
    if (WIDTH == 1) begin
	wire lut4_out;
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut4_out(lut4_out),.in({A[0],5'b0}));
	assign Y = lut4_out[0];
    end else
    if (WIDTH == 2) begin
	wire lut4_out;
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut4_out(lut4_out),.in({A[0:1],4'b0}));
	assign Y = lut4_out[0];
    end else
    if (WIDTH == 3) begin
	wire lut4_out;
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut4_out(lut4_out),.in({A[0:2],3'b0}));
	assign Y = lut4_out[0];
    end else
    if (WIDTH == 4) begin
	wire lut4_out;
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut4_out(lut4_out),.in({A[0:3],2'b0}));
	assign Y = lut4_out[0];
    end else
    if (WIDTH == 5) begin
	wire lut5_out;
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut5_out(lut5_out),.in({A[0:4],1'b0}));
	assign Y = lut5_out[0];
    end else
    if (WIDTH == 6) begin
        frac_lut6 #(.LUT(LUT)) _TECHMAP_REPLACE_ (.lut6_out(Y),.in(A));

    end else begin
        wire _TECHMAP_FAIL_ = 1;
    end
    endgenerate

endmodule
`endif

*/

