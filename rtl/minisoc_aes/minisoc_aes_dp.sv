`timescale 1ns/1ps

module minisoc_aes_dp (
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic         decrypt,
    input  logic [127:0] key,
    input  logic [127:0] data_in,
    output logic [127:0] data_out,
    output logic         busy,
    output logic         done
);

    // Banco concatenado de round keys: K0 ocupa os bits mais significativos.
    logic [1407:0] round_keys;
    // Estado intermediário, índice da rodada e resultados combinacionais.
    logic [127:0] state_reg;
    logic [3:0] round;
    logic [127:0] forward_state;
    logic [127:0] inverse_state;

    minisoc_aes_key_exp key_exp (
        .key_in(key),
        .round_keys(round_keys)
    );

    // Sinais intermediários do caminho direto e do caminho inverso.
    logic [127:0] sub_bytes_state;
    logic [127:0] shift_rows_state;
    logic [127:0] mix_columns_state;
    logic [127:0] add_key_state;
    logic [127:0] inv_shift_rows_state;
    logic [127:0] inv_sub_bytes_state;
    logic [127:0] inv_mix_columns_state;
    logic [127:0] inv_add_key_state;

    minisoc_aes_sub_bytes sub_bytes (
        .state_in(state_reg),
        .state_out(sub_bytes_state)
    );
    minisoc_aes_shift_rows shift_rows (
        .state_in(sub_bytes_state),
        .state_out(shift_rows_state)
    );
    minisoc_aes_mix_columns mix_columns (
        .state_in(shift_rows_state),
        .state_out(mix_columns_state)
    );
    minisoc_aes_add_round_key add_key (
        .state_in(mix_columns_state),
        .round_key(round_keys[1407-(128*round) -: 128]),
        .state_out(add_key_state)
    );
    minisoc_aes_inv_shift_rows inv_shift_rows (
        .state_in(state_reg),
        .state_out(inv_shift_rows_state)
    );
    minisoc_aes_inv_sub_bytes inv_sub_bytes (
        .state_in(inv_shift_rows_state),
        .state_out(inv_sub_bytes_state)
    );
    minisoc_aes_add_round_key inv_add_key (
        .state_in(inv_sub_bytes_state),
        .round_key(round_keys[1407-(128*round) -: 128]),
        .state_out(inv_add_key_state)
    );
    minisoc_aes_inv_mix_columns inv_mix_columns (
        .state_in(inv_add_key_state),
        .state_out(inv_mix_columns_state)
    );

    always_comb begin
        // Por padrão, uma rodada intermediária inclui MixColumns/InvMixColumns.
        forward_state = add_key_state;
        inverse_state = inv_mix_columns_state;
        if (round == 4'd10) begin
            // A rodada final de cifragem não aplica MixColumns.
            forward_state = shift_rows_state ^
                             round_keys[1407-(128*round) -: 128];
        end
        if (round == 4'd0) begin
            // A rodada final de decriptação não aplica InvMixColumns.
            inverse_state = inv_sub_bytes_state ^
                             round_keys[1407-(128*round) -: 128];
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= 128'h0;
            data_out <= 128'h0;
            round <= 4'h0;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            // done é um pulso de um ciclo; busy permanece ativo durante as rodadas.
            done <= 1'b0;
            if (start && !busy) begin
                busy <= 1'b1;
                if (decrypt) begin
                    // A decriptação começa com K10 e percorre K9 até K0.
                    state_reg <= data_in ^ round_keys[127:0];
                    round <= 4'd9;
                end else begin
                    // A cifragem começa com AddRoundKey usando K0.
                    state_reg <= data_in ^ round_keys[1407:1280];
                    round <= 4'd1;
                end
            end else if (busy) begin
                if (decrypt) begin
                    if (round == 4'd0) begin
                        // Publica o texto original ao concluir a rodada final inversa.
                        data_out <= inverse_state;
                        state_reg <= inverse_state;
                        busy <= 1'b0;
                        done <= 1'b1;
                    end else begin
                        state_reg <= inverse_state;
                        round <= round - 1'b1;
                    end
                end else if (round == 4'd10) begin
                    // Publica o texto cifrado ao concluir a rodada final direta.
                    data_out <= forward_state;
                    state_reg <= forward_state;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    state_reg <= forward_state;
                    round <= round + 1'b1;
                end
            end
        end
    end

endmodule
