`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:52:39 07/11/2011 
// Design Name: 
// Module Name:    timer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module timer(
	input	wire		reset,
	input	wire		tx_clk,

	input	wire		frame_sent;
	input	wire		frame_caught;

	output	wire		time_dif_out;
    );
	reg	[19:0]		time_counter;
	reg	[19:0]		time_counter_next;
	
	reg	[19:0]		time_sent;
	reg	[19:0]		time_caught;


//	time counter
	always @* begin
		time_count_next = time_count + 1;
	end

//	Sequential Logic
	always @ (posedge tx_clk or posedge reset) begin
		if (reset) begin
			time_counter	<= 0;
		end
		else begin
			time_counter	<= time_counter_next;
		end

endmodule
