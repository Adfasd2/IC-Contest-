module huffman(clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;
//wire count_state;
reg [7:0] compare0,compare1,compare2,compare3,compare4,compare5,gray_data_reg;
reg [5:0] done;
reg [4:0] state,next_state;
//reg [7:0] A0,A1,A2,A3,A4,A5;
reg [7:0] p [0:6];
reg [7:0] code [0:5];
reg [7:0] code_m [0:5];
wire[7:0] CNT_total;
wire [7:0] max0,mid0,min0,max1,mid1,min1,b0,b1,b2,b3,c1,c2,c3,c0,d0,d1,d2,d3,a0,a1,a2,a3,a4,a5,n0,n1,n2,n3,n4,n5;
integer i;
parameter  idle = 5'd0, count = 5'd1, initialization = 5'd2, combination1 = 5'd3, combination2 = 5'd4, combination3 = 5'd5, combination4 = 5'd6, split1 = 5'd7, split1_reorder = 5'd8;
parameter split2 = 5'd9,split2_reorder = 5'd10, split3 = 5'd11,split3_reorder = 5'd12,split4 = 5'd13, split4_reorder = 5'd14;
parameter hc1_state = 5'd15, hc2_state = 5'd16, hc3_state = 5'd17, hc4_state = 5'd18, hc5_state = 5'd19, hc6_state = 5'd20, output_data = 5'd21, finish = 5'd22,combination1_reorder = 5'd23,combination2_reorder = 5'd24,combination3_reorder = 5'd25,combination4_reorder = 5'd26;
//----------------------------------------------------------------------------------
assign CNT_total = CNT1 + CNT2 + CNT3 + CNT4 + CNT5 + CNT6;

always@(posedge clk or posedge reset)
begin
    if(reset)
        gray_data_reg <= 8'd0;
    else
        gray_data_reg <= gray_data;
end
//================狀態機===================//
always@(posedge clk or posedge reset)
begin
    if(reset)
        state <= idle;
    else
        state <= next_state;
end
always@(*)
begin
    case(state)
        idle:
        begin
            if(gray_valid == 1'd1)
                next_state = count;
            else
                next_state = idle;
        end
        count:
        begin
            if(gray_valid == 1'd0 && CNT_total == 8'd99)
                next_state = initialization;
            else
                next_state = count;
        end
        initialization:
            next_state = combination1;
        combination1:
            next_state = combination1_reorder;
        combination1_reorder:
            next_state = combination2;
        combination2:
            next_state = combination2_reorder;
        combination2_reorder:
            next_state = combination3;
        combination3:
            next_state = combination3_reorder;
        combination3_reorder:
            next_state = combination4;
        combination4:
            next_state = combination4_reorder;
        combination4_reorder:
            next_state = split1;
        split1:
            next_state = split1_reorder;
        split1_reorder:
            next_state = split2;
        split2:
            next_state = split2_reorder;
        split2_reorder:
            next_state = split3;
        split3:
            next_state = split3_reorder;
        split3_reorder:
            next_state = split4;
        split4:
            next_state = split4_reorder;
        split4_reorder:
            next_state = hc1_state;
        hc1_state:
            next_state = hc2_state;
        hc2_state:
            next_state = hc3_state;
        hc3_state:
            next_state = hc4_state;
        hc4_state:
            next_state = hc5_state;
        hc5_state:
            next_state = hc6_state;
        hc6_state:
            next_state = output_data;
        output_data:
            next_state = finish;
        default:
            next_state = state;
    endcase



end

//=====================================//

//==============CNT====================//
//assign count_state = (state == count);
always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT1 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd1)
        CNT1 <= CNT1 + 8'd1;
    else
        CNT1 <= CNT1;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT2 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd2)
        CNT2 <= CNT2 + 8'd1;
    else
        CNT2 <= CNT2;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT3 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd3)
        CNT3 <= CNT3 + 8'd1;
    else
        CNT3 <= CNT3;

end

always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT4 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd4)
        CNT4 <= CNT4 + 8'd1;
    else
        CNT4 <= CNT4;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT5 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd5)
        CNT5 <= CNT5 + 8'd1;
    else
        CNT5 <= CNT5;

end

always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT6 <= 8'd0;
    else if(state == count && gray_data_reg == 8'd6)
        CNT6 <= CNT6 + 8'd1;
    else
        CNT6 <= CNT6;
end
//=====================================//
always @(*)
begin
    case(state)
        initialization:
            compare0 = CNT1;
        // combination1_reorder:   compare0 = p[0];
        // combination2_reorder:   compare0 = p[0];
        // combination3_reorder:   compare0 = p[0];
        // split1_reorder: compare0 = p[0];
        // split2_reorder: compare0 = p[0];
        // split3_reorder: compare0 = p[0];
        default:
            compare0 = p[0];
    endcase
end
always @(*)
begin
    case(state)
        initialization:
            compare1 = CNT2;
        // combination1_reorder:   compare1 = p[1];
        // combination2_reorder:   compare1 = p[1];
        // combination3_reorder:   compare1 = p[1];
        // split1_reorder: compare1 = p[1];
        // split2_reorder: compare1 = p[1];
        // split3_reorder: compare1 = p[1];
        default:
            compare1 = p[1];
    endcase
end
always @(*)
begin
    case(state)
        initialization:
            compare2 = CNT3;
        // combination1_reorder:   compare2 = p[2];
        // combination2_reorder:   compare2 = p[2];
        // combination3_reorder:   compare2 = p[2];
        // split1_reorder: compare2 = p[2];
        // split2_reorder: compare2 = p[2];
        // split3_reorder: compare2 = p[2];
        default:
            compare2 = p[2];
    endcase
end
always @(*)
begin
    case(state)
        initialization:
            compare3 = CNT4;
        // combination1_reorder:   compare3 = p[3];
        // combination2_reorder:   compare3 = p[3];
        combination3_reorder:
            compare3 = 8'd0;
        split1_reorder:
            compare3 = 8'd0;
        // split2_reorder: compare3 = p[3];
        // split3_reorder: compare3 = p[3];
        default:
            compare3 = p[3];
    endcase
end
always @(*)
begin
    case(state)
        initialization:
            compare4 = CNT5;
        // combination1_reorder: compare4 = p[4];
        combination2_reorder:
            compare4 = 8'd0;
        combination3_reorder:
            compare4 = 8'd0;
        split1_reorder:
            compare4 = 8'd0;
        split2_reorder:
            compare4 = 8'd0;
        // split3_reorder: compare4 = p[4];
        default:
            compare4 = p[4];
    endcase
end
always @(*)
begin
    case(state)
        initialization:
            compare5 = CNT6;
        combination1_reorder:
            compare5 = 8'd0;
        combination2_reorder:
            compare5 = 8'd0;
        combination3_reorder:
            compare5 = 8'd0;
        split1_reorder:
            compare5 = 8'd0;
        split2_reorder:
            compare5 = 8'd0;
        split3_reorder:
            compare5 = 8'd0;
        default:
            compare5 = p[5];
    endcase
end
//============================排序==========================//


compare3 com0(compare0,compare1,compare2,max0,mid0,min0);
compare3 com1(compare3,compare4,compare5,max1,mid1,min1);
assign {n0,b0} = (max0 > max1) ? {max0,max1} : {max1,max0}; //最大   n0
assign {n5,b1} = (min0 < min1) ? {min0,min1} : {min1,min0}; //最小   n5
assign {b2,b3} = {mid0,mid1};
assign {c0,c1} = (b0 > b1) ? {b0,b1} : {b1,b0};
assign {c2,c3} = (b2 > b3) ? {b2,b3} : {b3,b2};
assign {d0,d1} = (c0 > c2) ? {c0,c2} : {c2,c0};
assign {d2,d3} = (c1 > c3) ? {c1,c3} : {c3,c1};
assign {n1,n4} = (d0 > d3) ? {d0,d3} : {d3,d0};
assign {n2,n3} = (d1 > d2) ? {d1,d2} : {d2,d1};
//========================================================//
//========================比大小=========================//
always @(posedge clk or posedge reset)
begin
    if(reset)
        for(i = 0 ; i<=5 ; i = i + 1)
        begin
            p[i] <= 8'd0;
        end             //p[0] 大 > 小 p[6]
    else
    begin
        case(state)
            initialization:
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,n4,n5,p[6]};
            combination1:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[3], p[4] + p[5], p[4] + p[5], p[4] };
            end
            combination1_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,n4,p[5],p[6]};
            end
            combination2:
            begin                                                                                                                                                                     //
                if(p[5] == p[4] || p[5] == p[3])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[3] + p[4],p[3] + p[4],p[5], p[6] };
                else if(p[5] == p[2])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[3],p[2] + p[4],p[2] + p[4],p[5], p[6] };
                else if(p[5] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[2],p[3],p[1] + p[4],p[1] + p[4],p[5], p[6] };
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[1],p[2],p[3],p[0] + p[4],p[0] + p[4],p[5], p[6] };
            end
            combination2_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,p[4],p[5],p[6]};
            end
            combination3:
            begin
                if(p[4] == p[3] || p[4] == p[2])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2]+p[3],p[2]+p[3],p[4],p[5],p[6] };
                else if(p[4] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[2],p[1]+p[3],p[1]+p[3],p[4],p[5],p[6] };
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <={p[1],p[2],p[0]+p[3],p[0]+p[3],p[4],p[5],p[6] };
            end
            combination3_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,p[3],p[4],p[5],p[6]};
            end
            combination4:
            begin
                if(p[2] == p[3] || p[1] == p[3])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1]+p[2],p[1]+p[2],p[3],p[4],p[5],p[6] };
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[1],p[0]+p[2],p[0]+p[2],p[3],p[4],p[5], p[6] };
            end
            combination4_reorder:
            begin
                if(p[0]>p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[3],p[4],p[5],p[6]};
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[1],p[0],p[2],p[3],p[4],p[5],p[6]};
            end
            split1:
            begin
                if(p[2] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[3],p[2] - p[3],p[3],p[4],p[5],p[6]};   //p2紀錄混合集團是多少
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[3],p[1],p[2] - p[3], p[3],p[4],p[5],p[6]};
            end
            split1_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,p[3],p[4],p[5],p[6]};
            end
            split2:
            begin
                if(p[3] == p[2])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[3] - p[4], p[4], p[4], p[5], p[6]};
                else if(p[3] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[3] - p[4], p[2], p[4], p[4], p[5], p[6]};
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[3] - p[4],p[1], p[2], p[4], p[4], p[5], p[6]};
            end
            split2_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,p[4],p[5],p[6]};
            end
            split3:
            begin
                if(p[4] == p[3])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2], p[5], p[4] - p[5], p[5], p[6]};
                else if(p[4] == p[2])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[5], p[3], p[4] - p[5], p[5], p[6]};
                else if(p[4] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[5],p[2], p[3], p[4] - p[5], p[5], p[6]};
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[5],p[1],p[2], p[3], p[4] - p[5], p[5], p[6]};
            end
            split3_reorder:
            begin
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,n4,p[5],p[6]};
            end
            split4:
            begin
                if(p[5] == p[4])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[3], p[6], p[5] - p[6], p[6]};
                else if(p[5] == p[3])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[6], p[4], p[5] - p[6], p[6]};
                else if(p[5] == p[2])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[6],p[3], p[4], p[5] - p[6], p[6]};
                else if(p[5] == p[1])
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[6],p[2],p[3], p[4], p[5] - p[6], p[6]};
                else
                    {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[6],p[1],p[2],p[3], p[4], p[5] - p[6], p[6]};
            end
            split4_reorder:
            begin
                // if(p[2] > max4) {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],max4,mid4,min4,p[6]};
                // else if(p[2] > mid4) {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],max4,p[2],mid4,min4,p[6]};
                // else if(p[2] > min4) {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],max4,mid4,p[2],min4,p[6]};
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {n0,n1,n2,n3,n4,n5,p[6]};
            end
            default:
                {p[0],p[1],p[2],p[3],p[4],p[5],p[6]} <= {p[0],p[1],p[2],p[3],p[4],p[5],p[6]};
        endcase
    end
end
//==============================================================//

//===================計算huffman code=====================//
always @(posedge clk or posedge reset)
begin
    if(reset)
        {code[0],code[1],code[2],code[3],code[4],code[5]} <= {48'd0};
    else
    begin
        case(state)
            combination4:
            begin
                {code[0],code[1],code[2],code[3],code[4],code[5]} <= {8'd0,8'd1,32'd0};
            end
            split1:
            begin
                if(p[2] == p[1])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0], code[1] << 1, (code[1] << 1) + 1'b1,code[3],code[4],code[5] };
                else
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[1], code[0] << 1, (code[0] << 1) + 1'b1,code[3],code[4],code[5] };
            end
            split2:
            begin
                if(p[3] == p[2])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[2] << 1, (code[2] << 1) + 1'b1,code[4],code[5]};
                else if(p[3] == p[1])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[2],code[1] << 1, (code[1] << 1) + 1'b1,code[4],code[5]};
                else
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[1],code[2],code[0] << 1, (code[0] << 1) + 1'b1,code[4],code[5]};
            end
            split3:
            begin
                if(p[4] == p[3])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[2],code[3] << 1, (code[3] << 1) + 1'b1,code[5]};
                else if(p[4] == p[2])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[3],code[2] << 1, (code[2] << 1) + 1'b1,code[5]};
                else if(p[4] == p[1])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[2],code[3],code[1] << 1, (code[1] << 1) + 1'b1,code[5]};
                else
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[1],code[2],code[3],code[0] << 1, (code[0] << 1) + 1'b1,code[5]};
            end
            split4:
            begin
                if(p[5] == p[4])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[2],code[3],code[4] << 1, (code[4] << 1) + 1'b1};
                else if(p[5] == p[3])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[2],code[4],code[3] << 1, (code[3] << 1) + 1'b1};
                else if(p[5] == p[2])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[1],code[3],code[4],code[2] << 1, (code[2] << 1) + 1'b1};
                else if(p[5] == p[1])
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[0],code[2],code[3],code[4],code[1] << 1, (code[1] << 1) + 1'b1};
                else
                    {code[0],code[1],code[2],code[3],code[4],code[5]} <= {code[1],code[2],code[3],code[4],code[0] << 1, (code[0] << 1) + 1'b1};
            end
        endcase
    end
end

//=======================================================//

//===================計算遮罩=====================//
always @(posedge clk or posedge reset)
begin
    if(reset)
        {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {48'b0};
    else if(state == combination1)
    begin
        {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {8'b1,8'b1,32'b0};
    end
    else if(state == split1)
    begin
        if(p[2] == p[1])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],(code_m[1] << 1) + 1'b1 ,(code_m[1] << 1) + 1'b1,code_m[3],code_m[4],code_m[5]};
        else
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[1],(code_m[0] << 1) + 1'b1 ,(code_m[0] << 1) + 1'b1,code_m[3],code_m[4],code_m[5]};
    end
    else if(state == split2)
    begin
        if(p[3] == p[2])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],(code_m[2] << 1) + 1'b1,(code_m[2] << 1) + 1'b1,code_m[4],code_m[5]};
        else if(p[3] == p[1])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[2],(code_m[1] << 1) + 1'b1,(code_m[1] << 1) + 1'b1,code_m[4],code_m[5]};
        else
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[1],code_m[2],(code_m[0] << 1) + 1'b1 ,(code_m[0] << 1) + 1'b1,code_m[4],code_m[5]};
    end
    else if(state == split3)
    begin
        if(p[4] == p[3])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],code_m[2],(code_m[3] << 1) + 1'b1,(code_m[3] << 1) + 1'b1,code_m[5]};
        else if(p[4] == p[2])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],code_m[3],(code_m[2] << 1) + 1'b1,(code_m[2] << 1) + 1'b1,code_m[5]};
        else if(p[4] == p[1])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[2],code_m[3],(code_m[1] << 1) + 1'b1,(code_m[1] << 1) + 1'b1,code_m[5]};
        else
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[1],code_m[2],code[3],(code_m[0] << 1) + 1'b1 ,(code_m[0] << 1) + 1'b1,code_m[5]};
    end

    else if(state == split4)
    begin
        if(p[5] == p[4])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],code_m[2],code_m[3],(code_m[4] << 1) + 1'b1,(code_m[4] << 1) + 1'b1};
        else if(p[5] == p[3])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],code_m[2],code_m[4],(code_m[3] << 1) + 1'b1,(code_m[3] << 1) + 1'b1};
        else if(p[5] == p[2])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[1],code_m[3],code_m[4],(code_m[2] << 1) + 1'b1,(code_m[2] << 1) + 1'b1};
        else if(p[5] == p[1])
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[0],code_m[2],code_m[3],code_m[4],(code_m[1] << 1) + 1'b1,(code_m[1] << 1) + 1'b1};
        else
            {code_m[0],code_m[1],code_m[2],code_m[3],code_m[4],code_m[5]} <= {code_m[1],code_m[2],code_m[3],code_m[4],(code_m[0] << 1) + 1'b1,(code_m[0] << 1) + 1'b1};
    end
end

//=======================================================//


//================CNT_valid=================//
always@(posedge clk or posedge reset)
begin
    if(reset)
        CNT_valid <= 1'd0;
    else if(state == initialization)
        CNT_valid <= 1'd1;
    else
        CNT_valid <= 1'd0;
end

//==================code_valid===================//

always@(posedge clk or posedge reset)
begin
    if(reset)
        code_valid <= 1'd0;
    else if(state == output_data)
        code_valid <= 1'd1;
    else
        code_valid <= 1'd0;
end
//================================================//

//======================輸出=======================//

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC1 <= 8'd0;
    else if(state == hc1_state)
    begin
        if     (CNT1 == p[0])
            HC1 <= code[0];
        else if(CNT1 == p[1])
            HC1 <= code[1];
        else if(CNT1 == p[2])
            HC1 <= code[2];
        else if(CNT1 == p[3])
            HC1 <= code[3];
        else if(CNT1 == p[4])
            HC1 <= code[4];
        else if(CNT1 == p[5])
            HC1 <= code[5];
    end
    else
        HC1 <= HC1;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M1 <= 8'd0;
    else if(state == hc1_state)
    begin
        if     (CNT1 == p[0])
            M1 <= code_m[0];
        else if(CNT1 == p[1])
            M1 <= code_m[1];
        else if(CNT1 == p[2])
            M1 <= code_m[2];
        else if(CNT1 == p[3])
            M1 <= code_m[3];
        else if(CNT1 == p[4])
            M1 <= code_m[4];
        else if(CNT1 == p[5])
            M1 <= code_m[5];
    end
    else
        M1 <= M1;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC2 <= 8'd0;
    else if(state == hc2_state)
    begin
        if     (CNT2 == p[0] && !done[0])
            HC2 <= code[0];
        else if(CNT2 == p[1] && !done[1])
            HC2 <= code[1];
        else if(CNT2 == p[2] && !done[2])
            HC2 <= code[2];
        else if(CNT2 == p[3] && !done[3])
            HC2 <= code[3];
        else if(CNT2 == p[4] && !done[4])
            HC2 <= code[4];
        else if(CNT2 == p[5] && !done[5])
            HC2 <= code[5];
    end
    else
        HC2 <= HC2;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M2 <= 8'd0;
    else if(state == hc2_state)
    begin
        if     (CNT2 == p[0] && !done[0])
            M2 <= code_m[0];
        else if(CNT2 == p[1] && !done[1])
            M2 <= code_m[1];
        else if(CNT2 == p[2] && !done[2])
            M2 <= code_m[2];
        else if(CNT2 == p[3] && !done[3])
            M2 <= code_m[3];
        else if(CNT2 == p[4] && !done[4])
            M2 <= code_m[4];
        else if(CNT2 == p[5] && !done[5])
            M2 <= code_m[5];
    end
    else
        M2 <= M2;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC3 <= 8'd0;
    else if(state == hc3_state)
    begin
        if     (CNT3 == p[0] && !done[0])
            HC3 <= code[0];
        else if(CNT3 == p[1] && !done[1])
            HC3 <= code[1];
        else if(CNT3 == p[2] && !done[2])
            HC3 <= code[2];
        else if(CNT3 == p[3] && !done[3])
            HC3 <= code[3];
        else if(CNT3 == p[4] && !done[4])
            HC3 <= code[4];
        else if(CNT3 == p[5] && !done[5])
            HC3 <= code[5];
    end
    else
        HC3 <= HC3;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M3 <= 8'd0;
    else if(state == hc3_state)
    begin
        if     (CNT3 == p[0] && !done[0])
            M3 <= code_m[0];
        else if(CNT3 == p[1] && !done[1])
            M3 <= code_m[1];
        else if(CNT3 == p[2] && !done[2])
            M3 <= code_m[2];
        else if(CNT3 == p[3] && !done[3])
            M3 <= code_m[3];
        else if(CNT3 == p[4] && !done[4])
            M3 <= code_m[4];
        else if(CNT3 == p[5] && !done[5])
            M3 <= code_m[5];
    end
    else
        M3 <= M3;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC4 <= 8'd0;
    else if(state == hc4_state)
    begin
        if     (CNT4 == p[0] && !done[0])
            HC4 <= code[0];
        else if(CNT4 == p[1] && !done[1])
            HC4 <= code[1];
        else if(CNT4 == p[2] && !done[2])
            HC4 <= code[2];
        else if(CNT4 == p[3] && !done[3])
            HC4 <= code[3];
        else if(CNT4 == p[4] && !done[4])
            HC4 <= code[4];
        else if(CNT4 == p[5] && !done[5])
            HC4 <= code[5];
    end
    else
        HC4 <= HC4;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M4 <= 8'd0;
    else if(state == hc4_state)
    begin
        if     (CNT4 == p[0] && !done[0])
            M4 <= code_m[0];
        else if(CNT4 == p[1] && !done[1])
            M4 <= code_m[1];
        else if(CNT4 == p[2] && !done[2])
            M4 <= code_m[2];
        else if(CNT4 == p[3] && !done[3])
            M4 <= code_m[3];
        else if(CNT4 == p[4] && !done[4])
            M4 <= code_m[4];
        else if(CNT4 == p[5] && !done[5])
            M4 <= code_m[5];
    end
    else
        M4 <= M4;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC5 <= 8'd0;
    else if(state == hc5_state)
    begin
        if     (CNT5 == p[0] && !done[0])
            HC5 <= code[0];
        else if(CNT5 == p[1] && !done[1])
            HC5 <= code[1];
        else if(CNT5 == p[2] && !done[2])
            HC5 <= code[2];
        else if(CNT5 == p[3] && !done[3])
            HC5 <= code[3];
        else if(CNT5 == p[4] && !done[4])
            HC5 <= code[4];
        else if(CNT5 == p[5] && !done[5])
            HC5 <= code[5];
    end
    else
        HC5 <= HC5;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M5 <= 8'd0;
    else if(state == hc5_state)
    begin
        if     (CNT5 == p[0] && !done[0])
            M5 <= code_m[0];
        else if(CNT5 == p[1] && !done[1])
            M5 <= code_m[1];
        else if(CNT5 == p[2] && !done[2])
            M5 <= code_m[2];
        else if(CNT5 == p[3] && !done[3])
            M5 <= code_m[3];
        else if(CNT5 == p[4] && !done[4])
            M5 <= code_m[4];
        else if(CNT5 == p[5] && !done[5])
            M5 <= code_m[5];
    end
    else
        M5 <= M5;
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        HC6 <= 8'd0;
    else if(state == hc6_state)
    begin
        if     (CNT6 == p[0] && !done[0])
            HC6 <= code[0];
        else if(CNT6 == p[1] && !done[1])
            HC6 <= code[1];
        else if(CNT6 == p[2] && !done[2])
            HC6 <= code[2];
        else if(CNT6 == p[3] && !done[3])
            HC6 <= code[3];
        else if(CNT6 == p[4] && !done[4])
            HC6 <= code[4];
        else if(CNT6 == p[5] && !done[5])
            HC6 <= code[5];
    end
    else
        HC6 <= HC6;
end
always@(posedge clk or posedge reset)
begin
    if(reset)
        M6 <= 8'd0;
    else if(state == hc6_state)
    begin
        if     (CNT6 == p[0] && !done[0])
            M6 <= code_m[0];
        else if(CNT6 == p[1] && !done[1])
            M6 <= code_m[1];
        else if(CNT6 == p[2] && !done[2])
            M6 <= code_m[2];
        else if(CNT6 == p[3] && !done[3])
            M6 <= code_m[3];
        else if(CNT6 == p[4] && !done[4])
            M6 <= code_m[4];
        else if(CNT6 == p[5] && !done[5])
            M6 <= code_m[5];
    end
    else
        M6 <= M6;
end


//=========================紀錄哪幾個寫過了==========================//
always @(posedge clk or posedge reset)
begin
    if(reset)
        done <= 6'b0;
    else if(state == hc1_state)
    begin
        if(CNT1 == p[0])
            done <= 6'b000001;
        else if(CNT1 == p[1])
            done <= 6'b000010;
        else if(CNT1 == p[2])
            done <= 6'b000100;
        else if(CNT1 == p[3])
            done <= 6'b001000;
        else if(CNT1 == p[4])
            done <= 6'b010000;
        else if(CNT1 == p[5])
            done <= 6'b100000;
    end
    else if(state == hc2_state)
    begin
        if(CNT2 == p[0] && !done[0])
            done <= done + 6'b000001;
        else if(CNT2 == p[1] && !done[1])
            done <= done + 6'b000010;
        else if(CNT2 == p[2] && !done[2])
            done <= done + 6'b000100;
        else if(CNT2 == p[3] && !done[3])
            done <= done + 6'b001000;
        else if(CNT2 == p[4] && !done[4])
            done <= done + 6'b010000;
        else if(CNT2 == p[5] && !done[5])
            done <= done + 6'b100000;
    end
    else if(state == hc3_state)
    begin
        if(CNT3 == p[0] && !done[0])
            done <= done + 6'b000001;
        else if(CNT3 == p[1] && !done[1])
            done <= done + 6'b000010;
        else if(CNT3 == p[2] && !done[2])
            done <= done + 6'b000100;
        else if(CNT3 == p[3] && !done[3])
            done <= done + 6'b001000;
        else if(CNT3 == p[4] && !done[4])
            done <= done + 6'b010000;
        else if(CNT3 == p[5] && !done[5])
            done <= done + 6'b100000;
    end
    else if(state == hc4_state)
    begin
        if(CNT4 == p[0] && !done[0])
            done <= done + 6'b000001;
        else if(CNT4 == p[1] && !done[1])
            done <= done + 6'b000010;
        else if(CNT4 == p[2] && !done[2])
            done <= done + 6'b000100;
        else if(CNT4 == p[3] && !done[3])
            done <= done + 6'b001000;
        else if(CNT4 == p[4] && !done[4])
            done <= done + 6'b010000;
        else if(CNT4 == p[5] && !done[5])
            done <= done + 6'b100000;
    end
    else if(state == hc5_state)
    begin
        if(CNT5 == p[0] && !done[0])
            done <= done + 6'b000001;
        else if(CNT5 == p[1] && !done[1])
            done <= done + 6'b000010;
        else if(CNT5 == p[2] && !done[2])
            done <= done + 6'b000100;
        else if(CNT5 == p[3] && !done[3])
            done <= done + 6'b001000;
        else if(CNT5 == p[4] && !done[4])
            done <= done + 6'b010000;
        else if(CNT5 == p[5] && !done[5])
            done <= done + 6'b100000;
    end
    else if(state == hc6_state)
    begin
        if(CNT6 == p[0] && !done[0])
            done <= done + 6'b000001;
        else if(CNT6 == p[1] && !done[1])
            done <= done + 6'b000010;
        else if(CNT6 == p[2] && !done[2])
            done <= done + 6'b000100;
        else if(CNT6 == p[3] && !done[3])
            done <= done + 6'b001000;
        else if(CNT6 == p[4] && !done[4])
            done <= done + 6'b010000;
        else if(CNT6 == p[5] && !done[5])
            done <= done + 6'b100000;
    end
    else
        done <= done;
end

//====================================================================//


endmodule




    module compare3(in1,in2,in3,max,mid,min);
input [7:0] in1,in2,in3;
output [7:0] max,mid,min;
wire [7:0] max1,mid1,min1,max2,mid2,min2;
assign {max1,mid1,min1} = (in1 > in2) ? {in1,in2,in3} : {in2,in1,in3};
assign {max2,mid2,min2} = (max1 > min1) ? {max1,mid1,min1} : {min1,mid1,max1};
assign {max,mid,min} = (mid2 > min2) ? {max2,mid2,min2} : {max2,min2,mid2};
endmodule


