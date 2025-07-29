
`ifndef USB_HST_SEQUENCER_SV
  `define USB_HST_SEQUENCER_SV
  
  class usb_hst_sequencer extends uvm_sequencer#(usb_host_xfer_item);
    `uvm_component_utils(usb_hst_sequencer)

    function new(string name="", uvm_component parent);
      super.new(name,parent);
    endfunction

  endclass
`endif
