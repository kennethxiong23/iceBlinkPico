// cycle


module cycle #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 167,            // Transition to next state after 167 increments / decrements, which is 0.167s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX,
    parameter START_STATE = PWM_HOLD_HIGH_END
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    localparam PWM_HOLD_HIGH_BEG = 3'b000;
    localparam PWM_HOLD_HIGH_END = 3'b001;
    localparam PWM_DEC = 3'b010;
    localparam PWM_HOLD_LOW_BEG = 3'b011;
    localparam PWM_HOLD_LOW_END = 3'b100;
    localparam PWM_INC = 3'b101;

    // Declare state variables
    logic[2:0] current_state = START_STATE;
    logic[2:0] next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 2'bxx;
        case (current_state)
            PWM_INC:
                next_state = PWM_HOLD_HIGH_BEG;
            PWM_HOLD_HIGH_BEG:
                next_state = PWM_HOLD_HIGH_END;
            PWM_HOLD_HIGH_END:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_HOLD_LOW_BEG;
            PWM_HOLD_LOW_BEG:
                next_state = PWM_HOLD_LOW_END;
            PWM_HOLD_LOW_END:
                next_state=PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_HOLD_HIGH_BEG, PWM_HOLD_HIGH_END:
                pwm_value <= PWM_INTERVAL;
            PWM_HOLD_LOW_BEG, PWM_HOLD_LOW_END:
                pwm_value <= 0;
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
