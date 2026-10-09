`timescale 1ns/1ps

module tb_porta_and;

    // Sinais do testbench
    logic a;
    logic b;
    logic y;

    // Instanciação do DUT (Device Under Test)
    porta_and dut (
        .a(a),
        .b(b),
        .y(y)
    );

    // Geração do dump FSDB
    // 
    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, tb_porta_and);
    end

    // Estímulos
    initial begin
        a = 0; b = 0;
        #10
        a = 0; b = 1;
        #10
        a = 1; b = 0;
        #10
        a = 1; b = 1;
        #10
        $finish;
    end

endmodule