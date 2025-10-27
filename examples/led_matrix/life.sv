module life(
    input  logic [511:0] data_in,   
    output logic [511:0] data_out,
);
    // Declare everything up front
    integer i, x, y, dx, dy, nx, ny, n_idx, neighbors;
    logic alive, next_alive;

    always_comb begin
        data_out = '0;

        for (i = 0; i < 64; i = i + 1) begin
            neighbors = 0;
            x = i % 8;   
            y = i / 8;   

            for (dy = -1; dy <= 1; dy = dy + 1) begin
                for (dx = -1; dx <= 1; dx = dx + 1) begin
                    if (!(dx == 0 && dy == 0)) begin
                        nx = (x + dx + 8) % 8;
                        ny = (y + dy + 8) % 8;
                        n_idx = ny * 8 + nx;

                        if (data_in[n_idx*8 +: 8] != 8'h00)
                            neighbors = neighbors + 1;
                    end
                end
            end

            alive = (data_in[i*8 +: 8] != 8'h00);
            next_alive = alive ? (neighbors == 2 || neighbors == 3)
                               : (neighbors == 3);
            data_out[i*8 +: 8] = next_alive ? 8'hFF : 8'h00;
        end
    end
endmodule
