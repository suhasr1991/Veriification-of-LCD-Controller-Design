program read_a_file;

class read;

   	int r, addr, data, file;
	int NUM_OF_CYCLE, GET_OP_CYCLE, TOTAL_EXP_OP;
	int MEM[*];
	int WMEM[*];
	string cmd;
	int EXP_DATA_OP[$];

    function void something;
    begin	    
		file = $fopen("t0.txt","r");	
	while (!$feof(file)) begin
		r = $fscanf(file, "%s", cmd);
		$display("cmd = %s",cmd);
		
		case(cmd)
		"m":  begin
			r = $fscanf(file, "%h %h", addr, data);
			MEM[addr] = data;
		        $display("addr = %h, data = %h",addr, data);
			$display("Data at Addr=%h is %h",addr, MEM[addr]);
	     	      end
		"w": begin
			r = $fscanf(file, "%h %h", addr, data);
		        WMEM[addr] = data;
		        $display("addr = %h, data = %h",addr, data);
			$display("Data at Addr=%h is %h",addr, WMEM[addr]);

	     	     end
	        "f": begin
			r = $fscanf(file, "%d", NUM_OF_CYCLE);
		        $display("Number of cycle = %d",NUM_OF_CYCLE);
	     	     end
	        "n": begin
			r = $fscanf(file, "%d", GET_OP_CYCLE);
		        $display("cycles to get op = %d",GET_OP_CYCLE);
	     	     end
	        "a": begin
			r = $fscanf(file, "%d", TOTAL_EXP_OP);
		        $display("value of a = %d",TOTAL_EXP_OP);
	     	     end
		"q": begin
			$fclose(file);		
		        $display("file closed");
		     end
		endcase
	end
    end
    endfunction : something

		
endclass


read rdd;

initial begin
 rdd=new;

 rdd.something();

end


endprogram
