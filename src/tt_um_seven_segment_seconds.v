`default_nettype none

module tt_um_seven_segment_seconds #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset = ! rst_n;
    reg [7:0] led_out;

    wire flag; // indicate led shift.


    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;

    // put bottom 8 bits of second counter out on the bidirectional gpio
    assign uio_out = second_counter[7:0];

    // external clock is 10MHz, so need 24 bit counter
    reg [23:0] second_counter;

    // if external inputs are set then use that as compare count
    // otherwise use the hard coded MAX_COUNT
    wire [23:0] compare = MAX_COUNT;

    always @(posedge clk) begin
        // if reset, set counter to 0
        if (reset) begin
            second_counter <= 0;
        end else begin
            // if up to 16e6
            if (second_counter == compare) begin
                // reset
                second_counter <= 0;

            end else
                // increment counter
                second_counter <= second_counter + 1'b1;
        end
    end

    assign flag = second_counter >= MAX_COUNT - 24'd1;

    // led water
	always@(posedge clk) begin
		if(reset)
			led_out <= 8'b0000_0000;
		else if(flag)
			if(led_out == 8'b0000_0000)
				led_out <= 8'b1111_1110;
			else
				led_out <= {led_out[6:0],led_out[7]};
		else
			led_out <= led_out;
	end

	assign uo_out = led_out;

endmodule
