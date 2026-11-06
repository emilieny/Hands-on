`timescale 1ns/1ps

module minisoc_aes_add_round_key (
    input  logic [127:0] state_in,
    input  logic [127:0] round_key,
    output logic [127:0] state_out
);

    // Combina cada byte do estado com a round key por XOR.
    assign state_out = state_in ^ round_key;

endmodule
