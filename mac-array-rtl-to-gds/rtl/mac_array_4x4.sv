// 16 independent MAC units. Buses are flattened so the ports stay simple for P&R.
module mac_array_4x4 (
    input  logic         clk,
    input  logic         rst,
    input  logic [15:0]  en,
    input  logic [127:0] a,
    input  logic [127:0] b,
    input  logic [511:0] c,
    output logic [511:0] y
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : MAC_UNITS
            mac_unit u_mac (
                .clk (clk),
                .rst (rst),
                .en  (en[i]),
                .a   (a[i*8 +: 8]),
                .b   (b[i*8 +: 8]),
                .c   (c[i*32 +: 32]),
                .y   (y[i*32 +: 32])
            );
        end
    endgenerate

endmodule
