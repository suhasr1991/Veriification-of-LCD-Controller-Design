// 
// 
//
class flag_send;
	int flag;
	int count;	
endclass : flag_send

class lcd_seq_item extends uvm_sequence_item;

	int r, addr, data, file;
	int NUM_OF_CYCLE, GET_OP_CYCLE, TOTAL_EXP_OP;
	int MEM[*];
	int WMEM[*];
	string cmd;
	int EXP_DATA_OP[$];
	int op;
	string testname;
	int fp;
	int tot;
	int numc;
	int c; 
	int flag; 
  `uvm_object_utils_begin(lcd_seq_item)
     `uvm_field_int(r,UVM_ALL_ON)
     `uvm_field_int(addr,UVM_ALL_ON)
     `uvm_field_int(data,UVM_ALL_ON|UVM_NOCOMPARE)
     `uvm_field_int(file,UVM_ALL_ON|UVM_NOCOMPARE)
     `uvm_field_int(GET_OP_CYCLE,UVM_ALL_ON|UVM_NOCOMPARE)
     `uvm_field_int(NUM_OF_CYCLE,UVM_ALL_ON|UVM_NOCOMPARE)
     `uvm_field_int(TOTAL_EXP_OP,UVM_ALL_ON|UVM_NOCOMPARE)
     `uvm_field_string(cmd,UVM_ALL_ON|UVM_NOCOMPARE)
   `uvm_object_utils_end

  function new(string name = "lcd_seq_item");
    super.new(name);
  endfunction

    function void read_file;
    begin
      if ($test$plusargs("272test=")) begin	    
   		$value$plusargs("272test=%s",testname); 
		file = $fopen(testname,"r");	
	while (!$feof(file)) begin
		r = $fscanf(file, "%s", cmd);
		
		case(cmd)
		"m":  begin
			r = $fscanf(file, "%h %h", addr, data);
			MEM[addr] = data;
		        
	     	      end
		"w": begin
			r = $fscanf(file, "%h %h", addr, data);
		        WMEM[addr] = data;
	     	     end
	        "f": begin
			r = $fscanf(file, "%d", NUM_OF_CYCLE);
		        
	     	     end
	        "n": begin
			r = $fscanf(file, "%d", GET_OP_CYCLE);
		        
	     	     end
	        "a": begin
			r = $fscanf(file, "%d", TOTAL_EXP_OP);
		        
	     	     end
		"d": begin
			r = $fscanf(file, "%6h", data);
			EXP_DATA_OP.push_back(data);
		        
	     	     end	
		
		endcase
	end

		$fclose(file);		
		//$display("file closed");
	end
    end
    endfunction : read_file
   
endclass: lcd_seq_item

class lcd_seq extends uvm_sequence #(lcd_seq_item);

	int i;
	`uvm_object_utils(lcd_seq)

	lcd_seq_item seq_slave;

	function new(string name = "lcd_seq");
	  super.new(name);
	endfunction		

	task body;
	  begin	
	     seq_slave = lcd_seq_item::type_id::create("seq_slave");
	     
	     seq_slave.read_file(); 

	     $display("Elements in reg mempry:",seq_slave.WMEM.size());   
		
	     //$display("Elements in data memory:",seq_slave.MEM.size());   
	     if (seq_slave.WMEM.first(i)) do begin
		start_item(seq_slave);
			seq_slave.addr = i;
			//$display("address = %8h",address);
			seq_slave.data    = seq_slave.WMEM[i]; 	
			//$display("data = %8h", data);

		finish_item(seq_slave);	
		end
		while(seq_slave.WMEM.next(i));
  	  end
	endtask : body	


endclass : lcd_seq
//
//
//
class lcd_seq_master extends uvm_sequence #(lcd_seq_item);

	int i;
	`uvm_object_utils(lcd_seq_master)

	lcd_seq_item seq_master;

	function new(string name = "lcd_seq_master");
	  super.new(name);
	endfunction		

	task body;
	  begin	
	     //seq_master = lcd_seq_item::type_id::create("seq_master");
	     
	     //seq_master.read_file(); 

	     //$display("Elements in data memory:",seq_master.MEM.size());   
		
	     //if (seq_master.MEM.first(i)) do begin
		//start_item(seq_master);
			//seq_master.addr = i;
			//$display("address = %8h",address);
			//seq_master.data    = seq_master.MEM[i]; 	
			//$display("data = %8h", data);

		//finish_item(seq_master);	
//		end
//		while(seq_master.MEM.next(i));
  	  end
	endtask : body	


endclass : lcd_seq_master
