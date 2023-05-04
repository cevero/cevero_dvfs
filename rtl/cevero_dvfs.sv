module cevero_dvfs
#(
  parameter int unsigned MaxErrorRate = 3,
  parameter int unsigned TimeFrame    = 10,
  parameter int unsigned OkThreshold  = 10
) (
  input   logic       clk_i,
  input   logic       rst_ni,
  input   logic       error_i,
  input   logic [2:0] def_voltage_i,
  output  logic [2:0] set_voltage_o
);

  typedef enum logic [1:0] {IDLE  = 2'b00,
                            EVAL  = 2'b01,
                            INCV  = 2'b10,
                            DECV  = 2'b11,
                            XX    = 2'bxx} state_e;

  state_e state, next;

  logic [31:0] timer, error_counter, ok_counter;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      state <= IDLE;
      set_voltage_o <= def_voltage_i;
      error_counter <= '0;
      ok_counter <= '0;
      timer <= '0;
    end else begin
      if (error_i) error_counter <= error_counter + 1;
      case (state)
        IDLE : begin
          timer = timer + 1;
          if (timer > TimeFrame) begin
            timer = 0; 
            next = EVAL;
          end else begin
            next = IDLE;
          end
        end
        EVAL : begin
          if (error_counter == 0 && ok_counter > OkThreshold) begin
            ok_counter = '0;
            next = DECV;
          end else if (error_counter > MaxErrorRate) begin
            ok_counter = '0;
            next = INCV;
          end else begin
            ok_counter = ok_counter + 1;
            next = IDLE;
          end
          error_counter = 0;
        end

        DECV : begin
          if (set_voltage_o > 0)
            set_voltage_o = set_voltage_o - 1;
          next = IDLE;
        end

        INCV : begin
          if (set_voltage_o < 5)
            set_voltage_o = set_voltage_o + 1;
          next = IDLE;
        end

        default: begin
          next = XX; 
        end
      endcase
      state <= next;
    end
  end


endmodule
