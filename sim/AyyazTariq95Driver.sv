class driver;
  virtual my_interface.DUT myin_dut;
  mailbox #(Transaction) gene_to_driv;

  function new(input virtual my_interface.DUT myin_dut, input mailbox gene_to_driv);
       this.myin_dut = myin_dut;
       this.gene_to_driv = gene_to_driv;
  endfunction 
  
  task rest; // reset
    if (!myin_dut.HRESETn)
      begin
      $display("Reset is ACTIVE");
      myin_dut.HADDR <= 0;                   
      myin_dut.HREADY <= 1; 
      myin_dut.HRDATA <= 0;
      myin_dut.HSIZE <= 0;
      end
    else
      $display("Reset is INACTIVE");
  endtask

  task write_send; // write operation
    while (myin_dut.HRESETn)
      forever begin
        Transaction transac;
        gene_to_driv.get(transac);  
        @(posedge myin_dut.HCLK);
        myin_dut.HREADY <= 1;
        myin_dut.HWRITE <= 1;
        myin_dut.HADDR <= transac.HADRR;
        @(posedge myin_dut.HCLK);
        myin_dut.HWDATA <= transac.HWDATA;
        $display("Data written at address %0d is %0d:",myin_dut.HADDR,myin_dut.HWDATA);
      end
  endtask

  task read_send; // read operation
    while (myin_dut.HRESETn)
      forever begin
        Transaction transac;
        gene_to_driv.get(transac); 
        @(posedge myin_dut.HCLK);
        myin_dut.HREADY <= 1;
        myin_dut.HWRITE <= 0;
        myin_dut.HADDR <= transac.HADRR;
        @(posedge myin_dut.HCLK);
        myin_dut.HRDATA <= transac.HWDATA;
	$display("Data read at address %0d is %0d:",myin_dut.HADDR,myin_dut.HRDATA);
      end
  endtask

task burst_of_reads;
case(myin_dut.HBURST)
0 : read_send;

1 :
begin 
myin_dut.HTRANS = 0b10;
read_send;
while(myin_dut.HTRANS != 0b10)
begin
read_send;
end
end

2 :
begin 
(for j = 0; j<4; j++)  read_send;
end

3:
begin 
(for j = 0; j<4; j++)  read_send;
end

4:
begin
(for j = 0; j<8; j++)  read_send;
end

5:
begin
(for j = 0; j<8; j++)  read_send;
end

6:
begin
(for j = 0; j<16; j++)  read_send;
end

7:
begin
(for j = 0; j<16; j++)  read_send;
end
endcase 

endtask burst_of_reads

 task burst_of_writes;
case(myin_dut.HBURST)
0 : write_send;

1 : 
begin
myin_dut.HTRANS = 0b10;
write_send;
while(myin_dut.HTRANS != 0b10)
begin
write_send;
end
end

2 :
begin 
(for j = 0; j<4; j++)  write_send;
end

3:
begin 
(for j = 0; j<4; j++)  write_send;
end

4:
begin
(for j = 0; j<8; j++)  write_send;
end

5:
begin
(for j = 0; j<8; j++)  write_send;
end;

6:
begin
(for j = 0; j<16; j++)  write_send;
end

7:
begin
(for j = 0; j<16; j++)  write_send;
end
endcase
endtask

    task run_driver;
      @(posedge myin_dut.HCLK);
      if (transac.HWRITE == 1);
      //write_send;
      burst_of_writes;
      $display("Something is being written");
      elseif (transac.HWRITE == 0);
      //read_send;
      burst_of_reads;
      $display("Something is being read");  
    endtask: run_driver

endclass: driver
