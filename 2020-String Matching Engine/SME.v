module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;
//============================================================================
reg [7:0] string_r [0:31];
reg [7:0] pattern_r [0:7];
parameter read_data = 4'd0, compare = 4'd1 ;
reg [3:0] state,next_state;
reg [4:0] string_counter,string_compare_counter;
reg [2:0] pattern_counter,pattern_compare_counter;
reg pass, flag, valid_signal, match_signal, flag1;
integer i;
wire c1;
//========FSM=======//
always @(posedge clk or posedge reset)
begin
    if(reset)   state <= read_data;
    else  state <= next_state;
end
always @(*) 
begin
    next_state = state;
    case(state)
        read_data:
        begin 
            if(!ispattern && !isstring ) 
                next_state = compare;
            else 
                next_state = read_data;
        end
        compare:
        begin
            if(valid_signal) next_state = read_data;
            else next_state = compare;
        end
    endcase    
end
//=================//

//========存string=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
    begin
        for(i=0; i<32; i=i+1)
        begin
            string_r[i] <= 8'd0;
        end
    end
    else if(state == read_data && isstring && valid)
    begin
        for(i=1; i<32; i=i+1)
        begin
            string_r[i] <= 8'd0;
        end
        string_r[string_counter] <= chardata;
    end
    else if(state == read_data && isstring)
    begin
        string_r[string_counter] <= chardata;
    end
end

//======================//

//========string_counter=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        string_counter <= 5'd0;
    // else if(state == read_data && isstring && valid)
    // begin
    //     string_counter <= 5'd0;
    // end
    else if(state == read_data && isstring)
    begin
        string_counter <= string_counter + 5'd1;
    end
    else if(state == compare)
        string_counter <= 5'd0;     //不清0因為要記錄string有幾個bit

end
//======================//

//========存pattern=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
    begin
        for(i=0; i<8; i=i+1)
        begin
            pattern_r[i] <= 8'd0;
        end
    end
    else if(state == read_data && ispattern && pattern_counter == 3'd0)
    begin
        for(i=1; i<8; i=i+1)
        begin
            pattern_r[i] <= 8'd0;
        end
        pattern_r[pattern_counter] <= chardata;
    end
    else if(state == read_data && ispattern)
    begin
        pattern_r[pattern_counter] <= chardata;
    end
end

//======================//

//========pattern_counter=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) pattern_counter <= 3'd0;
    else if(state == read_data && ispattern)
    begin
        pattern_counter <= pattern_counter + 3'd1;
    end
    else if(state == compare)
    begin
        if(valid_signal) 
            pattern_counter <= 3'd0;
        else 
            pattern_counter <= pattern_counter;     //不清0因為要記錄有幾個pattern
    end
end
//======================//

//+++++++++compare_state+++++++++//
//========string_compare_counter=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        string_compare_counter <= 5'd0;
    else if(state == read_data) 
        string_compare_counter <= 5'd0;
    else if(state == compare)
    begin
        if(flag && !pass) 
            string_compare_counter <= string_compare_counter;
        else if(pattern_r[pattern_compare_counter] == 8'h2A)
            string_compare_counter <= string_compare_counter;
        else    
            string_compare_counter <= string_compare_counter + 5'd1;     
    end  
end
//======================//
//========pattern_compare_counter=======//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        pattern_compare_counter <= 3'd0;
    else if(state == read_data) 
        pattern_compare_counter <= 3'd0;
    else if(state == compare)
    begin
        if(pass) 
            pattern_compare_counter <= pattern_compare_counter + 3'd1;     
        else if(flag && !pass)
            pattern_compare_counter <= 3'd0;
        else if(string_r[string_compare_counter] == 8'h20) 
            pattern_compare_counter <= pattern_compare_counter;
        // else if(pattern_r[pattern_compare_counter] == 8'h5E && pattern_r[pattern_compare_counter + 3'd1] == 8'h2E && pattern_r[pattern_compare_counter + 3'd2] == 8'h2E)
        //     pattern_compare_counter <= pattern_compare_counter + 3'd1;
        else 
            pattern_compare_counter <= pattern_compare_counter ;
    end  
end
//======================//

//===========pass 這一個Bit string跟Pattern比對成功===========//
always @(*) 
begin
    if(state == compare)
    begin
        if(string_r[string_compare_counter] == pattern_r[pattern_compare_counter] || pattern_r[pattern_compare_counter] == 8'h2E )  //比對成功或pattern=2E 比對任意字元 
            pass = 1'd1;
        else if(string_r[string_compare_counter] == 8'h20 && pattern_r[pattern_compare_counter] == 8'h5E) //5E是word開頭 20是空白
            pass = 1'd1;
        else if(pattern_r[pattern_compare_counter] == 8'h2A)  //2A比對一次或零次任意字元
            pass = 1'd1;
        else
            pass = 1'd0;
    end
    else pass = 1'd0;
    
end
//==========================================================//
assign c1 = (pattern_compare_counter == (pattern_counter - 3'd1) && string_r[string_compare_counter] == pattern_r[pattern_compare_counter]);
//===========match valid match_index===========//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        match_signal <= 1'd0;
    else if(state == compare)
    begin
        if(c1) 
            match_signal <= 1'd1;
        else if(pattern_compare_counter == (pattern_counter - 3'd1) && pattern_r[pattern_compare_counter] == 8'h24 && string_r[string_compare_counter] == 8'h20)
            match_signal <= 1'd1;
        else if(pattern_compare_counter == (pattern_counter - 3'd1) && pattern_r[pattern_compare_counter] == 8'h24 && string_r[string_compare_counter] == 8'h0)
            match_signal <= 1'd1;
        else if(pattern_compare_counter == (pattern_counter - 3'd1) && pattern_r[pattern_compare_counter] == 8'h2E )
            match_signal <= 1'd1;
        else if(string_r[string_compare_counter] == pattern_r[pattern_compare_counter] && pattern_r[pattern_counter - 3'd1] == 8'h24 && string_compare_counter == 5'd31)
            match_signal <= 1'd1;
        else 
            match_signal <= 1'd0;
    end
    else match_signal <= 1'd0;
end

always @(posedge clk or posedge reset) 
begin
    if(reset) 
        valid_signal <= 1'd0;
    else if(state == compare)
    begin
        if(c1) 
            valid_signal <= 1'd1;
        else if(pattern_compare_counter == (pattern_counter - 3'd1) && pattern_r[pattern_compare_counter] == 8'h24 && string_r[string_compare_counter] == 8'h0)
            valid_signal <= 1'd1;
        else if(string_compare_counter == 5'd31) 
            valid_signal <= 1'd1;
        else if(pattern_compare_counter == (pattern_counter - 3'd1) && pattern_r[pattern_compare_counter] == 8'h2E )
            valid_signal <= 1'd1;
        
        else if( pattern_r[pattern_compare_counter] == 8'h24 && string_r[string_compare_counter] == 8'h20)
            valid_signal <= 1'd1;
        
        else 
            valid_signal <= 1'd0;
    end
    else valid_signal <= 1'd0;
    
end

always @(posedge clk or posedge reset) 
begin
    if(reset) 
        match <= 1'd0;
    else  
        match <= match_signal;   
end

always @(posedge clk or posedge reset) 
begin
    if(reset) 
        valid <= 1'd0;
    else  
        valid <= valid_signal;   
end
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        match_index <= 5'd0;
    else if(state == read_data)
        match_index <= 5'd0;
    else if(state == compare)
    begin
        if(string_r[string_compare_counter] == pattern_r[pattern_compare_counter] &&  !flag && !flag1) 
            match_index <= string_compare_counter ;
        else if(pattern_r[pattern_compare_counter] == 8'h2E &&  !flag && !flag1) 
            match_index <= string_compare_counter ;
        else if(pattern_r[0] == 8'h5E && pattern_r[1] == 8'h2E && pattern_r[2] == 8'h2E && pattern_r[3] == 8'h0)
            match_index <= 5'd0;
        else 
            match_index <= match_index;
    end
    else 
        match_index <= match_index;
    
end

always @(posedge clk or posedge reset) 
begin
    if(reset) 
        flag <= 1'd0;
    else if(state == read_data)
        flag <= 1'd0;
    else if(state == compare)
    begin
        if(string_r[string_compare_counter] == pattern_r[pattern_compare_counter] || pattern_r[pattern_compare_counter] == 8'h2E ) 
            flag <= 1'd1;
        else if(!pass) 
            flag <= 1'd0;
        // else if(string_r[string_compare_counter - 5'd1] == 8'h20 && pattern_r[pattern_compare_counter - 3'd1] == 8'h5E && string_r[string_compare_counter] == pattern_r[pattern_compare_counter]) 
        //     flag <= 1'd1;
        else
            flag <= 1'd0;
    end
    else 
        flag <= flag;
    
end
//================================//
always @(posedge clk or posedge reset) 
begin
    if(reset) 
        flag1 <= 1'd0;
    else if(state == read_data)
        flag1 <= 1'd0;
    else if(state == compare)
    begin
        if(pattern_r[pattern_compare_counter] == 8'h2A ) 
            flag1 <= 1'd1;
        else
            flag1 <= flag1;
    end
    else 
        flag1 <= flag1;
    
end



endmodule




