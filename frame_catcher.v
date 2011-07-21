`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:51:33 07/11/2011 
// Design Name: 
// Module Name:    frame_catcher 
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
module frame_catcher(
	input	wire		reset,
	input	wire		rx_clk,

	output	wire		conf_rx_en,
	output	wire		conf_rx_no_chk_crc,
	output	wire		conf_rx_jumbo_en,

	input	wire	[7:0]	mac_rx_data,
	input	wire		mac_rx_dvld,
	input	wire		mac_rx_goodframe,
	input	wire		mac_rx_badframe	
    );

//	State Machine Parameters
	localparam IDOL		= 4'd0;
	localparam DATA		= 4'd1;
	localparam CHECK	= 4'd2;
	localparam RESET	= 4'd15;

	reg [3:0]		catch_state;
	reg [3:0]		catch_state_next;
	reg [13:0]		catch_counter;
	reg [13:0]		catch_counter_next;

//	Counter
	always @* begin
		if(catch_state != catch_state_next)
			catch_counter_next = 1;
		else
			catch_counter_next = catch_counter + 1;
	end

//	Frame Catcher
	always @* begin
		case (catch_state) begin
		
		endcase

//	State Machine
	always @* begin
	  if (reset) begin
		catch_state_next = RESET;
	  end
	  else
		case (catch_state) begin
			IDOL: begin
			  if(mac_rx_dvld)
				catch_state_next = DATA;	
			end
			DATA: begin
			  if (!mac_rx_dvld)
				catch_state_next = CHECK;	
			end
			CHECK: begin
				catch_state_next = IDOL;
			end
			RESET: begin
				catch_state_next = IDOL;
			end
		endcase
	end

//	Sequential Logic
	always @(posedge rx_clk or posedge reset) begin
		if (reset) begin
			catch_state	<= RESET;
			catch_counter	<= 13'd0;
		end
		else begin
			catch_state	<= catch_state_next;
			catch_counter 	<= catch_counter_next;
		end
endmodule
