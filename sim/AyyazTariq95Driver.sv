`include "AyyazTariq95Generator.sv"
class driver;
  int NT;
  virtual my_interface.driver myin_dut;
  mailbox gene_to_driv;

  function new(virtual my_interface.driver myin_dut,mailbox gene_to_driv);
     begin
       this.myin_dut = myin_dut;
       this.gene_to_driv = gene_to_driv;
     end
  endfunction 
  
  task rest; // reset
    wait(myin_dut.HRESETn)
      begin
      $display("Reset state is high");
      myin_dut.HADDR <= 0; 
      myin_dut.HSIZE <= 0;                   
      myin_dut.HREADY <= 1;
      end
   wait(myin_dut.HRESETn)
      $display("Reset state is low");
  endtask


  task write_driver; // write operation
     begin
        Transaction transac;
        gene_to_driv.get(transac);
        @(posedge myin_dut.HCLK);
       myin_dut.HREADY <= 1'b1;
        myin_dut.HADDR <= transac.HADDR;
        myin_dut.HWRITE <= 1'b1;
        @(posedge myin_dut.HCLK);
        myin_dut.HWRITE <= transac.HWRITE;
        myin_dut.HWDATA <= transac.HWDATA;
        $displayh("\tADDR = %0h \tWDATA = %0h",transac.HADDR,transac.HWDATA);
        @(posedge myin_dut.HCLK);
      end
    endtask : write_driver
   
   task read_driver; // read operation
     begin 
        Transaction transac; 
	gene_to_driv.get(transac);
	@(posedge myin_dut.HCLK);
        myin_dut.HREADY <= 1'b1;
        myin_dut.HADDR <= transac.HADDR;
        myin_dut.HWRITE <= 1'b0;
        @(posedge myin_dut.HCLK)
        myin_dut.HWRITE <= transac.HWRITE;
        @(posedge myin_dut.HCLK);
        transac.HRDATA = myin_dut.HWDATA;
        $displayh("\tADDR = %0h \tRDATA = %0h",transac.HADDR,transac.HRDATA);
	@(posedge myin_dut.HCLK);
        end
  endtask : read_driver 

task run_driv;
      Transaction transac;
       gene_to_driv.get(transac);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",NT);
      begin
        if(myin_dut.HWRITE == 1'b1)
        write_driver;
        if(myin_dut.HWRITE == 1'b0)
        read_driver;
        myin_dut.HRESP <=1'b0;
        myin_dut.HREADY <= 1'b1;
      end
      $display("-----------------------------------------");
      NT++;
  endtask
  task drive_it;
    fork
        //Thread-1: Waiting for reset
        begin
          wait(!myin_dut.HRESETn);
        end
        //Thread-2: Calling drive task
        begin
          forever
            run_driv;
        end
      join_any
      disable fork;
   endtask

endclass: driver
