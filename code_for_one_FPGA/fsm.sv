module fsm(
	input  logic clk,
	input  logic rst,

	input  logic left,
	input  logic right,
	input  logic put,
	
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
	output logic [2:0] selected_col,//Track selected column
	output logic [41:0] winner_tokens,
	output logic [41:0] color_p0,//blue
	output logic [41:0] color_p1//red	
	 /*
    35 36 37 38 39 40 41
    28 29 30 31 32 33 34
    21 22 23 24 25 26 27
    14 15 16 17 18 19 20
    07 08 09 10 11 12 13
    00 01 02 03 04 05 06
    */
	
);

logic automatic_player_0 = 1;
logic automatic_player_1 = 0;

logic [2:0] counter_column_0;
logic [2:0] counter_column_1;
logic [2:0] counter_column_2;
logic [2:0] counter_column_3;
logic [2:0] counter_column_4;
logic [2:0] counter_column_5;
logic [2:0] counter_column_6;

logic [3:0] i,j;
logic [3:0] k,l;
logic [10:0] counter=1; //this is for automatic


logic edge_right,edge_left,edge_put,rising_edge_right,rising_edge_left,rising_edge_put;

enum logic [3:0] { Initial=4'b0000, Move_0=4'b0001, Move_1=4'b0010, Check_move=4'b0011, Check_board=4'b0100, Next_move=4'b0101,Automatic_player=4'b0110} state;	

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

if(rst) 
	begin	
	state <= Initial;  //all squares are empty
	end 
	
else 
	begin	
	case(state)
	
	Initial:
		begin
		which_player <= 0;  //which_player 0
		invalid_detect <= 0;
		win_a <= 0;
		win_b <= 0;
		full_panel <= 0;
		selected_col <= 0; //Start from 0 column
		put_enable <= 0;
		//Reset Board
		color_p0 <= {42{1'b0}};	
		color_p1 <= {42{1'b0}};		
		//Reset Counters
		counter_column_0 <= 0;
		counter_column_1 <= 0;
		counter_column_2 <= 0;
		counter_column_3 <= 0;
		counter_column_4 <= 0;
		counter_column_5 <= 0;
		counter_column_6 <= 0;
		state <= Move_0;
		//for automatic player
		if(automatic_player_0==1)
			state <= Automatic_player;
		end
				  
	Move_0:
		begin			
		if(rising_edge_put)
			begin
			which_player <= 0;
			state <= Check_move;
			put_enable <= 1;
			right_enable <= 0;
			left_enable <= 0;
			invalid_detect <= 0;
			end
			
		else
			begin
			if(rising_edge_left & !rising_edge_right & (selected_col > 0))
				begin
				which_player <= 0;
				selected_col <= selected_col - 1;
				put_enable <= 0;
				right_enable <= 0;
				left_enable <= 1;
				end
				
			else if(rising_edge_right & !rising_edge_left & (selected_col < 6))
				begin
				which_player <= 0;
				selected_col <= selected_col + 1;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				end
				
			else if((rising_edge_right & selected_col==6) || (rising_edge_left & selected_col==0))
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
		
	Move_1:
		begin			
		if(rising_edge_put)
			begin
			which_player <= 1;
			state <= Check_move;
			put_enable <= 1;
			right_enable <= 0;
			left_enable <= 0;
			invalid_detect <= 0;
			end
			
		else
			begin
			if(rising_edge_left & !rising_edge_right & (selected_col > 0))
				begin
				which_player <= 1;
				selected_col <= selected_col - 1;
				put_enable <= 0;
				right_enable <= 0;
				left_enable <= 1;
				end
				
			else if(rising_edge_right & !rising_edge_left & (selected_col < 6))
				begin
				which_player <= 1;
				selected_col <= selected_col + 1;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				end
				
			else if((rising_edge_right & selected_col==6) || (rising_edge_left & selected_col==0))
				begin
				which_player <= 1;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				invalid_detect <= 1;
				state <= Check_board;	
				end   
			end	
		end
		
	Check_move:
		begin
		if(selected_col==0 && counter_column_0 < 6)
			begin
			counter_column_0 <= counter_column_0 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_0))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_0))] <= 1;
			end
				
		else if(selected_col==1 && counter_column_1 < 6)
			begin
			counter_column_1 <= counter_column_1 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_1))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_1))] <= 1;
			end
				
		else if(selected_col==2 && counter_column_2 < 6)
			begin
			counter_column_2 <= counter_column_2 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_2))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_2))] <= 1;
			end
				
		else if(selected_col==3 && counter_column_3 < 6)
			begin
			counter_column_3 <= counter_column_3 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_3))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_3))] <= 1;
			end
				
		else if(selected_col==4 && counter_column_4 < 6)
			begin
			counter_column_4 <= counter_column_4 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_4))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_4))] <= 1;
			end
				
		else if(selected_col==5 && counter_column_5 < 6)
			begin
			counter_column_5 <= counter_column_5 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_5))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_5))] <= 1;
			end
				
		else if(selected_col==6 && counter_column_6 < 6)
			begin
			counter_column_6 <= counter_column_6 + 1;
			if(which_player==0)
				color_p0[(selected_col + (7*counter_column_6))] <= 1;
			else if(which_player==1)
				color_p1[(selected_col + (7*counter_column_6))] <= 1;
			end
				
		else 
			begin
			invalid_detect <= 1;
			if(which_player==0 && automatic_player_0==0) state <= Move_0;
			else if(which_player==0 && automatic_player_0==1) state <= Automatic_player;
			else if(which_player==1 && automatic_player_1==0) state <= Move_1;
			else state <= Automatic_player;
			end

		state <= Check_board;
		end

	Check_board:
		begin
		player <= which_player;
		invalid_move <= invalid_detect;
		if(counter_column_0 == 6 && counter_column_1 == 6 && counter_column_2 == 6 && counter_column_3 == 6 && counter_column_4 == 6 && counter_column_5 == 6 && counter_column_6 == 6)
			full_panel <= 1;
		else
			begin
			full_panel <= 0;
			end 
			
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
		if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_1==0 && invalid_detect==0)
			state <= Move_1;
		else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_1==1 && invalid_detect==0)
			state <= Automatic_player;
		else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_0==0 && invalid_detect==0)
			state <= Move_0;
		else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_0==1 && invalid_detect==0)
			state <= Automatic_player;
		else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_0==0 && invalid_detect==1)
			state <= Move_0;
		else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_1==0 && invalid_detect==1)
			state <= Move_1;
		else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_0==1 && invalid_detect==1)
			state <= Automatic_player;
		else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && automatic_player_1==1 && invalid_detect==1)
			state <= Automatic_player;
		end
	
		Automatic_player:
		begin
		if(rising_edge_put)
			begin
			if(automatic_player_0==1) which_player <= 0;
			else which_player <= 1;
			state <= Check_move;
			put_enable <= 1;
			right_enable <= 0;
			left_enable <= 0;
			invalid_detect <= 0;
			end
			
		else
		//logic for automatic strategy
			begin
			  if(rising_edge_right)
			  begin
				
				// Initially choose the middle column as long as counter_column_3 < 6
				if(counter_column_3 < 6 && counter!=2) selected_col <= 3; 
				//Second Move
				if(counter==2 && color_p0[2]==0 && color_p1[2]==0) selected_col <= 2;
				else if(counter==2 && color_p0[4]==0 && color_p1[4]==0) selected_col <= 4; 
					
				
				//check for doubles and make triplet!
				//if there are 2 consecutive squares place one extra to make a triplet
				if(automatic_player_0 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<5; j=j+1) begin //Column
							 if(color_p1[7*i+(j)]==0 & color_p0[7*i+(j)]==0 & color_p0[7*i+(j+1)] & color_p0[7*i+(j+2)] )
								begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p0[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p0[7*i+(j+2)]) 
								begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p0[7*i+(j)] & color_p0[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 ) 
								begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<4; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p0[7*(j+1)+i] & color_p0[7*(j+2)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p0[7*(j+2)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p0[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0) selected_col <= i;
						end
					end
					for(i=0; i<5; i=i+1) begin //Column
						for(j=0; j<4; j=j+1) begin //Row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j+1)+(i+1)] & color_p0[7*(j+2)+(i+2)]) 
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p0[7*(j+2)+(i+2)]) 
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0) 
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
						end
					end
					for(i=0; i<5; i=i+1) begin //Column 
						for(j=2; j<6; j=j+1) begin //Row 
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)]) 
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i; //i
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p0[7*(j-2)+(i+2)] ) 
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0 ) 
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
						end
					end
					
				end	
				
				//if automatic player is player 1
				else if(automatic_player_1 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<5; j=j+1) begin //Column
							 if(color_p0[7*i+(j)]==0 & color_p1[7*i+(j)]==0 & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)] ) 
								 begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p1[7*i+(j+2)])
								 begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 ) 
								 begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<4; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p1[7*(j+2)+i] ) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0) selected_col <= i;
						end
					end
					for(i=0; i<5; i=i+1) begin //Starting column
						for(j=0; j<4; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)])
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p1[7*(j+2)+(i+2)] )
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0)
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
						end
					end
					for(i=0; i<5; i=i+1) begin //Starting column
						for(j=2; j<6; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)] )
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i; 
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p1[7*(j-2)+(i+2)])
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0)
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
						end
					end
					
				end
				
				
				
				//check for threats
				// if there are threats overwrite previous choice of column
				if(automatic_player_0 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<4; j=j+1) begin //Column
							 if(color_p0[7*i+(j)]==0 & color_p1[7*i+(j)]==0 & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)] & color_p1[7*i+(j+3)]) 
								 begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p1[7*i+(j+2)] & color_p1[7*i+(j+3)])
								 begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 & color_p1[7*i+(j+3)]) 
								 begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)]  & color_p1[7*i+(j+3)]==0 & color_p0[7*i+(j+3)]==0)
								 begin
								 if(i==0) selected_col <= j+3;
								 if(color_p0[7*(i-1)+(j+3)]==1 || color_p1[7*(i-1)+(j+3)]==1) selected_col <= j+3;
								 end
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0 & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]==0 & color_p0[7*(j+3)+i]==0) selected_col <= i;
						end
					end
					for(i=0; i<4; i=i+1) begin //Starting column
						for(j=0; j<3; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0 & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)]==0 & color_p0[7*(j+3)+(i+3)]==0)
								 begin
								 if(j==0) selected_col <= i+3;
								 if(color_p0[7*(j+2)+(i+3)]==1 || color_p1[7*(j+2)+(i+3)]==1) selected_col <= i+3;
								 end
						end
					end
					for(i=0; i<4; i=i+1) begin //Starting column
						for(j=3; j<6; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)] & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p1[7*(j-2)+(i+2)] & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0 & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]& color_p1[7*(j-3)+(i+3)]==0 & color_p0[7*(j-3)+(i+3)]==0)
								 begin
								 if(j==3) selected_col <= i+3;
								 if(color_p0[7*(j-4)+(i+3)]==1 || color_p1[7*(j-4)+(i+3)]==1) selected_col <= i+3;
								 end
						end
					end
					
				end
				//if automatic player is player 1
				else if(automatic_player_1 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<4; j=j+1) begin //Column
							 if(color_p1[7*i+(j)]==0 & color_p0[7*i+(j)]==0 & color_p0[7*i+(j+1)] & color_p0[7*i+(j+2)] & color_p0[7*i+(j+3)])
								begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p0[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p0[7*i+(j+2)] & color_p0[7*i+(j+3)]) 
								begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p0[7*i+(j)] & color_p0[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 & color_p0[7*i+(j+3)]) 
								begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
							 else if(color_p0[7*i+(j)] & color_p0[7*i+(j+1)] & color_p0[7*i+(j+2)]  & color_p1[7*i+(j+3)]==0 & color_p0[7*i+(j+3)]==0) 
								begin
								 if(i==0) selected_col <= j+3;
								 if(color_p0[7*(i-1)+(j+3)]==1 || color_p1[7*(i-1)+(j+3)]==1) selected_col <= j+3;
								 end
							 
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p0[7*(j+1)+i] & color_p0[7*(j+2)+i] & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p0[7*(j+2)+i] & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p0[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0 & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p0[7*(j+1)+i] & color_p0[7*(j+2)+i] & color_p1[7*(j+3)+i]==0 & color_p0[7*(j+3)+i]==0) selected_col <= i;
							 
						end
					end
					for(i=0; i<4; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j+1)+(i+1)] & color_p0[7*(j+2)+(i+2)] & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p0[7*(j+2)+(i+2)] & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0 & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j+1)+(i+1)] & color_p0[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)]==0 & color_p0[7*(j+3)+(i+3)]==0) 
								 begin
								 if(j==0) selected_col <= i+3;
								 if(color_p0[7*(j+2)+(i+3)]==1 || color_p1[7*(j+2)+(i+3)]==1) selected_col <= i+3;
								 end
							 
						end
					end
					for(i=0; i<4; i=i+1) begin //Column 
						for(j=3; j<6; j=j+1) begin //Row 
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)] & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p0[7*(j-2)+(i+2)] & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0 & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)]& color_p1[7*(j-3)+(i+3)]==0 & color_p0[7*(j-3)+(i+3)]==0) 
								 begin
								 if(j==3) selected_col <= i+3;
								 if(color_p0[7*(j-4)+(i+3)]==1 || color_p1[7*(j-4)+(i+3)]==1) selected_col <= i+3;
								 end
							 
						end
					end
					
				end	
			
				
				//check for triplets and play to win!
				if(automatic_player_0 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<4; j=j+1) begin //Column
							 if(color_p1[7*i+(j)]==0 & color_p0[7*i+(j)]==0 & color_p0[7*i+(j+1)] & color_p0[7*i+(j+2)] & color_p0[7*i+(j+3)])
								begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p0[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p0[7*i+(j+2)] & color_p0[7*i+(j+3)]) 
								begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p0[7*i+(j)] & color_p0[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 & color_p0[7*i+(j+3)]) 
								begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
							 else if(color_p0[7*i+(j)] & color_p0[7*i+(j+1)] & color_p0[7*i+(j+2)]  & color_p1[7*i+(j+3)]==0 & color_p0[7*i+(j+3)]==0) 
								begin
								 if(i==0) selected_col <= j+3;
								 if(color_p0[7*(i-1)+(j+3)]==1 || color_p1[7*(i-1)+(j+3)]==1) selected_col <= j+3;
								 end
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p0[7*(j+1)+i] & color_p0[7*(j+2)+i] & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p0[7*(j+2)+i] & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p0[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0 & color_p0[7*(j+3)+i]) selected_col <= i;
							 else if(color_p0[7*(j)+i] & color_p0[7*(j+1)+i] & color_p0[7*(j+2)+i] & color_p1[7*(j+3)+i]==0 & color_p0[7*(j+3)+i]==0) selected_col <= i;
							 
						end
					end
					for(i=0; i<4; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j+1)+(i+1)] & color_p0[7*(j+2)+(i+2)] & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p0[7*(j+2)+(i+2)] & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0 & color_p0[7*(j+3)+(i+3)]) 
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j+1)+(i+1)] & color_p0[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)]==0 & color_p0[7*(j+3)+(i+3)]==0) 
								 begin
								 if(j==0) selected_col <= i+3;
								 if(color_p0[7*(j+2)+(i+3)]==1 || color_p1[7*(j+2)+(i+3)]==1) selected_col <= i+3;
								 end
							 
						end
					end
					for(i=0; i<4; i=i+1) begin //Column 
						for(j=3; j<6; j=j+1) begin //Row 
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)] & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p0[7*(j-2)+(i+2)] & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0 & color_p0[7*(j-3)+(i+3)]) 
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p0[7*(j)+(i)] & color_p0[7*(j-1)+(i+1)] & color_p0[7*(j-2)+(i+2)]& color_p1[7*(j-3)+(i+3)]==0 & color_p0[7*(j-3)+(i+3)]==0) 
								 begin
								 if(j==3) selected_col <= i+3;
								 if(color_p0[7*(j-4)+(i+3)]==1 || color_p1[7*(j-4)+(i+3)]==1) selected_col <= i+3;
								 end
						end
					end
					
				end	
				//if automatic player is player 1
				else if(automatic_player_1 == 1)
				begin
					for(i=0; i<6; i=i+1) begin //Row
						for(j=0; j<4; j=j+1) begin //Column
							 if(color_p0[7*i+(j)]==0 & color_p1[7*i+(j)]==0 & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)] & color_p1[7*i+(j+3)]) 
								 begin
								 if(i==0) selected_col <= j;
								 if(color_p0[7*(i-1)+(j)]==1 || color_p1[7*(i-1)+(j)]==1) selected_col <= j;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)]==0 & color_p0[7*i+(j+1)]==0 & color_p1[7*i+(j+2)] & color_p1[7*i+(j+3)])
								 begin
								 if(i==0) selected_col <= j+1;
								 if(color_p0[7*(i-1)+(j+1)]==1 || color_p1[7*(i-1)+(j+1)]==1) selected_col <= j+1;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)]==0 & color_p0[7*i+(j+2)]==0 & color_p1[7*i+(j+3)]) 
								 begin
								 if(i==0) selected_col <= j+2;
								 if(color_p0[7*(i-1)+(j+2)]==1 || color_p1[7*(i-1)+(j+2)]==1) selected_col <= j+2;
								 end
							 else if(color_p1[7*i+(j)] & color_p1[7*i+(j+1)] & color_p1[7*i+(j+2)]  & color_p1[7*i+(j+3)]==0 & color_p0[7*i+(j+3)]==0)
								 begin
								 if(i==0) selected_col <= j+3;
								 if(color_p0[7*(i-1)+(j+3)]==1 || color_p1[7*(i-1)+(j+3)]==1) selected_col <= j+3;
								 end
						end
					end
					for(i=0; i<7; i=i+1) begin //Column
						for(j=0; j<3; j=j+1) begin //Row
							 if(color_p0[7*(j)+i]==0 & color_p1[7*(j)+i]==0 & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i]==0 & color_p0[7*(j+1)+i]==0 & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i]==0 & color_p0[7*(j+2)+i]==0 & color_p1[7*(j+3)+i]) selected_col <= i;
							 else if(color_p1[7*(j)+i] & color_p1[7*(j+1)+i] & color_p1[7*(j+2)+i] & color_p1[7*(j+3)+i]==0 & color_p0[7*(j+3)+i]==0) selected_col <= i;
						end
					end
					for(i=0; i<4; i=i+1) begin //Starting column
						for(j=0; j<3; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i;
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)]==0 & color_p0[7*(j+1)+(i+1)]==0 & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i+1;
								 if(color_p0[7*(j)+(i+1)]==1 || color_p1[7*(j)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)]==0 & color_p0[7*(j+2)+(i+2)]==0 & color_p1[7*(j+3)+(i+3)])
								 begin
								 if(j==0) selected_col <= i+2;
								 if(color_p0[7*(j+1)+(i+2)]==1 || color_p1[7*(j+1)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j+1)+(i+1)] & color_p1[7*(j+2)+(i+2)] & color_p1[7*(j+3)+(i+3)]==0 & color_p0[7*(j+3)+(i+3)]==0)
								 begin
								 if(j==0) selected_col <= i+3;
								 if(color_p0[7*(j+2)+(i+3)]==1 || color_p1[7*(j+2)+(i+3)]==1) selected_col <= i+3;
								 end
						end
					end
					for(i=0; i<4; i=i+1) begin //Starting column
						for(j=3; j<6; j=j+1) begin //Starting row
							 if(color_p1[7*(j)+(i)]==0 & color_p0[7*(j)+(i)]==0 & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)] & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-1)+(i)]==1 || color_p1[7*(j-1)+(i)]==1) selected_col <= i;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)]==0 & color_p0[7*(j-1)+(i+1)]==0 & color_p1[7*(j-2)+(i+2)] & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-2)+(i+1)]==1 || color_p1[7*(j-2)+(i+1)]==1) selected_col <= i+1;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]==0 & color_p0[7*(j-2)+(i+2)]==0 & color_p1[7*(j-3)+(i+3)])
								 begin
								 if(color_p0[7*(j-3)+(i+2)]==1 || color_p1[7*(j-3)+(i+2)]==1) selected_col <= i+2;
								 end
							 else if(color_p1[7*(j)+(i)] & color_p1[7*(j-1)+(i+1)] & color_p1[7*(j-2)+(i+2)]& color_p1[7*(j-3)+(i+3)]==0 & color_p0[7*(j-3)+(i+3)]==0)
								 begin
								 if(j==3) selected_col <= i+3;
								 if(color_p0[7*(j-4)+(i+3)]==1 || color_p1[7*(j-4)+(i+3)]==1) selected_col <= i+3;
								 end
						end
					end
					
				end
				
				
				//if invalid play somewhere that is valid
				if(invalid_detect==1)
					begin
					if(counter_column_0<6) selected_col<=0;
					else if(counter_column_1<6) selected_col<=1;
					else if(counter_column_2<6) selected_col<=2;
					else if(counter_column_3<6) selected_col<=3;
					else if(counter_column_4<6) selected_col<=4;
					else if(counter_column_5<6) selected_col<=5;
					else if(counter_column_6<6) selected_col<=6;
					end
					
				if(automatic_player_0==1) which_player <= 0;
				else which_player <= 1;
				put_enable <= 0;
				right_enable <= 1;
				left_enable <= 0;
				counter = counter + 1;
			  end
			end	  
		
	end	

	endcase
       
	
end

end

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