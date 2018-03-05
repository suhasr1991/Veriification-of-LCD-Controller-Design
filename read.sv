module read_file();


    initial begin
	int r, addr, data, file;
	int NUM_OF_CYCLE, GET_OP_CYCLE, TOTAL_EXP_OP;
	int temp;	
	int MEM[*];
	int WMEM[*];
	string cmd;
	int EXP_DATA_OP[$];

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
		"d": begin
			r = $fscanf(file, "%6h", data);
			EXP_DATA_OP.push_back(data);
		        $display("data = %6h",data);
			$display("%d",EXP_DATA_OP.size());
	     	     end
		endcase
	end

		
	
    end

endmodule
