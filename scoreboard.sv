`ifndef USB_SCOREBOARD_SV
  `define USB_SCOREBOARD_SV
class scoreboard #(type T = usb_host_xfer_item) extends uvm_scoreboard;
  typedef scoreboard#(T) scb_type;
  `uvm_component_param_utils(scb_type)

  `uvm_analysis_imp_decl(_host)
  `uvm_analysis_imp_decl(_device)

  uvm_analysis_imp_host #(T, scb_type) mon_host;
  uvm_analysis_imp_device #(T, scb_type) mon_dev;

  T host_tx_q[$], host_rx_q[$];
  T dev_tx_q[$], dev_rx_q[$];

  int compare_count = 0;
  int log_fd;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    log_fd = $fopen("usb_scoreboard.log", "w");
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_host = new("mon_host", this);
    mon_dev  = new("mon_dev", this);
  endfunction

  virtual function void write_host(T item);
    if (item.tx_bytes.size() > 0)
      host_tx_q.push_back(item);
    if (item.rx_bytes.size() > 0)
    begin
      host_rx_q.push_back(item);
        compare_items("DEV TX to HOST RX", dev_tx_q.pop_front(), host_rx_q.pop_front());
      end
  endfunction

  virtual function void write_device(T item);
    if (item.tx_bytes.size() > 0)
      dev_tx_q.push_back(item);
    if (item.rx_bytes.size() > 0)
    begin
      dev_rx_q.push_back(item);
        compare_items("HOST TX to DEV RX", host_tx_q.pop_front(), dev_rx_q.pop_front());
    end
  endfunction


  virtual function void compare_items(string label, T tx, T rx);
    compare_count++;
    if (tx.tx_bytes != rx.rx_bytes) begin
      `uvm_error("SCB", $sformatf(
        "[%s] MISMATCH #%0d\nTX: %p\nRX: %p\n", label, compare_count, tx.tx_bytes, rx.rx_bytes))
      $fwrite(log_fd, "[%s] MISMATCH #%0d\nTX: %p\nRX: %p\n\n", label, compare_count, tx.tx_bytes, rx.rx_bytes);
    end else begin
      `uvm_info("SCB", $sformatf("[%s] MATCH #%0d\nTX: %p\nRX: %p\n\n", label, compare_count, tx.tx_bytes, rx.rx_bytes), UVM_LOW)
      $fwrite(log_fd, "[%s] MATCH #%0d\nTX: %p\nRX: %p\n\n", label, compare_count, tx.tx_bytes, rx.rx_bytes);
    end
  endfunction

endclass

`endif  
