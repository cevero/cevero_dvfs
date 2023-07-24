module cevero_dvfs
#(
  parameter int unsigned MaxErrorRate = 3,
  parameter int unsigned TimeFrame    = 10,
  parameter int unsigned MinFreq      = 10,
  parameter int unsigned MinVoltage   = 0,
  parameter int unsigned MaxVoltage   = 5,
  parameter int unsigned OkThreshold  = 10
) (
  input   logic       clk_i,
  input   logic       rst_ni,
  input   logic       error_i,
  input   logic [2:0] def_voltage_i,
  input   logic [2:0] def_freq_i,
  output  logic [2:0] set_voltage_o,
  output  logic [2:0] set_freq_o
);

  typedef enum logic [2:0] {IDLE  = 3'b000,
                            EVAL  = 3'b001,
                            INCV  = 3'b010,
                            DECV  = 3'b011,
                            INCF  = 3'b100,
                            DECF  = 3'b101,
                            XX    = 3'bxxx} state_e;

  state_e state, next;

  logic [31:0] timer, error_counter, ok_counter;
  logic has_decf;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      state <= IDLE;
      set_voltage_o <= def_voltage_i;
      error_counter <= '0;
      ok_counter <= '0;
      timer <= '0;
      has_decf <= '0;
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
          if (error_counter < MaxErrorRate && ok_counter > OkThreshold) begin
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

        DECF: begin
          if (set_freq_o > MinFreq)
            set_freq_o = set_freq_o - 1;
          next = IDLE;
        end

        DECV : begin
          if (set_voltage_o > MinVoltage) begin
            if (!has_decf) begin
              next = DECF;
              has_decf = 1'b1;
            end else begin
              has_decf = 1'b0;
              set_voltage_o = set_voltage_o - 1;
              next = IDLE;
            end
          end else begin
            has_decf = 1'b0;
            next = INCF;
          end
        end

        INCF : begin
          if (set_freq_o < def_freq_i)
            set_freq_o = set_freq_o + 1;
          next = IDLE;
        end
        
        INCV : begin
          if (!has_decf) begin
            next = DECF;
            has_decf = 1'b1;
          end else begin
            has_decf = 1'b0;
            if (set_voltage_o < MaxVoltage)
              set_voltage_o = set_voltage_o + 1;
            next = IDLE;
          end
        end

        default: begin
          next = XX; 
        end
      endcase
      state <= next;
    end
  end


endmodule
