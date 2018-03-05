//
// This is a simple test bench for the 24xx lcd controller
// 

`timescale 1ns/10ps

`include "lcdif.sv"

package tl_pkg;

`include "uvm.sv"

import uvm_pkg::*;




`include "tbregs.svp"

`include "tbdef.svp"

`include "lcduvm.svp"


endpackage : tl_pkg



module top();

import uvm_pkg::*;
import tl_pkg::*;

AHBIF Q();
MEMIF R();
MEMIF S();
RAM128IF cpal();
RAM256IF crsr();
LCDOUT lcdout();


initial begin
Q.HCLK=1;
forever #5 Q.HCLK = ~ Q.HCLK;

end

default clocking CB @(posedge(Q.HCLK));


endclocking : CB

initial begin
  $dumpvars(9,top);
  $dumpfile("lcd.vcd");
  ##10000000;
  $display("\n\n\n============= Time Out reached ==================\n\n\n");
  $finish;
end

lcd l(Q.AHBCLKS, Q.AHBM, Q.AHBS, R.F0, S.F0,cpal.R0,crsr.R0,lcdout.O0);

mem128x32 palmem(Q.HCLK,cpal.write,cpal.waddr,cpal.wdata,
    cpal.raddr,cpal.rdata,cpal.raddr1,cpal.rdata1);
    
mem256x32 cursmem(Q.HCLK,crsr.write,crsr.waddr,crsr.wdata,
    crsr.raddr,crsr.rdata,crsr.raddr1,crsr.rdata1);

mem32x32 fifoMem0(Q.HCLK,R.f0_waddr,R.f0_wdata,R.f0_write,
    R.f0_raddr,R.f0_rdata);

mem32x32 fifoMem1(Q.HCLK,S.f0_waddr,S.f0_wdata,S.f0_write,
    S.f0_raddr,S.f0_rdata);

initial
  begin
    Q.mHGRANT=0;
  end

initial
  begin
    uvm_config_db #(virtual  AHBIF)::set(null, "uvm_test_top", 
      "ahbif"  , Q);
    uvm_config_db #(virtual LCDOUT)::set(null, "uvm_test_top", 
      "lcdout" , lcdout);
    run_test("l0_test");
    ##100;
    $finish;
  end



endmodule : top

`include "lcd.sv"
`include "mem32x32.sv"
`include "mem128x32.sv"
`include "mem256x32.sv"

