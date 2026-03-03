module bheeshm_core(
    input clk,
    input reset,
    
    // The Drone's Secret ID Badge
    input [7:0] secret_key_in, 
    
    // The 4 Network Features from the AI
    input [7:0] sttl,  
    input [7:0] rate,  
    input [7:0] sload, 
    input [7:0] dload, 
    
    input data_valid,
    output reg packet_drop,
    output wire alarm
);
    // --- 1. FIREWALL LOGIC ---
    parameter SECRET_KEY = 8'hA5; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            packet_drop <= 1'b1; // Block by default
        end else if (data_valid) begin
            // Cryptographic Handshake
            packet_drop <= (secret_key_in == SECRET_KEY) ? 1'b0 : 1'b1;
        end
    end

    // --- 2. AI NEURON LOGIC (Quantized Perceptron) ---
    // We use 32-bit signed integers because the weights are large and negative
    wire signed [31:0] w1 = 15100;
    wire signed [31:0] w2 = 73498;
    wire signed [31:0] w3 = -121197;
    wire signed [31:0] w4 = -20099;
    wire signed [31:0] bias = -500100;

    // Convert the 8-bit unsigned sensor inputs into 32-bit signed numbers for math
    wire signed [31:0] in1 = $signed({24'b0, sttl});
    wire signed [31:0] in2 = $signed({24'b0, rate});
    wire signed [31:0] in3 = $signed({24'b0, sload});
    wire signed [31:0] in4 = $signed({24'b0, dload});

    // The Parallel MAC Operation: (W*X) + Bias
    wire signed [31:0] mac_out;
    assign mac_out = (w1 * in1) + (w2 * in2) + (w3 * in3) + (w4 * in4) + bias;

    // Activation Function: If the total sum is greater than 0, it's an ATTACK!
    assign alarm = (mac_out > 0) ? 1'b1 : 1'b0;

endmodule