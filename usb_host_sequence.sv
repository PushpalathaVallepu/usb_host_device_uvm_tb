`ifndef USB_HOST_SEQUENCE_SV
  `define USB_HOST_SEQUENCE_SV

  class usb_host_sequence extends uvm_sequence#(usb_host_xfer_item); 
  
    `uvm_declare_p_sequencer(usb_hst_sequencer)

    `uvm_object_utils(usb_host_sequence)

    rand usb_host_xfer_item item;

    function new(string name = "");
      super.new(name);	
    endfunction

    virtual task body();
      //`uvm_do_with(item,{token.pid[3:0] == 4'h5 ;})
      //`uvm_do_with(item,{token.pid[3:0] == 4'hD ;})
      `uvm_do_with(item,{token.pid[3:0] == 4'h9 ;})
      `uvm_do_with(item,{token.pid[3:0] == 4'h1 ;})
    endtask
  endclass
`endif
