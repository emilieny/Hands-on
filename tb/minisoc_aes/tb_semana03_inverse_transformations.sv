`timescale 1ns/1ps

module tb_semana03_inverse_transformations;

    int error_count = 0;
    logic [7:0] inv_sbox_in, inv_sbox_out;
    logic [127:0] inv_mix_in, inv_mix_out;
    logic [127:0] inv_shift_in, inv_shift_out;
    logic [127:0] inv_sub_in, inv_sub_out;

    minisoc_aes_inv_sbox u_inv_sbox (
        .in(inv_sbox_in),
        .out(inv_sbox_out)
    );

    minisoc_aes_inv_mix_columns u_inv_mix (
        .state_in(inv_mix_in),
        .state_out(inv_mix_out)
    );

    minisoc_aes_inv_shift_rows u_inv_shift (
        .state_in(inv_shift_in),
        .state_out(inv_shift_out)
    );

    minisoc_aes_inv_sub_bytes u_inv_sub (
        .state_in(inv_sub_in),
        .state_out(inv_sub_out)
    );

    initial begin
        $display("==================================================");
        $display("  TESTBENCH SEMANA 03 - Transformacoes inversas  ");
        $display("==================================================");

        inv_sbox_in = 8'h63;
        #1;
        if (inv_sbox_out !== 8'h00) begin
            $error("[ERRO InvSbox] InvSbox(0x63) = obtido %02x, esperado 00",
                   inv_sbox_out);
            error_count++;
        end

        inv_sbox_in = 8'hed;
        #1;
        if (inv_sbox_out !== 8'h53) begin
            $error("[ERRO InvSbox] InvSbox(0xED) = obtido %02x, esperado 53",
                   inv_sbox_out);
            error_count++;
        end

        inv_mix_in = 128'h046681e5e0cb199a48f8d37a2806264c;
        #1;
        if (inv_mix_out !== 128'hd4bf5d30e0b452aeb84111f11e2798e5) begin
            $error("[ERRO InvMixColumns] Obtido %h, esperado d4bf5d30e0b452aeb84111f11e2798e5",
                   inv_mix_out);
            error_count++;
        end

        inv_shift_in = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        #1;
        if (inv_shift_out !== 128'hd42711aee0bf98f1b8b45de51e415230) begin
            $error("[ERRO InvShiftRows] Obtido %h, esperado d42711aee0bf98f1b8b45de51e415230",
                   inv_shift_out);
            error_count++;
        end

        inv_sub_in = 128'hd42711aee0bf98f1b8b45de51e415230;
        #1;
        if (inv_sub_out !== 128'h193de3bea0f4e22b9ac68d2ae9f84808) begin
            $error("[ERRO InvSubBytes] Obtido %h, esperado 193de3bea0f4e22b9ac68d2ae9f84808",
                   inv_sub_out);
            error_count++;
        end

        if (error_count == 0)
            $display("STATUS FINAL: PASS - Transformacoes inversas passaram.");
        else
            $display("STATUS FINAL: FAIL - %0d erro(s) encontrado(s).", error_count);

        $finish;
    end

endmodule
