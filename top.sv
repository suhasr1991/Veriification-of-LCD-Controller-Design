// A top level file for the UVM simulation
//
`timescale 1ns/10ps
import uvm_pkg::*;
`include "uvm_macros.svh"

 //Include all files
`include "lcdif.sv"
//`include "lcduvmproj.svp"
//`include "apb_rw.svh"
//`include "lcd_driver_seq_mon.sv"
//`include "lcd_sequences.sv"
`include "lcd_agent_env_config.sv"
`include "lcd_test.sv"
`include "lcd.sv"
`include "mem32x32.sv"
`include "mem128x32.sv"
`include "mem256x32.sv"
//--------------------------------------------------------
//Top level module that instantiates  just a physical AHB and LCD interfaces
//--------------------------------------------------------
module top;

   
  AHBIF    AHB_IF();
  MEMIF R();
  MEMIF S();
  RAM128IF cpal();
  RAM256IF crsr();
  LCDOUT   lcdout();

  initial begin
    AHB_IF.HSEL=0;
    //AHB_IF.HADDR=0;
    AHB_IF.HCLK=1;
    forever #10 AHB_IF.HCLK = ~ AHB_IF.HCLK;

  end
  initial begin
    #20; 
    AHB_IF.HRESET = 1;
    #10;
    AHB_IF.HRESET = 0;

    #10;
    AHB_IF.HRESET = 1;
    #10;
    AHB_IF.HRESET = 0;
  end
  default clocking CB @(posedge(AHB_IF.HCLK));


  endclocking : CB

  lcd l(AHB_IF.AHBCLKS, AHB_IF.AHBM, AHB_IF.AHBS, R.F0, S.F0,cpal.R0,crsr.R0,lcdout.O0);

  mem128x32 palmem(AHB_IF.HCLK,cpal.write,cpal.waddr,cpal.wdata,
      cpal.raddr,cpal.rdata,cpal.raddr1,cpal.rdata1);
    
  mem256x32 cursmem(AHB_IF.HCLK,crsr.write,crsr.waddr,crsr.wdata,
      crsr.raddr,crsr.rdata,crsr.raddr1,crsr.rdata1);

  mem32x32 fifoMem0(AHB_IF.HCLK,R.f0_waddr,R.f0_wdata,R.f0_write,
      R.f0_raddr,R.f0_rdata);

  mem32x32 fifoMem1(AHB_IF.HCLK,S.f0_waddr,S.f0_wdata,S.f0_write,
      S.f0_raddr,S.f0_rdata);


  initial begin
	AHB_IF.mHGRANT = 0;	
  end
    
  initial begin
    //Pass this physical interface to test top (which will further pass it down to drv/sqr/mon
    uvm_config_db#(virtual AHBIF)::set( null, "*", "AHBIF", AHB_IF);
    uvm_config_db#(virtual LCDOUT)::set( null, "uvm_test_top", "LCDOUT", lcdout);
    //Call the test - but passing run_test argument as test class name
    //Another option is to not pass any test argument and use +UVM_TEST on command line to sepecify which test to run
    run_test("lcd_test");
  end
 
initial begin
  $dumpfile("lcd_cont.vcd");
  $dumpvars(9,top);
  ##1000000000;
  $display("\n\n\n=======Ran out of clocks");
  $finish;

end

 
  
endmodule : top
