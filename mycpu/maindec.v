`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
module maindec(
    input wire stallD,
//	input wire [5:0] op,
//	input wire [5:0] funct,
//	input wire [4:0] rt,
    input wire [31:0] instrD,
	output wire memtoreg,memwrite,
	output wire branch,
	output wire [1:0] alusrc,         //原来是1位的，现在变成两位 因为有符号扩展和0扩展两种扩展  00：alu的第二个操作数是寄存器中的数 01:alu的第二个操作数是有符号扩展数 10：alu的第二个操作数是0扩展数
	output wire regdst,regwrite,
	output wire jump,
	output wire [3:0] aluop,
	output wire hilo_weD,
	output wire div_validD,div_signD,
	output wire jrD,jalD,jalrD,balD,
	output wire memenD,
	output wire cp0weD,
	output reg invalidD   //指令异常
    );

    wire [5:0] op;
    wire [5:0] funct;
    wire [4:0] rt,rs;
    assign op = instrD[31:26];
	assign funct = instrD[5:0];
	assign rt = instrD[20:16];
	assign rs = instrD[25:21];
	
    assign div_validD =((op == `R_TYPE&&funct ==`DIV)||(op==`R_TYPE&&funct ==`DIVU))&&~stallD;    //判断当前指令是否是除法
    assign div_signD = (op==`R_TYPE &&funct ==`DIV)&&~stallD; //有符号除法
    assign cp0weD = ((op==`SPECIAL3_INST)&(rs==`MTC0))?1:0;
    
	reg[17:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,jrD,jalD,jalrD,balD,hilo_weD,memenD,aluop} = controls;
	always @(*) begin
	   invalidD=1'b0;
//	   if(stallD | instrD==32'b0)begin   //暂停
//	       controls=18'b0000000000000000;
//	   end
	   
//	   else begin
	       controls=18'b0000000000000000;
            case (op)
                `R_TYPE:begin
                        case(funct)
                            `AND:controls = {14'b11000000000000,`R_TYPE_OP}; //AND
                            `OR:controls = {14'b11000000000000,`R_TYPE_OP}; //OR
                            `XOR:controls = {14'b11000000000000,`R_TYPE_OP}; //XOR
                            `NOR:controls = {14'b11000000000000,`R_TYPE_OP}; //NOR
                            
                            `SLL:controls = {14'b11000000000000,`R_TYPE_OP}; //SLL
                            `SRL:controls = {14'b11000000000000,`R_TYPE_OP}; //SRL
                            `SRA:controls = {14'b11000000000000,`R_TYPE_OP}; //SRA
                            `SLLV:controls = {14'b11000000000000,`R_TYPE_OP}; //SLLV
                            `SRLV:controls = {14'b11000000000000,`R_TYPE_OP}; //SRLV
                            `SRAV:controls = {14'b11000000000000,`R_TYPE_OP}; //SRAV
                            
                            `MFHI:controls = {14'b11000000000000,`R_TYPE_OP}; //MFHI
                            `MFLO:controls = {14'b11000000000000,`R_TYPE_OP}; //MFLO
                            `MTHI:controls = {14'b00000000000010,`R_TYPE_OP}; //MTHI
                            `MTLO:controls = {14'b00000000000010,`R_TYPE_OP}; //MTLO
                            
                            `ADD:controls = {14'b11000000000000,`R_TYPE_OP}; //ADD
                            `ADDU:controls = {14'b11000000000000,`R_TYPE_OP}; //ADDU
                            `SUB:controls = {14'b11000000000000,`R_TYPE_OP}; //SUB
                            `SUBU:controls = {14'b11000000000000,`R_TYPE_OP}; //SUBU
                            `SLT:controls = {14'b11000000000000,`R_TYPE_OP}; //SLT
                            `SLTU:controls = {14'b11000000000000,`R_TYPE_OP}; //SLTU
                            `MULT:controls = {14'b00000000000010,`R_TYPE_OP}; //MULT
                            `MULTU:controls = {14'b00000000000010,`R_TYPE_OP}; //MULTU
                            `DIV:controls = {14'b00000000000010,`R_TYPE_OP}; //DIV
                            `DIVU:controls = {14'b00000000000010,`R_TYPE_OP}; //DIVU
                            
                            `JR:controls = {14'b00000000100000,`USELESS_OP}; //JR
                            `JALR:controls ={14'b11000000001000,`USELESS_OP}; //JALR
                            default: invalidD=1'b1;//illegal op
                          endcase
                         end

                `REGIMM_INST: begin    //BGEZ、BGEZAL、BLTZ、BLTZAL指令需要先根据op判断是REGIMM_INST后，再根据指令的16-20bit进一步判断
					case(rt)
						`BGEZ:   controls = {14'b00001000000000,`USELESS_OP};
                        `BGEZAL:   controls = {14'b10001000000100,`USELESS_OP};
						`BLTZ:   controls = {14'b00001000000000,`USELESS_OP};  
						`BLTZAL:   controls = {14'b10001000000100,`USELESS_OP};
						default: invalidD=1'b1;
					endcase
				end
				
		         //mfc0 and mtc0
                `SPECIAL3_INST:begin
                    case(rs)
                        `MTC0:controls ={14'b00000000000000,`MTC0_OP};//控制信号;
                        `MFC0:controls = {14'b10000000000000,`MFC0_OP};//控制信号;
                        `ERET:controls = 18'b000000000000000000;//控制信号;
//                        default: invalid_o=1;//无效指令
                         default: invalidD=1'b1;
                    endcase
				end
				
                //I-TYPE:
                `ANDI:controls = {14'b10100000000000,`ANDI_OP}; //ANDI
                `ORI:controls = {14'b10100000000000,`ORI_OP}; //ORI
                `XORI:controls = {14'b10100000000000,`XORI_OP}; //XORI
                `LUI:controls = {14'b10100000000000,`LUI_OP}; //LUI
                
                `ADDI:controls = {14'b10010000000000,`ADDI_OP}; //ADDI
                `ADDIU:controls = {14'b10010000000000,`ADDIU_OP}; //ADDIU
                `SLTI:controls = {14'b10010000000000,`SLTI_OP}; //SLTI
                `SLTIU:controls = {14'b10010000000000,`SLTIU_OP}; //SLTIU
		          
		        `BEQ:controls = {14'b00001000000000,`USELESS_OP}; //BEQ
		        `BNE:controls = {14'b00001000000000,`USELESS_OP}; //BNE
//		        `BGEZ:controls = {14'b00001000000000,`USELESS_OP}; //BGEZ
		        `BGTZ:controls = {14'b00001000000000,`USELESS_OP}; //BGTZ
		        `BLEZ:controls = {14'b00001000000000,`USELESS_OP}; //BLEZ
//		        `BLTZ:controls = {14'b00001000000000,`USELESS_OP}; //BLTZ
		        
		        //{regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,jrD,jalD,jalrD,balD,hilo_weD,memen,aluop}
		        `LB:controls = {14'b10010010000001,`ADDI_OP}; //LB
		        `LBU:controls = {14'b10010010000001,`ADDI_OP}; //LBU
		        `LH:controls = {14'b10010010000001,`ADDI_OP}; //LH
		        `LHU:controls = {14'b10010010000001,`ADDI_OP}; //LHU
		        `LW:controls = {14'b10010010000001,`ADDI_OP}; //LW
		        
		        `SB:controls = {14'b00010100000001, `ADDI_OP}; //SB
		        `SH:controls = {14'b00010100000001, `ADDI_OP}; //SH
		        `SW:controls = {14'b00010100000001, `ADDI_OP}; //SW
		        
		        //J-TYPE:
    			`J:controls = {14'b00000001000000,`USELESS_OP}; //J
    			`JAL:controls ={14'b10000000010000,`USELESS_OP}; //JAL
    			
                default: invalidD=1'b1;//illegal op
		  endcase
		end
//	end
endmodule
