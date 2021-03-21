module \$_DFF_P_ (D, Q, C);
    input D;
    input C;
    output Q;
    dff _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C));
endmodule

module \$_DFF_PN0_ (D, Q, C, R);
    input D;
    input C;
    input R;
    output Q;
    dffr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .R(R));
endmodule

module \$_DFF_PP0_ (D, Q, C, R);
    input D;
    input C;
    input R;
    output Q;
    dffr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .R(!R));
endmodule

