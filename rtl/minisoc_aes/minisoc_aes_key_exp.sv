`timescale 1ns/1ps

module minisoc_aes_key_exp (
    input  logic [127:0]  key_in,
    output logic [1407:0] round_keys
);

    // As 11 chaves de rodada são organizadas de K0 a K10.
    logic [127:0] key [0:10];
    logic [31:0]  temp [1:10];
    logic [31:0]  next_word [1:10][0:3];
    logic [7:0]   sub_bytes [1:10][0:3];

    // Multiplicação por x em GF(2^8), usada para gerar o Rcon.
    function automatic logic [7:0] xtime(input logic [7:0] value);
        xtime = {value[6:0], 1'b0} ^ (8'h1b & {8{value[7]}});
    endfunction

    // Gera o constante de rodada 2^(round_number-1) em GF(2^8).
    function automatic logic [7:0] rcon(input integer round_number);
        logic [7:0] value;
        begin
            value = 8'h01;
            for (int index = 1; index < round_number; index = index + 1)
                value = xtime(value);
            rcon = value;
        end
    endfunction

    genvar round;
    genvar byte_index;
    generate
        for (round = 0; round < 11; round = round + 1) begin : key_round
            if (round == 0) begin : initial_key
                // K0 é a chave original fornecida na entrada.
                assign key[round] = key_in;
            end else begin : expanded_key
                // RotWord desloca o primeiro byte da palavra para o final.
                assign temp[round] = {
                    key[round-1][23:16],
                    key[round-1][15:8],
                    key[round-1][7:0],
                    key[round-1][31:24]
                };

                for (byte_index = 0; byte_index < 4; byte_index = byte_index + 1) begin : sub_word
                    // SubWord aplica a S-box aos quatro bytes de RotWord.
                    minisoc_aes_sbox sbox_inst (
                        .in(temp[round][31-(8*byte_index) -: 8]),
                        .out(sub_bytes[round][byte_index])
                    );
                end

                // A primeira palavra recebe SubWord, Rcon e XOR com a chave anterior.
                assign next_word[round][0] = key[round-1][127:96] ^
                                      {sub_bytes[round][0], sub_bytes[round][1],
                                       sub_bytes[round][2], sub_bytes[round][3]} ^
                                      {rcon(round), 24'h0};
                // As palavras seguintes são calculadas por XOR em cadeia.
                assign next_word[round][1] = key[round-1][95:64] ^ next_word[round][0];
                assign next_word[round][2] = key[round-1][63:32] ^ next_word[round][1];
                assign next_word[round][3] = key[round-1][31:0] ^ next_word[round][2];
                assign key[round] = {next_word[round][0], next_word[round][1],
                                     next_word[round][2], next_word[round][3]};
            end

            // Mantém K0 no trecho mais significativo e K10 no menos significativo.
            assign round_keys[1407-(128*round) -: 128] = key[round];
        end
    endgenerate

endmodule
