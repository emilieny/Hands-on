`timescale 1ns/1ps

module minisoc_aes_inv_sub_bytes (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // Aplica a S-box inversa a cada byte.
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : byte_inv_sbox
            minisoc_aes_inv_sbox inv_sbox_inst (
                .in(state_in[127-(8*i) -: 8]),
                .out(state_out[127-(8*i) -: 8])
            );
        end
    endgenerate

endmodule
