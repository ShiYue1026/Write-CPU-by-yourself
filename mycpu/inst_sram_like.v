`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/03 10:32:47
// Design Name: 
// Module Name: inst_sram_like
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_sram_like(
    input wire clk, rst,
    //sram
    input wire inst_sram_en,
    input wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_rdata,
    output wire i_stall,
    //sram like
    output wire inst_req, //
    output wire inst_wr,
    output wire [1:0] inst_size,
    output wire [31:0] inst_addr,
    output wire [31:0] inst_wdata,
    input wire inst_addr_ok,
    input wire inst_data_ok,
    input wire [31:0] inst_rdata,

    input wire longest_stall
    );
    
    reg addr_rcv;      
    reg do_finish;
    
    always @(posedge clk) begin
        addr_rcv <= rst          ? 1'b0 :
                    inst_req & inst_addr_ok & ~inst_data_ok ? 1'b1 :    //从slave接收到地址到slave返回data_ok的之间的那段时间
                    inst_data_ok ? 1'b0 : addr_rcv;
    end

    always @(posedge clk) begin
        do_finish <= rst          ? 1'b0 :      
                     inst_data_ok ? 1'b1 :     //如果inst_data_ok等于1 说明此次传输结束，do_finish置1
                     ~longest_stall ? 1'b0 : do_finish;    //否则如果longest_stall等于1 说明还在处理中 do_finish等于上个时钟周期的值
    end

    //save rdata
    reg [31:0] inst_rdata_save;
    always @(posedge clk) begin
        inst_rdata_save <= rst ? 32'b0:
                           inst_data_ok ? inst_rdata : inst_rdata_save;
    end

    //sram like
    assign inst_req = inst_sram_en & ~addr_rcv & ~do_finish;
    assign inst_wr = 1'b0;
    assign inst_size = 2'b10;
    assign inst_addr = inst_sram_addr;
    assign inst_wdata = 32'b0;

    //sram
    assign inst_sram_rdata = inst_rdata_save;
    assign i_stall = inst_sram_en & ~do_finish;
    
endmodule
