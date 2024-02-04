`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 21:02:26
// Design Name: 
// Module Name: div
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


module quick_div(
    input wire clk,rst,
    input wire [31:0] a,b,  //a是被除数，b是除数
    input wire valid,
    input wire is_sign,  //用来判断是否是有符号的除法运算
    output reg div_stall,  //标记除法器是否正忙
    output wire [63:0] result   //高32位是余数，低32位是商
    );
    
    wire [31:0] divident_abs,divisor_abs;
    wire [31:0] final_remainer,final_quotient;
    reg [31:0] a_save,b_save;
    reg is_sign_save;
    reg [64:0] Shift_right;   //开始时，32位除数左移一位后放在高33位，低32位填0
    reg [31:0] remainer_temp; //余数，初始化为被除数，最后不断减除数后，结果为余数
    wire [31:0] quotient_temp;
    wire [32:0] divisor_temp;
    wire carry_out;    //加法器进位：用来判断当前被除数-除数是大于等于0还是小于0
    wire [32:0] sub_result;
    wire [31:0] mux_result;
    reg left_shift; //是否是左移阶段：除数还能增大的阶段
    reg [31:0] flag;
    
    assign divisor_temp = Shift_right[64:32];   //除数是移位寄存器的高33位
    assign quotient_temp = {Shift_right[0],Shift_right[1],Shift_right[2],Shift_right[3],Shift_right[4],Shift_right[5],Shift_right[6],Shift_right[7],Shift_right[8],
                       Shift_right[9],Shift_right[10],Shift_right[11],Shift_right[12],Shift_right[13],Shift_right[14],Shift_right[15],Shift_right[16],
                       Shift_right[17],Shift_right[18],Shift_right[19],Shift_right[20],Shift_right[21],Shift_right[22],Shift_right[23],Shift_right[24],
                       Shift_right[25],Shift_right[26],Shift_right[27],Shift_right[28],Shift_right[29],Shift_right[30],Shift_right[31]}; //商是移位寄存器的低32位的逆序
    
    //求绝对值
    assign divident_abs = (is_sign & a[31]) ? ~a + 1'b1 : a;
    assign divisor_abs = (is_sign & b[31]) ? ~b + 1'b1 : b;
    
    adder_with_carry adder(1'b1,~divisor_temp,{1'b0,remainer_temp},sub_result,carry_out); //被除数-除数
    
    
    assign mux_result = !left_shift & carry_out ? sub_result[31:0] : remainer_temp;   //右移阶段说明在做除法：carry_out为1，说明被除数减去除数大于0：更新被除数；反之不变
    
    //除
    always @(posedge clk,posedge rst) begin
        if(rst)begin
            div_stall <= 1'b0;    
            left_shift <=1'b0; 
            a_save <= 1'b0;
            b_save <= 1'b0;
            is_sign_save <= 1'b0;
            remainer_temp <= 32'b0;
            Shift_right<= 33'b0;
            flag <= 32'h0000_0000;
        end
        
        else if(!div_stall & valid) begin   //当前除法器正空闲，可以开始工作,进行初始化
            left_shift <= 1'b1;
            div_stall <= 1'b1;
            a_save <= a;
            b_save <= b;
            is_sign_save <= is_sign;
            remainer_temp <= divident_abs;
            Shift_right[64:32] <= {divisor_abs[31:0],1'b0};  //初始化左移一格
            flag <= 32'h0000_0002;
            Shift_right[31:0] <= 32'b0;
        end
        
        else if(div_stall) begin   //除法器开始工作
            if(left_shift & carry_out) begin    //carry_out=1说明可以除
                Shift_right <= {Shift_right[63:0],1'b0};   //左移除数:扩大除数
                flag <= {flag[30:0],1'b0};
            end
            if(left_shift & !carry_out) begin   //carry_out=0说明被除数小于除数
                left_shift <= 1'b0;       //左移结束
                Shift_right <= {1'b0,Shift_right[64:1]};    //除数右移一格
                flag <= {1'b0,flag[31:1]}; 
            end
            else if(!left_shift) begin  //开始做除法
                if(flag[0]) begin //flag的1移动到第0位，除法结束
                   //end
                    remainer_temp <= mux_result;
                    Shift_right[31] <= carry_out;   //更新最新的商
                    div_stall <= 1'b0; 
                end
                else begin
                    remainer_temp <= mux_result;
                    Shift_right <= {1'b0,Shift_right[64:32],carry_out,Shift_right[30:1]}; //更新最新的商
                    flag <= {1'b0,flag[31:1]};
                end
            end
        end
    end
    
    //余数符号与被除数相同
    assign final_remainer = (is_sign_save & a_save[31]) ? ~remainer_temp + 1'b1 : remainer_temp;
    assign final_quotient = (is_sign_save & (a_save[31] ^ b_save[31])) ? ~quotient_temp + 1'b1 : quotient_temp;
    assign result = {final_remainer,final_quotient};
    
endmodule
