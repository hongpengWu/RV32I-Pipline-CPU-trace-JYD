`timescale 1ns / 1ps
`define STRINGIFY(x) `"x`"

module IROM # (
    ADDR_BITS = 16
)(
    input  wire         clka,
    input  wire         ena, 
    input  wire [ADDR_BITS-1:0] addra,
    output reg  [31:0]  douta
);

    integer i, j, mem_file;
    // (* RAM_STYLE="BLOCK" *)
    reg [32-1:0] mem[(2**20)-1:0];
    reg [32-1:0] mem_rd[(2**20)-1:0];
    initial begin
        // two nested loops for smaller number of iterations per loop
        // workaround for synthesizer complaints about large loop counts
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = 0;
            end
        end
        mem_file = $fopen(`STRINGIFY(`PATH), "r");
        if(mem_file == 0) begin
            $display("[ERROR] Open file %s failed, please check whether file exists!\n", `STRINGIFY(`PATH));
            $fatal;
        end
        $display("[INFO] Instruction ROM initialized with %s", `STRINGIFY(`PATH));
        $fread(mem_rd, mem_file);
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = {{mem_rd[j][07:00]}, {mem_rd[j][15:08]}, {mem_rd[j][23:16]}, {mem_rd[j][31:24]}};
            end
        end

        douta = 32'h0;
    end

    always @(posedge clka) begin
        if (ena) begin
            douta <= mem[addra];
        end
    end

endmodule

module DRAM # (
    ADDR_BITS = 16
)(
    input  wire         clka,
    input  wire [ADDR_BITS-1:0] addra,
    input  wire [ 3:0]  wea,
    input  wire [31:0]  dina,
    output reg  [31:0]  douta
);

    integer i, j, mem_file;
    // (* RAM_STYLE="BLOCK" *)
    reg [32-1:0] mem[(2**20)-1:0];
    reg [32-1:0] mem_rd[(2**20)-1:0];
    initial begin
        // two nested loops for smaller number of iterations per loop
        // workaround for synthesizer complaints about large loop counts
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = 0;
            end
        end
        mem_file = $fopen(`STRINGIFY(`PATH), "r");
        if(mem_file == 0) begin
            $display("[ERROR] Open file %s failed, please check whether file exists!\n", `STRINGIFY(`PATH));
            $fatal;
        end
        $display("[INFO] Data RAM initialized with %s", `STRINGIFY(`PATH));
        $fread(mem_rd, mem_file);
        for (i = 0; i < 2**20; i = i + 2**(20/2)) begin
            for (j = i; j < i + 2**(20/2); j = j + 1) begin
                mem[j] = {{mem_rd[j][07:00]}, {mem_rd[j][15:08]}, {mem_rd[j][23:16]}, {mem_rd[j][31:24]}};
            end
        end

        douta = 32'h0;
    end

    always @(posedge clka) begin
        if (wea[0]) mem[addra][ 7: 0] <= dina[ 7: 0];
        if (wea[1]) mem[addra][15: 8] <= dina[15: 8];
        if (wea[2]) mem[addra][23:16] <= dina[23:16];
        if (wea[3]) mem[addra][31:24] <= dina[31:24];

        // Write First
        douta <= {wea[3] ? dina[31:24] : mem[addra][31:24],
                  wea[2] ? dina[23:16] : mem[addra][23:16],
                  wea[1] ? dina[15: 8] : mem[addra][15: 8],
                  wea[0] ? dina[ 7: 0] : mem[addra][ 7: 0]};
    end

endmodule
