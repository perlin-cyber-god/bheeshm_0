module bheeshm_core(
    input clk,
    input reset,
    input [7:0] data_in,
    input data_valid,
    output reg packet_drop,
    output wire alarm
);
    // Secret Key for Firewall (A5 in Hex = 165)
    parameter SECRET_KEY = 8'hA5; 

    // --- 1. FIREWALL LOGIC ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            packet_drop <= 1'b1; // Block by default on reset
        end else if (data_valid) begin
            // Allow if key matches, otherwise block
            packet_drop <= (data_in == SECRET_KEY) ? 1'b0 : 1'b1;
        end
    end

    // --- 2. AI NEURON LOGIC ---
    // Equation: Output = (Weight * Input) + Bias
    wire [15:0] neuron_out;
    assign neuron_out = (data_in * 8'h02) + 16'h0005;

    // Trigger Alarm if the neuron output is dangerously high (> 400)
    assign alarm = (neuron_out > 16'd400) ? 1'b1 : 1'b0;

endmodule