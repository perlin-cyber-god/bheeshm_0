module hardware_firewall (
    input clk,
    input reset,
    input [7:0] data_in,
    input data_valid,
    output reg packet_drop,
    output reg [7:0] data_out,
    output reg alarm          // New: Triggers on multiple failures
);
    parameter SECRET_KEY = 8'hA5;
    reg [2:0] fail_count;     // Counter for failed attempts

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            packet_drop <= 1;
            data_out    <= 8'h00;
            fail_count  <= 0;
            alarm       <= 0;
        end else if (data_valid) begin
            if (data_in == SECRET_KEY) begin
                packet_drop <= 0;
                data_out    <= data_in;
                fail_count  <= 0; // Reset counter on success
            end else begin
                packet_drop <= 1;
                data_out    <= 8'h00;
                // Increment fail count if we aren't already alarmed
                if (fail_count < 3) fail_count <= fail_count + 1;
                if (fail_count >= 2) alarm <= 1; // Trigger alarm on 3rd fail
            end
        end
    end
endmodule