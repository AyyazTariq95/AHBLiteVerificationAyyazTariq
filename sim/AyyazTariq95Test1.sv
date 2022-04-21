//reset testing
`include "AyyazTariq95Environment.sv"
program AyyazTariq95Test1(my_interface my_vif);
  Environment Env;
  initial begin
    Env = new(my_vif);
    Env.Driv.rest;
    Env.Gen.end_addr = 256;
    Env.Gen.current_add = 4;
    Env.Gen.current_data = 44;
    Env.Gen.rand_me= 1;
    my_vif.HWRITE <= 1;
    my_vif.HTRANS <= 0;
    Env.run_env(Env.Gen.current_add,Env.Gen.end_addr,Env.Gen.current_data,Env.Gen.rand_me);
  end
endprogram
