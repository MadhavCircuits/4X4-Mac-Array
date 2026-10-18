// 8x8 multiply + 32-bit add, registered output.  y <= a*b + c
module mac_unit (
    input  logic        clk,
    input  logic        rst,
    input  logic        en,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    input  logic [31:0] c,
    output logic [31:0] y
);

    logic [15:0] product;

    assign product = a * b;               // combinational

    always_ff @(posedge clk) begin        // sequential
        if (rst)
            y <= 32'd0;
        else if (en)
            y <= product + c;
    end

endmodule
