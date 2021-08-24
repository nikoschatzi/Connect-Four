module vga_x2(

	input logic clk,
	input logic rst,

	input logic left_enable,
	input logic right_enable,
	input logic put_enable,
	input logic [41:0] winner_tokens,
	input logic [2:0] selected_col,
	input logic [41:0] color_p0,
	input logic [41:0] color_p1,
	input logic which_player,
	input logic invalid_detect,
	input logic win_a,
	input logic win_b,

		
	output logic hsync,
	output logic vsync,
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue	

);

logic [41:0] circle_enable={42{1'b0}};
logic [10:0] x;
logic [10:0] y;
logic [41:0][10:0] center_x;
logic [41:0][10:0] center_y; 

logic [10:0] m;
logic [10:0] n;
logic [10:0] w;
logic [10:0] z;
logic [10:0] a=0;;

logic enable ;
logic[9:0] counter_row ;   //for rows
logic[9:0] counter_col ;   //for columns


//this is for updating values for counter_col and counter_row
always_ff @(posedge clk,posedge rst)
begin

if(rst)
	begin
	enable <= 1;
	counter_col<= 0;
	counter_row<= 0;
	end
	
else
	begin
	if(enable)
		begin		
			if(counter_col == 799)
				begin
				counter_col <= 0;
				counter_row <= counter_row + 1;
				end
			else counter_col <= counter_col + 1;
				
			if(counter_row==523 && counter_col==799)
				begin
				counter_col <= 0;
				counter_row <= 0;
				end
		end
	enable <= ~enable;	
	end	
end
	
//this is for hsync
always_comb
begin		
	if(counter_col >= 656 && counter_col<=751) hsync = 0;	
	else hsync = 1;
end

//this is for vsync
always_comb
begin		
	if(counter_row >=491 && counter_row<=492) vsync = 0;
	else vsync = 1;				
end

//calculate all centers
always_comb
begin
	for(n=0; n<6; n=n+1)
	begin
	a=0;
		for(m=0; m<7; m=m+1)
		begin
			center_y[m+(7*n)]=(80+a);
			center_x[m+(7*n)]=(437-(80*n));
			a=(a+80);
		end
	end
end

//calculate center_enable table
always_comb
begin
	for(w=0; w<42; w=w+1)
	begin
		if (counter_row>center_x[w])
			x=(counter_row-center_x[w]);
		else
			begin
			x=(center_x[w]-counter_row);
			end
		if (counter_col>center_y[w])
			y=(counter_col-center_y[w]);
		else
			begin
			y=(center_y[w]-counter_col);
			end
		if (((x*x)+(y*y))<=729)
		circle_enable[w]=1;
		else
		circle_enable[w]=0;
	end
end

//this is for coloring the pixels
always_comb
begin

	red = 4'b0000;
	green = 4'b0000;
	blue = 4'b0000;

for(z=0; z<42; z=z+1)
	begin	
	
		//this is for circles
	    if(winner_tokens[z]==1 && circle_enable[z]==1)
			begin
			if(win_a==1)
				begin
				red = 4'b0000;
				green = 4'b1111;
				blue = 4'b1111;
				end
			else if(win_b==1)
				begin
				red = 4'b1111;
				green = 4'b0000;
				blue = 4'b1111;
				end
			end
			
		else if(color_p0[z]==1 && circle_enable[z]==1)
			begin
			red = 4'b0000;
			green = 4'b0000;
			blue = 4'b1111;
			end
			
		else if(color_p1[z]==1 && circle_enable[z]==1)
			begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
			end
	
		//this is for cersor
		if(z>=0 && z<=6)
		begin
			if((right_enable==1 || left_enable==1) && selected_col==z && counter_col>=(43+(80*z)) && counter_col<=(117+(80*z)) && counter_row >= 0 && counter_row <= 4)
				begin
				if(which_player==0)
					begin
					red = 4'b0000;
					green = 4'b0000;
					blue = 4'b1111;
					end
				else if(which_player==1)
					begin
					red = 4'b1111;
					green = 4'b0000;
					blue = 4'b0000;
					end
				end
					
			else if(put_enable==1 && selected_col==z && counter_col>=(43+(80*z)) && counter_col<=(117+(80*z)) && counter_row >= 0 && counter_row <= 4)
				begin
				if((which_player==0 && invalid_detect==0) || (which_player==1 && invalid_detect==1))
					begin
					red = 4'b1111;
					green = 4'b0000;
					blue = 4'b0000;
					end
				else if((which_player==1 && invalid_detect==0) || (which_player==0 && invalid_detect==1))
					begin
					red = 4'b0000;
					green = 4'b0000;
					blue = 4'b1111;
					end
				end
		 end
		 
		 //this is for green lines
		 if(z>=0 && z<=8)
		 begin
			if(	(counter_col >= (38+(80*z)) && counter_col <= (42+(80*z))) || (counter_col >= 38 && counter_col <= 602) && (counter_row >= (75+(80*z)) && counter_row <= (79+(80*z)))) 
				begin
				red = 4'b0000;
				green = 4'b1111;
				blue = 4'b0000;
				end
		 end
	end	
end
				
endmodule
