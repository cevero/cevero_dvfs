module tb_cevero_dvfs;

  logic     			clk;
  logic 	    		rst_n;
  logic           error;
  logic [2:0]     set_voltage;
  logic [2:0]     def_voltage;

  cevero_dvfs dut(
      .clk_i(clk),
      .rst_ni(rst_n),
      .error_i(error),
      .set_voltage_o(set_voltage),
      .def_voltage_i(def_voltage)
  );

  assign def_voltage = 5;
// clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin

    $display("time   | error_i | set_voltage_o | error_counter |");
    $monitor(" %5t |    %h    |     %4d      |     %4d      |",
                        $time,
                        dut.error_i,
                        dut.set_voltage_o,
                        dut.error_counter
              );

    rst_n = 0;
#20
    rst_n = 1;
#30
    error = 1;
#20
    error = 0;
#60
    error = 1;
#10
    error = 0;
#60
    error = 1;
#10
    error = 0;
#60
    error = 1;
#10
    error = 0;

#20000
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    error = 1;
#10
    error = 0;
#10
    $finish;

  end
endmodule
