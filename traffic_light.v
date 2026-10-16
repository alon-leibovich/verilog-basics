//=============================================================================
// traffic_light.v  -  four-state traffic light controller with timing

// צומת עם שני כיוונים: צפון-דרום (NS) ומזרח-מערב (EW).
//
//   NS ירוק   (T_GREEN מחזורים)
//        ↓
//   NS צהוב   (T_YELLOW מחזורים)
//        ↓
//   EW ירוק   (T_GREEN מחזורים)
//        ↓
//   EW צהוב   (T_YELLOW מחזורים)
//        ↓
//   ...וחוזר חלילה

//=============================================================================

`timescale 1ns / 1ps
`default_nettype none

module traffic_light #(
    parameter T_GREEN  = 5,     // כמה מחזורים ירוק
    parameter T_YELLOW = 2      // כמה מחזורים צהוב
)(
    input  wire       clk,
    input  wire       rst,
    output reg  [2:0] ns_light, // {red, yellow, green} - one-hot
    output reg  [2:0] ew_light
);

    // --- קידוד המצבים ---
    localparam [1:0] NS_GREEN  = 2'd0,
                     NS_YELLOW = 2'd1,
                     EW_GREEN  = 2'd2,
                     EW_YELLOW = 2'd3;

    // --- קידוד הנורות: one-hot, ביט לכל צבע ---
    localparam [2:0] RED    = 3'b100,
                     YELLOW = 3'b010,
                     GREEN  = 3'b001;

    reg [1:0] state, next_state;
    reg [7:0] timer;         // כמה מחזורים אנחנו כבר במצב הנוכחי
    reg [7:0] duration;      // כמה מחזורים המצב הנוכחי אמור להימשך
    wire      timer_done;


    // ------------------------------------------------------------------

    always @(*) begin
        case (state)
            NS_GREEN, EW_GREEN: duration = T_GREEN;
            default:            duration = T_YELLOW;
        endcase
    end

    // ------------------------------------------------------------------
    assign timer_done = (timer == duration - 1'b1); 

    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state <= NS_GREEN;
            timer <= 8'd0;
        end else if (timer_done) begin
            state <= next_state;
            timer <= 8'd0;
        end else begin
            timer <= timer + 1'b1;
        end
    end


    // ------------------------------------------------------------------

    always @(*) begin
        case (state)
            NS_GREEN:  next_state = NS_YELLOW;
            NS_YELLOW: next_state = EW_GREEN;
            EW_GREEN:  next_state = EW_YELLOW;
            EW_YELLOW: next_state = NS_GREEN;
            default:   next_state = NS_GREEN;
        endcase
    end


    // ------------------------------------------------------------------
    // בלוק 3 : הפלטים  (קומבינטורי, Moore)
    //
    // הנורות נגזרות **רק** מהמצב. זו הגדרת Moore.
    // ------------------------------------------------------------------
    always @(*) begin
        case (state)
            NS_GREEN:  begin ns_light = GREEN;  ew_light = RED;    end
            NS_YELLOW: begin ns_light = YELLOW; ew_light = RED;    end
            EW_GREEN:  begin ns_light = RED;    ew_light = GREEN;  end
            EW_YELLOW: begin ns_light = RED;    ew_light = YELLOW; end
            default:   begin ns_light = RED;    ew_light = RED;    end
        endcase
    end

endmodule

`default_nettype wire
