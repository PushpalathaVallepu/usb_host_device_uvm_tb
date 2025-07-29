`ifndef USB_HOST_MONITOR_SV
`define USB_HOST_MONITOR_SV

class usb_host_monitor extends uvm_monitor;
  `uvm_component_utils(usb_host_monitor)

  //-------------------------------------------------------------------
  // Ports / handles
  //-------------------------------------------------------------------
  virtual usb_intf vif;
  uvm_analysis_port #(usb_host_xfer_item) mon_ap;

  //-------------------------------------------------------------------
  function new(string name="", uvm_component parent=null);
    super.new(name,parent);
    mon_ap = new("mon_ap", this);
  endfunction

  //-------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual usb_intf)::get(this, "", "drvr_if", vif))
      `uvm_fatal(get_type_name(), "usb_rx_monitor: mon_if VIF not set!");
  endfunction

  //-------------------------------------------------------------------
  task run_phase (uvm_phase phase);
    fork
      collect_hst_tx();
      collect_hst_rx();

    join_any
  endtask
 
    task automatic collect_hst_tx();
      usb_host_xfer_item item;
      bit collecting = 0;
      forever begin
        @(vif.cb_hst);

      // Collect bytes while TxValid is high and txoe is low, sampling when TxReady = 1
        if (vif.cb_hst.TxValid_i_hst &&
              vif.cb_hst.TxReady_o_hst &&
              !vif.cb_hst.txoe_hst) begin

          if (!collecting) begin
            item       = usb_host_xfer_item::type_id::create("item", this);
            collecting = 1;
          end

          item.tx_bytes.push_back(vif.cb_hst.DataOut_i_hst);
        end

        if (collecting &&
              (!vif.cb_hst.TxValid_i_hst ||  vif.cb_hst.txoe_hst)) begin
          collecting = 0;
          if (item.tx_bytes.size() > 0)
            item.xfer_type = item.usb_decode_pid(item.tx_bytes[0]);
          `uvm_info("HOST_MON",
             $sformatf("Captured transmit packet %0d bytes : %p, xfer:%s",
                        item.tx_bytes.size(), item.tx_bytes,item.xfer_type.name()),
                          UVM_MEDIUM)

	
          mon_ap.write(item);
        end
      end

    endtask

    task automatic collect_hst_rx();


      usb_host_xfer_item item;
      forever begin
      //Wait for packet start (RxActive rising edge)
        @(posedge vif.cb_hst iff (vif.cb_hst.RxActive_o_hst == 1));

        item = usb_host_xfer_item::type_id::create("item", this);

      // Collect bytes while RxActive is high, sampling when RxValid = 1
        while (vif.cb_hst.RxActive_o_hst == 1) begin
          @(posedge vif.cb_hst);
          if (vif.cb_hst.RxValid_o_hst == 1) begin
            item.rx_bytes.push_back(vif.cb_hst.DataIn_o_hst);
          end
        end
        `uvm_info   ("HST_MON", $sformatf("Captured received packet (%p), %0d bytes", item.rx_bytes,item.rx_bytes.size()), UVM_MEDIUM);

        mon_ap.write(item);
      end

    endtask  
endclass

`endif

