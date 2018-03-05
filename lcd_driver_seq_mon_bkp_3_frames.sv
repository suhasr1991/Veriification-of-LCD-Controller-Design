`include "lcd_sequences.sv"

class lcd_monitor extends uvm_monitor;

`uvm_component_utils(lcd_monitor)

uvm_analysis_port #(lcd_seq_item) out_data;
lcd_seq_item q_op;


virtual LCDOUT LCD_OUT;
virtual AHBIF AHB_IF;

function new(string name = "lcd_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    out_data = new("out_data",this);
	//q_op = new("q_op",this);
  end
endfunction : build_phase

function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual LCDOUT)::get(null, "uvm_test_top",
        "LCDOUT", this.LCD_OUT)) begin
          `uvm_error("connect", "LCDOUT not found")
      end 
      if (!uvm_config_db #(virtual AHBIF)::get(null, "uvm_test_top",
        "AHBIF", this.AHB_IF)) begin
          `uvm_error("connect", "AHBIF not found")
      end 
endfunction: connect_phase;

task run_phase(uvm_phase phase);

	  q_op = lcd_seq_item ::type_id::create("q_op");

	  q_op.read_file(); 
	  $display("Elements in output queue:  %d",q_op.EXP_DATA_OP.size()); 

 	  fork 
            forever begin
 		@(posedge(LCD_OUT.LCDDCLK));
		if (LCD_OUT.LCDENA_LCDM==1 && AHB_IF.HSEL==0) begin
		    if (q_op.EXP_DATA_OP.size() > 0) begin
		 	//$display("queue size:",q_op.EXP_DATA_OP.size());
		 	q_op.op =  q_op.EXP_DATA_OP.pop_front();
		 	q_op.numc =  q_op.NUM_OF_CYCLE;
		 	out_data.write(q_op);
		    end
	        end
	    end
	  join_none

endtask : run_phase

endclass : lcd_monitor

//
//
//
class lcd_monitor1 extends uvm_monitor;

uvm_analysis_port #(flag_send) send_flag_port;
`uvm_component_utils(lcd_monitor1)

flag_send obj_flag;

integer lcd_fp;

virtual LCDOUT LCD_OUT;

function new(string name = "lcd_monitor1", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    lcd_fp=0;
    send_flag_port = new("send_flag_port",this);
    obj_flag = new;
    obj_flag.count=0;
  end
endfunction : build_phase

function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual LCDOUT)::get(null, "uvm_test_top",
        "LCDOUT", this.LCD_OUT)) begin
          `uvm_error("connect", "LCDOUT not found")
      end 
endfunction: connect_phase;

task run_phase(uvm_phase phase);

  	  //obj_flag = flag_send::type_id::create("flag_send");
 	  //fork 
            forever begin
 		@(posedge(LCD_OUT.LCDFP));
		lcd_fp += 1;
		if(lcd_fp==1) begin
			obj_flag.flag=1;
			obj_flag.count+=1;
		end else begin
			obj_flag.flag=0;
			lcd_fp = 0;
		end		

		send_flag_port.write(obj_flag);
			
	    end
	  //join_none

endtask : run_phase

endclass : lcd_monitor1
//
//
//
class lcd_monitor2 extends uvm_monitor;

`uvm_component_utils(lcd_monitor2)

uvm_tlm_analysis_fifo #(flag_send) ae_flag;
uvm_analysis_port #(lcd_seq_item) msg_cycle_port;

lcd_seq_item lcd_seq_obj;

flag_send obj_flag_check;

integer x;

virtual AHBIF AHB_IF;

function new(string name = "lcd_monitor2", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    ae_flag = new("ae_flag",this);
    msg_cycle_port = new("msg_cycle_port",this);
    x=0;
	//q_op = new("q_op",this);
  end
endfunction : build_phase

function void connect_phase(uvm_phase phase);
      
      if (!uvm_config_db #(virtual AHBIF)::get(null, "uvm_test_top",
        "AHBIF", this.AHB_IF)) begin
          `uvm_error("connect", "AHBIF not found")
      end 
endfunction: connect_phase;

task run_phase(uvm_phase phase);

      	  ae_flag.get(obj_flag_check);   //file read
	  lcd_seq_obj = lcd_seq_item ::type_id::create("lcd_seq_obj");
	  lcd_seq_obj.read_file(); 
	  fork 
            forever begin
		@(posedge(AHB_IF.HCLK));
		lcd_seq_obj.c=lcd_seq_obj.GET_OP_CYCLE;
		//$display("obj_flag_check.flag:%d",obj_flag_check.flag);
		if (obj_flag_check.flag==1 && obj_flag_check.count<= lcd_seq_obj.c) begin
			x=x+1;	
			//$display("obj_flag_check.flag:%d",obj_flag_check.flag);
			//$display("x=%d",x);
			lcd_seq_obj.flag=1;	
		end 
		if (obj_flag_check.flag==0 && x>0) begin
			//send counted frame value(x)
			$display("count=%d",obj_flag_check.count);
			$display("count in file=%d",lcd_seq_obj.c);
			lcd_seq_obj.fp=x;
			lcd_seq_obj.numc=lcd_seq_obj.NUM_OF_CYCLE;
			lcd_seq_obj.flag=0;
			msg_cycle_port.write(lcd_seq_obj);
			x=0;
			//$display("x=%d",x);	
				
		end			
			
	    end
	  join_none

endtask : run_phase

endclass : lcd_monitor2
//
//
class lcd_out_monitor extends uvm_monitor;

`uvm_component_utils(lcd_out_monitor)

uvm_analysis_port #(lcd_seq_item) output_data;
lcd_seq_item q_output;

//string op;

virtual LCDOUT LCD_OUT;
virtual AHBIF AHB_IF;

function new(string name = "lcd_out_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    output_data = new("output_data",this);
    //q_op = new("q_op",this);
  end
endfunction : build_phase

function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual LCDOUT)::get(null, "uvm_test_top",
        "LCDOUT", this.LCD_OUT)) begin
          `uvm_error("connect", "LCDOUT not found")
      end
      if (!uvm_config_db #(virtual AHBIF)::get(null, "uvm_test_top",
        "AHBIF", this.AHB_IF)) begin
          `uvm_error("connect", "AHBIF not found")
      end 
endfunction: connect_phase;

task run_phase(uvm_phase phase);

	  q_output = lcd_seq_item ::type_id::create("q_output");

 	  fork 
            forever begin
 		@(posedge(LCD_OUT.LCDDCLK));
		if (LCD_OUT.LCDENA_LCDM==1 && AHB_IF.HSEL==0) begin
		  q_output.op = LCD_OUT.LCDVD;
		  output_data.write(q_output);
		end
	    end
	  join_none

endtask : run_phase

endclass : lcd_out_monitor
//
//
//
//
// Simple Scoreboard
//
class lcd_scoreboard extends uvm_scoreboard;

	integer c;
uvm_tlm_analysis_fifo #(lcd_seq_item) ae_inp;

uvm_tlm_analysis_fifo #(lcd_seq_item) ae_res;

lcd_seq_item req,resp;
`uvm_component_utils(lcd_scoreboard)


function new(string name = "lcd_scoreboard", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    ae_inp = new("ae_inp",this);
    ae_res = new("ae_res",this);
    c=0;
  end
endfunction : build_phase

task run_phase(uvm_phase phase);
  fork
    forever begin
      ae_inp.get(req);
      ae_res.get(resp);
      
      if(req.op != resp.op )begin
        `uvm_error("wrong data",$sformatf("in=%h,out=%h",req.op,resp.op))  
      	c = c+1;
      end else begin
	 $display("data match:%6h,%6h",req.op,resp.op);
      	c = c+1;
      end
      //$display("c=%d",c);
    end
  join_none

endtask : run_phase

function void report_phase(uvm_phase phase);
 if(ae_inp.used() > 0) begin
    `uvm_error("oops","Not all data pushed out")
  end
endfunction : report_phase

endclass : lcd_scoreboard
//
//
//
//
class lcd_scoreboard1 extends uvm_scoreboard;

uvm_tlm_analysis_fifo #(lcd_seq_item) ae_inp1;
//uvm_tlm_analysis_fifo #(lcd_seq_item) ae_res1;

lcd_seq_item msg_cycle_in,msg_cycle_out;
`uvm_component_utils(lcd_scoreboard1)

integer i;

function new(string name = "lcd_scoreboard1", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  begin
    ae_inp1 = new("ae_inp1",this);
    //ae_res1 = new("ae_res1",this);
  end
endfunction : build_phase

task run_phase(uvm_phase phase);
  //fork
    forever begin
    //
    //for (i=0;i<=2;i++) begin
      ae_inp1.get(msg_cycle_in);
      //ae_res1.get(msg_cycle_out);
     
      if (msg_cycle_in.fp==msg_cycle_in.numc) begin
	   $display("frame match"); 	
	   $display("msg_cyclein=%d",msg_cycle_in.fp); 	
	   $display("msg_cycle_out=%d",msg_cycle_in.numc); 	
      end else begin
	   `uvm_error("fp error",$sformatf("got =%d,exp=%d",msg_cycle_in.fp,msg_cycle_in.numc))  
	   //`uvm_fatal("fp error",$sformatf("got =%d,exp=%d",msg_cycle_in.fp,msg_cycle_in.numc))  
      end 


    //end

      //break; 

    end
  //join_none

endtask : run_phase

endclass : lcd_scoreboard1
//
//
//
//
//
//slave_driver
class lcd_driver extends uvm_driver #(lcd_seq_item);
	
   virtual AHBIF AHB_IF;
   `uvm_component_utils(lcd_driver)

   lcd_seq_item seq_slave;

   int count_HWRITE; 

    function new(string name = "lcd_driver", uvm_component parent = null);
       super.new(name, parent);
    endfunction

    function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual AHBIF)::get(null, "uvm_test_top",
        "AHBIF", this.AHB_IF)) begin
          `uvm_error("connect", "AHBIF not found")
      end 
    endfunction: connect_phase;

task run_phase(uvm_phase phase);
  fork
  forever
    begin
      @(posedge AHB_IF.HCLK);
      if (AHB_IF.HRESET) begin
	   AHB_IF.HADDR  <= 0;
           AHB_IF.HWRITE <= 0;
           AHB_IF.HTRANS <= 2'd0;	
      end 
      //#20;
      seq_item_port.get_next_item(seq_slave); // Gets the sequence_item
      
      @(posedge AHB_IF.HCLK); 
      AHB_IF.HRESET <= #1 0;
      AHB_IF.HSEL   <= #1 1;
      AHB_IF.HWRITE <= #1 1;
      AHB_IF.HTRANS <= #1 2'd2;
      AHB_IF.HADDR  <= #1 seq_slave.addr;
      AHB_IF.HBURST <= #1 0;
      //AHB_IF.HWDATA <= 0;
      #20;
      //AHB_IF.HWRITE <= #1 0;
      AHB_IF.HTRANS <= #1 2'd0;
      AHB_IF.HWDATA <= #1 seq_slave.data;
      
      count_HWRITE += 1;
      
      if (count_HWRITE == seq_slave.WMEM.size()) begin
	#10;
      	AHB_IF.HSEL   <= #1 0;
      end
     
      //#10;

      seq_item_port.item_done();

      //$display("count_HWRITE=",count_HWRITE);
      
    end
  join_none
endtask: run_phase

endclass: lcd_driver


//
//
//
//master_driver
class master_driver extends uvm_driver #(lcd_seq_item);
	
   virtual AHBIF AHB_IF;
   `uvm_component_utils(master_driver)

   lcd_seq_item seq_master;
   
   int master_HADDR;
    
    function new(string name = "master_driver", uvm_component parent = null);
       super.new(name, parent);
    endfunction

    function void connect_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual AHBIF)::get(null, "uvm_test_top",
        "AHBIF", this.AHB_IF)) begin
          `uvm_error("connect", "AHBIF not found")
      end 
    endfunction: connect_phase;

task run_phase(uvm_phase phase);
	
  seq_master = lcd_seq_item ::type_id::create("seq_master");

  seq_master.read_file(); 
  $display("Elements in data memory:",seq_master.MEM.size());  

  fork
   forever
    begin
      
      AHBIF.mHREADY = #1 1; 
      if (AHBIF.HRESET && AHBIF.mHGRANT==0) begin
	  AHBIF.mHRDATA = 32'h00004321;
	  master_HADDR = 0;
      end

      @(posedge AHBIF.HCLK)
      if (AHBIF.mHBUSREQ==1) begin
	  //#10; 
	  //$display("i");
	  AHBIF.mHGRANT=#1 1;
	  master_HADDR =  AHBIF.mHADDR;
	  if (AHBIF.mHGRANT==1 && (AHBIF.mHTRANS==2'b10 || AHBIF.mHTRANS== 2'b11)) begin
	  //if (AHBIF.mHGRANT==1 ) begin//&& (AHBIF.mHTRANS==10 || AHBIF.mHTRANS== 2'b11)) begin
	      AHBIF.mHRDATA = #1 seq_master.MEM[master_HADDR];  
          end 
      end 
      if (AHBIF.mHBUSREQ==0) begin        
	  AHBIF.mHGRANT=#1 0;
	  AHBIF.mHRDATA = 32'h00004321;
      end
	
      
    end
  join_none
  
endtask: run_phase

endclass: master_driver

//
//
//slave seqr
class lcd_seqr extends uvm_sequencer #(lcd_seq_item);
  `uvm_object_utils(lcd_seqr)
  
  function new(string name="lcd_seqr");
    super.new(name);
  endfunction : new

endclass : lcd_seqr
//
//
//
//master seqr
class master_seqr extends uvm_sequencer #(lcd_seq_item);
  `uvm_object_utils(master_seqr)
  
  function new(string name="master_seqr");
    super.new(name);
  endfunction : new

endclass : master_seqr
