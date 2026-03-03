module tb_hardware_firewall();
    reg clk, reset, data_valid;
    reg [7:0] data_in;
    wire packet_drop, alarm;
    wire [7:0] data_out;

    hardware_firewall uut (
        .clk(clk), .reset(reset), .data_in(data_in),
        .data_valid(data_valid), .packet_drop(packet_drop),
        .data_out(data_out), .alarm(alarm)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_hardware_firewall);

        clk = 0; reset = 1; data_valid = 0; data_in = 8'h00;
        #10 reset = 0; // Release reset

        // Attempt 1: WRONG
        #10 data_in = 8'h11; data_valid = 1;
        #10 data_valid = 0;

        // Attempt 2: WRONG
        #10 data_in = 8'h22; data_valid = 1;
        #10 data_valid = 0;

        // Attempt 3: WRONG (Alarm should go HIGH here)
        #10 data_in = 8'h33; data_valid = 1;
        #10 data_valid = 0;

        #20;
        $display("Simulation Finished. Alarm Status: %b", alarm);
        $finish;
    end
endmodule