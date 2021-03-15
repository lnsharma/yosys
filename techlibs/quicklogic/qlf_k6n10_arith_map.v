(* techmap_celltype = "$alu" *)
module _80_quicklogic_alu (A, B, CI, BI, X, Y, CO);
    parameter A_SIGNED = 0;
    parameter B_SIGNED = 0;
    parameter A_WIDTH  = 1;
    parameter B_WIDTH  = 1;
    parameter Y_WIDTH  = 1;

    parameter _TECHMAP_CONSTMSK_CI_ = 0;
    parameter _TECHMAP_CONSTVAL_CI_ = 0;

    (* force_downto *)
    input [A_WIDTH-1:0] A;
    (* force_downto *)
    input [B_WIDTH-1:0] B;
    (* force_downto *)
    output [Y_WIDTH-1:0] X, Y;

    input CI, BI;
    (* force_downto *)
    output [Y_WIDTH-1:0] CO;

    wire _TECHMAP_FAIL_ = Y_WIDTH <= 2;

    (* force_downto *)
    wire [Y_WIDTH-1:0] A_buf, B_buf;
    \$pos #(.A_SIGNED(A_SIGNED), .A_WIDTH(A_WIDTH), .Y_WIDTH(Y_WIDTH)) A_conv (.A(A), .Y(A_buf));
    \$pos #(.A_SIGNED(B_SIGNED), .A_WIDTH(B_WIDTH), .Y_WIDTH(Y_WIDTH)) B_conv (.A(B), .Y(B_buf));

    (* force_downto *)
    wire [Y_WIDTH-1:0] AA = A_buf;
    (* force_downto *)
    wire [Y_WIDTH-1:0] BB = BI ? ~B_buf : B_buf;
    (* force_downto *)
    wire [Y_WIDTH-1:0] C;

    assign CO = C[Y_WIDTH-1];

    genvar i;
    generate for (i = 0; i < Y_WIDTH; i = i + 1) begin: slice

        wire ci;
        wire co;

        // First in chain
        generate if (i == 0) begin

            // CI connected to a constant
            if (_TECHMAP_CONSTMSK_CI_ == 1) begin

		adder adder_ci(
			.a(AA[i]),
			.b(BB[i]),
			.cin(),
			.cout(ci),
			.sumout(Y[i]));

            // CI connected to a non-const driver
            end else begin

		adder adder_ci_only(
			.a(1'b0),
			.b(1'b0),
			.cin(),
			.cout(ci),
			.sumout());
            end

        // Not first in chain
        end else begin
            assign ci = C[i-1];

        end endgenerate

        // ....................................................

        // Single 1-bit adder, mid-chain adder or non-const CI
        // adder
        generate if ((i == 0 && _TECHMAP_CONSTMSK_CI_ == 0) || (i > 0)) begin

		adder adder_inst(
			.a(AA[i]),
			.b(BB[i]),
			.cin(ci),
			.cout(co),
			.sumout(Y[i]));
        end else begin
            assign co = ci;

        end endgenerate

        // ....................................................

        // Last in chain
        generate if (i == Y_WIDTH-1) begin

		adder adder_ci(
			.a(1'b0),
			.b(co),
			.cin(co),
			.cout(),
			.sumout(C[i]));
        // Not last in chain
        end else begin
            assign C[i] = co;

        end endgenerate

    end: slice	  
    endgenerate

    /* End implementation */
    assign X = AA ^ BB;
endmodule
