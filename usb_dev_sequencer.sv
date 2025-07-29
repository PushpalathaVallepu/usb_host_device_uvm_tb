
`ifndef USB_DEV_SEQUENCER_SV
  `define USB_DEV_SEQUENCER_SV

  class usb_dev_sequencer extends uvm_sequencer#(usb_dev_xfer_item); 

    `uvm_component_utils(usb_dev_sequencer)
  
    //port for receiving items from the monitor
    uvm_analysis_imp#(usb_host_xfer_item, usb_dev_sequencer) port_from_mon;

    //FIFO containing the pending items on the bus
    uvm_tlm_fifo#(usb_host_xfer_item) pending_items;

    function new (string name = "", uvm_component parent);
      super.new(name, parent);
      port_from_mon = new("port_from_mon",this);	  
      pending_items = new("pending_items", this, 1);
    endfunction
  	
    virtual function void write(usb_host_xfer_item item);
      if (item.rx_bytes.size() > 0) begin
      `uvm_info("dev_sequencer",$sformatf("Captured host packet %0d bytes : %p",
                           item.rx_bytes.size(), item.rx_bytes),UVM_MEDIUM)
        

      if(pending_items.is_full()) begin
	 `uvm_fatal("ALGORITHM_ISSUE",$sformatf("FIFO %0s is full (size:%0d) - a possible cause is that there is no sequence started which pulls info from this FIFO",pending_items.get_full_name(),pending_items.size()))     
      end
      if (pending_items.try_put(item) == 0) begin
        `uvm_fatal("ALGORITHM_ISSUE", $sformatf("failed to push new item in the FIFO %0s", pending_items.get_full_name()))
      end else begin
        `uvm_info("FIFO_PUT", $sformatf("Successfully pushed item into FIFO: %p", item.rx_bytes), UVM_LOW)
      end
      end      
    endfunction
   
  
  endclass

`endif

