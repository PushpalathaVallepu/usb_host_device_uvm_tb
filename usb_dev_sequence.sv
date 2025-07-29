
`ifndef USB_DEV_SEQUENCE_SV
  `define USB_DEV_SEQUENCE_SV
  
  class usb_dev_sequence extends uvm_sequence #(usb_dev_xfer_item);
    `uvm_object_utils(usb_dev_sequence)

    `uvm_declare_p_sequencer(usb_dev_sequencer)

    function new(string name = "usb_dev_sequence");
      super.new(name);
    endfunction
    
    task body();
      usb_host_xfer_item observed_item;
      int wait_count;
      `uvm_info(get_type_name(), "Inside device sequence", UVM_DEBUG)
      #251000ns;
      forever begin
        wait_count = 0;
        while (!p_sequencer.pending_items.try_get(observed_item)) begin
          wait_count++;
          if (wait_count > 1000) begin
            `uvm_fatal("SEQ_TIMEOUT", "Timeout waiting for item from host monitor")
          end
          #100ns;
        end
        if (observed_item.xfer_type == USB_SOF) begin
          `uvm_info(get_type_name(), "Ignoring SOF packet in device sequence", UVM_LOW)
          continue;
        end
        `uvm_info(get_type_name(), $sformatf("observed item from host: %s, %p", observed_item.xfer_type,observed_item.rx_bytes), UVM_LOW)

        req = usb_dev_xfer_item::type_id::create("req"); 
        if (req == null)
          `uvm_fatal(get_type_name(), "req is NULL before start_item!")

        start_item(req);
        `uvm_info(get_type_name(), "start_item called successfully", UVM_DEBUG)

        req.xfer_type = observed_item.xfer_type;

        case (observed_item.xfer_type)
          USB_IN: begin
	    `uvm_info("SEQ", "Inside USB_IN case", UVM_LOW)
            if (!req.randomize()) begin
              `uvm_error("SEQ", "Failed to randomize usb_dev_xfer_item")
            end
            req.pack_for_dev();
          end
          USB_OUT, USB_SETUP: begin
	    `uvm_info("SEQ", "Inside OUT/SETUP case", UVM_LOW)
	    if (!req.randomize()) begin
              `uvm_error("SEQ", "Failed to randomize usb_dev_xfer_item")
            end
            req.pack_for_dev();

          end
        endcase
        `uvm_info(get_type_name(), "Before calling finish_item", UVM_DEBUG)
        finish_item(req);
      end
    endtask

  endclass
`endif
