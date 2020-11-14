`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
    output reg [15:0] score, 
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire whiteLine;
	reg[9:0] whiteLineY = 10'd435;
	
	//spaceship
    reg [9:0] xpos, ypos;
	wire spaceship;
    integer shipSize = 20;
    integer shipSpeed = 4;

    //celebration ship
	reg [9:0] c1_xpos, c1_ypos;
	wire c1;
	reg [9:0] c2_xpos, c2_ypos;
	wire c2;
    reg [9:0] c3_xpos, c3_ypos;
	wire c3;

    //takeover ships
    reg [9:0] s1_xpos, s1_ypos;
	wire s1;
	reg [9:0] s2_xpos, s2_ypos;
	wire s2;
    reg [9:0] s3_xpos, s3_ypos;
	wire s3;

	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter YELLOW = 12'b1111_1111_0000;
	parameter CYAN = 12'b0000_1111_1111;
	parameter GREY = 12'b1001_1001_1001;
	
	
	//asteroids
	wire asteroid_1;
	reg[9:0] asteroidY_1;
	reg[9:0] asteroidX_1;
	integer asteroid_1Speed = 2;
	integer a_1Size = 40;
	
	wire asteroid_2;
	reg[9:0] asteroidY_2;
	reg[9:0] asteroidX_2;
	integer asteroid_2Speed = 40;
	integer a_2Size = 40;
	integer a_2xtraj = 10;
	
	wire asteroid_3;
	reg[9:0] asteroidY_3;
	reg[9:0] asteroidX_3;
	integer asteroid_3Speed = 40;
	integer a_3Size = 20;
	integer a_3xtraj = 20;
	
	wire asteroid_4;
	reg[9:0] asteroidY_4;
	reg[9:0] asteroidX_4;
	integer asteroid_4Speed = 1;
	integer a_4Size = 40;
	
	wire asteroid_5;
	reg[9:0] asteroidY_5;
	reg[9:0] asteroidX_5;
	integer asteroid_5Speed = 3;
	integer a_5Size = 40;
	
//	wire asteroid_6;
//	reg[9:0] asteroidY_6;
//	reg[9:0] asteroidX_6;
//	integer asteroid_6Speed = 60;
//	integer a_6Size = 10;
    
    //flag for collision detection
	reg collide;
    
    task traj_gen_right;
        input[9:0] aX, aY, pX, pY;
        input integer speed;
        output integer value;
        integer ax,ay,px,py,xdiff,ydiff,x;
        begin
            ax = aX;
            ay = aY;
            px = pX;
            py = pY;
            xdiff = ax-px;
            ydiff = py-ay;
            x = speed*xdiff/ydiff;
            value = x;
        end
    endtask
        task traj_gen_left;
        input[9:0] aX, aY, pX, pY;
        input integer speed;
        output integer value;
        integer ax,ay,px,py,xdiff,ydiff,x;
        begin
            ax = aX;
            ay = aY;
            px = pX;
            py = pY;
            xdiff = px-ax;
            ydiff = py-ay;
            x = speed*xdiff/ydiff;
            value = x;
        end
    endtask
    //state 
    localparam ALIVE = 2'b00,
               DEAD = 2'b01,
               WIN =  2'b10,
               UNKNOWN = 2'b11;
    reg[1:0] state;
    reg flag;
    // State Machine and Next State Logic
    always@(posedge clk, posedge rst)
        begin
            if(rst)begin
                state <= ALIVE;
            end
            else if(clk)
                begin
                    case(state)                
                        ALIVE:
                        begin
                            background <= BLACK;
                            if(collide)
                                state <= DEAD;
                            else if(score == 16'd1000)
                                state <= WIN;
                        end
                        WIN:
                        begin
                            background <= GREEN;
                        end
                        DEAD:
                        begin
                            background <= RED;
                        end
                        default: background <=BLACK;
                     endcase
                 end
        end
    
	initial begin
	    state <= DEAD;
	    

	   
	   //asteroid 1
	    asteroidX_1 = 10'd340; 
		asteroidY_1 = 10'd50;

	   //asteroid 2
	    asteroidX_2 = 10'd800; 
		asteroidY_2 = 10'd50;
		
		//asteroid 3
	    asteroidX_3 = 10'd150; 
		asteroidY_3 = 10'd50;
		
		//asteroid 4
	    asteroidX_4 = 10'd580; 
		asteroidY_4 = 10'd50;
		
		//asteroid 5
	    asteroidX_5 = 10'd640; 
		asteroidY_5 = 10'd50;
		
		//asteroid 6
//	    asteroidX_6 = 10'd580; 
//		asteroidY_6 = 10'd50;
		
		//score output 
		score = 16'd0;
		
		//background color
        background <= BLACK;
        
        //start position of pixel
        xpos<=200;
        ypos<=450;
        
        //celebration ships
        c1_xpos <= 460;
        c1_ypos <= 275;
        c2_xpos <= 400;
        c2_ypos <= 200;
        c3_xpos <= 520;
        c3_ypos <= 200;
        
        //saucers
        s1_xpos <= 460;
        s1_ypos <= 275;
        s2_xpos <= 400;
        s2_ypos <= 200;
        s3_xpos <= 520;
        s3_ypos <= 200;

	end

	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
        if(state == WIN)begin
            if(~bright )	//force black if not inside the display area
                rgb = BLACK;
            else if (spaceship||c1||c2||c3) 
                rgb = CYAN; 
            else if (whiteLine)
                rgb = WHITE;
            else	
                rgb=background;
        end
        else if (state == DEAD)begin
            if(~bright )	//force black if not inside the display area
                rgb = BLACK;
            else if (
                asteroid_1 ||
                asteroid_2 ||
                asteroid_3 ||
                asteroid_4 ||
                asteroid_5 ||s1||s2||s3
                )
                rgb  =  GREY;
            else if (spaceship) 
                rgb = CYAN; 
            else if (whiteLine)
                rgb = WHITE;
            else	
                rgb=background;
        end
        else begin
            if(~bright )	//force black if not inside the display area
                rgb = BLACK;
            else if (spaceship) 
                rgb = CYAN; 
            else if (
                asteroid_1 ||
                asteroid_2 ||
                asteroid_3 ||
                asteroid_4 ||
                asteroid_5
                )
                rgb  =  GREY;
            else if (whiteLine)
                rgb = WHITE;
            else	
                rgb=background;
        end
	end
    //asteroid 1
    always@(posedge clk)
        begin
             if (clk)begin
                if((state == DEAD) || (state == WIN))begin
                    asteroidY_1 <= 10'd50;
                    asteroidX_1 <= 10'd340;
                end
                else if(state == ALIVE) begin
                    if(!collide)begin
                            asteroidY_1 <= asteroidY_1 + asteroid_1Speed;
                        if(asteroidY_1 >= 10'd 779) begin
                            asteroidY_1 <= 0;
                        end
                    end
                end
            end
        end
	//asteroid 2
    always@(posedge clk)
        begin
            if (clk)begin
                if((state == DEAD) || (state == WIN))begin
                    asteroidY_2 <= 10'd50;
                    asteroidX_2 <= 10'd800;
                end
                else if(state == ALIVE) begin
                    asteroidY_2 <= asteroidY_2 + asteroid_2Speed/10;
                    asteroidX_2 <= asteroidX_2 - a_2xtraj/10;
                    if(asteroidY_2 >= 10'd779) begin
                            asteroidY_2 <= 0;
                            asteroidX_2 <= 800;
                    end
                end
            end
        end
//      always@(posedge clk) //traj gen
//        begin
//        if(clk)begin
//            if((state == DEAD) || (state == WIN))begin
//               traj_gen_right(asteroidX_2,asteroidY_2,xpos,ypos,asteroid_2Speed,a_2xtraj);
//            end
//            else if (state == ALIVE) begin
//                if((asteroidY_2 == 0) && (asteroidX_2 == 800))
//                    traj_gen_right(asteroidX_2,asteroidY_2,xpos,ypos,asteroid_2Speed,a_2xtraj);    
//            end
//        end
//        end
	//asteroid 3
    always@(posedge clk)
        begin
            if (clk)begin
                if((state == DEAD) || (state == WIN))begin
                    asteroidY_3 <= 10'd50;
                    asteroidX_3 <= 10'd150;
                end
                else if(state == ALIVE) begin
                
                    asteroidY_3 <= asteroidY_3 + asteroid_3Speed/10;         
                    asteroidX_3 <= asteroidX_3 + a_3xtraj/10;
                    
                    if(asteroidY_3 >= 10'd779) begin
                            asteroidY_3 <= 0;
                            asteroidX_3 <= 150;
                    end
                end
            end
        end
    //asteroid 4
    always@(posedge clk)
        begin
             if (clk)begin
                if((state == DEAD) || (state == WIN))begin
                    asteroidY_4 <= 10'd50;
                    asteroidX_4 <= 10'd580;
                end
                else if(state == ALIVE) begin
                    if(!collide)begin
                            asteroidY_4 <= asteroidY_4 + asteroid_4Speed;
                        if(asteroidY_4 >= 10'd 779) begin
                            asteroidY_4 <= 0;
                        end
                    end
                end
            end
        end
     //asteroid 5
    always@(posedge clk)
        begin
             if (clk)begin
                if((state == DEAD) || (state == WIN))begin
                    asteroidY_5 <= 10'd50;
                    asteroidX_5 <= 10'd640;
                end
                else if(state == ALIVE) begin
                    if(!collide)begin
                            asteroidY_5 <= asteroidY_5 + asteroid_5Speed;
                        if(asteroidY_5 >= 10'd 779) begin
                            asteroidY_5 <= 0;
                        end
                    end
                end
            end
        end


      //trajectory generator
      always@(posedge clk) //traj gen
        begin
        if(clk)begin
            if((state == DEAD) || (state == WIN))begin
               traj_gen_right(asteroidX_2,asteroidY_2,xpos,ypos,asteroid_2Speed,a_2xtraj);
               traj_gen_left(asteroidX_3,asteroidY_3,xpos,ypos,asteroid_3Speed,a_3xtraj);

            end
            else if (state == ALIVE) begin
                if((asteroidY_2 == 0) && (asteroidX_2 == 800))
                    traj_gen_right(asteroidX_2,asteroidY_2,xpos,ypos,asteroid_2Speed,a_2xtraj);   
                if((asteroidY_3 == 0) && (asteroidX_3 == 150))
                     traj_gen_left(asteroidX_3,asteroidY_3,xpos,ypos,asteroid_3Speed,a_3xtraj);
            end
        end
        end
	//collision detection
	always@(posedge clk)
	   begin
	       if (clk) begin
               if ((state == DEAD) || (state == WIN))
                   collide <= 1'b0;
               else if (state == ALIVE) begin
                   if(
                   (((asteroidX_1 - a_1Size*2) <= (xpos+shipSize)) && ((asteroidX_1 - a_1Size*2) >= (xpos-shipSize)) && (asteroidY_1 >= (ypos-shipSize)) && (asteroidY_1-a_1Size/2 <= (ypos+shipSize))) ||
                   (((asteroidX_1 - a_1Size*2) <= (xpos+shipSize)) && (asteroidX_1 >= (xpos -shipSize)) && (asteroidY_1 >= (ypos-shipSize)) && (asteroidY_1-a_1Size/2 <= (ypos+shipSize))) ||
                   ((asteroidX_1 >= (xpos-shipSize))&& ((asteroidX_1 - a_1Size*2) <= (xpos+shipSize)) && (asteroidY_1 >= (ypos-shipSize)) && (asteroidY_1-a_1Size/2 <= (ypos+shipSize))) ||
                   
                   (((asteroidX_2 - a_2Size) <= (xpos+shipSize)) && ((asteroidX_2 - a_2Size) >= (xpos-shipSize)) && (asteroidY_2 >= (ypos-shipSize)) && (asteroidY_2-a_2Size <= (ypos+shipSize))) ||
                   (((asteroidX_2 - a_2Size) <= (xpos+shipSize)) && (asteroidX_2 >= (xpos -shipSize)) && (asteroidY_2 >= (ypos-shipSize)) && (asteroidY_2-a_2Size <= (ypos+shipSize))) ||
                   ((asteroidX_2 >= (xpos-shipSize))&& ((asteroidX_2 - a_2Size) <= (xpos+shipSize)) && (asteroidY_2 >= (ypos-shipSize)) && (asteroidY_2-a_2Size <= (ypos+shipSize))) ||
                   
                   (((asteroidX_3 - a_3Size) <= (xpos+shipSize)) && ((asteroidX_3 - a_3Size) >= (xpos-shipSize)) && (asteroidY_3 >= (ypos-shipSize)) && (asteroidY_3-a_3Size <= (ypos+shipSize))) ||
                   (((asteroidX_3 - a_3Size) <= (xpos+shipSize)) && (asteroidX_3 >= (xpos -shipSize)) && (asteroidY_3 >= (ypos-shipSize)) && (asteroidY_3-a_3Size <= (ypos+shipSize))) ||
                   ((asteroidX_3 >= (xpos-shipSize))&& ((asteroidX_3 - a_3Size) <= (xpos+shipSize)) && (asteroidY_3 >= (ypos-shipSize)) && (asteroidY_3-a_3Size <= (ypos+shipSize))) ||
                   
                   (((asteroidX_4 - a_4Size*4) <= (xpos+shipSize)) && ((asteroidX_4 - a_4Size*4) >= (xpos-shipSize)) && (asteroidY_4 >= (ypos-shipSize)) && (asteroidY_4-a_4Size/2 <= (ypos+shipSize))) ||
                   (((asteroidX_4 - a_4Size*4) <= (xpos+shipSize)) && (asteroidX_4 >= (xpos -shipSize)) && (asteroidY_4 >= (ypos-shipSize)) && (asteroidY_4-a_4Size/2 <= (ypos+shipSize))) ||
                   ((asteroidX_4 >= (xpos-shipSize))&& ((asteroidX_4 - a_4Size*4) <= (xpos+shipSize)) && (asteroidY_4 >= (ypos-shipSize)) && (asteroidY_4-a_4Size/2 <= (ypos+shipSize)))||
                   
                   (((asteroidX_5 - a_5Size*2) <= (xpos+shipSize)) && ((asteroidX_5 - a_5Size*2) >= (xpos-shipSize)) && (asteroidY_1 >= (ypos-shipSize)) && (asteroidY_5-a_5Size/2 <= (ypos+shipSize))) ||
                   (((asteroidX_5 - a_5Size*2) <= (xpos+shipSize)) && (asteroidX_5 >= (xpos -shipSize)) && (asteroidY_5 >= (ypos-shipSize)) && (asteroidY_5-a_5Size/2 <= (ypos+shipSize))) ||
                   ((asteroidX_5 >= (xpos-shipSize))&& ((asteroidX_5 - a_5Size*2) <= (xpos+shipSize)) && (asteroidY_5 >= (ypos-shipSize)) && (asteroidY_5-a_5Size/2 <= (ypos+shipSize)))
                   ) begin
                       collide <= 1'b1;
                     end
                   end
	        end
	   end
	
	//pixel position
	always@(posedge clk) 
	begin
	    if (clk) begin
		if((state == DEAD) || (state == WIN))
		begin 
			//start position
			xpos<=xpos;
			ypos<=ypos;
		end
		else if (state == ALIVE) begin
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  

            xpos<=200;
            ypos<=450;
		*/
			if(right) begin
				xpos<=xpos+shipSpeed; //change the amount you increment to make the speed faster 
				if(xpos==776) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					xpos<=776;
			end
			else if(left) begin
				xpos<=xpos-shipSpeed;
				if(xpos==152)
					xpos<=152;
			end
		end
		end
	end
	
    //score countingco
    always@(posedge clk)
        begin
            if (clk) begin
                if ((state == DEAD)) begin
                    score = 16'd0;
                end
                else if(state == WIN) begin
                    score = score;
                end
                else if (state == ALIVE) begin
                    if(((hCount >= 10'd144) && (hCount <= 10'd784)) && 
                        (
                        (asteroidY_1 >= whiteLineY)||
                        (asteroidY_2 >= whiteLineY)||
                        (asteroidY_3 >= whiteLineY)||
                        (asteroidY_4 >= whiteLineY)||
                        (asteroidY_5 >= whiteLineY)
                        )) // passing the white line 
                        begin
                            score = score + 16'd1;
                        end
                end
            end
        end

	assign whiteLine = ((hCount >= 10'd144) && (hCount <= 10'd784)) 
	       && ((vCount >= whiteLineY) && (vCount <= whiteLineY + 10'd25)) ? 1: 0;
	
	//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	//assign block_fill= vCount >= (ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
    
    assign spaceship = (

        ((vCount >= (ypos-20)) && (vCount <= (ypos-16)) && hCount>=(xpos-4) && hCount<=(xpos+4)) ||
        ((vCount >= (ypos-16)) && (vCount <= (ypos-12)) && hCount>=(xpos-8) && hCount<=(xpos+8)) ||
        
        ((vCount >= (ypos-12)) && (vCount <= (ypos-8)) && hCount>=(xpos-12) && hCount<=(xpos-4)) ||
        ((vCount >= (ypos-12)) && (vCount <= (ypos-8)) && hCount>=(xpos+4) && hCount<=(xpos+12)) ||
        
        
        ((vCount >= (ypos-8)) && (vCount <= (ypos-4)) && hCount>=(xpos-16) && hCount<=(xpos-4)) ||
        ((vCount >= (ypos-8)) && (vCount <= (ypos-4)) && hCount>=(xpos+4) && hCount<=(xpos+16)) ||
        
        ((vCount >= (ypos -4)) && (vCount <= ypos) && hCount>=(xpos-20) && hCount<=(xpos+20)) ||
        ((vCount >= ypos) && (vCount <= (ypos+4)) && hCount>=(xpos-16) && hCount<=(xpos+16)) ||
        ((vCount >= (ypos+4)) && (vCount <= (ypos+8)) && hCount>=(xpos-8) && hCount<=(xpos+8)) ||
        ((vCount >= (ypos+8)) && (vCount <= (ypos+12)) && hCount>=(xpos-6) && hCount<=(xpos+6)) ||
        ((vCount >= (ypos+12)) && (vCount <= ypos+16) && hCount>=(xpos-4) && hCount<=(xpos+4)) ||
        ((vCount >= (ypos+16)) && (vCount <= ypos+20) && hCount>=(xpos-4) && hCount<=(xpos+4)) ||
        
        ((vCount >= (ypos+4)) && (vCount <= ypos+12) && hCount>=(xpos-16) && hCount<=(xpos-12)) ||
        ((vCount >= (ypos+4)) && (vCount <= ypos+12) && hCount>=(xpos+12) && hCount<=(xpos+16))
      
           ) ? 1:0;
        assign c1 = (

        ((vCount >= (c1_ypos-20)) && (vCount <= (c1_ypos-16)) && hCount>=(c1_xpos-4) && hCount<=(c1_xpos+4)) ||
        ((vCount >= (c1_ypos-16)) && (vCount <= (c1_ypos-12)) && hCount>=(c1_xpos-8) && hCount<=(c1_xpos+8)) ||
        
        ((vCount >= (c1_ypos-12)) && (vCount <= (c1_ypos-8)) && hCount>=(c1_xpos-12) && hCount<=(c1_xpos-4)) ||
        ((vCount >= (c1_ypos-12)) && (vCount <= (c1_ypos-8)) && hCount>=(c1_xpos+4) && hCount<=(c1_xpos+12)) ||
        
        
        ((vCount >= (c1_ypos-8)) && (vCount <= (c1_ypos-4)) && hCount>=(c1_xpos-16) && hCount<=(c1_xpos-4)) ||
        ((vCount >= (c1_ypos-8)) && (vCount <= (c1_ypos-4)) && hCount>=(c1_xpos+4) && hCount<=(c1_xpos+16)) ||
        
        ((vCount >= (c1_ypos -4)) && (vCount <= c1_ypos) && hCount>=(c1_xpos-20) && hCount<=(c1_xpos+20)) ||
        ((vCount >= c1_ypos) && (vCount <= (c1_ypos+4)) && hCount>=(c1_xpos-16) && hCount<=(c1_xpos+16)) ||
        ((vCount >= (c1_ypos+4)) && (vCount <= (c1_ypos+8)) && hCount>=(c1_xpos-8) && hCount<=(c1_xpos+8)) ||
        ((vCount >= (c1_ypos+8)) && (vCount <= (c1_ypos+12)) && hCount>=(c1_xpos-6) && hCount<=(c1_xpos+6)) ||
        ((vCount >= (c1_ypos+12)) && (vCount <= c1_ypos+16) && hCount>=(c1_xpos-4) && hCount<=(c1_xpos+4)) ||
        ((vCount >= (c1_ypos+16)) && (vCount <= c1_ypos+20) && hCount>=(c1_xpos-4) && hCount<=(c1_xpos+4)) ||
        
        ((vCount >= (c1_ypos+4)) && (vCount <= c1_ypos+12) && hCount>=(c1_xpos-16) && hCount<=(c1_xpos-12)) ||
        ((vCount >= (c1_ypos+4)) && (vCount <= c1_ypos+12) && hCount>=(c1_xpos+12) && hCount<=(c1_xpos+16))
      
           ) ? 1:0;

        assign c2 = (

        ((vCount >= (c2_ypos-20)) && (vCount <= (c2_ypos-16)) && hCount>=(c2_xpos-4) && hCount<=(c2_xpos+4)) ||
        ((vCount >= (c2_ypos-16)) && (vCount <= (c2_ypos-12)) && hCount>=(c2_xpos-8) && hCount<=(c2_xpos+8)) ||
        
        ((vCount >= (c2_ypos-12)) && (vCount <= (c2_ypos-8)) && hCount>=(c2_xpos-12) && hCount<=(c2_xpos-4)) ||
        ((vCount >= (c2_ypos-12)) && (vCount <= (c2_ypos-8)) && hCount>=(c2_xpos+4) && hCount<=(c2_xpos+12)) ||
        
        
        ((vCount >= (c2_ypos-8)) && (vCount <= (c2_ypos-4)) && hCount>=(c2_xpos-16) && hCount<=(c2_xpos-4)) ||
        ((vCount >= (c2_ypos-8)) && (vCount <= (c2_ypos-4)) && hCount>=(c2_xpos+4) && hCount<=(c2_xpos+16)) ||
        
        ((vCount >= (c2_ypos -4)) && (vCount <= c2_ypos) && hCount>=(c2_xpos-20) && hCount<=(c2_xpos+20)) ||
        ((vCount >= c2_ypos) && (vCount <= (c2_ypos+4)) && hCount>=(c2_xpos-16) && hCount<=(c2_xpos+16)) ||
        ((vCount >= (c2_ypos+4)) && (vCount <= (c2_ypos+8)) && hCount>=(c2_xpos-8) && hCount<=(c2_xpos+8)) ||
        ((vCount >= (c2_ypos+8)) && (vCount <= (c2_ypos+12)) && hCount>=(c2_xpos-6) && hCount<=(c2_xpos+6)) ||
        ((vCount >= (c2_ypos+12)) && (vCount <= c2_ypos+16) && hCount>=(c2_xpos-4) && hCount<=(c2_xpos+4)) ||
        ((vCount >= (c2_ypos+16)) && (vCount <= c2_ypos+20) && hCount>=(c2_xpos-4) && hCount<=(c2_xpos+4)) ||
        
        ((vCount >= (c2_ypos+4)) && (vCount <= c2_ypos+12) && hCount>=(c2_xpos-16) && hCount<=(c2_xpos-12)) ||
        ((vCount >= (c2_ypos+4)) && (vCount <= c2_ypos+12) && hCount>=(c2_xpos+12) && hCount<=(c2_xpos+16))
      
           ) ? 1:0;
        assign c3= (

        ((vCount >= (c3_ypos-20)) && (vCount <= (c3_ypos-16)) && hCount>=(c3_xpos-4) && hCount<=(c3_xpos+4)) ||
        ((vCount >= (c3_ypos-16)) && (vCount <= (c3_ypos-12)) && hCount>=(c3_xpos-8) && hCount<=(c3_xpos+8)) ||
        
        ((vCount >= (c3_ypos-12)) && (vCount <= (c3_ypos-8)) && hCount>=(c3_xpos-12) && hCount<=(c3_xpos-4)) ||
        ((vCount >= (c3_ypos-12)) && (vCount <= (c3_ypos-8)) && hCount>=(c3_xpos+4) && hCount<=(c3_xpos+12)) ||
        
        
        ((vCount >= (c3_ypos-8)) && (vCount <= (c3_ypos-4)) && hCount>=(c3_xpos-16) && hCount<=(c3_xpos-4)) ||
        ((vCount >= (c3_ypos-8)) && (vCount <= (c3_ypos-4)) && hCount>=(c3_xpos+4) && hCount<=(c3_xpos+16)) ||
        
        ((vCount >= (c3_ypos -4)) && (vCount <= c3_ypos) && hCount>=(c3_xpos-20) && hCount<=(c3_xpos+20)) ||
        ((vCount >= c3_ypos) && (vCount <= (c3_ypos+4)) && hCount>=(c3_xpos-16) && hCount<=(c3_xpos+16)) ||
        ((vCount >= (c3_ypos+4)) && (vCount <= (c3_ypos+8)) && hCount>=(c3_xpos-8) && hCount<=(c3_xpos+8)) ||
        ((vCount >= (c3_ypos+8)) && (vCount <= (c3_ypos+12)) && hCount>=(c3_xpos-6) && hCount<=(c3_xpos+6)) ||
        ((vCount >= (c3_ypos+12)) && (vCount <= c3_ypos+16) && hCount>=(c3_xpos-4) && hCount<=(c3_xpos+4)) ||
        ((vCount >= (c3_ypos+16)) && (vCount <= c3_ypos+20) && hCount>=(c3_xpos-4) && hCount<=(c3_xpos+4)) ||
        
        ((vCount >= (c3_ypos+4)) && (vCount <= c3_ypos+12) && hCount>=(c3_xpos-16) && hCount<=(c3_xpos-12)) ||
        ((vCount >= (c3_ypos+4)) && (vCount <= c3_ypos+12) && hCount>=(c3_xpos+12) && hCount<=(c3_xpos+16))
      
           ) ? 1:0;
    assign asteroid_1 = ((hCount <= asteroidX_1) && (hCount >= asteroidX_1 - a_1Size*2)) &&
               ((vCount <= asteroidY_1) && (vCount >= asteroidY_1 - a_1Size/2)) ? 1 : 0;	
    assign asteroid_2 = ((hCount <= asteroidX_2) && (hCount >= asteroidX_2 - a_2Size)) &&
               ((vCount <= asteroidY_2) && (vCount >= asteroidY_2 - a_2Size)) ? 1 : 0;	
    assign asteroid_3 = ((hCount <= asteroidX_3) && (hCount >= asteroidX_3 - a_3Size)) &&
               ((vCount <= asteroidY_3) && (vCount >= asteroidY_3 - a_3Size)) ? 1 : 0;	
    assign asteroid_4 = ((hCount <= asteroidX_4) && (hCount >= asteroidX_4 - a_4Size*4)) &&
               ((vCount <= asteroidY_4) && (vCount >= asteroidY_4 - a_4Size/2)) ? 1 : 0;	
    assign asteroid_5 = ((hCount <= asteroidX_5) && (hCount >= asteroidX_5 - a_5Size*2)) &&
               ((vCount <= asteroidY_5) && (vCount >= asteroidY_5 - a_5Size/2)) ? 1 : 0;	
    assign s1 = ((hCount <= asteroidX_3) && (hCount >= asteroidX_3 - a_3Size)) &&
            ((vCount <= asteroidY_3) && (vCount >= asteroidY_3 - a_3Size)) ? 1 : 0;	
    assign s2= ((hCount <= asteroidX_2) && (hCount >= asteroidX_2 - a_2Size)) &&
        ((vCount <= asteroidY_2) && (vCount >= asteroidY_2 - a_2Size)) ? 1 : 0;	
    assign s3= ((hCount <= asteroidX_2) && (hCount >= asteroidX_2 - a_2Size)) &&
    ((vCount <= asteroidY_2) && (vCount >= asteroidY_2 - a_2Size)) ? 1 : 0;	

endmodule
