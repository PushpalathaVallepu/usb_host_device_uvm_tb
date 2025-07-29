`ifndef USB_DEV_MONITOR_SV
`define USB_DEV_MONITOR_SV

class usb_dev_monitor extends uvm_monitor;
  `uvm_component_utils(usb_dev_monitor)

  //-------------------------------------------------------------------
  // Ports / handles
  //-------------------------------------------------------------------
  virtual usb_intf vif;
  uvm_analysis_port #(usb_host_xfer_item) pkt_ap;

  //-------------------------------------------------------------------
  function new(string name="usb_dev_monitor", uvm_component parent=null);
    super.new(name,parent);
    pkt_ap = new("pkt_ap", this);
  endfunction

  //-------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual usb_intf)::get(this, "", "drvr_if", vif))
      `uvm_fatal(get_type_name(), "usb_rx_monitor: mon_if VIF not set!");
  endfunction

  //-------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    fork  
      collect_dev_tx();
      collect_dev_rx();
    join_any
  endtask

  task automatic collect_dev_tx();

    usb_host_xfer_item pkt;
    bit collecting = 0;
    forever begin
      @(vif.cb_dev);

      // Collect bytes while TxValid is high and txoe is low, sampling when TxReady = 1
      if (vif.cb_dev.TxValid_i_dev &&
            vif.cb_dev.TxReady_o_dev &&
            !vif.cb_dev.txoe_dev) begin

        if (!collecting) begin
          pkt = usb_host_xfer_item::type_id::create("pkt", this);
          collecting = 1;
        end

        pkt.tx_bytes.push_back(vif.cb_dev.DataOut_i_dev);
      end

      if (collecting &&
           (!vif.cb_dev.TxValid_i_dev ||  vif.cb_dev.txoe_dev)) begin
        collecting = 0;
        `uvm_info("DEVICE_MON",
           $sformatf("Captured dev transmit packet %0d bytes : %p",
                  pkt.tx_bytes.size(), pkt.tx_bytes),UVM_MEDIUM)
        

	
        pkt_ap.write(pkt);
      end
    end

  endtask  
 
  task automatic collect_dev_rx();

    usb_host_xfer_item pkt;
    forever begin
      //Wait for packet start (RxActive rising edge)
      @(posedge vif.cb_dev iff (vif.cb_dev.RxActive_o_dev == 1));

      pkt = usb_host_xfer_item::type_id::create("pkt", this);

      //Collect bytes while RxActive is high, sampling when RxValid = 1
      while (vif.cb_dev.RxActive_o_dev == 1) begin
        @(posedge vif.cb_dev);
        if (vif.cb_dev.RxValid_o_dev == 1) begin
          pkt.rx_bytes.push_back(vif.cb_dev.DataIn_o_dev);
        end
      end
      if (pkt.rx_bytes.size() > 0)
        pkt.xfer_type = pkt.usb_decode_pid(pkt.rx_bytes[0]);
      `uvm_info   ("DEV_MON", $sformatf("Captured dev received packet (%p), %0d bytes, xfer:%s", pkt.rx_bytes,pkt.rx_bytes.size(),pkt.xfer_type.name()), UVM_MEDIUM);

      pkt_ap.write(pkt);
    end

  endtask  
endclass

`endif
