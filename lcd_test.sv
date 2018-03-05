//--------------------------------------------------------
//Top level Test class that instantiates env, configures and starts stimulus
//--------------------------------------------------------
class lcd_test extends uvm_test;

  //Register with factory
  lcd_env  env;

  `uvm_component_utils_begin(lcd_test)
  	`uvm_field_object(env,UVM_ALL_ON)
  `uvm_component_utils_end 
 
  function new(string name = "lcd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  function void build_phase(uvm_phase phase);
      env = lcd_env::type_id::create("lcd_env",this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "start of test");
    env.agt.test_seq.start(env.agt.seqr);
    //#4000000;

    @(env.agt.mon.event_1.triggered);
    phase.drop_objection(this, "end of test");
  endtask: run_phase;
endclass
