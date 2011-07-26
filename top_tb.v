////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2003 Xilinx, Inc.
// All Right Reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1.03
//  \   \         Application : ISE
//  /   /         Filename : top_tbw.tfw
// /___/   /\     Timestamp : Thu Jul 14 22:39:31 2011
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: 
//Design Name: top_tbw
//Device: Xilinx
//
`timescale 1ns/1ps

module top_tbw;
    reg core_clk = 1'b0;
    reg nf2_reset = 1'b0;
    reg gtx_clk = 1'b0;
    wire phy_mdc;
    reg phy_mdio$inout$reg = 1'b0;
    wire phy_mdio = phy_mdio$inout$reg;
    reg rgmii_0_rx_ctl = 1'b0;
    reg rgmii_0_rxc = 1'b0;
    reg [3:0] rgmii_0_rxd = 4'b0000;
    wire rgmii_0_tx_ctl;
    wire rgmii_0_txc;
    wire [3:0] rgmii_0_txd;
    reg rgmii_1_rx_ctl = 1'b0;
    reg rgmii_1_rxc = 1'b0;
    reg [3:0] rgmii_1_rxd = 4'b0000;
    wire rgmii_1_tx_ctl;
    wire rgmii_1_txc;
    wire [3:0] rgmii_1_txd;

    parameter PERIOD = 8;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 4;

    initial    // Clock process for core_clk
    begin
        #OFFSET;
        forever
        begin
            core_clk = 1'b0;gtx_clk = 1'b0;
            #(PERIOD-(PERIOD*DUTY_CYCLE)) core_clk = 1'b1; gtx_clk = 1'b1;
            #(PERIOD*DUTY_CYCLE);
        end
    end

    top UUT (
        .core_clk(core_clk),
        .nf2_reset(nf2_reset),
        .gtx_clk(gtx_clk),
        .phy_mdc(phy_mdc),
        .phy_mdio(phy_mdio),
        .rgmii_0_rx_ctl(rgmii_0_rx_ctl),
        .rgmii_0_rxc(rgmii_0_rxc),
        .rgmii_0_rxd(rgmii_0_rxd),
        .rgmii_0_tx_ctl(rgmii_0_tx_ctl),
        .rgmii_0_txc(rgmii_0_txc),
        .rgmii_0_txd(rgmii_0_txd),
        .rgmii_1_rx_ctl(rgmii_1_rx_ctl),
        .rgmii_1_rxc(rgmii_1_rxc),
        .rgmii_1_rxd(rgmii_1_rxd),
        .rgmii_1_tx_ctl(rgmii_1_tx_ctl),
        .rgmii_1_txc(rgmii_1_txc),
        .rgmii_1_txd(rgmii_1_txd));

    initial begin
        // -------------  Current Time:  100ns
	#80;
		nf2_reset = 1'b1;
	#88;
		nf2_reset = 1'b0;

		// -------------------------------------
    end

endmodule

