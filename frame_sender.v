`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:50:47 07/11/2011 
// Design Name: 
// Module Name:    frame_sender 
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
module frame_sender(
	//	Reset, TX Clock
	input	wire		reset,
	input	wire		tx_clk,

	//	configuration pins
	output	wire		conf_tx_en,
	output	wire		conf_tx_jumbo_en,
	output	wire		conf_tx_no_gen_crc,
	output	wire [7:0]	mac_tx_data,
	output	wire		mac_tx_dvld,
	input	wire		mac_tx_ack

);
	//	Local Parameters
	localparam MAC_ADDR		= 48'h004e46324300;
	localparam USER_PRIORITY	= 4'b0000;
	localparam CFI			= 2'b00;
	localparam VID			= 12'h000; //note set

	
	localparam OPT_IPV4		= 16'h0800;
	localparam OPT_ARP		= 16'h0806;
	localparam OPT_RARP		= 16'h8035;
	localparam OPT_IPV6		= 16'h86DD;
/*
	localparam READY		=
//	Preamble created in gig_eth_mac_tx module
//	localparam PREAMBLE		= 
	localparam MAC_DEST		=
	localparam MAC_SNDR		=
	localparam ETH_TYPE		=
	localparam DATA			=
	
*/
	//	Wires & Regs
	reg			conf_tx_en_out_reg;
	reg			conf_tx_jumbo_en_out_reg;
	reg			conf_tx_no_gen_crc_out_reg;

	reg	[7:0]	mac_tx_data_out_reg;
	reg			mac_tx_dvld_out_reg;

//	reg	[3:0]	send_state;
//	reg [3:0]	send_state_next;
	reg	[13:0]	send_counter;
	reg	[13:0]	send_counter_next;

	//	0th netfpga Ethernet port's MAC address
	reg	[6*8-1:0]	MAC_addr;

	assign conf_tx_en		= conf_tx_en_out_reg;
	assign conf_tx_jumbo_en		= conf_tx_jumbo_en_out_reg;
	assign conf_tx_no_gen_crc	= conf_tx_no_gen_crc_out_reg;

	assign mac_tx_data		= mac_tx_data_out_reg;
	assign mac_tx_dvld		= mac_tx_dvld_out_reg;



	//	Sequential Logic
	always @(posedge tx_clk or posedge reset) begin
		if (reset) begin
			conf_tx_en_out_reg		<= 1'b0;
			conf_tx_jumbo_en_out_reg	<= 1'b0;
			conf_tx_no_gen_crc_out_reg	<= 1'b0;
			mac_tx_data_out_reg		<= 8'h00;
			mac_tx_dvld_out_reg		<= 1'b0;
			MAC_addr			<= MAC_ADDR;

		end

	end

endmodule
