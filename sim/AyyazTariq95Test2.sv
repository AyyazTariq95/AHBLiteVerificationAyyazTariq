`include "AyyazTariq95Environment.sv"
program AyyazTariq95Test2(my_interface my_vif);
  Environment Env;
initial begin
    Env = new(my_vif);
    Env.Gen.rand_me = 0;
    Env.Gen.current_add = 5;
    Env.Gen.end_addr = 256;
    Env.Gen.current_data = trr.HWDATA;
    my_vif.HWRITE <=1;
    my_vif.HTRANS <=0;
    Env.run_env(Env.Gen.current_add,Env.Gen.end_addr,Env.Gen.current_data,Env.Gen.rand_me);
  end
endprogram
