`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "life.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a
);
    logic done;
    logic [1:0] color_sel= 2'd0;
    logic [511:0] data_in_mux, data_out_mux;

    logic [511:0] red_init;
    logic [511:0] green_init;
    logic [511:0] blue_init;

    logic [511:0] red_old = 512'd0;
    logic [511:0] green_old = 512'd0;
    logic [511:0] blue_old = 512'd0;

    logic [511:0] red_new;
    logic [511:0] green_new;
    logic [511:0] blue_new;

    logic [5:0] pixel;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;


    // Instance sample memory for red channel
    memory #(
        .INIT_FILE      ("spiral/red.txt")
    ) u1 (
        .read_data      (red_init)
    );

    // Instance sample memory for green channel
    memory #(
        .INIT_FILE      ("spiral/green.txt")
    ) u2 (
        .read_data      (green_init)
    );

    // Instance sample memory for blue channel
    memory #(
        .INIT_FILE      ("spiral/blue.txt")
    ) u3 (
        .read_data      (blue_init)
    );

    // Instance the WS2812B output driver
    ws2812b u4 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel)
    );

    life life_engine (
        .data_in(data_in_mux),
        .data_out(data_out_mux),
    );
    
    always_comb begin
        case (color_sel)
            2'd0: data_in_mux = red_old;
            2'd1: data_in_mux = green_old;
            2'd2: data_in_mux = blue_old;
            default: data_in_mux = 512'd0;
        endcase
    end

logic initialized = 0;

always_ff @(posedge clk) begin
    if (!initialized) begin
        red_old   <= red_init;
        green_old <= green_init;
        blue_old  <= blue_init;
        initialized <= 1;
    end else if (load_sreg && pixel == 0) begin

        case (color_sel)
            2'd0: red_old   <= data_out_mux;
            2'd1: green_old <= data_out_mux;
            2'd2: blue_old  <= data_out_mux;
        endcase

        color_sel <= (color_sel == 2'd2) ? 2'd0 : (color_sel + 2'd1);
    end
end

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            unique case ({ SW, BOOT })
                2'b00:
                    shift_reg <= { green_old[pixel*8 +: 8], 16'd0 };
                2'b01:
                    shift_reg <= { 8'd0, red_old[pixel*8 +: 8], 8'd0 };
                2'b10:
                    shift_reg <= { 16'd0, blue_old[pixel*8 +: 8] };
                2'b11:
                    shift_reg <= { green_old[pixel*8 +: 8], red_old[pixel*8 +: 8], blue_old[pixel*8 +: 8] };
            endcase
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
