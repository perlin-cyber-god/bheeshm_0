`timescale 1ns/100ps 
module bheeshm_tb;

    // Inputs
    reg clk, reset, data_valid;
    reg [7:0] data_in;
    
    // Outputs
    wire packet_drop, alarm;

    // Instantiate the BHEESHM module
    bheeshm_core u0_DUT(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_valid(data_valid),
        .packet_drop(packet_drop),
        .alarm(alarm)
    );

    // Generate a clock signal
    always #5 clk = ~clk;

    // Initialize inputs and run tests
    initial begin
        // Dump files for GTKWave
        $dumpfile("bheeshm_wave.vcd");
        $dumpvars(0, bheeshm_tb);

        // Reset the system
        clk = 0; reset = 1; data_valid = 0; data_in = 8'h00;
        #15 reset = 0;

        // TEST 1: Friendly Drone (Correct Key: A5)
        #10 data_in = 8'hA5; data_valid = 1'b1;
        #10 data_valid = 0;

        // TEST 2: Enemy Drone (Wrong Key: 12)
        #10 data_in = 8'h12; data_valid = 1'b1;
        #10 data_valid = 0;

        // TEST 3: Hijacked Drone (Flooded Sensor: FF)
        #10 data_in = 8'hFF; data_valid = 1'b1;
        #10 data_valid = 0;

        #20 $finish;
    end
endmodule