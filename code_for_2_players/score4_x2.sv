module score4_x2(
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
	
	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue
);

//player 0 variables
logic which_player_c;
logic win_a_c;
logic win_b_c;
logic left_enable_c;
logic right_enable_c;
logic put_enable_c;
logic invalid_detect_c;
logic [41:0] winner_tokens_c;
logic player_c;
logic full_panel_c;
logic invalid_move_c;
logic [41:0] color_p0_c;
logic [41:0] color_p1_c;
logic [2:0] selected_col_c0;
logic fsm0_enable_0_changed_c;
logic fsm1_enable_0_changed_c;

//player 1 variables
logic full_panel_c1;
logic player_c1;
logic invalid_move_c1;
logic which_player_c1;
logic win_a_c1;
logic win_b_c1;
logic left_enable_c1;
logic right_enable_c1;
logic put_enable_c1;
logic invalid_detect_c1;
logic [41:0] winner_tokens_c1;
logic player1; 
logic fullpanel1;
logic invalid_move1;
logic [2:0] selected_col_c1;
logic fsm0_enable_1_changed_c;
logic fsm1_enable_1_changed_c;


//for vga
logic left_enable_vga;
logic right_enable_vga;
logic put_enable_vga;
logic [41:0] winner_tokens_vga;
logic [2:0] selected_col_vga;
logic [41:0] color_p0_vga;
logic [41:0] color_p1_vga;
logic which_player_vga;
logic invalid_detect_vga;
logic win_a_vga;
logic win_b_vga;

//extra variables for synchronization
logic edge_right,edge_left,edge_put,rising_edge_right,rising_edge_left,rising_edge_put;
logic [10:0] put_counter = 1;
logic [2:0]change;


//module declarations
	fsm0_x2 fsm0(
		.clk   		    (clk),
		.rst   		    (rst),
		.player         (player_c),
		.which_player   (which_player_c),
		.invalid_move   (invalid_move_c),
		.invalid_detect (invalid_detect_c),
		.full_panel     (full_panel_c),
		.left           (left),
		.right          (right),
		.put            (put),
		.win_a 		    (win_a_c),
		.win_b 		    (win_b_c),
		.left_enable    (left_enable_c),
		.right_enable   (right_enable_c),
		.put_enable     (put_enable_c),
		.winner_tokens  (winner_tokens_c),
		.color_p0       (color_p0_c),
		.color_p1       (color_p1_c),
		.selected_col_1_changed   (selected_col_c1),
		.selected_col_0_changed   (selected_col_c0),
		.fsm0_enable_0_changed    (fsm0_enable_0_changed_c),
		.fsm0_enable_1_changed    (fsm0_enable_1_changed_c),
		.fsm1_enable_0_changed    (fsm1_enable_0_changed_c),
		.fsm1_enable_1_changed    (fsm1_enable_1_changed_c)
		);
				
	fsm1_x2 fsm1(
		.clk   		    (clk),
		.rst   		    (rst),
		.player         (player_c1),
		.which_player   (which_player_c1),
		.invalid_move   (invalid_move_c1),
		.invalid_detect (invalid_detect_c1),
		.full_panel     (full_panel_c1),
		.left           (left),
		.right          (right),
		.put            (put),
		.win_a 		    (win_a_c1),
		.win_b 		    (win_b_c1),
		.left_enable    (left_enable_c1),
		.right_enable   (right_enable_c1),
		.put_enable     (put_enable_c1),
		.winner_tokens  (winner_tokens_c1),
		.color_p0       (color_p0_c),
		.color_p1       (color_p1_c),
		.selected_col_0_changed   (selected_col_c0),
		.selected_col_1_changed   (selected_col_c1),
		.fsm0_enable_0_changed    (fsm0_enable_0_changed_c),
		.fsm0_enable_1_changed    (fsm0_enable_1_changed_c),
		.fsm1_enable_0_changed    (fsm1_enable_0_changed_c),
		.fsm1_enable_1_changed    (fsm1_enable_1_changed_c)
		);
			
	vga_x2 vga(
		.clk   		   (clk),
		.rst   		   (rst),
		.which_player  (which_player_vga),
		.invalid_detect(invalid_detect_vga),
		.win_a 		   (win_a_vga),
		.win_b 		   (win_b_vga),
		.left_enable   (left_enable_vga),
		.right_enable  (right_enable_vga),
		.put_enable    (put_enable_vga),
		.winner_tokens (winner_tokens_c),
		.selected_col  (selected_col_vga),
		.color_p0      (color_p0_c),
		.color_p1      (color_p1_c),
		.hsync 		   (hsync),
		.vsync 		   (vsync),
		.red   		   (red),
		.green 		   (green),
		.blue  		   (blue)
		);


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


//define vga inputs according to rising edge put/right/left and which player plays
always_comb
begin
if(rising_edge_put)
	begin
	put_counter = put_counter+1;
	change = 0;
	end
else if(rising_edge_right) change=1;
else if(rising_edge_left) change=2;
	
	//if player 0 plays give as inputs to vga player's 0 variables 
	if((put_counter % 2)==0)
	begin
	which_player_vga = which_player_c;
	invalid_detect_vga = invalid_detect_c;
	win_a_vga = win_a_c;
	win_b_vga = win_b_c;
	left_enable_vga = left_enable_c;
	right_enable_vga = right_enable_c;
	put_enable_vga = put_enable_c;
	selected_col_vga = selected_col_c0;
	if(change==1) selected_col_vga = selected_col_c0 +1;
	if(change==2) selected_col_vga = selected_col_c0 -1;
	player = which_player_c;
	invalid_move = invalid_detect_c;
	win_a = win_a_c;
	win_b = win_b_c;
	full_panel = full_panel_c;
	end
		
	//if player 0 plays give as inputs to vga player's 0 variables 
	if((put_counter % 2)!=0)
	begin
	which_player_vga = which_player_c1;
	invalid_detect_vga = invalid_detect_c1;
	win_a_vga = win_a_c1;
	win_b_vga = win_b_c1;
	left_enable_vga = left_enable_c1;
	right_enable_vga = right_enable_c1;
	put_enable_vga = put_enable_c1;
	selected_col_vga = selected_col_c1;
	if(change==1) selected_col_vga = selected_col_c1 +1;
	if(change==2) selected_col_vga = selected_col_c1 -1;
	player = which_player_c1;
	invalid_move = invalid_detect_c1;
	win_a = win_a_c1;
	win_b = win_b_c1;
	full_panel = full_panel_c1;
	end
	
end
	
endmodule