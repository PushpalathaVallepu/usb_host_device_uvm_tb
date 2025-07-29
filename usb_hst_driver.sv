`ifndef USB_HOST_DRIVER_SV
  `define USB_HOST_DRIVER_SV

class usb_hst_driver extends uvm_driver #(usb_host_xfer_item);
  `uvm_component_utils(usb_hst_driver)
  virtual usb_intf vif;
  int pkt_id;

  function new(string name="", uvm_component parent); 
	  super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual usb_intf)::get(this,"","drvr_if",vif))
      `uvm_fatal(get_type_name(),"drvr_if VIF not set");
  endfunction

  // ---------------------------------------------------------------
  task run_phase(uvm_phase phase);
    reset_dut();
    forever begin
      
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(),$sformatf("usb_host_xfer_item  received=%0s",req.convert2string()),UVM_MEDIUM)
      if(req.tx_bytes.size()==0)
	req.pack_for_host();

      drive_packet(req.tx_bytes);           // TxValid stays HIGH whole pkt

      case(req.xfer_type)
        USB_SOF   : ;
        USB_OUT,
        USB_SETUP : expect_handshake_from_dev();
        USB_IN    : begin 
	              expect_data_from_dev(); 
		      send_ack_to_dev(); 
		    end
      endcase

      seq_item_port.item_done();
      `uvm_info(get_type_name(), "Item done returned, waiting for next item", UVM_LOW)
    end
  endtask

  // ---------------------------------------------------------------
  // drive entire packet with single TxValid window
  // ---------------------------------------------------------------
  task automatic drive_packet(byte unsigned bytes[$]);
    vif.cb_hst.TxValid_i_hst <= 1'b1;      // assert for full packet
    foreach (bytes[i]) begin
      int to = 1000;
      @(vif.cb_hst);                        // one extra UTMI cycle
      `uvm_info(get_type_name(),$sformatf("sending byte %0d : %0d",i,bytes[i]),UVM_DEBUG)
      vif.cb_hst.DataOut_i_hst <= bytes[i];
      // wait (vif.cb_hst.TxReady_o_hst == 1); // PHY consumed byte
      while (vif.cb_hst.TxReady_o_hst !== 1 && to--) 
        @(vif.cb_hst);
      if (to == 0) `uvm_error("DRV","Timeout waiting for TxReady_o_hst ");
      @(vif.cb_hst);                        // one extra UTMI cycle
    end
    vif.cb_hst.TxValid_i_hst <= 1'b0;      // drop → EOP generation
    wait_tx_packet_done();
  endtask

  // ---------------------------------------------------------------
  task automatic reset_dut();
    vif.cb_hst.rst <= 1;   
    vif.cb_hst.phy_tx_mode_hst <= 1;
    vif.cb_hst.TxValid_i_hst <= 0;
    repeat(2)   
    @(vif.cb_hst);
    vif.cb_hst.rst <= 0;   
    repeat(100) 
    @(vif.cb_hst);
    vif.cb_hst.rst <= 1;   
    repeat(25000)  
    @(vif.cb_hst);
  endtask

  // ---------------------------------------------------------------
  task automatic wait_tx_packet_done();
    // 1) wait for SE0 (txoe == 1)
    int to = 1000;
    while (vif.cb_hst.txoe_hst !== 1 && to--) 
      @(vif.cb_hst);
    if (to == 0) `uvm_error("DRV","Timeout waiting for SE0");

  endtask

  // ---------------------------------------------------------------
  // Receive helpers
  // ---------------------------------------------------------------
  task automatic expect_data_from_dev();
    int to = 1000;
    int pkt_id = 0;

    // Wait for RxActive to indicate start of packet
    while (!vif.cb_hst.RxActive_o_hst && to--)
      @(vif.cb_hst);
    if (to == 0) begin
      `uvm_error("DRV", "Timeout waiting for device packet start");
      return;
    end

    // Capture bytes on RxValid pulse while RxActive is still asserted
    while (vif.cb_hst.RxActive_o_hst) begin
      @(vif.cb_hst);
      if (vif.cb_hst.RxValid_o_hst) begin
        `uvm_info("HST_DRV_RX", $sformatf("byte %0d : %0d", pkt_id, vif.cb_hst.DataIn_o_hst), UVM_MEDIUM)
        pkt_id++;
      end
    end
  endtask
  

  task automatic expect_handshake_from_dev();
    int to1 = 1000;
    int to2 = 1000;
    //wait (vif.cb_hst.RxActive_o_hst == 1);
    while (vif.cb_hst.RxValid_o_hst !== 1 && to1--) 
      @(vif.cb_hst);
    if (to1 == 0) `uvm_error("DRV","Timeout waiting for RxActive_o_hst  ");
    @(vif.cb_hst);
    `uvm_info("DRV_RX", $sformatf("Handshake 0x%0h", vif.cb_hst.DataIn_o_hst), UVM_LOW)
    //wait (vif.cb_hst.RxActive_o_hst == 0);
    while (vif.cb_hst.RxValid_o_hst !== 0 && to2--) 
      @(vif.cb_hst);
    if (to2 == 0) `uvm_error("DRV","Timeout waiting for RxActive_o_hst == 0  ");

  endtask

  task automatic send_ack_to_dev();
    byte ACK_PID = 8'hD2;
    drive_packet('{ACK_PID});
  endtask

 endclass


`endif 

