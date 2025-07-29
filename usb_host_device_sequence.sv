`ifndef USB_HOST_DEVICE_SEQUENCE_SV
`define USB_HOST_DEVICE_SEQUENCE_SV


class usb_virtual_sequence extends uvm_sequence;

  `uvm_object_utils(usb_virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)

  function new(string name = "usb_virtual_sequence");
    super.new(name);
  endfunction

  virtual task body();

    usb_host_sequence host_seq;
    usb_dev_sequence  dev_seq;

    // Create and start sequences in parallel
    fork
      begin
        host_seq = usb_host_sequence::type_id::create("host_seq");
        host_seq.start(p_sequencer.host_seqr);
      end
      begin
        dev_seq = usb_dev_sequence::type_id::create("dev_seq");
        dev_seq.start(p_sequencer.dev_seqr);
      end
    join_any
  endtask

endclass


`endif

