`include "MP2Driver.sv"
class monitor;
  virtual my_interface.monitor myin_mon;
  mailbox mon_to_scb;

  function new(input virtual my_interface.monitor myin_mon, input mailbox mon_to_scb);
       this.myin_mon = myin_mon;
       this.mon_to_scb = mon_to_scb;
  endfunction 

  task receive; // write operation
      forever begin
        Transaction transac;
        transac = new;
        wait(myin_mon.HREADYOUT);
        begin
        @(posedge myin_mon.HCLK);
        myin_mon.HREADY <= transac.HREADY;
        myin_mon.HWRITE <= transac.HWRITE;
        myin_mon.HADDR <= transac.HADDR;
	myin_mon.HRESP = transac.HRESP;
	myin_mon.HSIZE = transac.HSIZE;
	myin_mon.HBURST = transac.HBURST;
	myin_mon.HPROT = transac.HPROT;
	myin_mon.HSEL = transac.HSEL;
	myin_mon.HTRANS = transac.HTRANS;
        @(posedge myin_mon.HCLK);
        myin_mon.HWDATA <= transac.HWDATA;
	myin_mon.HRDATA <= transac.HRDATA;
        @(posedge myin_mon.HCLK);
	mon_to_scb.put(transac);
        end
      end
  endtask

    task run_monitor;
      receive; 
    endtask: run_monitor

endclass: monitor