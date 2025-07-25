module lcddin_mod #(
    parameter NUM_COMMANDS = 4,
    NUM_DATA_ALL = 32,
    NUM_DATA_PERLINE = 16,
    DATA_BITS = 8,
    COUNT_MAX = 30000
)(
    input clk,
    input [6:0]leds,
    input [6:0]led_index,
    input [7:0] Hours,
    input [7:0] Minutes,
    input [7:0] Seconds,
    input [DATA_BITS-1:0] din_data, 
    output reg rs,
    output reg rw,
    output enable,
    output reg [DATA_BITS-1:0] data
);

// Uso buffer, en text, por lo mismo, no hay necesidad de usar la din_dara, estoy haciendo siempre todo "dinamico"

// Definición de estados
localparam IDLE              = 3'b000;
localparam STORE_DATA        = 3'b001;
localparam CONFIG_CMD1       = 3'b010;
localparam WR_STATIC_TEXT_1L = 3'b011;
localparam CONFIG_CMD2       = 3'b100;
localparam WR_STATIC_TEXT_2L = 3'b101;


    // Conversión de BCD a ASCII - Todas inician en 0
    wire [7:0] Hours_dec  = Hours[7:4] + 8'd48;
    wire [7:0] Hours_uni  = Hours[3:0] + 8'd48;
    wire [7:0] Min_dec   = Minutes[7:4] + 8'd48;
    wire [7:0] Min_uni   = Minutes[3:0] + 8'd48;
    wire [7:0] Sec_dec   = Seconds[7:4] + 8'd48;
    wire [7:0] Sec_uni   = Seconds[3:0] + 8'd48;


    // Arreglo de 32 caracteres para cada espacio de la LCD
    reg [7:0] text [0:31];

    // Siempre que hay un flanco guarda la información en text
    always @(posedge clk) begin
        text[0] <= 8'h48;
        text[1] <= 8'h6F;
        text[2] <= 8'h72;
        text[3] <= 8'h61;
        text[4] <= 8'h20;
        text[5] <= 8'h20;
        text[6] <= Hours_dec;
        text[7] <= Hours_uni;
        text[8] <= 8'h3A;
        text[9] <= Min_dec;
        text[10] <= Min_uni;
        text[11] <= 8'h3A;
        text[12] <= Sec_dec;
        text[13] <= Sec_uni;
        text[14] <= 8'h20;
        text[15] <= 8'h20;
        
        text[16] <= 8'h20;
        text[17] <= 8'h20;
        text[18] <= 8'h20;
        text[19] <= 8'h20;
        text[20] <= 8'h20;
        text[21] <= 8'h20;
        text[22] <= 8'h20;// leds +8'd48;
        text[23] <= 8'h20;
        text[24] <= 8'h20;
        text[25] <= 8'h20;//led_index + 8'd48;
        text[26] <= 8'h20;
        text[27] <= 8'h20;
        text[28] <= 8'h20;
        text[29] <= 8'h20;
        text[30] <= 8'h20;
        text[31] <= 8'h20;
    end

// Guardo los estados
reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;

// Comandos LCD
localparam CLEAR_DISPLAY              = 8'h01;
localparam SHIFT_CURSOR_RIGHT         = 8'h06;
localparam DISPON_CURSOROFF           = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit  = 8'h38;
localparam START_2LINE                = 8'hC0;

// Contadores
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
reg [$clog2(NUM_COMMANDS):0] command_counter;
reg [$clog2(NUM_DATA_PERLINE):0] data_counter;
reg [$clog2(NUM_DATA_ALL):0] input_counter;

// Memorias internas
reg [DATA_BITS-1:0] static_data_mem [0:NUM_DATA_ALL-1];
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1];

reg [DATA_BITS-1:0] last_sw_data;

// Otro clock para guardar  - no se si se podria hacer con beg, pero mejor cree otro clock
always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

// Inicialización
initial begin
    fsm_state <= IDLE;
    rs <= 0;
    rw <= 0;
    data <= 0;
    clk_16ms <= 0;
    clk_counter <= 0;
    input_counter <= 0;

    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_mem[1] <= SHIFT_CURSOR_RIGHT;
    config_mem[2] <= DISPON_CURSOROFF;
    config_mem[3] <= CLEAR_DISPLAY;
end

// FSM: cambio de estado cada nuevo clock 
always @(posedge clk_16ms) begin
    fsm_state <= next_state;
end

// FSM: lógica de transición 
always @(*) begin
    // Creo que, decido a que estado ir para el estado actual dependiente de los cases
    case (fsm_state)
        IDLE: begin
            next_state = CONFIG_CMD1;
        end

        CONFIG_CMD1: begin
            next_state = (command_counter == NUM_COMMANDS) ? WR_STATIC_TEXT_1L : CONFIG_CMD1;
        end

        WR_STATIC_TEXT_1L: begin
            next_state = (data_counter == NUM_DATA_PERLINE) ? CONFIG_CMD2 : WR_STATIC_TEXT_1L;
        end

        CONFIG_CMD2: begin
            next_state = WR_STATIC_TEXT_2L;
        end

        WR_STATIC_TEXT_2L: begin
            next_state = (data_counter == NUM_DATA_PERLINE) ? IDLE : WR_STATIC_TEXT_2L;
        end

        default: next_state = IDLE;
    endcase
end

// FSM: lógica de salida y control - se ejecuta cada clock div
always @(posedge clk_16ms) begin
    case (fsm_state)
        IDLE: begin
            command_counter <= 0;
            data_counter <= 0;
            input_counter <= 0;
            rs <= 0;
            data <= 0;
            last_sw_data <= 0; 
        end

        CONFIG_CMD1: begin
            rs <= 0;
            rw <= 0;
            data <= config_mem[command_counter];
            command_counter <= command_counter + 1;
        end

        WR_STATIC_TEXT_1L: begin
            rs <= 1;
            rw <= 0;
            data <= text[data_counter];
            data_counter <= data_counter + 1;
        end

        CONFIG_CMD2: begin
            rs <= 0;
            rw <= 0;
            data <= START_2LINE;
            data_counter <= 0;
        end

        WR_STATIC_TEXT_2L: begin
            rs <= 1;
            rw <= 0;
            data <= text[NUM_DATA_PERLINE + data_counter];
            data_counter <= data_counter + 1;
        end
    endcase
end


assign enable = ~clk_16ms;

endmodule
