`include "cycle.sv"
`include "pwm.sv"

// Cycle top level module

module top #(
    parameter PWM_INTERVAL = 6000       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B 
);
    localparam PWM_HOLD_HIGH_BEG = 3'b000;
    localparam PWM_HOLD_HIGH_END = 3'b001;
    localparam PWM_DEC = 3'b010;
    localparam PWM_HOLD_LOW_BEG = 3'b011;
    localparam PWM_HOLD_LOW_END = 3'b100;
    localparam PWM_INC = 3'b101;

    logic [$clog2(PWM_INTERVAL) - 1:0] red_pwm_value;
    logic red_pwm_out;

    logic [$clog2(PWM_INTERVAL) - 1:0] green_pwm_value;
    logic green_pwm_out;

    logic [$clog2(PWM_INTERVAL) - 1:0] blue_pwm_value;
    logic blue_pwm_out;

    cycle #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .START_STATE (PWM_HOLD_HIGH_END)
    ) cycle_red (
        .clk            (clk), 
        .pwm_value      (red_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_red (
        .clk            (clk), 
        .pwm_value      (red_pwm_value), 
        .pwm_out        (red_pwm_out)
    );

        cycle #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .START_STATE (PWM_INC)
        ) cycle_green (
        .clk            (clk), 
        .pwm_value      (green_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_green (
        .clk            (clk), 
        .pwm_value      (green_pwm_value), 
        .pwm_out        (green_pwm_out)
    );

    cycle #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .START_STATE (PWM_HOLD_LOW_BEG)
    ) cycle_blue (
        .clk            (clk), 
        .pwm_value      (blue_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm_blue (
        .clk            (clk), 
        .pwm_value      (blue_pwm_value), 
        .pwm_out        (blue_pwm_out)
    );

    assign RGB_R = ~red_pwm_out;
    assign RGB_G = ~green_pwm_out;
    assign RGB_B = ~blue_pwm_out;

endmodule
