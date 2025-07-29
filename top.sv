`include "uvm_macros.svh"
import uvm_pkg::*;
`include "interface.sv"
`include "base_pkt.sv"
`include "sof_pkt.sv"
`include "token_pkt.sv"
`include "data_pkt.sv"
`include "hs_pkt.sv"
`include "usb_host_xfer_item.sv"
`include "usb_dev_xfer_item.sv"
`include "usb_host_sequencer.sv"
`include "usb_dev_sequencer.sv"
`include "usb_hst_driver.sv"
`include "usb_dev_driver.sv"
`include "usb_host_monitor.sv"
`include "usb_dev_monitor.sv"
`include "usb_host_agent.sv"
`include "usb_dev_agent.sv"
`include "usb_host_sequence.sv"
`include "usb_dev_sequence.sv"
`include "virtual_sequencer.sv"
`include "usb_host_device_sequence.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

module top;

bit clk;
//clock generation

always #5ns clk = ~clk;

//instantiate interface
usb_intf intf(.clk(clk));

//instantiate DUT
usb_phy HOST(.clk(clk), .rst(intf.rst), .phy_tx_mode(intf.cb_hst.phy_tx_mode_hst), .usb_rst(intf.cb_hst.usb_rst_hst),
	
		// Transciever Interface
		.txdp(intf.cb_hst.txdp_hst), .txdn(intf.cb_hst.txdn_hst), .txoe(intf.cb_hst.txoe_hst),	
		.rxd(intf.cb_dev.txdp_dev), .rxdp(intf.cb_dev.txdp_dev), .rxdn(intf.cb_dev.txdn_dev),

		// UTMI Interface
		.DataOut_i(intf.cb_hst.DataOut_i_hst), .TxValid_i(intf.cb_hst.TxValid_i_hst), .TxReady_o(intf.cb_hst.TxReady_o_hst), .RxValid_o(intf.cb_hst.RxValid_o_hst),
		.RxActive_o(intf.cb_hst.RxActive_o_hst), .RxError_o(intf.cb_hst.RxError_o_hst), .DataIn_o(intf.cb_hst.DataIn_o_hst), .LineState_o(intf.cb_hst.LineState_o_hst)
		);

usb_phy DEVICE(.clk(clk), .rst(intf.rst), .phy_tx_mode(intf.cb_dev.phy_tx_mode_dev), .usb_rst(intf.cb_dev.usb_rst_dev),
	
		// Transciever Interface
		.txdp(intf.cb_dev.txdp_dev), .txdn(intf.cb_dev.txdn_dev), .txoe(intf.cb_dev.txoe_dev),	
		.rxd(intf.cb_hst.txdp_hst), .rxdp(intf.cb_hst.txdp_hst), .rxdn(intf.cb_hst.txdn_hst),

		// UTMI Interface
		.DataOut_i(intf.cb_dev.DataOut_i_dev), .TxValid_i(intf.cb_dev.TxValid_i_dev), .TxReady_o(intf.cb_dev.TxReady_o_dev), .RxValid_o(intf.cb_dev.RxValid_o_dev),
		.RxActive_o(intf.cb_dev.RxActive_o_dev), .RxError_o(intf.cb_dev.RxError_o_dev), .DataIn_o(intf.cb_dev.DataIn_o_dev), .LineState_o(intf.cb_dev.LineState_o_dev)
		);
		
//run_test(),uvm_config_db:set
initial begin

  uvm_config_db#(virtual usb_intf)::set(null,"*","drvr_if",intf);
	
  run_test();

end

endmodule
