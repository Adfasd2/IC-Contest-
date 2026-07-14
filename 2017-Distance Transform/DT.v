module DT(
    input clk,
    input reset,
    output reg done,
    output reg sti_rd,
    output reg [9:0] sti_addr,
    input [15:0] sti_di,
    output reg res_wr,
    output reg res_rd,
    output reg [13:0] res_addr,
    output reg [7:0] res_do,
    input [7:0] res_di);
//----------------------------------------------------------------------------------------------------
parameter idle = 5'd0,read_data = 5'd1 , counter_set = 5'd2,forward_pass_count = 5'd3 ,forward_pass=5'd4, nw = 5'd5, n = 5'd6, ne = 5'd7, w = 5'd8 ,forward_pass_write = 5'd9 ;
parameter backward_pass_counter_set = 5'd10,backward_pass_count = 5'd11, backward_pass = 5'd12, center = 5'd13, e = 5'd14, sw = 5'd15, s = 5'd16, se = 5'd17,backward_pass_write = 5'd18,finish = 5'd19;
parameter read_data1 = 5'd20,read_data2 = 5'd21;
reg [4:0] ns,cs,data_counter;
reg [13:0] res_addr_counter; 

always @(posedge clk or negedge reset) begin
    if(!reset)
        cs <= idle;
    else
        cs <= ns;
end

always @(*) begin    //切換狀態
    case(cs)
        idle:               ns = read_data;
        read_data:          ns = read_data1;
        read_data1:         ns = read_data2; 
        read_data2:         begin
                                if(res_addr == 14'd16383) ns = counter_set;
                                else ns = read_data; 
                            end         
        counter_set:        ns = forward_pass_count;
        forward_pass_count: ns = forward_pass;
        forward_pass:       begin
                                if(res_di == 1'd1) ns = nw;
                                else begin
                                    if(res_addr_counter == 14'd16126) ns = backward_pass_counter_set;
                                    else ns = counter_set;      
                                end
                            end
        nw: ns = n;
        n:  ns = ne;
        ne: ns = w;
        w:  ns = forward_pass_write;         
        forward_pass_write: begin
                                if(res_addr_counter == 14'd16126) ns = backward_pass_counter_set;  
                                else ns = forward_pass_count;
                            end
        backward_pass_counter_set:  ns = backward_pass_count;
        backward_pass_count:        ns = backward_pass;
        backward_pass:              ns = center;
        center:             begin
                                if(res_di != 1'd0) ns = e;
                                else begin
                                if(res_addr_counter == 14'd258) ns = finish;
                                else ns = backward_pass_count;      
                                end
                            end
        e:  ns = sw;
        sw: ns = s;
        s:  ns = se;
        se: ns = backward_pass_write;
        backward_pass_write:begin
                                if(res_addr_counter == 14'd258) ns = finish; 
                                else ns = backward_pass;
                            end
        finish: ns = finish;
    endcase
end

always@(posedge clk )begin      //狀態機輸出,寫資料到res_RAM
        case(cs)
            idle:                   res_do <= 8'd0;
            read_data :             res_do <= sti_di[data_counter];
            read_data1:             res_do <= sti_di[data_counter];
            read_data2:             res_do <= res_do;
            counter_set:            res_do <= res_do;
            forward_pass_count:     res_do <= res_do;
            forward_pass:           res_do <= res_di; 
            nw:                     res_do <= res_di;
            n:                      begin  
                                        if(res_di < res_do) res_do <= res_di;
                                        else res_do <= res_do; 
                                    end
            ne:                     begin  
                                        if(res_di < res_do) res_do <= res_di;
                                        else res_do <= res_do; 
                                    end        
            w:                      begin  
                                        if(res_di < res_do) res_do <= res_di +8'd1 ;
                                        else res_do <= res_do + 8'd1; 
                                    end         
            forward_pass_write:         res_do <= res_do;
            backward_pass_counter_set:  res_do <= res_do;  
            backward_pass_count:        res_do <= res_do; 
            backward_pass:              res_do <= res_do; 
            center:                     res_do <= res_di;
            e:                          begin  
                                            if(res_di+1'd1 < res_do) res_do <= res_di+8'd1;
                                            else res_do <= res_do; 
                                        end
            sw:                         begin  
                                            if(res_di+1'd1 < res_do) res_do <= res_di+8'd1;
                                            else res_do <= res_do; 
                                        end
            s:                          begin  
                                            if(res_di+1'd1 < res_do) res_do <= res_di+8'd1;
                                            else res_do <= res_do; 
                                        end                
            se:                         begin  
                                            if(res_di+1'd1 < res_do) res_do <= res_di+8'd1;
                                            else res_do <= res_do; 
                                        end
            backward_pass_write:        res_do <= res_do;
            finish:                     res_do <= 8'd0;
            
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle: data_counter <= 4'd15;
            read_data : begin 
                            if(data_counter == 4'd0) data_counter <= 4'd15;
                            else data_counter <= data_counter - 4'd1;
                        end
            read_data1: data_counter <= data_counter;  
             read_data2: data_counter <= data_counter;  
                     
            default :   data_counter <= 4'd15;
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:           sti_addr <= 10'd0;
            read_data :     begin 
                                if(data_counter == 4'd0) sti_addr <= sti_addr + 10'd1;
                                else sti_addr <= sti_addr ;
                            end
            read_data1 :    sti_addr <= sti_addr;
             read_data2:    sti_addr <= sti_addr;          
            default:        sti_addr <= 10'd0;            
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:                   res_addr <= 14'd0;
            read_data:              res_addr <= res_addr + 14'd1;
            read_data1:              res_addr <= res_addr ;
            read_data2:              res_addr <= res_addr ;
            counter_set:            res_addr <= res_addr;
            forward_pass_count:     res_addr <= res_addr_counter + 14'd128 ;
            forward_pass:           res_addr <= res_addr_counter - 14'd1; 
            nw:                     res_addr <= res_addr_counter ;
            n:                      res_addr <= res_addr_counter + 14'd1;
            ne:                     res_addr <= res_addr_counter + 14'd127;         
            w:                      res_addr <= res_addr_counter + 14'd128;           
            forward_pass_write:     res_addr <= 14'd0;
            backward_pass_counter_set:  res_addr <= 14'd0;
            backward_pass_count:        res_addr <= 14'd0;
            backward_pass:              res_addr <= res_addr_counter - 14'd129; 
            center:                     res_addr <= res_addr_counter - 14'd128; 
            e:                          res_addr <= res_addr_counter - 14'd2;   
            sw:                         res_addr <= res_addr_counter - 14'd1;    
            s:                          res_addr <= res_addr_counter ;                  
            se:                         res_addr <= res_addr_counter - 14'd129; 
            backward_pass_write:        res_addr <= 14'd0;
            finish:                     res_addr <= 14'd0;
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:                    res_addr_counter <= 14'd0;
            read_data :              res_addr_counter <= 14'd0;
            read_data1 :              res_addr_counter <= 14'd0;
            read_data2 :              res_addr_counter <= 14'd0;
            counter_set:             res_addr_counter <= res_addr_counter+ 14'd1;
            forward_pass_count:      res_addr_counter <= res_addr_counter; 
            forward_pass:            res_addr_counter <= res_addr_counter; 
            nw:                      res_addr_counter <= res_addr_counter;
            n:                       res_addr_counter <= res_addr_counter;
            ne:                      res_addr_counter <= res_addr_counter;         
            w:                       res_addr_counter <= res_addr_counter;           
            forward_pass_write:      res_addr_counter <= res_addr_counter+ 14'd1;
            backward_pass_counter_set:  res_addr_counter <= 14'd16384;
            backward_pass_count:        res_addr_counter <= res_addr_counter - 1'd1;      
            backward_pass:              res_addr_counter <= res_addr_counter;   
            center:                     res_addr_counter <= res_addr_counter; 
            e:                          res_addr_counter <= res_addr_counter; 
            sw:                         res_addr_counter <= res_addr_counter; 
            s:                          res_addr_counter <= res_addr_counter;              
            se:                         res_addr_counter <= res_addr_counter; 
            backward_pass_write:        res_addr_counter <= res_addr_counter - 1'd1;
            finish:                     res_addr_counter <= 14'd0;
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:                       res_wr <= 1'd0;
            read_data :                 res_wr <= 1'd1;
            read_data1 :                 res_wr <= 1'd1;
             read_data2 :                 res_wr <= 1'd1;
            counter_set:                res_wr <= 1'd0;
            forward_pass_count:         res_wr <= 1'd0;
            forward_pass:               res_wr <= 1'd0; 
            nw:                         res_wr <= 1'd0;
            n:                          res_wr <= 1'd0;
            ne:                         res_wr <= 1'd0;         
            w:                          res_wr <= 1'd1; 
            forward_pass_write:         res_wr <= 1'd0;
            backward_pass_counter_set:  res_wr <= 1'd0;
            backward_pass_count:        res_wr <= 1'd0; 
            backward_pass:              res_wr <= 1'd0; 
            center:                     res_wr <= 1'd0; 
            e:                          res_wr <= 1'd0; 
            sw:                         res_wr <= 1'd0; 
            s:                          res_wr <= 1'd0;              
            se:                         res_wr <= 1'd1; 
            backward_pass_write:        res_wr <= 1'd0; 
            finish:                     res_wr <= 1'd0; 
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:                res_rd <= 1'd0;
            read_data :          res_rd <= 1'd0;
            read_data1 :          res_rd <= 1'd0;
            read_data2 :          res_rd <= 1'd0;
            counter_set:         res_rd <= 1'd0;
            forward_pass_count:  res_rd <= 1'd1;
            forward_pass:        res_rd <= 1'd1; 
            nw:                  res_rd <= 1'd1;
            n:                   res_rd <= 1'd1;
            ne:                  res_rd <= 1'd1;         
            w:                   res_rd <= 1'd0; 
            forward_pass_write:  res_rd <= 1'd0;
            backward_pass_counter_set: res_rd <= 1'd0; 
            backward_pass_count:       res_rd <= 1'd0;  
            backward_pass:             res_rd <= 1'd1; 
            center:                    res_rd <= 1'd1;
            e:                         res_rd <= 1'd1;
            sw:                        res_rd <= 1'd1;
            s:                         res_rd <= 1'd1;              
            se:                        res_rd <= 1'd0;
            backward_pass_write:       res_rd <= 1'd0; 
            finish:                    res_rd <= 1'd0;
        endcase
end

always@(posedge clk )begin
        case(cs)
            idle:           sti_rd <= 1'd0;
            read_data :     sti_rd <= 1'd1;

            default:        sti_rd <= 1'd0;
        endcase
end
always@(posedge clk )begin
        case(cs)
            idle:           done <= 1'd0;
            finish :        done <= 1'd1;
            default:        done <= 1'd0;
        endcase
end

endmodule