module score4(
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


logic which_player_c;
logic win_a_c;
logic win_b_c;
logic left_enable_c;
logic right_enable_c;
logic put_enable_c;
logic invalid_detect_c;
logic [41:0] winner_tokens_c;
logic [41:0] color_p0_c;
logic [41:0] color_p1_c;
logic [2:0] selected_col_c;

logic hsync_c;
logic vsync_c;
logic [3:0]red_c;
logic [3:0]green_c;
logic [3:0]blue_c;

assign win_a=win_a_c;
assign win_b=win_b_c;


fsm fsm_values(
	.clk   		    (clk),
	.rst   		    (rst),
	.player         (player),
	.which_player   (which_player_c),
	.invalid_move   (invalid_move),
	.invalid_detect (invalid_detect_c),
	.full_panel     (full_panel),
	.left           (left),
	.right          (right),
	.put            (put),
	.win_a 		    (win_a_c),
	.win_b 		    (win_b_c),
	.left_enable    (left_enable_c),
	.right_enable   (right_enable_c),
	.put_enable     (put_enable_c),
	.winner_tokens  (winner_tokens_c),
	.selected_col   (selected_col_c),
	.color_p0       (color_p0_c),
	.color_p1       (color_p1_c)
	);
	
	

vga vga_values(
	.clk   		   (clk),
	.rst   		   (rst),
	.which_player  (which_player_c),
	.invalid_detect(invalid_detect_c),
	.win_a 		   (win_a_c),
	.win_b 		   (win_b_c),
	.left_enable   (left_enable_c),
	.right_enable  (right_enable_c),
	.put_enable    (put_enable_c),
	.winner_tokens (winner_tokens_c),
	.selected_col  (selected_col_c),
	.color_p0      (color_p0_c),
	.color_p1      (color_p1_c),
	.hsync 		   (hsync),
	.vsync 		   (vsync),
	.red   		   (red),
	.green 		   (green),
	.blue  		   (blue)
	);
	
endmodule