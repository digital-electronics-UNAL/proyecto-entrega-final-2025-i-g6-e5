module listen#(
    parameter Ndata = 59
)(
    input scl,
    input sda,
    input sda_en,

    input beg,
    output reg [0:7] Seconds,
    output reg [0:7] Minutes,
    output reg [7:0] Hours,
    output reg [7:0] Day,
    output reg [7:0] Date,
    output reg [7:0] Month,
    output reg [7:0] Year,
    output reg [2:0] Acknowledge
    );


reg [$clog2(Ndata):0] count; // Para el guardado de datos
reg [(Ndata)-1:0] data;

initial begin
    count <= 0;
    data <= 0;
    Seconds <= 0;
    Minutes <= 0;
    Hours <= 0;
    Day <= 0;
    Date <= 0;
    Month <= 0;
    Year <= 0;
    Acknowledge <= 0;
end

always @(posedge scl) begin
    if ((sda_en == 0)& (count != Ndata)) begin        
        data[count] <= sda;
        count <= count + 1;

    end else if (count == Ndata) begin
        count <= 0;
    end
    
end

function [7:0] reverse_bits8;
    input [7:0] in;
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            reverse_bits8[i] = in[7 - i];
        end
    end
endfunction

always @(negedge beg) begin
    Acknowledge[2:0] <= data[2:0];
    Seconds <= reverse_bits8(data[10:3]);
    Minutes <= reverse_bits8(data[18:11]);
    Hours <= reverse_bits8(data[26:19]);
    Day <= reverse_bits8(data[34:20]);
    Date <= reverse_bits8(data[42:35]);
    Month <= reverse_bits8(data[50:43]);
    Year <= reverse_bits8(data[58:51]);
end

endmodule