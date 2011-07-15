`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:45:48 05/25/2011 
// Design Name: 
// Module Name:    top 
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
module top(
	//Core Clock
	input 				core_clk,
	
	//Misc
	input 				nf2_reset,
	
	//RGMII interface for 4 MACs
	input				gtx_clk,	//125MHz common clock for TX
	output			phy_mdc, 	//Management Data Clock, 2.5MHz 
										//sourced continuously from STA(station managment entity)
	inout				phy_mdio,	//Management Data I/O, 5bit PHY address: 32devices
										//5bit reg address: 32registers
	input				rgmii_0_rx_ctl,
	input				rgmii_0_rxc,
	input 	[3:0]		rgmii_0_rxd,
	output				rgmii_0_tx_ctl,
	output				rgmii_0_txc,
	output	[3:0]		rgmii_0_txd,
	
	input				rgmii_1_rx_ctl,
	input				rgmii_1_rxc,
	input	[3:0]		rgmii_1_rxd,
	output				rgmii_1_tx_ctl,
	output				rgmii_1_txc,
	output	[3:0]		rgmii_1_txd
	
/*	input				rgmii_2_rx_ctl,
	input				rgmii_2_rxc,
	input	[3:0]		rgmii_2_rxd,
	output				rgmii_2_tx_ctl,
	output				rgmii_2_txc,
	output	[3:0]		rgmii_2_txd,
	
	input				rgmii_3_rx_ctl,
	input				rgmii_3_rxc,
	input	[3:0]		rgmii_3_rxd,
	output				rgmii_3_tx_ctl,
	output				rgmii_3_txc,
	output	[3:0]		rgmii_3_txd,
*/	
/*	//CPCI interface & clock
	input 				cpci_clk,	//	62.5 MHz
	input 				cpci_rd_wr_L,
	input 				cpci_req,
	input 	[26:0] 		cpci_addr,
	input 	[31:0]		cpci_data,
	output 				cpci_rd_rdy,
	output 				cpci_wr_rdy,
	output				nf2_err,
	
	//Spartan Configuration Pin
	input				cpci_rp_cclk,
	input 				cpci_rp_done,
	input 				cpci_rp_init_b,
	output 				cpci_rp_en,	
	output 				cpci_rp_prog_b,
	output				cpci_rp_din,
	
	//CPCI debug data
	input	[28:0]		cpci_debug_data,
	output 	[3:0]		cpci_tx_full,
	
	//CPCI DMA handshake signals
	input 	[1:0]		dma_op_code_req,
	input	[3:0]		dma_op_queue,
	output	[1:0]		dma_op_code_ack,
	//DMA data and flow control
	input				dma_vld_c2n,
	output				dma_vld_n2c,
	inout	[31:0]		dma_data,
	input 				dma_q_nearly_full_c2n,
	output				dma_q_nearly_full_n2c,

	//Debug bus connected LA connector
	output 				debug_led,
	output 	[1:0]		debug_clk,
	output 	[31:0]		debug_data,

	//SRAM1 
	output				sram1_we,
	output				sram1_zz,
	output	[3:0]		sram1_bw,
	output	[19:0]		sram1_addr,
	inout	[35:0]		sram1_data,

	//SRAM2
	output				sram2_we,
	output				sram2_zz,
	output				sram2_bw,
	output	[19:0]		sram2_addr,
	inout	[35:0]		sram2_data
*/
    );
	wire	reset;
	wire	core_locked;
	wire	disable_reset;

//	gtx_clk Clock Management
//	125MHz TX reference clock for the MACs

	IBUF	ibufg_gtx_clk (.I(gtx_clk), .O(gtx_clk_ibufg));
	
	//DCM is used to generate 2ns set-up and hold time
	
	DCM RGMII_TX_DCM (
		.CLKIN(gtx_clk_ibufg),
		.CLKFB(tx_rgmii_clk_int),
		.DSSEN(1'b0),
		.PSINCDEC(1'b0),
		.PSEN(1'b0),
		.PSCLK(1'b0),
		.RST(reset),
		.CLK0(tx_clk0),
		.CLK90(tx_clk90),
		.CLK180(),
		.CLK270(),
		.CLK2X(),
		.CLK2X180(),
		.CLKDV(),
		.CLKFX(),
		.CLKFX180(),
		.PSDONE(),
		.STATUS(),
		.LOCKED()
	);
	
	BUFGMUX BUFGMUX_TXCLK(
		.O(tx_rgmii_clk_int),
		.I0(tx_clk0),
		.I1(tx_clk90),
		.S(1'b0)
	);
	
	BUFGMUX BUFGMUX_TXCLK90(
		.O(tx_rgmii_clk90_int),
		.I1(tx_clk0),
		.I0(tx_clk90),
		.S(1'b0)
	);
/*	
   IBUFG inst_rgmii_0_rxc_ibuf  (.I(rgmii_0_rxc),  .O(rgmii_0_rxc_ibuf));
   IBUFG inst_rgmii_1_rxc_ibuf  (.I(rgmii_1_rxc),  .O(rgmii_1_rxc_ibuf));
   
   DCM RGMII_0_RX_DCM (
                       .CLKIN(rgmii_0_rxc_ibuf),
                       .CLKFB(rx_rgmii_0_clk_int),  // feedback from BUFGMUX
                       .DSSEN(1'b0),
                       .PSINCDEC(1'b0),
                       .PSEN(1'b0),
                       .PSCLK(1'b0),
                       .RST(reset),
                       .CLK0(rgmii_0_clk0),
                       .CLK90(),
                       .CLK180(),
                       .CLK270(),
                       .CLK2X(),
                       .CLK2X180(),
                       .CLKDV(),
                       .CLKFX(),
                       .CLKFX180(),
                       .PSDONE(),
                       .STATUS(),
                       .LOCKED()
                       );

   BUFGMUX BUFGMUX_RGMII_0_RXCLK (
                                  .O(rx_rgmii_0_clk_int),
                                  .I0(rgmii_0_clk0),
                                  .I1(),
                                  .S(1'b0)
                                  );
  DCM RGMII_1_RX_DCM (
                       .CLKIN(rgmii_1_rxc_ibuf),
                       .CLKFB(rx_rgmii_1_clk_int),  // feedback from BUFGMUX
                       .DSSEN(1'b0),
                       .PSINCDEC(1'b0),
                       .PSEN(1'b0),
                       .PSCLK(1'b0),
                       .RST(reset),
                       .CLK0(rgmii_1_clk0),
                       .CLK90(),
                       .CLK180(),
                       .CLK270(),
                       .CLK2X(),
                       .CLK2X180(),
                       .CLKDV(),
                       .CLKFX(),
                       .CLKFX180(),
                       .PSDONE(),
                       .STATUS(),
                       .LOCKED()
                       );

   BUFGMUX BUFGMUX_RGMII_1_RXCLK (
                                  .O(rx_rgmii_1_clk_int),
                                  .I0(rgmii_1_clk0),
                                  .I1(),
                                  .S(1'b0)
                                  );
*/  
   wire [7:0]    gmii_0_txd_int;
   wire [7:0]    gmii_0_rxd_reg;
   wire [1:0]    eth_clock_0_speed;

	rgmii_io	rgmii_0_io(
		.rgmii_rxc      (rgmii_0_rxc),//rx_rgmii_0_clk_int -> rgmii_0_rxc
		.rgmii_rxd             (rgmii_0_rxd),
		.rgmii_rx_ctl          (rgmii_0_rx_ctl),
		.rgmii_txc             (rgmii_0_txc),
		.rgmii_txd             (rgmii_0_txd),
		.rgmii_tx_ctl          (rgmii_0_tx_ctl),
		.gmii_txd_int          (gmii_0_txd_int),
		.gmii_tx_en_int        (gmii_0_tx_en_int),
		.gmii_tx_er_int        (gmii_0_tx_er_int),
		.gmii_col_int          (gmii_0_col_int),
		.gmii_crs_int          (gmii_0_crs_int),
		.gmii_rxd_reg          (gmii_0_rxd_reg),
		.gmii_rx_dv_reg        (gmii_0_rx_dv_reg),
		.gmii_rx_er_reg        (gmii_0_rx_er_reg),
		.eth_link_status       (eth_link_0_status),
		.eth_clock_speed       (eth_clock_0_speed),
		.eth_duplex_status     (eth_duplex_0_status),
		.tx_rgmii_clk_int      (tx_rgmii_clk_int),
		.tx_rgmii_clk90_int    (tx_rgmii_clk90_int),
		.reset                 (reset)
	);
	
   wire [7:0]    gmii_1_txd_int;
   wire [7:0]    gmii_1_rxd_reg;
   wire [1:0]    eth_clock_1_speed;
	
	rgmii_io	rgmii_1_io(
		.rgmii_rxc      (rgmii_1_rxc), //rx_rgmii_1_clk_int -> rgmii_1_rxc
		.rgmii_rxd             (rgmii_1_rxd),
		.rgmii_rx_ctl          (rgmii_1_rx_ctl),
		.rgmii_txc             (rgmii_1_txc),
		.rgmii_txd             (rgmii_1_txd),
		.rgmii_tx_ctl          (rgmii_1_tx_ctl),
		.gmii_txd_int          (gmii_1_txd_int),
		.gmii_tx_en_int        (gmii_1_tx_en_int),
		.gmii_tx_er_int        (gmii_1_tx_er_int),
		.gmii_col_int          (gmii_1_col_int),
		.gmii_crs_int          (gmii_1_crs_int),
		.gmii_rxd_reg          (gmii_1_rxd_reg),
		.gmii_rx_dv_reg        (gmii_1_rx_dv_reg),
		.gmii_rx_er_reg        (gmii_1_rx_er_reg),
		.eth_link_status       (eth_link_1_status),
		.eth_clock_speed       (eth_clock_1_speed),
		.eth_duplex_status     (eth_duplex_1_status),
		.tx_rgmii_clk_int      (tx_rgmii_clk_int),
		.tx_rgmii_clk90_int    (tx_rgmii_clk90_int),
		.reset                 (reset)
	);
// --- PHY MDIO tri-state
	
	wire phy_mdio_tri, phy_mdio_out, phy_mdio_in;
	assign phy_mdio = phy_mdio_tri ? phy_mdio_out : 1'bz;
	assign phy_mdio_in = phy_mdio;

// --- core clock logic.
        IBUFG inst_core_clk_ibuf (.I(core_clk), .O(core_clk_ibuf));

        DCM CORE_DCM_CLK(
                .CLKIN(core_clk_ibuf),
                .CLKFB(core_clk_int),
                .DSSEN(1'b0),
                .PSINCDEC(1'b0),
                .PSEN(1'b0),
                .PSCLK(1'b0),
                .RST(nf2_reset & ~disable_reset),
		.CLK0(core_clk0),
		.CLK90(),
		.CLK180(),
		.CLK270(),
		.CLK2X(),
		.CLK2X180(),
		.CLKDV(),
		.CLKFX(),
		.CLKFX180(),
		.PSDONE(),
		.STATUS(),
		.LOCKED(core_locked)
	);

	BUFGMUX BUFGMUX_CORE_CLK(
		.O(core_clk_int),
		.I1(),
		.I0(core_clk0),
		.S(1'b0)
	);
	
	//for debuggin purpose
	reg	[7:0]	rgmii_0_reg;
	reg	[7:0]	rgmii_1_reg;
	sta	sta(
		.clk(core_clk_int),
		.reset(reset),
		.phy_mdc	(phy_mdc),
		.phy_mdio_out	(phy_mdio_out),
		.phy_mdio_tri	(phy_mdio_tri),
		.phy_mdio_in	(phy_mdio_in)
	);
	nf_core nf_core(
		.eth_clock_0_speed		(eth_clock_0_speed),
		.eth_duplex_0_status	(eth_duplex_0_status),
		.eth_link_0_status		(eth_link_0_status),
		.gmii_0_crs_int			(gmii_0_crs_int),
		.gmii_0_col_int			(gmii_0_col_int),
		.gmii_0_rxd_reg			(gmii_0_rxd_reg),
		.gmii_0_rx_dv_reg		(gmii_0_rx_dv_reg),
		.gmii_0_rx_er_reg		(gmii_0_rx_er_reg),
		.gmii_0_txd_int			(gmii_0_txd_int),
		.gmii_0_tx_en_int		(gmii_0_tx_en_int),
		.gmii_0_tx_er_int		(gmii_0_tx_er_int),

		.eth_clock_1_speed		(eth_clock_1_speed),
		.eth_duplex_1_status	(eth_duplex_1_status),
		.eth_link_1_status		(eth_link_1_status),
		.gmii_1_crs_int			(gmii_1_crs_int),
		.gmii_1_col_int			(gmii_1_col_int),
		.gmii_1_rxd_reg			(gmii_1_rxd_reg),
		.gmii_1_rx_dv_reg		(gmii_1_rx_dv_reg),
		.gmii_1_rx_er_reg		(gmii_1_rx_er_reg),
		.gmii_1_txd_int			(gmii_1_txd_int),
		.gmii_1_tx_en_int		(gmii_1_tx_en_int),
		.gmii_1_tx_er_int		(gmii_1_tx_er_int),
		
		.tx_rgmii_clk_int		(tx_rgmii_clk_int),
		.rx_rgmii_0_clk_int		(rgmii_0_rxc),
		.rx_rgmii_1_clk_int		(rgmii_1_rxc),
		.core_clk_int			(core_clk_int),

		.reset					(reset)

	);
always @(posedge core_clk)
begin
	rgmii_0_reg <= gmii_0_rxd_reg;
	rgmii_1_reg <= gmii_1_rxd_reg;
end

	assign reset = (nf2_reset && !disable_reset) || !core_locked;
endmodule
