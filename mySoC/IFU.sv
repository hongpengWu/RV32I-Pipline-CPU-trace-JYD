`timescale 1ns / 1ps
`include "para.sv"

module IFU
(
    input                               clock                      ,
    input                               reset                      ,
    input              [  31: 0]        dnpc                       ,
    input                               dnpc_flag                  ,
    input              [31:0]                 irom_data                  ,
    input              stall                                        ,

    output             [  31: 0]        snpc                       ,
    output reg         [  31: 0]        pc                         ,
    output             [  31: 0]        inst                       ,

    input                               ready                      ,
    output reg                          valid                      

);

    localparam                          ResetValue                 = 32'h0;

    assign                              valid                       = 1'b1;
    assign                              snpc                        = pc + 4;
    assign                              inst                        = irom_data;


always @(posedge clock) begin
        if(reset)
            pc <= ResetValue;
        else if (stall & valid &ready)
            pc <= pc;
        else if(dnpc_flag&valid&ready)
            pc <= dnpc;
        else if(valid & ready)
            pc <= snpc;
end






endmodule

