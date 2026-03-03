`timescale 1ns/100ps 
module bheeshm_tb;

    // Inputs
    reg clk, reset, data_valid;
    reg [7:0] secret_key_in;
    reg [7:0] sttl, rate, sload, dload; // The 4 AI features
    
    // Outputs
    wire packet_drop, alarm;

    // Instantiate the BHEESHM Core
    bheeshm_core u0_DUT(
        .clk(clk), .reset(reset),
        .secret_key_in(secret_key_in),
        .sttl(sttl), .rate(rate), .sload(sload), .dload(dload),
        .data_valid(data_valid),
        .packet_drop(packet_drop), .alarm(alarm)
    );

    // Generate a 10ns clock
    always #5 clk = ~clk;

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("bheeshm_ai_wave.vcd");
        $dumpvars(0, bheeshm_tb);

        // System Initialization
        clk = 0; reset = 1; data_valid = 0;
        secret_key_in = 8'h00; sttl = 0; rate = 0; sload = 0; dload = 0;
        #15 reset = 0; // Release reset

        $display("==================================================");
        $display("   BHEESHM NIDS: HARDWARE AI SIMULATION STARTED   ");
        $display("==================================================");

        // ---------------------------------------------------------
        // TEST 1: NORMAL TRAFFIC
        // Scenario: Drone transmitting steady telemetry/video.
        // Features: Low rate, high steady load.
        // ---------------------------------------------------------
        #10;
        $display("[TIME: %0t] Injecting Normal Traffic...", $time);
        secret_key_in = 8'hA5; // Correct Cryptographic Key
        sttl  = 8'd30;   // Normal Time-To-Live
        rate  = 8'd10;   // Normal Packets/Sec
        sload = 8'd150;  // High Source Load (Video/Data)
        dload = 8'd150;  // High Dest Load
        data_valid = 1;
        #10 data_valid = 0;
        
        #10; 
        $display(" -> Firewall Drop: %b (0=Allowed)", packet_drop);
        $display(" -> AI Alarm     : %b (0=Safe, Math Result is Negative)", alarm);
        $display("--------------------------------------------------");


        // ---------------------------------------------------------
        // TEST 2: DDOS FLOODING ATTACK (Hijacked Drone)
        // Scenario: Attacker uses a valid drone to flood the network.
        // Features: Massive packet rate, tiny actual data payload.
        // ---------------------------------------------------------
        #20;
        $display("[TIME: %0t] Injecting DDoS Attack Traffic...", $time);
        secret_key_in = 8'hA5; // Key is CORRECT (Cryptosystem is bypassed!)
        sttl  = 8'd255;  // Max TTL
        rate  = 8'd250;  // Massive Packets/Sec (Flooding)
        sload = 8'd2;    // Almost zero real data
        dload = 8'd2;    // Almost zero real data
        data_valid = 1;
        #10 data_valid = 0;

        #10;
        $display(" -> Firewall Drop: %b (0=Allowed because key is right)", packet_drop);
        $display(" -> AI Alarm     : %b (1=ATTACK DETECTED, Math Overflows Threshold!)", alarm);
        $display("==================================================");

        #20 $finish;
    end
endmodule