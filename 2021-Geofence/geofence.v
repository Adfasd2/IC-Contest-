//synopsys translate_off
`include "DW_sqrt.v"
//synopsys translate_on
module geofence( clk,reset,X,Y,R,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
input [10:0] R;
output  reg valid;
output  reg is_inside;
//============================================================================ 

integer i;
reg [9:0] x_buffer, y_buffer; 
reg [10:0] r_buffer;
reg [9:0] x_data [1:6];
reg [9:0] y_data [1:6];
reg [10:0] r_data [1:6];
reg [22:0] triangle_area [1:6];
reg signed [22:0] Polygon_area, triangle_area_total;
reg [4:0] state, next_state,counter_read_data;
wire signed [10:0] vector12_x,vector12_y,vector13_x,vector13_y,vector14_x,vector14_y,vector15_x,vector15_y,vector16_x,vector16_y ;
reg signed [10:0] ax,by,bx,ay;
wire signed [22:0] outer_product;
parameter read_data = 5'd0, calculate = 5'd1, receiver_order1 = 5'd2, receiver_order2 = 5'd3, receiver_order3 = 5'd4, receiver_order4 = 5'd5,receiver_order5 = 5'd6,receiver_order6 = 5'd7 ;
parameter receiver_order7 = 5'd8,receiver_order8 = 5'd9,receiver_order9 = 5'd10,receiver_order10 = 5'd11, triangle_area1 = 5'd12,triangle_area2 = 5'd13,triangle_area3 = 5'd14;
parameter triangle_area4 = 5'd15,triangle_area5 = 5'd16,triangle_area6 = 5'd17, Polygon_area1 = 5'd18, Polygon_area2 = 5'd19,Polygon_area3 = 5'd20,Polygon_area4 = 5'd21,Polygon_area5 = 5'd22,Polygon_area6 = 5'd23,Polygon_area7 = 5'd24, idle = 5'd25,finish = 5'd26;
wire outer_product_negative;
wire [11:0] a, tri1_after, tri2_after;
reg signed [10:0]  x_sub, y_sub;
reg [11:0] b,c,a_r;
wire signed [22:0]  tri_area,Polygon_area_add;
wire [22:0] a_before, tri1_before, tri2_before;
wire [14:0] s;

//=====input_buffer=====//
always @(posedge clk or posedge reset) 
begin
    if(reset)
        x_buffer <= 10'd0;
    else
        x_buffer <= X;    
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
        y_buffer <= 10'd0;
    else
        y_buffer <= Y;    
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
        r_buffer <= 11'd0;
    else
        r_buffer <= R;    
end
//======================//

//=======FSM=======//
always @(posedge clk or posedge reset) 
begin
    if(reset)
        state <= read_data;
    else 
        state <= next_state;    
end
always @(*)
begin
    case(state)
        read_data:
        begin
            if(counter_read_data == 3'd7)
                next_state = receiver_order1;
            else 
                next_state = read_data; 
        end
        receiver_order1:
            next_state = receiver_order2;
        receiver_order2:
            next_state = receiver_order3;
        receiver_order3:
            next_state = receiver_order4;
        receiver_order4:
            next_state = receiver_order5;
        receiver_order5:
            next_state = receiver_order6;
        receiver_order6:
            next_state = receiver_order7;
        receiver_order7:
            next_state = receiver_order8;
        receiver_order8:
            next_state = receiver_order9;
        receiver_order9:
            next_state = receiver_order10;
        receiver_order10:
            next_state = triangle_area1;
        triangle_area1:
        begin
            if(counter_read_data == 5'd2)
                next_state = triangle_area2;
            else 
                next_state = triangle_area1;
        end
        triangle_area2:
        begin
            if(counter_read_data == 5'd2)
                next_state = triangle_area3;
            else 
                next_state = triangle_area2;
        end
        triangle_area3:
        begin
            if(counter_read_data == 5'd2)
                next_state = triangle_area4;
            else 
                next_state = triangle_area3;
        end
        triangle_area4:
        begin
            if(counter_read_data == 5'd2)
                next_state = triangle_area5;
            else 
                next_state = triangle_area4;
        end
        triangle_area5:
        begin
            if(counter_read_data == 5'd2)
                next_state = triangle_area6;
            else 
                next_state = triangle_area5;
        end   
        triangle_area6:
        begin
            if(counter_read_data == 5'd2)
                next_state = Polygon_area1;
            else 
                next_state = triangle_area6;
        end  
        Polygon_area1:
            next_state = Polygon_area2;
        Polygon_area2:
            next_state = Polygon_area3;
        Polygon_area3:
            next_state = Polygon_area4;
        Polygon_area4:
            next_state = Polygon_area5;
        Polygon_area5:
            next_state = Polygon_area6;
        Polygon_area6:
            next_state = Polygon_area7;
        Polygon_area7:
            next_state = finish;
        finish:
            next_state = idle;
        idle:
            next_state = read_data;
        default:
            next_state = state;
    endcase
end
//================//
//===counter_read_data===//
always @(posedge clk or posedge reset) 
begin
    if(reset)
        counter_read_data <= 5'd0;
    else if(state == read_data)
        counter_read_data <= counter_read_data + 5'd1;
    else if(state == triangle_area1 || state == triangle_area2 || state == triangle_area3 || state == triangle_area4 || state == triangle_area5 || state == triangle_area6)
    begin
        if(counter_read_data == 5'd2)
            counter_read_data <= 5'd0;
        else 
            counter_read_data <= counter_read_data + 5'd1;
    end
    else if(state == Polygon_area7)
        counter_read_data <= 5'd0;
    else 
        counter_read_data <= 5'd0;
end
//=======================//
assign outer_product_negative = (outer_product[22] == 1'b1) || (outer_product == 23'd0);
//=======x1-x6 y1-y6 r1-r6======//
always @(posedge clk or posedge reset) 
begin
    if(reset)
    begin
        for(i=1;i<=6;i=i+1)
            x_data[i] <= 10'd0;
    end  
    else 
    begin
        case(state)
            read_data:
            begin   
                    x_data[counter_read_data] <= x_buffer;
            end
            receiver_order1:
            begin
                if(outer_product_negative)
                begin
                    x_data[2] <= x_data[2];
                    x_data[3] <= x_data[3];
                end
                else 
                begin
                    x_data[2] <= x_data[3];
                    x_data[3] <= x_data[2];
                end
            end
            receiver_order2:
            begin
                if(outer_product_negative)
                begin
                    x_data[2] <= x_data[2];
                    x_data[4] <= x_data[4];
                end
                else 
                begin
                    x_data[2] <= x_data[4];
                    x_data[4] <= x_data[2];
                end
            end
            receiver_order3:
            begin
                if(outer_product_negative)
                begin
                    x_data[2] <= x_data[2];
                    x_data[5] <= x_data[5];
                end
                else 
                begin
                    x_data[2] <= x_data[5];
                    x_data[5] <= x_data[2];
                end
            end
            receiver_order4:
            begin
                if(outer_product_negative)
                begin
                    x_data[2] <= x_data[2];
                    x_data[6] <= x_data[6];
                end
                else 
                begin
                    x_data[2] <= x_data[6];
                    x_data[6] <= x_data[2];
                end
            end
            receiver_order5:
            begin
                if(outer_product_negative)
                begin
                    x_data[3] <= x_data[3];
                    x_data[4] <= x_data[4];
                end
                else 
                begin
                    x_data[3] <= x_data[4];
                    x_data[4] <= x_data[3];
                end
            end
            receiver_order6:
            begin
                if(outer_product_negative)
                begin
                    x_data[3] <= x_data[3];
                    x_data[5] <= x_data[5];
                end
                else 
                begin
                    x_data[3] <= x_data[5];
                    x_data[5] <= x_data[3];
                end
            end
            receiver_order7:
            begin
                if(outer_product_negative)
                begin
                    x_data[3] <= x_data[3];
                    x_data[6] <= x_data[6];
                end
                else 
                begin
                    x_data[3] <= x_data[6];
                    x_data[6] <= x_data[3];
                end
            end
            receiver_order8:
            begin
                if(outer_product_negative)
                begin
                    x_data[4] <= x_data[4];
                    x_data[5] <= x_data[5];
                end
                else 
                begin
                    x_data[4] <= x_data[5];
                    x_data[5] <= x_data[4];
                end
            end
            receiver_order9:
            begin
                if(outer_product_negative)
                begin
                    x_data[4] <= x_data[4];
                    x_data[6] <= x_data[6];
                end
                else 
                begin
                    x_data[4] <= x_data[6];
                    x_data[6] <= x_data[4];
                end
            end
            receiver_order10:
            begin
                if(outer_product_negative)
                begin
                    x_data[5] <= x_data[5];
                    x_data[6] <= x_data[6];
                end
                else 
                begin
                    x_data[5] <= x_data[6];
                    x_data[6] <= x_data[5];
                end
            end
            Polygon_area7:
            begin
                for(i=1;i<=6;i=i+1)
                    x_data[i] <= 10'd0;
            end  
        endcase
    end  
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
    begin
        for(i=1;i<=6;i=i+1)
            y_data[i] <= 10'd0;
    end  
    else 
    begin
        case(state)
            read_data:
            begin
                    y_data[counter_read_data] <= y_buffer;
            end
            receiver_order1:
            begin
                if(outer_product_negative)
                begin
                    y_data[2] <= y_data[2];
                    y_data[3] <= y_data[3];
                end
                else 
                begin
                    y_data[2] <= y_data[3];
                    y_data[3] <= y_data[2];
                end
            end
            receiver_order2:
            begin
                if(outer_product_negative)
                begin
                    y_data[2] <= y_data[2];
                    y_data[4] <= y_data[4];
                end
                else 
                begin
                    y_data[2] <= y_data[4];
                    y_data[4] <= y_data[2];
                end
            end
            receiver_order3:
            begin
                if(outer_product_negative)
                begin
                    y_data[2] <= y_data[2];
                    y_data[5] <= y_data[5];
                end
                else 
                begin
                    y_data[2] <= y_data[5];
                    y_data[5] <= y_data[2];
                end
            end
            receiver_order4:
            begin
                if(outer_product_negative)
                begin
                    y_data[2] <= y_data[2];
                    y_data[6] <= y_data[6];
                end
                else 
                begin
                    y_data[2] <= y_data[6];
                    y_data[6] <= y_data[2];
                end
            end
            receiver_order5:
            begin
                if(outer_product_negative)
                begin
                    y_data[3] <= y_data[3];
                    y_data[4] <= y_data[4];
                end
                else 
                begin
                    y_data[3] <= y_data[4];
                    y_data[4] <= y_data[3];
                end
            end
            receiver_order6:
            begin
                if(outer_product_negative)
                begin
                    y_data[3] <= y_data[3];
                    y_data[5] <= y_data[5];
                end
                else 
                begin
                    y_data[3] <= y_data[5];
                    y_data[5] <= y_data[3];
                end
            end
            receiver_order7:
            begin
                if(outer_product_negative)
                begin
                    y_data[3] <= y_data[3];
                    y_data[6] <= y_data[6];
                end
                else 
                begin
                    y_data[3] <= y_data[6];
                    y_data[6] <= y_data[3];
                end
            end
            receiver_order8:
            begin
                if(outer_product_negative)
                begin
                    y_data[4] <= y_data[4];
                    y_data[5] <= y_data[5];
                end
                else 
                begin
                    y_data[4] <= y_data[5];
                    y_data[5] <= y_data[4];
                end
            end
            receiver_order9:
            begin
                if(outer_product_negative)
                begin
                    y_data[4] <= y_data[4];
                    y_data[6] <= y_data[6];
                end
                else 
                begin
                    y_data[4] <= y_data[6];
                    y_data[6] <= y_data[4];
                end
            end
            receiver_order10:
            begin
                if(outer_product_negative)
                begin
                    y_data[5] <= y_data[5];
                    y_data[6] <= y_data[6];
                end
                else 
                begin
                    y_data[5] <= y_data[6];
                    y_data[6] <= y_data[5];
                end
            end
            Polygon_area7:
            begin
                for(i=1;i<=6;i=i+1)
                    y_data[i] <= 10'd0;
            end 
        endcase
    end   
end
always @(posedge clk or posedge reset) 
begin
    if(reset)
    begin
        for(i=1;i<=6;i=i+1)
            r_data[i] <= 11'd0;
    end  
    else 
    begin
        case(state)
            read_data:
            begin
                r_data[counter_read_data] <= r_buffer;
            end
            receiver_order1:
            begin
                if(outer_product_negative)
                begin
                    r_data[2] <= r_data[2];
                    r_data[3] <= r_data[3];
                end
                else 
                begin
                    r_data[2] <= r_data[3];
                    r_data[3] <= r_data[2];
                end
            end
            receiver_order2:
            begin
                if(outer_product_negative)
                begin
                    r_data[2] <= r_data[2];
                    r_data[4] <= r_data[4];
                end
                else 
                begin
                    r_data[2] <= r_data[4];
                    r_data[4] <= r_data[2];
                end
            end
            receiver_order3:
            begin
                if(outer_product_negative)
                begin
                    r_data[2] <= r_data[2];
                    r_data[5] <= r_data[5];
                end
                else 
                begin
                    r_data[2] <= r_data[5];
                    r_data[5] <= r_data[2];
                end
            end
            receiver_order4:
            begin
                if(outer_product_negative)
                begin
                    r_data[2] <= r_data[2];
                    r_data[6] <= r_data[6];
                end
                else 
                begin
                    r_data[2] <= r_data[6];
                    r_data[6] <= r_data[2];
                end
            end
            receiver_order5:
            begin
                if(outer_product_negative)
                begin
                    r_data[3] <= r_data[3];
                    r_data[4] <= r_data[4];
                end
                else 
                begin
                    r_data[3] <= r_data[4];
                    r_data[4] <= r_data[3];
                end
            end
            receiver_order6:
            begin
                if(outer_product_negative)
                begin
                    r_data[3] <= r_data[3];
                    r_data[5] <= r_data[5];
                end
                else 
                begin
                    r_data[3] <= r_data[5];
                    r_data[5] <= r_data[3];
                end
            end
            receiver_order7:
            begin
                if(outer_product_negative)
                begin
                    r_data[3] <= r_data[3];
                    r_data[6] <= r_data[6];
                end
                else 
                begin
                    r_data[3] <= r_data[6];
                    r_data[6] <= r_data[3];
                end
            end
            receiver_order8:
            begin
                if(outer_product_negative)
                begin
                    r_data[4] <= r_data[4];
                    r_data[5] <= r_data[5];
                end
                else 
                begin
                    r_data[4] <= r_data[5];
                    r_data[5] <= r_data[4];
                end
            end
            receiver_order9:
            begin
                if(outer_product_negative)
                begin
                    r_data[4] <= r_data[4];
                    r_data[6] <= r_data[6];
                end
                else 
                begin
                    r_data[4] <= r_data[6];
                    r_data[6] <= r_data[4];
                end
            end
            receiver_order10:
            begin
                if(outer_product_negative)
                begin
                    r_data[5] <= r_data[5];
                    r_data[6] <= r_data[6];
                end
                else 
                begin
                    r_data[5] <= r_data[6];
                    r_data[6] <= r_data[5];
                end
            end
            Polygon_area7:
            begin
                for(i=1;i<=6;i=i+1)
                    r_data[i] <= 11'd0;
            end  
        endcase
    end  
end
//===================================//

//=======向量計算=======//
assign vector12_x = x_data[2] - x_data[1];
assign vector12_y = y_data[2] - y_data[1];
assign vector13_x = x_data[3] - x_data[1];
assign vector13_y = y_data[3] - y_data[1];
assign vector14_x = x_data[4] - x_data[1];
assign vector14_y = y_data[4] - y_data[1];
assign vector15_x = x_data[5] - x_data[1];
assign vector15_y = y_data[5] - y_data[1];
assign vector16_x = x_data[6] - x_data[1];
assign vector16_y = y_data[6] - y_data[1];



assign outer_product = ax * by - bx * ay;  //外積是負的表示a在b的逆時針方向

always @(*) 
begin  
    case(state)
        receiver_order1, receiver_order2, receiver_order3, receiver_order4:
            ax = vector12_x;
        receiver_order5, receiver_order6, receiver_order7:
            ax = vector13_x;
        receiver_order8, receiver_order9:
            ax = vector14_x;
        receiver_order10:
            ax = vector15_x;
        Polygon_area1:
            ax = x_data[2];
        Polygon_area2:
            ax = x_data[3];
        Polygon_area3:
            ax = x_data[4];
        Polygon_area4:
            ax = x_data[5];
        Polygon_area5:
            ax = x_data[6];
        Polygon_area6:
            ax = x_data[1];
        default:
            ax = 11'd0;
    endcase
end
always @(*) 
begin
    case(state)
        receiver_order1: 
            by = vector13_y;
        receiver_order2:
            by = vector14_y;
        receiver_order3:
            by = vector15_y;
        receiver_order4:
            by = vector16_y;
        receiver_order5:
            by = vector14_y;
        receiver_order6:
            by = vector15_y;
        receiver_order7:
            by = vector16_y;
        receiver_order8:
            by = vector15_y;
        receiver_order9:
            by = vector16_y;
        receiver_order10:
            by = vector16_y;
        Polygon_area1:
            by = y_data[1];
        Polygon_area2:
            by = y_data[2];
        Polygon_area3:
            by = y_data[3];
        Polygon_area4:
            by = y_data[4];
        Polygon_area5:
            by = y_data[5];
        Polygon_area6:
            by = y_data[6];
        default:
            by = 11'd0;
    endcase    
end
always @(*) 
begin
    case(state)
        receiver_order1: 
            bx = vector13_x;
        receiver_order2: 
            bx = vector14_x;
        receiver_order3: 
            bx = vector15_x;
        receiver_order4: 
            bx = vector16_x;
        receiver_order5:
            bx = vector14_x;
        receiver_order6:
            bx = vector15_x;
        receiver_order7:
            bx = vector16_x;
        receiver_order8:
            bx = vector15_x;
        receiver_order9:
            bx = vector16_x;
        receiver_order10:
            bx = vector16_x;
        Polygon_area1:
            bx = x_data[1];
        Polygon_area2:
            bx = x_data[2];
        Polygon_area3:
            bx = x_data[3];
        Polygon_area4:
            bx = x_data[4];
        Polygon_area5:
            bx = x_data[5];
        Polygon_area6:
            bx = x_data[6];
        default:
            bx = 11'd0;
    endcase    
end
always @(*) 
begin
    case(state)
        receiver_order1, receiver_order2, receiver_order3, receiver_order4:
            ay = vector12_y;
        receiver_order5, receiver_order6, receiver_order7:
            ay = vector13_y;
        receiver_order8, receiver_order9:
            ay = vector14_y;
        receiver_order10:
            ay = vector15_y;
        Polygon_area1:
            ay = y_data[2];
        Polygon_area2:
            ay = y_data[3];
        Polygon_area3:
            ay = y_data[4];
        Polygon_area4:
            ay = y_data[5];
        Polygon_area5:
            ay = y_data[6];
        Polygon_area6:
            ay = y_data[1];
        default:
            ay = 11'd0;

    endcase
       
end
//==================================//

//==========面積計算==========//
assign a_before = (x_sub * x_sub) + (y_sub * y_sub);  //距離 
DW_sqrt #(23,0)
         sqrt1(.a(a_before), .root(a));       //三角形其中一邊 另外兩邊是兩個R
always @(posedge clk or posedge reset) 
begin
    if(reset)
        a_r <= 12'd0;
    else if(state == triangle_area1 || state == triangle_area2 || state == triangle_area3 || state == triangle_area4 || state == triangle_area5 || state == triangle_area6) 
    begin
        if(counter_read_data == 5'd0)
            a_r <= a;
        else
            a_r <= a_r;
    end   
    else
        a_r <= a_r;
end
//========================//
assign s = (a_r + b + c) >> 1;
assign tri1_before = s * (s - a_r);
assign tri2_before = (s - b) * (s - c);
//========================//
DW_sqrt #(23,0)
         sqrt2(.a(tri1_before), .root(tri1_after));
DW_sqrt #(23,0)
         sqrt3(.a(tri2_before), .root(tri2_after));

assign tri_area = tri1_after * tri2_after; //最終結果再用循序存起來

always @(posedge clk or posedge reset) 
begin
    if(reset)
    begin
        for(i=1;i<=6;i=i+1)
            triangle_area[i] <= 23'd0;
    end  
    else if(counter_read_data == 5'd1)
    begin
        case(state)
            triangle_area1:
                triangle_area[1] <= tri_area;
            triangle_area2:
                triangle_area[2] <= tri_area;
            triangle_area3:
                triangle_area[3] <= tri_area;
            triangle_area4:
                triangle_area[4] <= tri_area;
            triangle_area5:
                triangle_area[5] <= tri_area;
            triangle_area6:
                triangle_area[6] <= tri_area;
        endcase
    end
end

always @(posedge clk or posedge reset) 
begin
    if(reset)
        triangle_area_total <= 23'd0;
    else if(state == read_data)
        triangle_area_total <= 23'd0;
    else if(state == Polygon_area1)
        triangle_area_total <= (triangle_area[1] + triangle_area[2]) + (triangle_area[3] + triangle_area[4]) + (triangle_area[5] + triangle_area[6]);
end
//=========================//
assign Polygon_area_add = Polygon_area + outer_product;

always @(posedge clk or posedge reset) 
begin
    if(reset)
        Polygon_area <= 23'd0; 
    else 
    begin
        case(state)
            idle:
                Polygon_area <= 23'd0;
            Polygon_area1:
                Polygon_area <= Polygon_area_add;
            Polygon_area2:
                Polygon_area <= Polygon_area_add;
            Polygon_area3:
                Polygon_area <= Polygon_area_add;
            Polygon_area4:
                Polygon_area <= Polygon_area_add;
            Polygon_area5:
                Polygon_area <= Polygon_area_add;
            Polygon_area6:
                Polygon_area <= (Polygon_area_add >> 1 );
            Polygon_area7:
                Polygon_area <= Polygon_area ;
        endcase
    end
    
end



//========================//
always @(*) 
begin
    case(state)
        triangle_area1:
            x_sub = x_data[2] - x_data[1];   
        triangle_area2:
            x_sub = x_data[3] - x_data[2]; 
        triangle_area3:
            x_sub = x_data[4] - x_data[3];
        triangle_area4:
            x_sub = x_data[5] - x_data[4];
        triangle_area5:
            x_sub = x_data[6] - x_data[5];
        triangle_area6:
            x_sub = x_data[1] - x_data[6];
        default:
            x_sub = 11'd0;
    endcase
end
always @(*) 
begin
    case(state)
        triangle_area1:
            y_sub = y_data[2] - y_data[1];   
        triangle_area2:
            y_sub = y_data[3] - y_data[2]; 
        triangle_area3:
            y_sub = y_data[4] - y_data[3];
        triangle_area4:
            y_sub = y_data[5] - y_data[4];
        triangle_area5:
            y_sub = y_data[6] - y_data[5];
        triangle_area6:
            y_sub = y_data[1] - y_data[6];
        default:
            y_sub = 11'd0;
    endcase
end
always @(*) 
begin
    case(state)
        triangle_area1:
            b = r_data[1];
        triangle_area2:
            b = r_data[2];
        triangle_area3:
            b = r_data[3];
        triangle_area4:
            b = r_data[4];
        triangle_area5:
            b = r_data[5];
        triangle_area6:
            b = r_data[6];
        default:
            b = 10'd0;
    endcase    
end
always @(*) 
begin
    case(state)
        triangle_area1:
            c = r_data[2];
        triangle_area2:
            c = r_data[3];
        triangle_area3:
            c = r_data[4];
        triangle_area4:
            c = r_data[5];
        triangle_area5:
            c = r_data[6];
        triangle_area6:
            c = r_data[1];
        default:
            c = 10'd0;
    endcase    
end






//======================================//

always @(posedge clk or posedge reset) 
begin
    if(reset)
        is_inside <= 1'd0;
    else if(state == finish)
    begin
        if(triangle_area_total > Polygon_area)
            is_inside <= 1'd0;
        else
            is_inside <= 1'd1;
    end
    else 
        is_inside <= 1'd0;
end

always @(posedge clk or posedge reset) 
begin
    if(reset)
        valid <= 1'd0;
    else if(state == finish)
        valid <= 1'd1;
    else 
        valid <= 1'd0;
end
endmodule

