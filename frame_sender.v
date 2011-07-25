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

	//	Configuration pins
	output	wire		conf_tx_en,
	output	wire		conf_tx_jumbo_en,
	output	wire		conf_tx_no_gen_crc,

	//	MAC Interface
	output	wire [7:0]	mac_tx_data,
	output	wire		mac_tx_dvld,
	input	wire		mac_tx_ack

);
//	Local Parameters
	localparam SAMPLE_FRAME		= 448'hFFFFFFFFFFFF0022FA157ada0806010800060400010022FA157ADACBB28BD5000000000000CBB28B9F0000000000000000000000000000;  
	localparam SAMPLE_FRAME_SIZE	= 56;

//	MAC parameters
	localparam MAC_NF2C0_ADDR	= 48'h004e46324300; //nf2c0
	localparam MAC_NF2C1_ADDR	= 48'h004e46324301; //nf2c1
	localparam ARP_TARGET_ADDR	= 48'h000000000000;
//	Ethernet Types
	localparam ETH_TYPE_IPV4	= 16'h0800;
	localparam ETH_TYPE_ARP		= 16'h0806;
	localparam ETH_TYPE_RARP	= 16'h8035;
	localparam ETH_TYPE_IPV6	= 16'h86DD;


//	IP Parameters
//	IP Header Length(h) & Version(l) Field
//	No Option Fields: 5*4*8bits long
	localparam IPV4_HDRLEN_5	= 8'b01010100;	
	localparam IPV4_TOS_ALL_0	= 8'b00000000;
	localparam IPV4_TOTAL_LEN	= (IPV4_HDRLEN_5-4)/8; // + IPV4_DATA_LEN); 16bit wide
	localparam IPV4_ID_ZERO		= 16'd0;
	localparam IPV4_NOFRAG_FLAG	= 16'd1;
	localparam IPV4_TTL			= 8'd10;
	localparam IPV4_UDP_PROTOCOL= 8'h11; //8'd17
//	localparam IPV4_HDR_CHECKSUM= 16'
//	localparam IPV4_SDR_ADDR	= 
	localparam IPV4_BROADCAST	= 32'hFFFFFFFF;
//	localparam IPV4_DATA_LENGTH	= 

//	State Machine Parameters
	localparam IDOL				= 4'd0;
	localparam WAIT_FOR_ACK		= 4'd1;
	localparam MAC_DST			= 4'd2;
	localparam MAC_SRC			= 4'd3;
	localparam ETH_TYPE			= 4'd4;
	localparam DATA				= 4'd5;
	localparam WAIT_ACK			= 4'd6;

	localparam GEN_VALID_FRAME	= 4'hd;
	localparam GEN_CHKSUM		= 4'he;
	localparam RESET			= 4'hf;
	
//	Wires & Regs
	reg		conf_tx_en_out_reg;
	reg		conf_tx_en_out_reg_next;
	reg		conf_tx_jumbo_en_out_reg;
	reg		conf_tx_jumbo_en_out_reg_next;
	reg		conf_tx_no_gen_crc_out_reg;
	reg		conf_tx_no_gen_crc_out_reg_next;

	reg [7:0]	mac_tx_data_out_reg;
	reg		mac_tx_dvld_out_reg;
	wire	mac_tx_dvld_out_reg_next;
	reg		mac_tx_ack_in_reg;
	

	reg [3:0]	send_state;
	reg [3:0]	send_state_next;
	reg [13:0]	send_counter;
	reg [13:0]	send_counter_next;

	//	MAC Registers
	//	Destination MAC Addr
	reg	[6*8-1:0]	MAC_dst_addr;
	//	0th netfpga Ethernet port's MAC address
	reg	[6*8-1:0]	MAC_src_addr;
	reg [2*8-1:0]	ETH_type;
	//	IP Header Registers;
	//Largest Herder length = 16*32bit
	reg [16*32-1:0]	IP_HDR_reg;

//	Frame Storing Register
	reg [8*64-1:0] valid_arp; //64*8 <- 56*8 = 448;
	reg [8*64-1:0] valid_arp_next;

	// Assigning Wires
	assign conf_tx_en		= conf_tx_en_out_reg;
	assign conf_tx_jumbo_en		= conf_tx_jumbo_en_out_reg;
	assign conf_tx_no_gen_crc	= conf_tx_no_gen_crc_out_reg;

	assign mac_tx_data		= mac_tx_data_out_reg;
	assign mac_tx_dvld		= mac_tx_dvld_out_reg;

//	Counter
	always @* begin
	  if(send_state != send_state_next)
		send_counter_next	= 1;
	  else
		send_counter_next	= send_counter + 1;
	end

//	Send MAC
	always @* begin
/*	  if(send_state	== MAC_DST)
	    case(send_counter)
			1:	mac_tx_data_out_reg_next = MAC_dst_addr[6*8-1:5*8];
			2:	mac_tx_data_out_reg_next = MAC_dst_addr[5*8-1:4*8];
			3:	mac_tx_data_out_reg_next = MAC_dst_addr[4*8-1:3*8];
			4:	mac_tx_data_out_reg_next = MAC_dst_addr[3*8-1:2*8];
			5:	mac_tx_data_out_reg_next = MAC_dst_addr[2*8-1:1*8];
			6:	mac_tx_data_out_reg_next = MAC_dst_addr[1*8-1:0*8];
		endcase
	  if(send_state	== MAC_SRC)
	  	case(send_counter)
			1:	mac_tx_data_out_reg_next = MAC_src_addr[6*8-1:5*8];
			2:	mac_tx_data_out_reg_next = MAC_src_addr[5*8-1:4*8];
			3:	mac_tx_data_out_reg_next = MAC_src_addr[4*8-1:3*8];
			4:	mac_tx_data_out_reg_next = MAC_src_addr[3*8-1:2*8];
			5:	mac_tx_data_out_reg_next = MAC_src_addr[2*8-1:1*8];
			6:	mac_tx_data_out_reg_next = MAC_src_addr[1*8-1:0*8];
		endcase
	  if(send_state == ETH_TYPE)
	  	case(send_counter)
			1:	mac_tx_data_out_reg_next = ETH_type[2*8-1:1*8];
			2:	mac_tx_data_out_reg_next = ETH_type[1*8-1:0*8];
		endcase
*/
//		mac_tx_dvld_out_reg = (send_state == WAIT_FOR_ACK ||    send_state == MAC_DST || send_state == MAC_SRC ||   send_state == ETH_TYPE || send_state == DATA);
/*
		if (send_state == GEN_VALID_FRAME) begin
			conf_tx_en_out_reg_next			= 1'b1;
			conf_tx_jumbo_en_out_reg_next	= 1'b0;
			conf_tx_no_gen_crc_out_reg_next	= 1'b0;
		end
		if (send_state == RESET) begin	
			mac_tx_data_out_reg				= 8'b00000000; 
			valid_arp[8*(64)-1:8*(64-55)]	=   448'hFFFFFFFFFFFF0022FA157ada0806010800060400010022FA157ADACBB28BD5000000000000CBB28B9F0000000000000000000000000000;
	  		mac_tx_data_out_reg = 8'b00000000;
		end
		if (send_state == WAIT_FOR_ACK && !mac_tx_ack) begin
			mac_tx_data_out_reg[7:0] = valid_arp[8*64-1:8*63];
		end
		if (send_state == WAIT_FOR_ACK && mac_tx_ack) begin
			valid_arp[8*64-1:8*1] = valid_arp[8*63-1:8*0];
			mac_tx_data_out_reg[7:0] = valid_arp[8*64-1:8*63];
		end
		if (send_state == DATA) begin
			valid_arp[8*64-1:8*1] = valid_arp[8*63-1:8*0];
	  		mac_tx_data_out_reg[7:0] = valid_arp[8*64-1:8*63];
		end
*/
		case (send_state)
			GEN_VALID_FRAME: begin
				conf_tx_en_out_reg_next			= 1'b1;
				conf_tx_jumbo_en_out_reg_next 	= 1'b0;
				conf_tx_no_gen_crc_out_reg_next	= 1'b0;
				valid_arp_next[8*(64)-1:8*(64-(SAMPLE_FRAME_SIZE - 1))] = SAMPLE_FRAME;	//511 ~ 72 = 440 = 55; 19 -14 = 5
			end
			RESET: begin
				mac_tx_data_out_reg             = 8'b00000000; 
			end
			WAIT_FOR_ACK: begin
				if(!mac_tx_ack)
					mac_tx_data_out_reg[7:0]	= valid_arp[8*64-1:8*63];
				else if(mac_tx_ack) begin
					valid_arp_next [8*64-1:8*1]		= valid_arp[8*63-1:8*0];
					mac_tx_data_out_reg[7:0]	= valid_arp[8*64-1:8*63];
				end
			end
			DATA: begin
				if(!reset) begin
					valid_arp_next [8*64-1:8*1]		= valid_arp[8*63-1:8*0];
					mac_tx_data_out_reg[7:0]	= valid_arp[8*64-1:8*63];
				end
			end

		endcase
	end

/*
	always @* begin
		if (send_state == IDOL && send_state_next == GEN_CHKSUM) begin
			IP_HDR_reg[1*8-1:0*8] <= IPV4_HDRLEN_5;
			IP_HDR_reg[2*8-1:1*8] <= IPV4_TOS_ALL_0;
			IP_HDR_reg[4*8-1:2*8] <= IPV4_TOTAL_LEN;
			IP_HDR_reg[6*8-1:4*8] <= IPV4_ID_ZERO;
			IP_HDR_reg[8*8-1:6*8] <= IPV4_NOFRAG_FLAG;
			IP_HDR_reg[9*8-1:8*8] <= IPV4_TTL;
			IP_HDR_reg[10*8-1:9*8] <= IPV4_UDP_PROTOCOL;
			IP_HDR_reg[12*8-1:10*8] <= 16'd0;	// Header Checksum		
		end
	end
*/

//	State Machine
	always @* begin
		case(send_state)
		  IDOL: begin
			if(send_counter == 100)
				send_state_next = GEN_VALID_FRAME;
		  end
		  GEN_VALID_FRAME: begin
				send_state_next = WAIT_FOR_ACK;
		  end
		  WAIT_FOR_ACK: begin
			if (mac_tx_ack) begin
				send_state_next = DATA;
			end
		  end
		  DATA: begin
			if(send_counter == (SAMPLE_FRAME_SIZE - 2))
				send_state_next = IDOL;
		  end
		  RESET: begin
			send_state_next = IDOL;
		  end
		endcase
	end

	//	Sequential Logic
	always @(posedge tx_clk or posedge reset) begin
		if (reset) begin
			conf_tx_en_out_reg		<= 1'b0;
			conf_tx_jumbo_en_out_reg	<= 1'b0;
			conf_tx_no_gen_crc_out_reg	<= 1'b0;
			mac_tx_dvld_out_reg		<= 1'b0;
			send_state			<= RESET;
			send_counter			<= 0;
		end
		else begin
			conf_tx_en_out_reg		<= conf_tx_en_out_reg_next;
			conf_tx_jumbo_en_out_reg<= conf_tx_jumbo_en_out_reg_next;
			conf_tx_no_gen_crc_out_reg<= conf_tx_no_gen_crc_out_reg_next;
			mac_tx_ack_in_reg		<= mac_tx_ack;
			send_state				<= send_state_next;
			send_counter			<= send_counter_next;
			valid_arp 				<= valid_arp_next;
			// 	set 0 when not sending & waiting CRC gen
			mac_tx_dvld_out_reg 	<= 
				send_state_next == WAIT_FOR_ACK	||
				send_state_next == MAC_DST		||
				send_state_next == MAC_SRC		||
				send_state_next == ETH_TYPE		||
				send_state_next == DATA;

		end
	end
endmodule
