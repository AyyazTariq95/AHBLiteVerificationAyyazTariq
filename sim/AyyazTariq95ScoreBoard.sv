`include "MP2Monitor.sv"
class scoreboard;
  mailbox mon_to_scb;
  Transaction transac;
function new(mailbox mon_to_scb);
	this.mon_to_scb = mon_to_scb;
endfunction
  task run_scoreboard(input bit[31:0]ref_data);
  bit[31:0] stored_data;
      begin
	this.mon_to_scb.get(transac);
        if(transac.HWRITE == 1)
	   stored_data = this.transac.HWDATA;
        if(transac.HWRITE == 0)
        begin
	if (transac.HRDATA == ref_data)
	$display("Receipt is okay");
	else 
	$error("Receipt is Not okay"); 
         end
      end
endtask

    task run_scb;
      run_scoreboard(32'b0); 
    endtask: run_scb
endclass