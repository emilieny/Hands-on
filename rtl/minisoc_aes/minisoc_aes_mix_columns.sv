`timescale 1ns/1ps

module minisoc_aes_mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    logic [31:0] column_out [0:3];

    // Multiplica um byte por x usando GF(2^8).
    function automatic logic [7:0] xtime(input logic [7:0] value);
        xtime = {value[6:0], 1'b0} ^ (8'h1b & {8{value[7]}});
    endfunction

    // Multiplicacao generica usada pela matriz MixColumns.
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
        for (column = 0; column < 4; column = column + 1) begin : mix_column
            // Cada palavra do estado contem uma coluna: [b0 b1 b2 b3].
            assign column_out[column][31:24] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h02) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h03) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h01);

            assign column_out[column][23:16] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h02) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h03) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h01);

            assign column_out[column][15:8] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h02) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h03);

            assign column_out[column][7:0] =
                gmul(state_in[127-(8*4*column) -: 8], 8'h03) ^
                gmul(state_in[119-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[111-(8*4*column) -: 8], 8'h01) ^
                gmul(state_in[103-(8*4*column) -: 8], 8'h02);
        end
    endgenerate

    assign state_out = {
        column_out[0],
        column_out[1],
        column_out[2],
        column_out[3]
    };

endmodule
