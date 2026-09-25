module tb_exemplo;

    logic clk;
    logic rst_n;
    logic a;
    logic b;
    logic y;

    exemplo dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .y     (y)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;
        a     = 0;
        b     = 0;

        #12;
        rst_n = 1;

        a = 0;
        b = 0;
        #10;
        assert (y == 0);

        a = 0;
        b = 1;
        #10;
        assert (y == 1);

        a = 1;
        b = 0;
        #10;
        assert (y == 1);

        a = 1;
        b = 1;
        #10;
        assert (y == 0);

        $display("SIMULATION PASS");
        $finish;
    end

endmodule

