`timescale 1ns/1ps

module tb_semana03_round_transformations;

    int error_count = 0;

    logic [127:0] mix_in;
    logic [127:0] mix_out;
    logic [127:0] add_key_state_in;
    logic [127:0] add_key_round_key;
    logic [127:0] add_key_state_out;

    minisoc_aes_mix_columns u_mix_columns (
        .state_in(mix_in),
        .state_out(mix_out)
    );

    minisoc_aes_add_round_key u_add_round_key (
        .state_in(add_key_state_in),
        .round_key(add_key_round_key),
        .state_out(add_key_state_out)
    );

    initial begin
        $display("==================================================");
        $display("  TESTBENCH SEMANA 03 - MixColumns/AddRoundKey  ");
        $display("==================================================");

        // Vetor intermediario do Apendice B da FIPS-197.
        mix_in = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        #1;
        if (mix_out !== 128'h046681e5e0cb199a48f8d37a2806264c) begin
            $error("[ERRO MixColumns] Obtido %h; esperado 046681e5e0cb199a48f8d37a2806264c",
                   mix_out);
            error_count++;
        end

        // Vetor intermediario da rodada 1 apos AddRoundKey.
        add_key_state_in = 128'h046681e5e0cb199a48f8d37a2806264c;
        add_key_round_key = 128'ha0fafe1788542cb123a339392a6c7605;
        #1;
        if (add_key_state_out !== 128'ha49c7ff2689f352b6b5bea43026a5049) begin
            $error("[ERRO AddRoundKey] Obtido %h; vetor intermediario incorreto", add_key_state_out);
            error_count++;
        end

        if (error_count == 0)
            $display("STATUS FINAL: PASS - MixColumns e AddRoundKey passaram.");
        else
            $display("STATUS FINAL: FAIL - %0d erro(s) encontrado(s).", error_count);

        $finish;
    end

endmodule
