`timescale 1ns/1ps
`define DMEM_N_FILE(x,y) {x,y,".mem"}

module dmem (
    input clk,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata
);
    // 4K location, 16KB total, split in 4 banks
    reg [7:0] mem0[0:4095];  
    reg [7:0] mem1[0:4095];  
    reg [7:0] mem2[0:4095];  
    reg [7:0] mem3[0:4095];  

    wire [29:0] a;
    

    initial begin 
        $readmemh({`TESTDIR,"/data0.mem"}, mem0); 
        $readmemh({`TESTDIR,"/data1.mem"}, mem1); 
        $readmemh({`TESTDIR,"/data2.mem"}, mem2); 
        $readmemh({`TESTDIR,"/data3.mem"}, mem3); 
    end

    assign a = daddr[31:2];
    
    // Selecting bytes to be done inside CPU
    assign drdata = { mem3[a], mem2[a], mem1[a], mem0[a]};  

    always @(posedge clk) begin
        if (dwe[3]) mem3[a] = dwdata[31:24];
        if (dwe[2]) mem2[a] = dwdata[23:16];
        if (dwe[1]) mem1[a] = dwdata[15: 8];
        if (dwe[0]) mem0[a] = dwdata[ 7: 0];
    end
endmodule