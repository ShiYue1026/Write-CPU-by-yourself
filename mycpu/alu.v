`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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

`include "defines2.vh"
module alu(
	input wire[31:0] a,b,
	input wire [4:0] sa,
	input wire [63:0] hilo_inE,  //从hilo寄存器中读的值
	input wire [4:0] op,
    input wire [31:0] cp0_inE,
	output reg [31:0] aluoutE,
	output reg [63:0] hilo_outE,   //专门存要放到hilo寄存器中的变量
	output reg overflow,
    output reg [31:0] cp0_outE
    );

//	wire[31:0] s,bout;
//	assign bout = op[2] ? ~b : b;
//	assign s = a + bout + op[2];
	always @(*) begin
        overflow = 1'b0;
        aluoutE = 32'b0;
        hilo_outE = 64'b0;
        cp0_outE = 32'b0;
		case (op)
			`AND_CONTROL: 
                aluoutE = a & b;
			`OR_CONTROL: aluoutE = a | b;
			`XOR_CONTROL: aluoutE = a ^ b;
			`NOR_CONTROL: aluoutE = ~(a | b);
			`LUI_CONTROL: aluoutE ={b[15:0], 16'b0};
			
			`SLL_CONTROL: aluoutE = b << sa;
			`SRL_CONTROL: aluoutE = b >> sa;
			`SRA_CONTROL: aluoutE = $signed(b) >>> sa;
			`SLLV_CONTROL: aluoutE = b << a[4:0];
			`SRLV_CONTROL: aluoutE = b >> a[4:0];
			`SRAV_CONTROL: aluoutE = $signed(b) >>> a[4:0];
		     
		    `MFHI_CONTROL: aluoutE = hilo_inE[63:32];
            `MFLO_CONTROL: aluoutE = hilo_inE[31:0];
            `MTHI_CONTROL: hilo_outE = {a,hilo_inE[31:0]};
            `MTLO_CONTROL: hilo_outE = {hilo_inE[63:32],a};
            
            `ADD_CONTROL: begin
                aluoutE= a + b;
                overflow =  (a[31] == b[31]) & (aluoutE[31] != a[31]);
            end
            `ADDU_CONTROL: aluoutE= a + b;
            `SUB_CONTROL: begin
                aluoutE = a - b;
                overflow = (a[31]^b[31]) & (aluoutE[31]==b[31]);
            end
            `SUBU_CONTROL: aluoutE= a - b;
            `SLT_CONTROL: aluoutE= ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU_CONTROL: aluoutE= (a < b )? 1 : 0;
            `MULT_CONTROL: hilo_outE= $signed(a) * $signed(b);
            `MULTU_CONTROL: hilo_outE= a * b;
            `MFC0_CONTROL:  aluoutE = cp0_inE;
			`MTC0_CONTROL:  cp0_outE = b;
			default : begin 
                overflow = 1'b0;
                aluoutE = 32'b0;
                hilo_outE = 64'b0;
                cp0_outE = 32'b0;
			  end
		endcase	
	end

//	always @(*) begin
//		case (op[2:1])
//			2'b01:overflow <= a[31] & b[31] & ~s[31] |
//							~a[31] & ~b[31] & s[31];
//			2'b11:overflow <= ~a[31] & b[31] & s[31] |
//							a[31] & ~b[31] & ~s[31];
//			default : overflow <= 1'b0;
//		endcase	
//	end
endmodule
