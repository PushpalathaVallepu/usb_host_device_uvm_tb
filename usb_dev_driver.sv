`ifndef USB_DEV_DRIVER_SV
  `define USB_DEV_DRIVER_SV



  class usb_dev_driver extends uvm_driver #(usb_dev_xfer_item); 

    //factory registration
    `uvm_component_utils(usb_dev_driver)

    //declare handles
    virtual usb_intf vif;
    int pkt_id;
    
    //constructor
    function new(string name="usb_dev_driver", uvm_component parent); 
      super.new(name,parent);
    endfunction

    //build_phase
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    
      if(!uvm_config_db#(virtual usb_intf)::get(this,"","drvr_if",vif))
      `uvm_fatal(get_type_name(),"drvr_if VIF not set");
    endfunction


    //run_phase
    task run_phase(uvm_phase phase);
      reset_dut();
      `uvm_info(get_type_name(), "Entered run_phase of usb_dev_driver", UVM_DEBUG)
      fork
        begin
          #40000ns;
          `uvm_fatal("TIMEOUT", "Driver did not receive item from sequence in time!")
        end
        begin
	forever begin
	  seq_item_port.get_next_item(req);

	  `uvm_info(get_type_name(),$sformatf("usb_dev_xfer_item  received=%0s",
	                                       req.convert2string()),UVM_LOW)
	  if(req.tx_bytes.size()==0) 
	    req.pack_for_dev();

	  drive_packet(req.tx_bytes);           // TxValid stays HIGH whole pkt

	  case(req.xfer_type)
	    USB_SOF   : ;
	    USB_OUT,
	    USB_SETUP : begin 
			  expect_data_from_hst(); 
			  send_ack_to_hst(); 
			end
	    USB_IN    : expect_handshake_from_hst();
	  endcase

	  seq_item_port.item_done();
	  `uvm_info(get_type_name(), "DEVICE Item done returned, waiting for next item", UVM_LOW)
	end
        end
      join_any
      disable fork;
    endtask

// ---------------------------------------------------------------
// drive entire packet with single TxValid window
// ---------------------------------------------------------------
    task automatic drive_packet (byte unsigned bytes[$]);

      vif.cb_dev.TxValid_i_dev <= 1'b1;           // keep high for whole pkt
      foreach (bytes[i]) begin
        int to;

          @(vif.cb_dev);

      //DRIVE the byte
        vif.cb_dev.DataOut_i_dev <= bytes[i];
        `uvm_info("DRV_DEV", $sformatf("TX[%0d] = %0d", i, bytes[i]), UVM_MEDIUM)

      //WAIT for TxReady to go LOW  (PHY consumed the byte)
        to = 1000;
        while (vif.cb_dev.TxReady_o_dev !== 1'b1 && to--)
          @(vif.cb_dev);
        if (to == 0)
        `uvm_error("DRV_DEV","Timeout waiting for TxReady == 0");
        @(vif.cb_dev);
      end

      vif.cb_dev.TxValid_i_dev <= 1'b0;
      wait_tx_packet_done();                      
    endtask
  

  // ---------------------------------------------------------------
    task automatic reset_dut();
      vif.cb_dev.rst <= 1;   
      vif.cb_dev.phy_tx_mode_dev <= 1;  
      vif.cb_dev.TxValid_i_dev <= 0;
      repeat(2)   
      @(vif.cb_dev);
      vif.cb_dev.rst <= 0;   
      repeat(100) 
      @(vif.cb_dev);
      vif.cb_dev.rst <= 1;   
      repeat(25000)  
      @(vif.cb_dev);
    endtask

  // ---------------------------------------------------------------
    task automatic wait_tx_packet_done();
      // 1) wait for SE0 (txoe == 1)
      int to = 1000;
      while (vif.cb_dev.txoe_dev !== 1 && to--) 
        @(vif.cb_dev);
      if (to == 0) `uvm_error("DRV_DEV","Timeout waiting for SE0");
    endtask

  // ---------------------------------------------------------------
  // Receive helpers
  // ---------------------------------------------------------------
    task automatic expect_data_from_hst();
    
      int to = 1000;
      int pkt_id = 0;

  // Wait for RxActive to indicate start of packet
      while (!vif.cb_dev.RxActive_o_dev && to--)
        @(vif.cb_dev);
      if (to == 0) begin
        `uvm_error("DRV", "Timeout waiting for host packet start");
         return;
      end

  // Capture bytes on RxValid pulse while RxActive is still asserted
      while (vif.cb_dev.RxActive_o_dev) begin
        @(vif.cb_dev);
        if (vif.cb_dev.RxValid_o_dev) begin
          `uvm_info("DEV_DRV_RX", $sformatf("byte %0d : %0d", pkt_id, vif.cb_dev.DataIn_o_dev), UVM_LOW)
          pkt_id++;
        end
     end
 
    endtask

    task automatic expect_handshake_from_hst();
      int to1 = 1000;
      int to2 = 1000;
      //wait (vif.cb_hst.RxActive_o_hst == 1);
      while (vif.cb_dev.RxValid_o_dev !== 1 && to1--) 
        @(vif.cb_dev);
      if (to1 == 0) `uvm_error("DRV","Timeout waiting for RxValid_o_dev  ");
      @(vif.cb_dev);
      `uvm_info("DEV_DRV_RX", $sformatf("Handshake 0x%0h", vif.cb_dev.DataIn_o_dev), UVM_LOW)
      //wait (vif.cb_hst.RxActive_o_hst == 0);
      while (vif.cb_dev.RxValid_o_dev !== 0 && to2--) 
        @(vif.cb_dev);
      if (to2 == 0) `uvm_error("DRV","Timeout waiting for RxValid_o_dev == 0  "); 
    endtask

    task automatic send_ack_to_hst();
      byte ACK_PID = 8'hD2;
      `uvm_info(get_type_name(), "Sending ACK to host", UVM_LOW)
      drive_packet('{ACK_PID});
    endtask

  endclass

`endif 


