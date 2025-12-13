`include "para.sv"
`timescale 1ns / 1ps

module ALU #(
    parameter BW = 32
) (
    input      [BW-1:0] d1,
    input      [BW-1:0] d2,
    input      [3:0]    choice,
    output logic [BW-1:0] res
);

    logic choose_add_sub;
    logic [BW-1:0]       add_result;
    logic [BW-1:0]       d2_inv;
    logic [BW-1:0]       d1_inv;
    assign d2_inv = ~d2;
    assign d1_inv = ~d1;

    always_comb begin
        res = '0;
        unique case (choice)
            `alu_signed_comparator: begin
                choose_add_sub = 1'b1;
                res = '0;
                res[0] = (d1[BW-1] != d2[BW-1]) ? d1[BW-1] : add_result[BW-1];
            end
            `alu_unsigned_comparator: begin
                choose_add_sub = 1'b0;
                res[0] = (d1 < d2);
            end
            `alu_add: begin
                choose_add_sub = 1'b0;
                res = add_result;
            end
            `alu_sub: begin
                choose_add_sub = 1'b1;
                res = add_result;
            end
            `alu_and: begin
                res = d1 & d2;
                choose_add_sub = 1'b0;
            end
            `alu_or: begin
                res = d1 | d2;
                choose_add_sub = 1'b0;
            end
            `alu_xor: begin
                res = (d1 & d2_inv) | (d1_inv & d2);
                choose_add_sub = 1'b0;
            end
            `alu_equal: begin
                choose_add_sub = 1'b0;
                res = '0;
                res[0] = (d1 != d2);
            end
            `alu_sll: begin
                choose_add_sub = 1'b0;
                res = d1 << d2[4:0];
            end
            `alu_srl: begin
                choose_add_sub = 1'b0;
                res = {{{BW{1'b0}}, d1} >> d2[4:0]};
            end
            `alu_sra: begin
                choose_add_sub = 1'b0;
                res = {{{BW{d1[BW-1]}}, d1} >> d2[4:0]};
            end
            default: begin
                choose_add_sub = 1'b0;
                res = '0;
            end
        endcase
    end

    add #(
        .BW (BW)
    ) add_inst0 (
        .choose_add_sub (choose_add_sub),
        .add_1          (d1),
        .add_2          (d2),
        .add_2_inv      (d2_inv),
        .result         (add_result)
    );

endmodule
