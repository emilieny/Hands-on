`timescale 1ns/1ps

module minisoc_aes_inv_mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    logic [31:0] column_out [0:3];

    // Multiplica um byte por x usando GF(2^8).
    function automatic logic [7:0] xtime(input logic [7:0] value);
        xtime = {value[6:0], 1'b0} ^ (8'h1b & {8{value[7]}});
    endfunction

    // Multiplicacao generica usada pela matriz InvMixColumns.
    function automatic logic [7:0] gmul(
        input logic [7:0] value,
        input logic [7:0] multiplier
    );
        logic [7:0] result;
        logic [7:0] current;
        logic [7:0] factor;

        result = 8'h00;
        current = value;
        factor = multiplier;
        for (int bit_index = 0; bit_index < 8; bit_index++) begin
            if (factor[0])
                result = result ^ current;
            current = xtime(current);
            factor = factor >> 1;
        end
        gmul = result;
    endfunction

    genvar column;
    generate
        for (column = 0; column < 4; column = column + 1) begin : inv_mix_column
            // Primeira linha da matriz InvMixColumns: 0e 0b 0d 09.
            assign column_out[column][31:24] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h0e) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h0b) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h0d) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h09);

            // Segunda linha da matriz InvMixColumns: 09 0e 0b 0d.
            assign column_out[column][23:16] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h09) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h0e) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h0b) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h0d);

            // Terceira linha da matriz InvMixColumns: 0d 09 0e 0b.
            assign column_out[column][15:8] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h0d) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h09) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h0e) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h0b);

            // Quarta linha da matriz InvMixColumns: 0b 0d 09 0e.
            assign column_out[column][7:0] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h0b) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h0d) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h09) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h0e);
        end
    endgenerate

    // Reagrupa as quatro colunas processadas em uma palavra de estado de 128 bits.
    assign state_out = {column_out[0], column_out[1], column_out[2], column_out[3]};

endmodule
