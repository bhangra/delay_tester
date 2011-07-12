`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:47:28 05/25/2011 
// Design Name: 
// Module Name:    rgmii_io 
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
module rgmii_io(
//	Pad side Signals
	input			rgmii_rxc,	//from rx_rgmii_clk_int -> rgmii_rxc
	input	[3:0]	rgmii_rxd,
	input			rgmii_rx_ctl,

	output			rgmii_txc,
	output	[3:0]	rgmii_txd,
	output			rgmii_tx_ctl,

//	Core side Signals
	input 	[7:0]	gmii_txd_int, 
	input       	gmii_tx_en_int,
	input       	gmii_tx_er_int,
	output  		gmii_col_int,
	output	 	   	gmii_crs_int,

	output reg [7:0]gmii_rxd_reg,   // RGMII double data rate data valid
	output reg	    gmii_rx_dv_reg, // gmii_rx_dv_ibuf registered in IOBs
	output reg     	gmii_rx_er_reg, // gmii_rx_er_ibuf registered in IOBs

//----------------------------------------------------------------------
//-- Clocks and misc
//----------------------------------------------------------------------
	output reg    	eth_link_status,
	output reg [1:0]eth_clock_speed,
	output reg    	eth_duplex_status,

// FOllowing are generated by DCMs
	input		tx_rgmii_clk_int,     // Internal RGMII transmitter clock.
	input	 	tx_rgmii_clk90_int,   // Internal RGMII transmitter clock w/ 90 deg phase
	input 			reset
	);

//added the symbol "(* IOB="FORCE" *)" 
//to get around [PAD symbol "*****" is unconnected] error
//////////////////////////////////////////////////////////////////////////////
//http://dora.bk.tsukuba.ac.jp/~takeuchi/index.php?%C5%C5%B5%A4%B2%F3%CF%A9%2FHDL%2FXilinx%20ISE%20%A4%CB%A4%AA%A4%B1%A4%EB%A4%CE%C0%A9%CC%F3%A4%CE%CD%BF%A4%A8%CA%FD	
//////////////////////////////////////////////////////////////////////////////
	(* IOB="FORCE" *)wire					rgmii_rx_ctl_ibuf;
	(* IOB="FORCE" *)wire		[3:0]	rgmii_rxd_ibuf;     // RGMII receiver data input.
	wire	[3:0]	rgmii_txd_obuf;


	reg		[7:0]	rgmii_rxd_ddr;
	reg				rgmii_rx_dv_ddr;    // Inverted version of the signal.
	reg				rgmii_rx_ctl_ddr;   // RGMII double data rate data.
	reg		[7:0]	rgmii_rxd_reg;      // RGMII double data rate data valid.
	reg				rgmii_rx_dv_reg;    // RGMII double data rate control signal.
	reg				rgmii_rx_ctl_reg;   // RGMII data. gmii_tx_en signal.
	
	reg		[7:0]	gmii_txd_rising;
	reg				gmii_tx_en_rising;
	reg				rgmii_tx_ctl_rising;
	reg		[3:0]	gmii_txd_falling;
	reg				rgmii_tx_ctl_falling;
	
//	RGMII Receiver Logic

//receive RGMII rx signals through Input Buffers
/*	IBUF drive_rgmii_rx_ctl(.I(rgmii_rx_ctl), .O(rgmii_rx_ctl_ibuf));

	IBUF drive_rgmii_rxd3(.I(rgmii_rxd[3]), .O(rgmii_rxd_ibuf[3]));
	IBUF drive_rgmii_rxd2(.I(rgmii_rxd[2]), .O(rgmii_rxd_ibuf[2]));
	IBUF drive_rgmii_rxd1(.I(rgmii_rxd[1]), .O(rgmii_rxd_ibuf[1]));
	IBUF drive_rgmii_rxd0(.I(rgmii_rxd[0]), .O(rgmii_rxd_ibuf[0]));
*/

//
//RX Interface
//

//Double Data Rate Input 
	always @ (posedge rgmii_rxc or posedge reset)
	begin
		if(reset)
			begin
				rgmii_rxd_ddr[3:0]	<= 4'b0;
				rgmii_rx_dv_ddr		<= 1'b0;
			end
		else
			begin
				rgmii_rxd_ddr[3:0]	<= rgmii_rxd;
				rgmii_rx_dv_ddr		<= rgmii_rx_ctl;
			end
	end
	
	assign not_rgmii_rxc = ~rgmii_rxc;

	always @ (posedge not_rgmii_rxc or posedge reset)
	begin
		if(reset)
			begin
				rgmii_rxd_ddr[7:4]	<= 4'b0;
				rgmii_rx_ctl_ddr	<= 1'b0;
			end
		else
			begin
				rgmii_rxd_ddr[7:4]	<= rgmii_rxd;
				rgmii_rx_ctl_ddr		<= rgmii_rx_ctl;
			end
	end
	
	//DDR signals 
	always @ (posedge rgmii_rxc or posedge reset)	//rx_rgmii_clk_int
	begin
		if(reset)
			begin
				rgmii_rxd_reg[3:0]	<= 4'b0;
				rgmii_rx_dv_reg		<= 1'b0;
			end
		else
			begin
				rgmii_rxd_reg[3:0]	<= rgmii_rxd_ddr[3:0];
				rgmii_rx_dv_reg		<=	rgmii_rx_dv_ddr;
			end
	end

	always @ (posedge not_rgmii_rxc or posedge reset)	//not_rx_rgmii_clk_int
	begin
		if(reset)
			begin
				rgmii_rxd_reg[7:4]	<= 4'b0;
				rgmii_rx_ctl_reg		<=	1'b0;
			end
		else
			begin
				rgmii_rxd_reg[7:4]	<= rgmii_rxd_ddr[7:4];
				rgmii_rx_ctl_reg		<= rgmii_rx_ctl_ddr;
			end
	end
	
	always @ (posedge rgmii_rxc or posedge reset)	//rx_rgmii_clk_int
	begin
		if(reset)
			begin
				gmii_rxd_reg[7:0]	<= 8'b0;
				gmii_rx_dv_reg			<= 1'b0;
				gmii_rx_er_reg			<= 1'b0;
			end
		else
			begin
				gmii_rxd_reg[7:0]	<= rgmii_rxd_reg;
				gmii_rx_dv_reg			<=	rgmii_rx_dv_reg;
				gmii_rx_er_reg			<= rgmii_rx_ctl_reg ^ rgmii_rx_dv_reg;
			end
	end
//	
//	TX Interface 
//

//TX clock
	FDDRRSE	gmii_tx_clk_ddr_iob(
		.Q		(rgmii_txc_obuf),
		.D0	(1'b1),
		.D1	(1'b0),
		.C0	(tx_rgmii_clk90_int),
		.C1	(not_tx_rgmii_clk90_int),
		.CE	(1'b1),
		.R		(1'b1),
		.S		(1'b0)
	);
	assign	not_tx_rgmii_clk90_int = ~(tx_rgmii_clk90_int);
	OBUF drive_rgmii_txc	(.I(rgmii_tx_obuf), .O(rgmii_txc));
	
//RGMII transmitter Logic
//

	assign	rgmii_tx_ctl_int = gmii_tx_en_int ^ gmii_tx_er_int;
	
	always @	(posedge tx_rgmii_clk_int or posedge reset)
	begin
		if (reset)
			begin
				gmii_txd_rising		<= 8'b0;
				gmii_tx_en_rising		<=	1'b0;
				rgmii_tx_ctl_rising	<=	1'b0;
			end
		else
			begin
				gmii_txd_rising		<=	gmii_txd_int;
				gmii_tx_en_rising		<=	gmii_tx_en_int;
				rgmii_tx_ctl_rising	<=	rgmii_tx_ctl_int;
			end
	end
	
	assign	not_tx_rgmii_clk_int = ~(tx_rgmii_clk_int);
	
	always @ (posedge not_tx_rgmii_clk_int or posedge reset)
	begin
		if(reset)
			begin
				gmii_txd_falling		<=	4'b0;
				rgmii_tx_ctl_falling	<=	1'b0;
			end
		else
			begin
				gmii_txd_falling		<=	gmii_txd_rising[7:4];
				rgmii_tx_ctl_falling	<=	rgmii_tx_ctl_rising;
			end
	end
	
	FDDRRSE	rgmii_txd_out3(
		.Q		(rgmii_txd_obuf[3]),
		.D0	(gmii_txd_rising[3]),
		.D1	(gmii_txd_falling[3]),
		.C0	(tx_rgmii_clk_int),
		.C1	(not_tx_rgmii_clk_int),
		.CE	(1'b1),
		.R		(reset),
		.S		(1'b0)
	);
	FDDRRSE	rgmii_txd_out2(
		.Q		(rgmii_txd_obuf[2]),
		.D0	(gmii_txd_rising[2]),
		.D1	(gmii_txd_falling[2]),
		.C0	(tx_rgmii_clk_int),
		.C1	(not_tx_rgmii_clk_int),
		.CE	(1'b1),
		.R		(reset),
		.S		(1'b0)
	);
	FDDRRSE	rgmii_txd_out1(
		.Q		(rgmii_txd_obuf[1]),
		.D0	(gmii_txd_rising[1]),
		.D1	(gmii_txd_falling[1]),
		.C0	(tx_rgmii_clk_int),
		.C1	(not_tx_rgmii_clk_int),
		.CE	(1'b1),
		.R		(reset),
		.S		(1'b0)
	);
	FDDRRSE	rgmii_txd_out0(
		.Q		(rgmii_txd_obuf[0]),
		.D0	(gmii_txd_rising[0]),
		.D1	(gmii_txd_falling[0]),
		.C0	(tx_rgmii_clk_int),
		.C1	(not_tx_rgmii_clk_int),
		.CE	(1'b1),
		.R		(reset),
		.S		(1'b0)
	);
	
	OBUF drive_rgmii_ctl	(.I(rgmii_tx_ctl_obuf), .O(rgmii_tx_ctl));
	OBUF drive_rgmii_txd3 (.I(rgmii_txd_obuf[3]), .O(rgmii_txd[3]));
	OBUF drive_rgmii_txd2 (.I(rgmii_txd_obuf[2]), .O(rgmii_txd[2]));
	OBUF drive_rgmii_txd1 (.I(rgmii_txd_obuf[1]), .O(rgmii_txd[1]));
	OBUF drive_rgmii_txd0 (.I(rgmii_txd_obuf[0]), .O(rgmii_txd[0]));
	
//
//Inband Status Registers
//
	assign inband_ce = !(gmii_rx_dv_reg || gmii_rx_er_reg);

	always @ (posedge rgmii_rxc or posedge reset)
	begin
		if (reset)
			begin
				eth_link_status		<= 1'b0;
				eth_clock_speed[1:0]<= 2'b0;
				eth_duplex_status	<= 1'b0;
		end
		else if (inband_ce)
			begin
				eth_link_status		<= gmii_rxd_reg[0];
				eth_clock_speed[1:0]<= gmii_rxd_reg[2:1];
				eth_duplex_status	<= gmii_rxd_reg[3];
		end
	end
	
	assign gmii_col_int = (gmii_tx_en_int | gmii_tx_er_int) & (gmii_rx_dv_reg | gmii_rx_er_reg);
	assign gmii_crs_int = (gmii_tx_en_int | gmii_tx_er_int) & (gmii_rx_dv_reg | gmii_rx_er_reg);

endmodule