`ifndef VIRTUAL_SEQUENCER_SV
`define VIRTUAL_SEQUENCER_SV

class virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(virtual_sequencer)

  // Handles to both host and device sequencers
  usb_hst_sequencer host_seqr;
  usb_dev_sequencer  dev_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif

