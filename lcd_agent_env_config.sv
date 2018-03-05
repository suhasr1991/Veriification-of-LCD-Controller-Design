`include "lcd_driver_seq_mon.sv"
//---------------------------------------
// LCD Agent class
//---------------------------------------
class lcd_agent extends uvm_agent;

   //Agent will have the sequencer, driver and monitor components for the LCD interface
   lcd_seqr         seqr;
   lcd_driver       drv;
   lcd_monitor      mon;
   lcd_monitor1      mon1;
   lcd_monitor2      mon2;
   lcd_out_monitor  omon;
   lcd_seq          test_seq;
   lcd_seq_master   test_seq_master;
   master_driver    mdrv;
   master_seqr      mseqr;
   lcd_scoreboard   score;
   lcd_scoreboard1   score1;
   
  `uvm_component_utils_begin(lcd_agent)
    `uvm_field_object(seqr,UVM_ALL_ON)
    `uvm_field_object(mon,UVM_ALL_ON)
    `uvm_field_object(drv,UVM_ALL_ON)
  `uvm_component_utils_end

   function new(string name = "lcd_agent", uvm_component parent = null);
      super.new(name, parent);
   endfunction

  function void build_phase(uvm_phase phase);
   begin
    super.build_phase(phase);
    seqr = lcd_seqr::type_id::create("seqr",this);
    mseqr = master_seqr::type_id::create("master_seqr",this);
    drv = lcd_driver::type_id::create("slave_driver",this);
    mdrv = master_driver::type_id::create("master_driver",this);
    mon = lcd_monitor::type_id::create("lcd_monitor",this);
    mon1 = lcd_monitor1::type_id::create("lcd_monitor1",this);
    mon2 = lcd_monitor2::type_id::create("lcd_monitor2",this);
    omon = lcd_out_monitor::type_id::create("lcd_out_monitor",this);
    test_seq = lcd_seq::type_id::create("lcd_seq",this);
    test_seq_master = lcd_seq_master::type_id::create("lcd_seq_master",this);
    score = lcd_scoreboard::type_id::create("lcd_scoreboard",this);
    score1 = lcd_scoreboard1::type_id::create("lcd_scoreboard1",this);
   end
   endfunction: build_phase;

   //Connect - driver and sequencer port to export
   function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(seqr.seq_item_export);
      uvm_report_info("lcd_agent::", "connect_phase, connected slave driver to sequencer");
      mdrv.seq_item_port.connect(mseqr.seq_item_export);
      uvm_report_info("lcd_agent::", "connect_phase, connected master driver to sequencer");
      mon.out_data.connect(score.ae_inp.analysis_export);
      //mon.out_data.connect(score1.ae_res1.analysis_export);
      mon1.send_flag_port.connect(mon2.ae_flag.analysis_export);
      mon2.msg_cycle_port.connect(score1.ae_inp1.analysis_export);
      omon.output_data.connect(score.ae_res.analysis_export);
   endfunction

  /* 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "start of test");
    test_seq.start(seqr);
    //#4000000;

    @(mon.event_1.triggered);
    phase.drop_objection(this, "end of test");
  endtask: run_phase;
  */
endclass: lcd_agent

//----------------------------------------------
// LCD Env class
//----------------------------------------------
class lcd_env  extends uvm_env;

   //ENV class will have agent as its sub component
   lcd_agent  agt;

   `uvm_component_utils_begin(lcd_env)
      `uvm_field_object(agt,UVM_ALL_ON)  
   `uvm_component_utils_end 

   //Build phase - Construct agent 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = lcd_agent::type_id::create("agt",this); 
  endfunction: build_phase;
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction: connect_phase;
  
  function new(string name="lcd_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new;
  
endclass : lcd_env 
