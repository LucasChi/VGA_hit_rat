`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/21 09:48:34
// Design Name: 
// Module Name: VGA00
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

module VGA(clock,switch,disp_RGB,hsync,vsync,up,down,left,right,middle,rst ,QC_OUT,QA_OUT,led);
input clock;    //系统输入时钟100MHz
input[1:0]switch;
input rst;
output [7:0] QC_OUT; 
output[3:0] QA_OUT;   
output [7:0] led;
input up,down,left,right,middle;
output[11:0]disp_RGB;//VGA数据输出
output hsync;//VGA行同步信号
output vsync;//VGA场同步信号
reg [9:0]  hcount;   //VGA行扫描计数器
reg [9:0]  vcount; //VGA场扫描计数器
reg [11:0]  data;
reg [11:0]  h_dat;
reg [11:0]  v_dat;
reg [11:0] x_dat;
reg [11:0] data1;
reg flag=0;
wire hcount_ov;
wire vcount_ov;
wire dat_act;
wire hsync;
wire vsync;
reg background=12'b010010000101;   
reg gezi=12'b01010100001;
reg jieshuse=12'hf00;
reg vga_clk=0;
reg cnt_clk=0;//分频计数
   


always@(posedge clock)
begin
if(cnt_clk==1)begin
vga_clk<=~vga_clk;
cnt_clk<=0;
end
else
cnt_clk<=cnt_clk+1;
end
//***************VGA驱动部分*****************8//
//行扫描
// VGA行、场扫描时序参数表
parameter hsync_end =10'd95,
hdat_begin=10'd143,
hdat_end=10'd783,
hpixel_end=10'd799,
vsync_end=10'd1,
vdat_begin =10'd34,
vdat_end=10'd514,
vline_end=10'd524;

always@(posedge clock)
begin
if(cnt_clk==1)begin
vga_clk<=~vga_clk;
cnt_clk<=0;
end
else
cnt_clk<=cnt_clk+1;
end
//***************VGA驱动部分*****************8//
//行扫描

always@(posedge vga_clk)
begin
    if(hcount_ov)
    hcount<=10'd0;
    else
    hcount <= hcount + 10'd1;
 end
assign hcount_ov =(hcount==hpixel_end);

//场扫描
always@(posedge vga_clk)
begin 
    if(hcount_ov)
begin 
         if(vcount_ov)
           vcount<=10'd0;
        else 
    vcount<=vcount+10'd1;
    end
    end
    assign vcount_ov=(vcount==vline_end);
    
    //数据、同步信号
    assign dat_act=((hcount>=hdat_begin)&&(hcount<hdat_end))&&((vcount>=vdat_begin)&&(vcount<vdat_end));
    assign hsync=(hcount>hsync_end);
    assign vsync=(vcount>vsync_end);
    assign disp_RGB=(dat_act)?data:12'h00;
    
  //显示图像  
   /* always@(posedge vga_clk)
begin
        case(switch[1:0])
        2'd0:data<=h_dat;
        2'd1:data<=v_dat;
        2'd2:data<=h_dat&v_dat;
        2'd3:data<=x_dat&h_dat&v_dat;
   
        endcase;
end */
  
//计时1秒
reg [28:0]jishu_1s=0;
reg clk_1s=0;
 localparam tick=50000000;
always @ (posedge clock)
begin
         if(jishu_1s==tick)
          begin
           jishu_1s<=0;
           clk_1s=~clk_1s;
          end
        else
           begin
           jishu_1s<=jishu_1s+1;
           end 
end

//计时50ms
reg clk_50ms=0;
    localparam DVSR=5000000;
      reg [28:0] js;
always @ (posedge clock)
begin
         if(js==DVSR)
          begin
           js<=0;
           clk_50ms=~clk_50ms;
          end
        else
           begin
           js<=js+1;
           end 
end


//产生竖长条
always@(posedge vga_clk)
begin
    if(hcount<=220||hcount>=620)
	v_dat <= 12'h000;//hei
    else if(hcount==240 ||hcount ==360||hcount ==480||hcount==600)
      v_dat <= 12'h000;//hei
   else 
     v_dat <= 12'hfff;//bai
end

//产生横长条
always@(posedge vga_clk)
begin
    if(vcount<=70||vcount>=470)
	h_dat <= 12'h000;//hei
    else if(vcount==90 ||vcount ==210||vcount ==330||vcount ==450)
      h_dat <= 12'h000;
   else
     h_dat <= 12'hfff;                                                      //背景
end


parameter  WIDTH = 60, //矩形长
                                        HEIGHT = 60,  //矩形宽
                                         //显示区域的边界
                                       DISV_TOP = 10'd120,
                                      DISV_DOWN =DISV_TOP+HEIGHT,
                                       DISH_LEFT = 10'd270,
                                       DISH_RIGHT = DISH_LEFT + WIDTH;

                             //初始矩形的位置，在显示区的左下角               
                             reg [9:0] topbound =DISV_TOP;
                           reg [9:0] downbound  ;
                             reg [9:0] leftbound = DISH_LEFT ;
                           reg [9:0] rightbound  ;
                             reg [2:0] weizhi=0;
          
     //5个位置信息                        
  always@(posedge clk_50ms)
begin
    case(weizhi[2:0])
        
         3'b000:begin 
                                                 leftbound<=10'd390; //上
                                                topbound<=10'd120;
                                         end
         3'b001:begin 
                                                 leftbound<=10'd270;
                                                topbound<=10'd240; //左
                                         end 
        3'b010:  begin 
                                            leftbound<=10'd390;
                                                topbound<=10'd240;   //中                                           
                                         end
       3'b011:  begin
                                           leftbound<=10'd510;
                                                topbound<=10'd240;  //右
                                       end      
       3'b100:  begin
                                                leftbound<=10'd390;
                                                topbound<=10'd360; //下
                                      end
                           
     endcase
end

reg flag_on=0;
    always @(posedge clk_50ms) begin 
                                    if( up==1 && weizhi==0 )begin
                                   flag<=1;
                                 //  flag_on<=1;
                                   end
                                   else if( left==1 && weizhi==1 )begin
                                   flag<=1;
                                //   flag_on<=1;
                                   end
                               else if( middle==1 && weizhi==2 )begin
                                   flag<=1;
                                //   flag_on<=1;
                                   end
                                 else   if( right==1 && weizhi==3 )begin
                                   flag<=1;
                                   flag_on<=1;
                                   end
                              else   if( down==1 && weizhi==4 )begin
                                   flag<=1;
                                //   flag_on<=1;
                                   end
                                  else   begin
                                  flag<=0;
                             //    flag_on<=0;
                                  end
                             end
                             
//每过2秒色块换一个位置
reg [7:0] Q1;
reg [7:0] Q2;
reg [7:0] Q3;
reg [7:0] Q4;
reg [7:0] Q;
reg [7:0] Q_OUT; 
reg [5:0] i=0;
wire [7:0] position[0:19];
assign position[0]=0;
assign position[1]=4; 
assign position[2]=2;
assign position[3]=1;
assign position[4]=3;
assign position[5]=0;
assign position[6]=4; 
assign position[7]=1;
assign position[8]=2;
assign position[9]=4;
assign position[10]=0;
assign position[11]=2; 
assign position[12]=1;
assign position[13]=3;
assign position[14]=1;
assign position[15]=0;
assign position[16]=3; 
assign position[17]=2;
assign position[18]=1;
assign position[19]=4;    
reg [11:0]data2=12'h652;
 reg count_20=0;
reg [5:0]num=0;              
reg [5:0]num1=0;    
 reg [5:0]cnt_30ss=30;    
 reg flag_kaishi=0;
  reg flag_jieshu=0;
  reg [4:0]cnt_30s=0;
  always@(posedge clk_1s)
begin
i<=i+1;
weizhi<=position[i];
if(i>=19)
i<=0;
if(weizhi>=5)
weizhi<=0;
if(flag==1)
num1<=num1+1;
if(num1==30)begin
num1<=0;
 x_dat<= data2;
end
if(rst==1)
num1<=0;
if( flag_kaishi )
cnt_30ss<=cnt_30ss-1;
if(cnt_30ss==0)
cnt_30ss<=0;
end
           
                   //着色一个小色块
     always @(posedge clock) begin  
                                     rightbound = leftbound + 10'd60 ;
                                     downbound = topbound + 10'd60;
                                    if( hcount >= leftbound &&  hcount <= rightbound &&  vcount<= downbound &&  vcount >= topbound && flag==0)
                                    x_dat<= 12'h0f0;
                                    else if( hcount >= leftbound &&  hcount <= rightbound &&  vcount<= downbound &&  vcount >= topbound && flag==1)begin
                                    x_dat<= 12'hf00;     
                                    end    
                                  else 
                                    x_dat<=12'hfff; //黑色
                             end               
  
/*   always@(posedge clk_1s)
begin
          if( flag_kaishi==1)
        cnt_30s<=cnt_30s-1; 
            else
            cnt_30s<=23;m
end
*/
   always@(posedge clock)
begin
 if(rst==1)
 num<=0;
 cnt_30ss<=30;
end
  //显示图像  
    always@(posedge clock)
begin
           if(rst)begin
      data1<=h_dat&v_dat;
      cnt_30ss<=30;
      flag_kaishi<=0;
      flag_jieshu<=0;
  //    num1<=0;
    end
    
      if(!rst && up==1||down==1||left==1||right==1||middle==1)
     flag_kaishi=1;
     
     if(!rst && flag_kaishi==1 && !flag_jieshu)
    data1<=x_dat&h_dat&v_dat;
     
     if(cnt_30ss==0)begin
     flag_jieshu=1;      
    // data1<= hcount;

     end                               //背景
        case(switch[1:0])
        2'd0:data<=data1;
        2'd1:data<=data1;
        2'd2:data<=data1;
        2'd3:data<=data2;
        endcase;
end



    reg[28:0]jishu_96hz=0;  //余晖至少要96Hz  100MHz/2^19=190.73Hz  
     reg [2:0]hex_in;
 localparam tick1=200008;
 reg clk_96hz=0;
reg  clk_190;
    reg [7:0] QC_OUT;
    reg [3:0] QA_OUT; 
 //   reg [5:0]cnt_30s1=24;
 //   reg [5:0] num1=26;
    

//时钟分频96hz
always@(posedge clock)
begin
         if(jishu_96hz==tick1)
          begin
           jishu_96hz<=0;
           clk_96hz=~clk_96hz;
          end
        else
           begin
           jishu_96hz<=jishu_96hz+1;
           end 
end

    
 always@(posedge clock) begin
 num=num1; 
 Q1=num/10;   
Q2=cnt_30ss%10;
Q3=cnt_30ss/10;
Q4=num%10;
end



//数码管译码
   always @(posedge vga_clk)
          begin
              case(Q)
                  0:       QC_OUT <= 8'b11111100; 
                  1:       QC_OUT <= 8'b01100000;   
                  2:      QC_OUT <= 8'b11011010;     
                  3:      QC_OUT <= 8'b11110010;  
                  4:       QC_OUT <= 8'b01100110;   
                  5:      QC_OUT<=8'b10110110;   
                    6:      QC_OUT<=8'b10111110;   
                    7:      QC_OUT<=8'b11100000;   
                    8:      QC_OUT<=8'b11111110;   
                    9:      QC_OUT<=8'b11110110;   
                 default:   QC_OUT <= 8'b00000000;           
              endcase            
          end
          

           
  //数码管片选
    always@(posedge clk_96hz )
       case(QA_OUT)
           4'd1:
               begin
                    Q<=Q1;
                    QA_OUT<= 2;                 
               end
           4'd2:
               begin
                    Q<=Q2;
                    QA_OUT<=4;
                    end
             4'd4:
               begin
                       Q<=Q3;          
                    QA_OUT<=8;
                    end
             4'd8:
               begin
                    Q<=Q4;
                    QA_OUT<=1;
                    end
               
             default : begin 
                QA_OUT<=4'b0001;
                end
           endcase


endmodule