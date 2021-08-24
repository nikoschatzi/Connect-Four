module fsm0_x2(
	input  logic clk,
	input  logic rst,

	input  logic left,
	input  logic right,
	input  logic put,
	
	input logic [41:0] color_p1,
	input logic [2:0] selected_col_1_changed,
	input logic fsm0_enable_1_changed,
	input logic fsm1_enable_1_changed,
	
	output logic fsm0_enable_0_changed,	
	output logic fsm1_enable_0_changed,
	
	output logic player,
	output logic invalid_move,
	output logic win_a,
	output logic win_b,
	output logic full_panel,
	
	output logic which_player,
	output logic invalid_detect,
	output logic put_enable,
	output logic right_enable,
	output logic left_enable,
	output logic [2:0] selected_col_0_changed,//Track selected column
	output logic [41:0] winner_tokens,
	output logic [41:0] color_p0
	 /*
    35 36 37 38 39 40 41
    28 29 30 31 32 33 34
    21 22 23 24 25 26 27
    14 15 16 17 18 19 20
    07 08 09 10 11 12 13
    00 01 02 03 04 05 06
    */
);

//declare variables
logic [2:0] counter_column_0;
logic [2:0] counter_column_1;
logic [2:0] counter_column_2;
logic [2:0] counter_column_3;
logic [2:0] counter_column_4;
logic [2:0] counter_column_5;
logic [2:0] counter_column_6;

logic [3:0] i,j;
logic [3:0] k,l;
logic first_move;
logic edge_right,edge_left,edge_put,rising_edge_right,rising_edge_left,rising_edge_put;
enum logic [3:0] { Initial=4'b0000, Move_0=4'b0001, Check_move=4'b0011, Check_board=4'b0100, Next_move=4'b0101, Wait=4'b1111} state;	



//this is for coloring the winning combo
always_comb
begin
			for(k=0; k<7; k=k+1) begin //for columns
				for(l=0; l<3; l=l+1) begin //for rows
					//Check all 4 are the same color
					if(color_p0[(7*l)+k] && color_p0[(7*(l+1))+k] && color_p0[7*(l+2)+k] && color_p0[7*(l+3)+k])
						begin
						winner_tokens[(7*l)+k] = 1;
						winner_tokens[(7*(l+1))+k] = 1;
						winner_tokens[(7*(l+2))+k] = 1;
						winner_tokens[(7*(l+3))+k] = 1;
						end
					if(color_p1[(7*l)+k] && color_p1[(7*(l+1))+k] && color_p1[7*(l+2)+k] && color_p1[7*(l+3)+k])
						begin
						winner_tokens[(7*l)+k] = 1;
						winner_tokens[(7*(l+1))+k] = 1;
						winner_tokens[(7*(l+2))+k] = 1;
						winner_tokens[(7*(l+3))+k] = 1;
						end
				end
		    end 
		    for(k=0; k<6; k=k+1) begin //Row
				for(l=0; l<4; l=l+1) begin //Column
					//Check all 4 are the same color
					if(color_p0[(7*k)+l] && color_p0[(7*k)+l+1] && color_p0[(7*k)+l+2] && color_p0[(7*k)+l+3])
						begin
						winner_tokens[(7*k)+l] = 1;
						winner_tokens[(7*k)+l+1] = 1;
						winner_tokens[(7*k)+l+2] = 1;
						winner_tokens[(7*k)+l+3] = 1;
						end
					if(color_p1[(7*k)+l] && color_p1[(7*k)+l+1] && color_p1[(7*k)+l+2] && color_p1[(7*k)+l+3])
						begin
						winner_tokens[(7*k)+l] = 1;
						winner_tokens[(7*k)+l+1] = 1;
						winner_tokens[(7*k)+l+2] = 1;
						winner_tokens[(7*k)+l+3] = 1;
						end
				end
		    end
		    for(k=0; k<6; k=k+1) begin //Starting column
				for(l=0; l<4; l=l+1) begin //Starting row
					if(color_p0[7*(l)+(k)] && color_p0[7*(l+1)+(k+1)] && color_p0[7*(l+2)+(k+2)] && color_p0[7*(l+3)+(k+3)]) 
						begin
						winner_tokens[7*(l)+(k)] = 1;
						winner_tokens[7*(l+1)+(k+1)] = 1;
						winner_tokens[7*(l+2)+(k+2)] = 1;
						winner_tokens[7*(l+3)+(k+3)] = 1;
						end
					if(color_p1[7*(l)+(i)] && color_p1[7*(l+1)+(i+1)] && color_p1[7*(l+2)+(i+2)] && color_p1[7*(l+3)+(i+3)]) 
						begin
						winner_tokens[7*(l)+(k)] = 1;
						winner_tokens[7*(l+1)+(k+1)] = 1;
						winner_tokens[7*(l+2)+(k+2)] = 1;
						winner_tokens[7*(l+3)+(k+3)] = 1;
						end
				end
		    end
		    for(k=0; i<4; k=k+1) begin //Starting column
				for(l=3; l<6; l=l+1) begin //Starting row
					if(color_p0[7*(l)+(k)] & color_p0[7*(l-1)+(k+1)] & color_p0[7*(l-2)+(k+2)] & color_p0[7*(l-3)+(k+3)]) 
						begin
						winner_tokens[7*(l)+(k)] = 1;
						winner_tokens[7*(l-1)+(k+1)] = 1;
						winner_tokens[7*(l-2)+(k+2)] = 1;
						winner_tokens[7*(l-3)+(k+3)] = 1;
						end
					if(color_p1[7*(l)+(k)] & color_p1[7*(l-1)+(k+1)] & color_p1[7*(l-2)+(k+2)] & color_p1[7*(l-3)+(k+3)]) 
						begin
						winner_tokens[7*(l)+(k)] = 1;
						winner_tokens[7*(l-1)+(k+1)] = 1;
						winner_tokens[7*(l-2)+(k+2)] = 1;
						winner_tokens[7*(l-3)+(k+3)] = 1;
						end
				end
		    end
end



//FSM logic
always_ff @(posedge clk, posedge rst)
begin
if(rst) state <= Initial;  //all squares are empty

else 
	begin	
	case(state)
	Initial:
		begin
		//Reset variables
		which_player <= 0;  
		invalid_detect <= 0;
		win_a <= 0;
		win_b <= 0;
		full_panel <= 0;
		selected_col_0_changed <= 0; //Start from 0 column
		put_enable <= 0;
		color_p0 <= {42{1'b0}};		
		counter_column_0 <= 0;
		counter_column_1 <= 0;
		counter_column_2 <= 0;
		counter_column_3 <= 0;
		counter_column_4 <= 0;
		counter_column_5 <= 0;
		counter_column_6 <= 0;	
		fsm0_enable_0_changed <= 1;
		fsm1_enable_0_changed <= 0;
		right_enable<=0;
		left_enable<=0;
		put_enable<=0;
		first_move<=1;
		
		state <= Move_0;
		end
				  
	Move_0:
		begin
		//while the other player waits, change synchronization variables in order to play
		if(fsm0_enable_1_changed==1 && fsm1_enable_1_changed==0 && right_enable==0 && left_enable==0)
			begin
			fsm0_enable_0_changed<=1;
			fsm1_enable_0_changed<=0;
			selected_col_0_changed <= selected_col_1_changed;
			end
		
		//if its your turn play
		if(fsm0_enable_1_changed==1 && fsm1_enable_1_changed==0 && fsm0_enable_0_changed==1 && fsm1_enable_0_changed==0)
		begin
		if(rising_edge_put)
			begin
			which_player <= 0;
			state <= Check_move;
			put_enable <= 1;
			right_enable <= 0;
			left_enable <= 0;
			invalid_detect <= 0;
			first_move<=0;
			
			//if its not the first move update counter values
			if(first_move!=1)
				begin
				if(selected_col_1_changed==0) counter_column_0<=counter_column_0+1;
				else if(selected_col_1_changed==1) counter_column_1<=counter_column_1+1;
				else if(selected_col_1_changed==2) counter_column_2<=counter_column_2+1;
				else if(selected_col_1_changed==3) counter_column_3<=counter_column_3+1;
				else if(selected_col_1_changed==4) counter_column_4<=counter_column_4+1;
				else if(selected_col_1_changed==5) counter_column_5<=counter_column_5+1;
				else if(selected_col_1_changed==6) counter_column_6<=counter_column_6+1;
				end
	
			end
			
		else
			begin
			if(rising_edge_left & !rising_edge_right & (selected_col_0_changed > 0))
				begin
				which_player <= 0;
				selected_col_0_changed <= selected_col_0_changed - 1;
				put_enable <= 0;
				right_enable <= 0;
				left_enable <= 1;
				end
			else if(rising_edge_right & !rising_edge_left & (selected_col_0_changed < 6))
				begin
				which_player <= 0;
				selected_col_0_changed <= selected_col_0_changed + 1;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				end
			else if((rising_edge_right & selected_col_0_changed==6) || (rising_edge_left & selected_col_0_changed==0))
				begin
				which_player <= 0;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				invalid_detect <= 1;
				state <= Check_board;	
				end 
			end	
			end
		end
		

				
	Check_move:
	//here you select which column you want to play
		begin
		if(selected_col_0_changed==0 && counter_column_0 < 6)
			begin
			counter_column_0 <= counter_column_0 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_0))] <= 1;
			end
				
		else if(selected_col_0_changed==1 && counter_column_1 < 6)
			begin
			counter_column_1 <= counter_column_1 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_1))] <= 1;
			end
				
		else if(selected_col_0_changed==2 && counter_column_2 < 6)
			begin
			counter_column_2 <= counter_column_2 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_2))] <= 1;
			end
				
		else if(selected_col_0_changed==3 && counter_column_3 < 6)
			begin
			counter_column_3 <= counter_column_3 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_3))] <= 1;
			end
				
		else if(selected_col_0_changed==4 && counter_column_4 < 6)
			begin
			counter_column_4 <= counter_column_4 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_4))] <= 1;
			end
				
		else if(selected_col_0_changed==5 && counter_column_5 < 6)
			begin
			counter_column_5 <= counter_column_5 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_5))] <= 1;
			end
				
		else if(selected_col_0_changed==6 && counter_column_6 < 6)
			begin
			counter_column_6 <= counter_column_6 + 1;
			color_p0[(selected_col_0_changed + (7*counter_column_6))] <= 1;
			end
				
		else 
			begin
			invalid_detect <= 1;
			state <= Move_0;
			end

		state <= Check_board;
		end

	Check_board:
		begin
		player <= which_player;
		invalid_move <= invalid_detect;
		
		//check if panel is full
		if(counter_column_0 == 6 && counter_column_1 == 6 && counter_column_2 == 6 && counter_column_3 == 6 && counter_column_4 == 6 && counter_column_5 == 6 && counter_column_6 == 6)
			full_panel <= 1;
		else
			begin
			full_panel <= 0;
			end 
		
		//check if someone wins and update variables win_a & win_b
		for(i=0; i<7; i=i+1) begin //for columns
				for(j=0; j<3; j=j+1) begin //for rows
					//Check all 4 are the same color
					if(color_p0[(7*j)+i] && color_p0[(7*(j+1))+i] && color_p0[7*(j+2)+i] && color_p0[7*(j+3)+i])
						begin
						win_a <= 1;
						end
					if(color_p1[(7*j)+i] && color_p1[(7*(j+1))+i] && color_p1[7*(j+2)+i] && color_p1[7*(j+3)+i])
						begin
						win_b <= 1;
						end
				end
		  end 
		   for(i=0; i<6; i=i+1) begin //Row
				for(j=0; j<4; j=j+1) begin //Column
					//Check all 4 are the same color
					if(color_p0[(7*i)+j] && color_p0[(7*i)+j+1] && color_p0[(7*i)+j+2] && color_p0[(7*i)+j+3])
						begin
						win_a <= 1;
						end
					if(color_p1[(7*i)+j] && color_p1[(7*i)+j+1] && color_p1[(7*i)+j+2] && color_p1[(7*i)+j+3])
						begin
						win_b <= 1; 
						end
				end
		  end
		    for(i=0; i<4; i=i+1) begin //Starting column
				for(j=0; j<3; j=j+1) begin //Starting row
					if(color_p0[7*(j)+(i)] && color_p0[7*(j+1)+(i+1)] && color_p0[7*(j+2)+(i+2)] && color_p0[7*(j+3)+(i+3)]) 
						win_a <= 1;
					if(color_p1[7*(j)+(i)] && color_p1[7*(j+1)+(i+1)] && color_p1[7*(j+2)+(i+2)] && color_p1[7*(j+3)+(i+3)]) 
						win_b <= 1;
				end
		  end
			 for(i=0; i<4; i=i+1) begin //Starting column
				for(j=3; j<6; j=j+1) begin //Starting row
					if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)] & color_p0[7*(j-3)+(i+3)]) 
						win_a <= 1;
					if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)] & color_p1[7*(j-3)+(i+3)]) 
						win_b <= 1;
				end
		  end
		state <= Next_move;
		end
		
		
	Next_move:
		begin
		if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0)
			begin
			state <= Wait;
			fsm0_enable_0_changed <= 0;
			fsm1_enable_0_changed <= 1;
			end
		else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1)
			begin
			state <= Move_0;
			end	
		end
		
	Wait:
		begin
		state <= Move_0;
		end
	
	endcase
       
end
end

//detect rising edges
always_ff @(posedge clk, posedge rst)  //right,left,put
begin
if(rst) 
	begin
	edge_right <= 1'b0;
	edge_left <= 1'b0;
	edge_put <= 1'b0;	
	end
else 
	begin
	edge_right <= right;
	edge_left <= left;
	edge_put <= put;
	end
end
assign rising_edge_right = (~edge_right) & right;
assign rising_edge_left = (~edge_left) & left;
assign rising_edge_put = (~edge_put) & put;

endmodule