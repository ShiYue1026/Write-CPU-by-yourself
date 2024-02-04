`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/28 21:56:40
// Design Name: 
// Module Name: memsel
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


module memory_select(
    input wire [31:0] pcM,
    input wire [5:0] opM,
    input wire [31:0] aluoutM,
    input wire [31:0] readdataM,writedataM,
    output reg [3:0] selM,    //写数据对应的字节位
    output reg [31:0] final_readdataM,final_writedataM,   //最终需要 从内存读出/写入内存的数据
    output reg adelM,adesM,     //地址异常：一个读一个写
    output reg [31:0] bad_addrM
    );
    
    always @(*) begin
        final_writedataM = writedataM;
        final_readdataM = readdataM;
        adelM = 1'b0;
        adesM = 1'b0;
        bad_addrM = pcM;
        case(opM)
            `LB:begin
                selM=4'b0000;
                case(aluoutM[1:0])
                    2'b11: final_readdataM = {{24{readdataM[31]}},readdataM[31:24]};
					2'b10: final_readdataM = {{24{readdataM[23]}},readdataM[23:16]};
					2'b01: final_readdataM = {{24{readdataM[15]}},readdataM[15:8]};
					2'b00: final_readdataM = {{24{readdataM[7]}},readdataM[7:0]};
					default:final_readdataM =32'h00000000;
			    endcase
            end
            
            `LBU:begin
                selM=4'b0000;
                case(aluoutM[1:0])
                    2'b11: final_readdataM = {{24{1'b0}},readdataM[31:24]};
					2'b10: final_readdataM = {{24{1'b0}},readdataM[23:16]};
					2'b01: final_readdataM = {{24{1'b0}},readdataM[15:8]};
					2'b00: final_readdataM = {{24{1'b0}},readdataM[7:0]};
					default:final_readdataM =32'h00000000;
			    endcase
            end
            
            `LH:begin
                case(aluoutM[1:0])
					2'b10: begin 
					           selM=4'b0000; 
					           final_readdataM = {{16{readdataM[31]}},readdataM[31:16]};
					       end
					2'b00: begin 
					           selM=4'b0000; 
					           final_readdataM = {{16{readdataM[15]}},readdataM[15:0]};
					       end
					default: begin
                               adelM = 1'b1;
                               bad_addrM = aluoutM;
						       selM = 4'b0000;
					       end 
			    endcase
            end
            
            `LHU:begin
                case(aluoutM[1:0])
					2'b10: begin
					           selM=4'b0000; 
					           final_readdataM = {{16{1'b0}},readdataM[31:16]};
					       end
					2'b00: begin
					           selM=4'b0000; 
					           final_readdataM = {{16{1'b0}},readdataM[15:0]};
					       end
					default: begin
                               adelM = 1'b1;
                               bad_addrM = aluoutM;
						       selM = 4'b0000;
					       end 
			    endcase
            end
            
            `LW:begin
                if(aluoutM[1:0] != 2'b00) begin
					adelM = 1'b1;
					bad_addrM = aluoutM;
					selM = 4'b0000;
				end
				else begin
				    selM = 4'b0000;
				    final_readdataM = readdataM;
				end
            end
            
            `SB:begin
                final_writedataM = {writedataM[7:0],writedataM[7:0],writedataM[7:0],writedataM[7:0]};
                case (aluoutM[1:0])
					2'b11:selM = 4'b1000;
					2'b10:selM = 4'b0100;
					2'b01:selM = 4'b0010;
					2'b00:selM = 4'b0001;
					default:selM =4'b0000;
				endcase
            end
            
            `SH:begin
                final_writedataM = {writedataM[15:0],writedataM[15:0]};
                case (aluoutM[1:0])
					2'b10:selM = 4'b1100;
					2'b00:selM = 4'b0011;
					default :begin 
						adesM = 1'b1;
						bad_addrM = aluoutM;
						selM = 4'b0000;
					end 
				endcase
            end
            
            `SW:begin
                final_writedataM = writedataM;
                if(aluoutM[1:0]==2'b00)begin
                    selM = 4'b1111;
                end
                else begin
                    adesM = 1'b1;
					bad_addrM = aluoutM;
					selM = 4'b0000;
                end
            end
            
            default :begin
                         selM = 4'b0000;
                         final_readdataM=32'b0;
                         final_writedataM=32'b0;
                     end
                    
        endcase
        
    end
endmodule
