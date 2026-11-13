`timescale 1ns/1ps

module tb_semana04_aes128;

    logic clk = 1'b0;
    logic reset;
    logic start;
    logic decrypt;
    logic [127:0] key;
    logic [127:0] data_in;
    logic [127:0] data_out;
    logic busy;
    logic done;
    int error_count = 0;

    always #5 clk = ~clk;

    minisoc_aes_dp dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .decrypt(decrypt),
        .key(key),
        .data_in(data_in),
        .data_out(data_out),
        .busy(busy),
        .done(done)
    );

    initial begin
        $fsdbDumpfile("waves_semana04_aes128.fsdb");
        $fsdbDumpvars(0, tb_semana04_aes128);
    end

    task automatic run_vector(
        input logic [127:0] vector_key,
        input logic [127:0] plaintext,
        input logic [127:0] ciphertext
    );
        begin
            key = vector_key;
            data_in = plaintext;
            decrypt = 1'b0;
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;
            wait (done);
            if (data_out !== ciphertext) begin
                $error("[ERRO cifragem] obtido %h; esperado %h", data_out, ciphertext);
                error_count++;
            end

            data_in = ciphertext;
            decrypt = 1'b1;
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;
            wait (done);
            if (data_out !== plaintext) begin
                $error("[ERRO decriptacao] obtido %h; esperado %h", data_out, plaintext);
                error_count++;
            end
        end
    endtask

    initial begin
        reset = 1'b1;
        start = 1'b0;
        decrypt = 1'b0;
        key = 128'h0;
        data_in = 128'h0;
        repeat (2) @(posedge clk);
        reset = 1'b0;

        run_vector(
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00112233445566778899aabbccddeeff,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a
        );
        run_vector(
            128'h2b7e151628aed2a6abf7158809cf4f3c,
            128'h3243f6a8885a308d313198a2e0370734,
            128'h3925841d02dc09fbdc118597196a0b32
        );

        if (error_count == 0)
            $display("STATUS FINAL: PASS - AES-128 cifragem e decriptacao passaram.");
        else
            $display("STATUS FINAL: FAIL - %0d erro(s) encontrado(s).", error_count);
        $finish;
    end

endmodule
