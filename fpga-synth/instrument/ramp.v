`timescale 1ns / 1ps

module foo(
    clk,
    out_a,
    out_b,
    out_c,
    out_d
    );

input clk;
output out_a;  // A0
output out_b;  // A1
output out_c;  // A2
output out_d;  // A3
wire out_a;
wire out_b;
wire out_c;
wire out_d;

reg [9:0] fast_counter;
reg [6:0] ramp_counter;
reg [4:0] dac_counter;
reg [14:0] dac_data;
reg cs_active;
wire clk_slow;
assign clk_slow = fast_counter == 0;
assign out_c = !clk;
assign out_b = ((dac_data >> (13 - dac_counter)) & 1) && (dac_counter < 14);
assign out_d = !cs_active;
assign out_a = 0;

always @(posedge clk) begin

    // the ramp is generated by counting up on each clk_slow tick
    // 7 bits => 31.25 kHz / (2**7) = 244-ish Hz, a little below middle C
    if (clk_slow) begin
        ramp_counter <= ramp_counter + 1;
    end

    // clk_slow is 32 MHz divided by 1024, or 31.25 kHz
    fast_counter <= fast_counter + 1;

    // on each clk_slow tick, send a sample to the serial 14-bit DAC
    if (clk_slow) begin
        dac_counter <= 0;
        cs_active <= 1;
    end else if (dac_counter < 16) begin
        if (dac_counter == 15) begin
            dac_data <= (ramp_counter << 6) + (1 << 12);
            cs_active <= 0;
        end
        dac_counter <= dac_counter + 1;
    end
end

endmodule
