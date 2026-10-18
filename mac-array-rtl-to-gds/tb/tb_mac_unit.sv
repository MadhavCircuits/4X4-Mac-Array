`timescale 1ns/1ps

module tb_mac_unit;

    logic        clk, rst, en;
    logic [7:0]  a, b;
    logic [31:0] c, y;

    mac_unit dut (.clk(clk), .rst(rst), .en(en), .a(a), .b(b), .c(c), .y(y));

    always #5 clk = ~clk;   // 10 ns period

    initial begin
        clk = 0; rst = 1; en = 0; a = 0; b = 0; c = 0;

        // Test 1: reset
        @(posedge clk); #1;
        if (y !== 32'd0) $fatal(1, "FAIL: Reset");

        // Test 2: multiply and add
        @(negedge clk);
        rst = 0; en = 1; a = 8'd10; b = 8'd20; c = 32'd50;
        @(posedge clk); #1;
        if (y !== 32'd250) $fatal(1, "FAIL: Expected 250, got %0d", y);
        $display("PASS: 10*20+50 = %0d", y);

        // Test 3: enable low holds the value
        @(negedge clk);
        en = 0; a = 8'd5; b = 8'd5; c = 32'd0;
        @(posedge clk); #1;
        if (y !== 32'd250) $fatal(1, "FAIL: Enable hold");
        $display("PASS: Output held at %0d", y);

        // Test 4: maximum 8-bit operands
        @(negedge clk);
        en = 1; a = 8'd255; b = 8'd255; c = 32'd100;
        @(posedge clk); #1;
        if (y !== 32'd65125) $fatal(1, "FAIL: Expected 65125, got %0d", y);
        $display("PASS: 255*255+100 = %0d", y);

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
