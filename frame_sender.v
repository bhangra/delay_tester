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
	localparam MAC_SRC_ADDR		= 48'h004e46324300;
	localparam MAC_DST_ADDR		= 48'h004e46324301;

/*	localparam USER_PRIORITY	= 4'b0000;
	localparam CFI			= 2'b00;
	localparam VID			= 12'h000000; //note set 
*/
	
	localparam OPT_IPV4		= 16'h0800;
	localparam OPT_ARP		= 16'h0806;
	localparam OPT_RARP		= 16'h8035;
	localparam OPT_IPV6		= 16'h86DD;

	localparam IDOL			= 4'd0;
//assign mac_tx_ack_out_reg_next  = tx_state == TX_PREAMBLE && tx_counter == 7;
	localparam WAIT_PREAMBLE	= 4'd1;
	localparam MAC_DEST		= 4'd2;
	localparam MAC_SRC		= 4'd3;
	localparam ETH_TYPE		= 4'd4;
	localparam DATA			= 4'd5;
	
	//	Wires & Regs
	reg		conf_tx_en_out_reg;
	reg		conf_tx_en_out_reg_next;
	reg		conf_tx_jumbo_en_out_reg;
	reg		conf_tx_jumbo_en_out_reg_next;
	reg		conf_tx_no_gen_crc_out_reg;
	reg		conf_tx_no_gen_crc_out_reg_next;

	reg [7:0]	mac_tx_data_out_reg;
	reg [7:0]	mac_tx_data_out_reg_next;
	reg		mac_tx_dvld_out_reg;
	reg		mac_tx_dvld_out_reg_next;
	reg		mac_tx_ack_in_reg;
	

	reg [3:0]	send_state;
	reg [3:0]	send_state_next;
	reg [13:0]	send_counter;
	reg [13:0]	send_counter_next;

	//	0th netfpga Ethernet port's MAC address
	reg	[6*8-1:0]	MAC_src_addr;
	reg	[6*8-1:0]	MAC_dst_addr;

	assign conf_tx_en		= conf_tx_en_out_reg;
	assign conf_tx_jumbo_en		= conf_tx_jumbo_en_out_reg;
	assign conf_tx_no_gen_crc	= conf_tx_no_gen_crc_out_reg;

	assign mac_tx_data		= mac_tx_data_out_reg;
	assign mac_tx_dvld		= mac_tx_dvld_out_reg;

//	Counter
	always @* begin
	  if(send_state_next != send_state_next)
		send_counter_next	= 1;
	  else
		send_counter_next	= send_counter + 1;
	end

	always @* begin
	//	send MAC
	  if(tx_state	== MAC_DST)
		mac_tx_data_out_reg_next = MAC_dst_addr[(7-send_counter)*8-1:(6-(send_counter))*8];
	  if(tx_state	== MAC_SRC)
		mac_tx_data_out_reg_next = MAC_src_addr[(7-send_counter)*8-1:(6-send_counter))*8];
	end

//	State Machine
	always @* begin
		case(send_state)
		  IDOL: begin
			if(send_count = 1000)
				send_state_next = WAIT_PREAMBLE;
		  end
		  WAIT_PREAMBLE: begin
			if(mac_tx_ack_in_reg)
				send_state_next = MAC_DST;
		  end
		  MAC_DST: begin
			if(send_count = 6)
				send_state_next = MAC_SRC;
		  end
		  MAC_SRC: begin
			if(send_count = 6)
				send_state_next = ETH_TYPE;
		  end
		  ETH_TYPE: begin
			if(send_count = 2)
				send_state_next = DATA;
		  end
		endcase

	//	Sequential Logic
	always @(posedge tx_clk or posedge reset) begin
		if (reset) begin
			conf_tx_en_out_reg		<= 1'b0;
			conf_tx_jumbo_en_out_reg	<= 1'b0;
			conf_tx_no_gen_crc_out_reg	<= 1'b0;
			mac_tx_data_out_reg		<= 8'h00;
			mac_tx_dvld_out_reg		<= 1'b0;
			MAC_dst_addr			<= MAC_DST_ADDR;
			MAC_src_addr			<= MAC_SRC_ADDR;
			send_state			<= IDOL;
			send_counter			<= 0;
		end
			mac_tx_data_out_reg		<= mac_tx_data_out_reg_next;
			mac_tx_data_dvld_out_reg	<= mac_tx_data_dvld_out_reg_next;		
			mac_tx_ack_in_reg		<= mac_tx_ack;
			send_counter			<= send_state_counter_next;
			mac_tx_data_out_reg		<= mac_tx_data_out_reg_next;
	end

endmodule
