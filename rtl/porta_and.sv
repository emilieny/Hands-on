`timescale 1ns/1ps

module porta_and (
    input  logic a,
    input  logic b,
    output logic y
);

    assign y = a & b;

endmodule