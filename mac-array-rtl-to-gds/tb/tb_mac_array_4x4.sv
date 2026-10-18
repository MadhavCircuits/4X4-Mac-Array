`timescale 1ns/1ps

module tb_mac_array_4x4;

    logic         clk, rst;
    logic [15:0]  en;
    logic [127:0] a, b;
    logic [511:0] c, y;

    mac_array_4x4 dut (.clk(clk), .rst(rst), .en(en), .a(a), .b(b), .c(c), .y(y));

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0; rst = 1; en = 0; a = 0; b = 0; c = 0;

        // Test 1: reset
        @(posedge clk); #1;
        for (i = 0; i < 16; i = i + 1)
            if (y[i*32 +: 32] !== 32'd0) $fatal(1, "FAIL: Reset at MAC %0d", i);
        $display("PASS: Reset");

        // Test 2: all 16 MACs compute (i+1)*2 + 100
        @(negedge clk);
        rst = 0; en = 16'hFFFF;
        for (i = 0; i < 16; i = i + 1) begin
            a[i*8 +: 8]   = i + 1;
            b[i*8 +: 8]   = 2;
            c[i*32 +: 32] = 100;
        end
        @(posedge clk); #1;
        for (i = 0; i < 16; i = i + 1)
            if (y[i*32 +: 32] !== ((i + 1) * 2 + 100))
                $fatal(1, "FAIL: MAC %0d, got %0d", i, y[i*32 +: 32]);
        $display("PASS: All 16 MAC units");

        // Test 3: enable low holds every output
        @(negedge clk);
        en = 16'h0000; a = 0; b = 0; c = 0;
        @(posedge clk); #1;
        for (i = 0; i < 16; i = i + 1)
            if (y[i*32 +: 32] !== ((i + 1) * 2 + 100))
                $fatal(1, "FAIL: Enable hold at MAC %0d", i);
        $display("PASS: Enable hold");

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
