/* Deal with the Data hazard */

module Data_hazard(
    input              [   4: 0] IDU_rs1                    ,
    input              [   4: 0] IDU_rs2                    ,

    input              [   4: 0] EXU_rd                     ,
    input              [   4: 0] MEM_rd                     ,

    input                        IDU_valid                  ,
    input                        EXU_valid                  ,
    input                        MEM_valid                  ,

    input                        MEM_mem_ren                ,
    input                        EXU_R_Wen                  ,
    input                        MEM_R_Wen                  ,

    output             [   1: 0] IDU_rs1_choice             ,
    output             [   1: 0] IDU_rs2_choice              
);

assign IDU_rs1_choice = (EXU_R_Wen && (EXU_rd == IDU_rs1 && EXU_rd != 0 ))? 
                        2'b01:(MEM_R_Wen && (MEM_rd == IDU_rs1 ) && (MEM_rd!=0))? 
                        (MEM_mem_ren? 2'b011:2'b10):2'b000;

assign IDU_rs2_choice = (EXU_R_Wen && (EXU_rd == IDU_rs2 && EXU_rd != 0 ))? 
                        2'b01:(MEM_R_Wen && (MEM_rd == IDU_rs2 ) && (MEM_rd!=0))? 
                        (MEM_mem_ren? 2'b011:2'b10):2'b000;

endmodule                                                           //Aribter



