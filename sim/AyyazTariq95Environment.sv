//`include "MP2Transaction.sv"
//`include "MP2Generator.sv"
//`include "MP2Driver.sv"
//`include "MP2Monitor.sv"
`include "MP2Scoreboard.sv"
class Environment;
bit [31:0] current_add,current_data,end_addr;
bit rand_me;
Generator Gen;
driver Driv;
mailbox gene_to_driv;
virtual my_interface my_vif;
monitor Mon;
scoreboard Scb;
mailbox mon_to_scb;
function new(input virtual my_interface my_vif);
this.my_vif = my_vif;
gene_to_driv = new();
mon_to_scb = new();
Gen = new(gene_to_driv);
Driv = new(my_vif,gene_to_driv);
Mon = new(my_vif,mon_to_scb);
Scb = new(mon_to_scb);
endfunction


  task pre_test();
    Driv.rest();
  endtask

task test(input bit [31:0]current_add,input bit [31:0]end_addr,input bit [31:0]current_data, input bit rand_me);
    fork
      Gen.run_Gen(current_add,end_addr,current_data,rand_me);
      Driv.drive_it;
      Mon.run_monitor;
      Scb.run_scb;
    join_any
  endtask

  task wrap();
    wait(Gen.transac_count == Driv.NT);
    $display ("Transactions have completed");
  endtask

  task run_env(input bit [31:0]current_add,input bit [31:0]end_addr,input bit [31:0]current_data, input bit rand_me);
    pre_test();
    test(current_add,end_addr,current_data,rand_me);
    wrap();
  endtask

  `ifdef DEBUG
  `undef DEBUG
  `endif

endclass