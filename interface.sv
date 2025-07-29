interface usb_intf (input clk);
  logic rst;
//--------host signals-----------
  logic		phy_tx_mode_hst;
  logic		usb_rst_hst;
  logic		txdp_hst, txdn_hst, txoe_hst;
  logic		rxd_hst, rxdp_hst, rxdn_hst;
  logic	   [7:0]DataOut_i_hst;
  logic		TxValid_i_hst;
  logic		TxReady_o_hst;
  logic	   [7:0]DataIn_o_hst;
  logic		RxValid_o_hst;
  logic		RxActive_o_hst;
  logic		RxError_o_hst;
  logic	   [1:0]LineState_o_hst;


//---------- device signals--------
  logic		phy_tx_mode_dev;
  logic		usb_rst_dev;
  logic		txdp_dev, txdn_dev, txoe_dev;
  logic		rxd_dev, rxdp_dev, rxdn_dev;
  logic	   [7:0]DataOut_i_dev;
  logic		TxValid_i_dev;
  logic		TxReady_o_dev;
  logic	   [7:0]DataIn_o_dev;
  logic		RxValid_o_dev;
  logic		RxActive_o_dev;
  logic		RxError_o_dev;
  logic	   [1:0]LineState_o_dev;


  clocking cb_hst@(posedge clk);

    output rst;

    output      phy_tx_mode_hst;
    output	rxd_hst, rxdp_hst, rxdn_hst;
    output	DataOut_i_hst;
    output	TxValid_i_hst;
    output	DataIn_o_hst;
    input	TxReady_o_hst;
    input	usb_rst_hst;
    input	txdp_hst, txdn_hst, txoe_hst;
    input	RxValid_o_hst;
    input	RxActive_o_hst;
    input	RxError_o_hst;
    input	LineState_o_hst;

  endclocking

  clocking cb_dev@(posedge clk);

    output rst;

    output	phy_tx_mode_dev;
    output	rxd_dev, rxdp_dev, rxdn_dev;
    output	DataOut_i_dev;
    output	TxValid_i_dev;
    output	DataIn_o_dev;
    input	usb_rst_dev;
    input	txdp_dev, txdn_dev, txoe_dev;
    input	TxReady_o_dev;
    input	RxValid_o_dev;
    input	RxActive_o_dev;
    input	RxError_o_dev;
    input	LineState_o_dev;

  endclocking


endinterface
