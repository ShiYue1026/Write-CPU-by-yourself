`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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
module aludec(
	input wire[31:0] instrD,
	input wire[3:0] aluop,
	input wire stallD,
	output reg[4:0] alucontrol
    );
    wire [5:0] funct;
    assign funct=instrD[5:0];
	always @(*) begin
	   if(stallD)begin
	       alucontrol = 5'b00000;
	   end
	   else begin
	    alucontrol = 5'b00000;
		case (aluop)
		//I-Type
			`ANDI_OP:alucontrol = `AND_CONTROL;
			`ORI_OP:alucontrol = `OR_CONTROL;
			`XORI_OP:alucontrol = `XOR_CONTROL;
			`LUI_OP:alucontrol = `LUI_CONTROL;
			`ADDI_OP:alucontrol = `ADD_CONTROL;
			`ADDIU_OP:alucontrol = `ADDU_CONTROL;
			`SLTI_OP:alucontrol = `SLT_CONTROL; 
			`SLTIU_OP:alucontrol = `SLTU_CONTROL;
			
		//SPECIAL
			`MFC0_OP: alucontrol = `MFC0_CONTROL;  //MFCO
			`MTC0_OP: alucontrol = `MTC0_CONTROL;  //MTCO
			
		//R-type
			`R_TYPE_OP : begin
			   case (funct)
				`AND:alucontrol = `AND_CONTROL; //AND
				`OR:alucontrol = `OR_CONTROL; //OR
				`XOR:alucontrol = `XOR_CONTROL; //XOR
				`NOR:alucontrol = `NOR_CONTROL; //NOR
				
				`SLL:alucontrol = `SLL_CONTROL; //SLL
				`SRL:alucontrol = `SRL_CONTROL; //SRL
				`SRA:alucontrol = `SRA_CONTROL; //SRA
				`SLLV:alucontrol = `SLLV_CONTROL; //SLLV
				`SRLV:alucontrol = `SRLV_CONTROL; //SRLV
				`SRAV:alucontrol = `SRAV_CONTROL; //SRAV
				
			    `MFHI:alucontrol = `MFHI_CONTROL; //MFHI
                `MFLO:alucontrol = `MFLO_CONTROL; //MFLO
                `MTHI:alucontrol = `MTHI_CONTROL; //MTHI
                `MTLO:alucontrol = `MTLO_CONTROL; //MTLO
                
                `ADD:alucontrol = `ADD_CONTROL; //ADD
                `ADDU:alucontrol = `ADDU_CONTROL; //ADDU
                `SUB:alucontrol = `SUB_CONTROL; //SUB
                `SUBU:alucontrol = `SUBU_CONTROL; //SUBU
                `SLT:alucontrol = `SLT_CONTROL; //SLT
                `SLTU:alucontrol = `SLTU_CONTROL; //SLTU
                `MULT:alucontrol = `MULT_CONTROL; //MULT
                `MULTU:alucontrol = `MULTU_CONTROL; //MULTU
                `DIV:alucontrol = `DIV_CONTROL; //DIV
                `DIVU:alucontrol = `DIVU_CONTROL; //DIVU
                default: alucontrol = 5'b00000;
			endcase
			end

			default:  alucontrol = 5'b00000;
		endcase
	   end
	end
endmodule
