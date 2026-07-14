`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input               clk;
input               reset;
input               gray_ready;
input      [7:0]    gray_data;
output reg [13:0]   gray_addr;
output reg          gray_req;
output reg [13:0]   lbp_addr;
output reg          lbp_valid;
output reg [7:0]    lbp_data;
output reg          finish;
//====================================================================

reg [7:0] gc,gp; //存讀進來的data
reg [7:0] lbp_xy;  //存計算後的值 ,
reg [3:0] counter,counter11;
reg [13:0] counter2;
reg [8:0] counter3;
reg ready_to_finish;
wire s;

always @(posedge clk or posedge reset)
begin
    if(reset)
        gray_req <= 1'b0;              //reset 後 gray_ready=1
    else if(gray_ready)
        gray_req <= 1'b1;    // 下一個clk gray_req=1
    else
        gray_req <= gray_req;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        counter11 <= 4'd0;
    else if(counter11 == 4'd11 || counter2 == 14'd128)
        counter11<=4'd0;
    else
        counter11 <= counter11 +4'd1;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        counter <= 4'd0;
    else
        counter <= counter11;
end

always @(posedge clk or posedge reset)
begin
    if (reset)
        counter2 <= 14'd0;   // 從129開始抓 ,130,131,132....
    else if(gray_ready && (~gray_req))
        counter2 <= 14'd128;
    else if(counter2 == 9'd128)
        counter2 <= counter2 +1'd1;
    else if(counter2[6:0] != 7'b1111110 && counter == 4'd10 )
        counter2 <= counter2 +1'd1;
    else if(counter2[6:0] == 7'b1111110 && counter == 4'd10)
        counter2 <= counter2 +2'd3;       //10000001 =1111110+11
    else
        counter2 <= counter2;
end

always @(posedge clk or posedge reset)
begin
    if(reset)
        gray_addr <= 14'd0;
    else
    begin
        case(counter11)
            4'd0:
                gray_addr <= counter2 ;              //先抓gc
            4'd1:
                gray_addr <= counter2 - 9'd129;      //g0
            4'd2:
                gray_addr <= counter2 - 8'd128;      //g1
            4'd3:
                gray_addr <= counter2 - 8'd127;      //g2
            4'd4:
                gray_addr <= counter2 - 1'd1  ;      //g3
            4'd5:
                gray_addr <= counter2 + 1'd1  ;      //g4
            4'd6:
                gray_addr <= counter2 + 8'd127;      //g5
            4'd7:
                gray_addr <= counter2 + 8'd128;      //g6
            4'd8:
                gray_addr <= counter2 + 9'd129;      //g7
            default:
                gray_addr <= 14'd0;
        endcase
    end
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        gc<=8'd0;
    else
    begin
        case(counter11)
            4'd1:
                gc <= gray_data;        //129  gc
            4'd2:
                gc <= gc;
            4'd3:
                gc <= gc;
            4'd4:
                gc <= gc;
            4'd5:
                gc <= gc;
            4'd6:
                gc <= gc;
            4'd7:
                gc <= gc;
            4'd8:
                gc <= gc;
            4'd9:
                gc <= gc;
            default:
                gc <= 8'd0;
        endcase
    end
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        gp<=8'd0;
    else if(gray_ready)
    begin
        case(counter11)
            4'd1:
                gp <= 8'd0;
            4'd2:
                gp <= gray_data;          //g0
            4'd3:
                gp <= gray_data;          //g1
            4'd4:
                gp <= gray_data;          //g2
            4'd5:
                gp <= gray_data;          //g3
            4'd6:
                gp <= gray_data;          //g4
            4'd7:
                gp <= gray_data;          //g5
            4'd8:
                gp <= gray_data;          //g6
            4'd9:
                gp <= gray_data;          //g7
            default:
                gp <= 8'd0;
        endcase
    end
end

assign s = ((gp > gc) || (gp == gc)) ? 1'b1 : 1'b0;

always@(posedge clk or posedge reset)
begin
    if(reset)
        lbp_xy <= 8'd0;
    else
    begin
        case(counter11)
            4'd0:
                lbp_xy <= 8'd0;
            4'd1:
                lbp_xy <= 8'd0;
            4'd2:
                lbp_xy <= 8'd0;               //沒運算
            4'd3:
                lbp_xy <= { {7'b0} , s} ;
            4'd4:
                lbp_xy <= { {6'b0} , s, lbp_xy[0] } ;
            4'd5:
                lbp_xy <= { {5'b0} , s, lbp_xy[1], lbp_xy[0] } ;
            4'd6:
                lbp_xy <= { {4'b0} , s, lbp_xy[2], lbp_xy[1], lbp_xy[0] } ;
            4'd7:
                lbp_xy <= { {3'b0} , s, lbp_xy[3], lbp_xy[2], lbp_xy[1], lbp_xy[0] } ;
            4'd8:
                lbp_xy <= { {2'b0} , s, lbp_xy[4], lbp_xy[3], lbp_xy[2], lbp_xy[1], lbp_xy[0] } ;
            4'd9:
                lbp_xy <= { 1'b0    , s, lbp_xy[5], lbp_xy[4], lbp_xy[3], lbp_xy[2], lbp_xy[1], lbp_xy[0] } ;
            4'd10:
                lbp_xy <= {           s, lbp_xy[6], lbp_xy[5], lbp_xy[4], lbp_xy[3], lbp_xy[2], lbp_xy[1], lbp_xy[0] } ;
            default:
                lbp_xy <= lbp_xy;
        endcase
    end
end




always@(posedge clk or posedge reset)
begin
    if(reset)
    begin
        lbp_valid <= 1'd0;
        lbp_data <= 8'd0;
    end
    else if(counter == 4'd10)
    begin
        lbp_valid <= 1'd1;
        lbp_data <= lbp_xy;
    end   // 計算完一個矩陣發出lpb_valid信號
    else
    begin
        lbp_valid <= 1'd0;
        lbp_data <= 8'd0;
    end
end




always@(posedge clk or posedge reset)
begin      //寫回的位址
    if(reset)
        lbp_addr <= 9'd129;
    else
        lbp_addr <= counter2 ;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        ready_to_finish <= 1'd0;
    else if (counter2 == 14'd16254)
        ready_to_finish <= 1'd1;
    else
        ready_to_finish <= ready_to_finish;
end

always@(posedge clk or posedge reset)
begin     //一開始 finish=0 全部計算完 =1
    if(reset)
        finish <= 1'd0;
    else if( counter == 4'd10 && ready_to_finish)
        finish <= 1'd1;
    else
        finish <= finish;
end

endmodule

