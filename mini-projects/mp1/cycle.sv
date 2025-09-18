// cycle

module top(
    input logic     clk, 
    output logic    RGB_B,
    output logic    RGB_G,
    output logic    RGB_R
);

    // CLK frequency is 12MHz, so 12,000,000 cycles is 1s
    parameter CYCLE_INTERVAL = 12000000;
    parameter YELLOW_INTERVAL = 2000000;
    parameter GREEN_INTERVAL = 4000000;
    parameter CYAN_INTERVAL = 6000000;
    parameter BLUE_INTERVAL = 8000000;
    parameter MAGENTA_INTERVAL = 10000000;
    logic [$clog2(CYCLE_INTERVAL) - 1:0] count = 0;

    initial begin
        RGB_B = ~1'b0;
        RGB_R = 1'b0;
        RGB_G = ~1'b0;
    end

    always_ff @(posedge clk) begin
         if (count == YELLOW_INTERVAL - 1) begin
            count <= count + 1; //RG
            RGB_G <= ~RGB_G;
        end
        else if (count == GREEN_INTERVAL - 1) begin
            count <= count + 1; //G
            RGB_R <= ~RGB_R;
        end
        else if (count == CYAN_INTERVAL - 1) begin
            count <= count + 1; //GB
            RGB_B <= ~RGB_B;
        end
        else if (count == BLUE_INTERVAL - 1) begin
            count <= count + 1; //B
            RGB_G <= ~RGB_G;
        end
        else if (count == MAGENTA_INTERVAL - 1) begin
            count <= count + 1; //BR
            RGB_R <= ~RGB_R;
        end
        else if (count == CYCLE_INTERVAL - 1) begin
            count <= 0; //R
            RGB_B <= ~RGB_B;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule
