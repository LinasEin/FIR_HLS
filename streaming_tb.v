`timescale 1 ns / 1 ns
module streaming_tb ();

parameter integer NUM_EXPECTED_OUTPUT = 1024;
// Source drain assertion probability (0-99); Disable by setting it 0.
parameter integer SOURCE_DRAIN_PROB = 0;
// Back pressure assertion probability (0-99); Disable by setting it 0.
parameter integer BACK_PRESSURE_STALL_PROB = 0;
parameter integer TERMINATE_AFTER =
    20 * NUM_EXPECTED_OUTPUT * 100 /
    (100 - SOURCE_DRAIN_PROB - BACK_PRESSURE_STALL_PROB);

// clk.
reg clk;
initial clk = 0;
always @(clk) clk <= #10 ~clk;

// reset.
reg reset = 1;
initial begin
    @(negedge clk);
    @(negedge clk);
    reset <= 0;
end

// Streaming interface signals connecting with DUT.
// Downstream, return_val.
reg ready_TO_DUT_DS;
wire valid_FROM_DUT_DS;
wire [31:0] data_FROM_DUT_DS;
// Upstream, arguments.
wire in_ready_FROM_DUT_US;
reg in_valid_TO_DUT_US;
reg [31:0] in_data_TO_DUT_US;

// The pipeline function, 16-TAP FIR with coefficients, 0,1,2,3, ... 15.
FIRFilterStreaming_top DUT (
    .clk( clk ),
    .reset( reset ),
	.start( 1'b1 ),
	.finish(),
    // Return value.
    .output_fifo_ready_from_sink( ready_TO_DUT_DS ),
    .output_fifo_valid_to_sink( valid_FROM_DUT_DS ),
    .output_fifo_data_to_sink( data_FROM_DUT_DS ),
    // Argument.
    .input_fifo_ready_to_source( in_ready_FROM_DUT_US ),
    .input_fifo_valid_from_source( in_valid_TO_DUT_US ),
    .input_fifo_data_from_source( in_data_TO_DUT_US )
);

/* Golden input and output.
in: from 1, 2, 3, to NUM_EXPECTED_OUTPUT.
output: start with 15 zeros to fill in buffer, following with,
    1360, 1480, 1600, 1720, 1840 ... (increment by 120).
*/

reg [31:0] expected_output;
integer clk_cntr, match_cntr = 0, output_cntr = 0;

// Input valid signals (upstream) and ready (downstream).
always @ (posedge clk) begin
    if (reset) begin
        in_valid_TO_DUT_US <= 0;
        ready_TO_DUT_DS <= 0;
    end else begin
        if (in_data_TO_DUT_US == NUM_EXPECTED_OUTPUT + 1)
            in_valid_TO_DUT_US <=  0;
        else
            in_valid_TO_DUT_US <= ($urandom_range(100, 1) >= SOURCE_DRAIN_PROB);

        ready_TO_DUT_DS <= ($urandom_range(100, 1) >= BACK_PRESSURE_STALL_PROB);
    end
end

// Input data, and expected output.
always @ (posedge clk) begin
    if (reset) begin
        in_data_TO_DUT_US <= 1;
        expected_output <= 0;
    end else begin
        if (in_valid_TO_DUT_US & in_ready_FROM_DUT_US)
            in_data_TO_DUT_US <= in_data_TO_DUT_US + 1;
        if (valid_FROM_DUT_DS & ready_TO_DUT_DS) begin
            if (output_cntr < 14)
                expected_output <= 0;
            else if (output_cntr == 14)
                expected_output <= 1360;
            else
                expected_output <= expected_output + 120;
        end
    end
end

// Monitor.
always @ (posedge clk) begin
    clk_cntr <= reset ? 0 : clk_cntr + 1;
    if (valid_FROM_DUT_DS & ready_TO_DUT_DS) begin
        output_cntr <= output_cntr + 1;
        if (expected_output == data_FROM_DUT_DS) begin
            match_cntr <= match_cntr + 1;
            // $display("At cycle %d: output matches expected value, %d == %d",
            //     clk_cntr, expected_output, data_FROM_DUT_DS);
        end else begin
            $display("At cycle %d: output != expected value, %d != %d",
                clk_cntr, data_FROM_DUT_DS, expected_output);
        end
    end
    if (output_cntr == NUM_EXPECTED_OUTPUT) begin
        if (match_cntr == output_cntr)
            $display("At cycle %d: PASS", clk_cntr);
        else
            $display("FAIL: %d matches out of %d", match_cntr, output_cntr);
        $finish;
    end
    if (clk_cntr == TERMINATE_AFTER) begin
        $display("FAIL: the simulation should have finished by now, (cycle %d)",
            clk_cntr);
        $finish;
    end
end

endmodule
