module beg_com(input clk, output reg beg);
// clk de 50 MHz, f * s = N de posedges necesario
parameter freq = 25000000;
parameter tiempo = 1; // en segundos
// se recomiendan 0.0015 para simulación | en quartus son cada segundo y medio aproximadamente
reg [$clog2(freq):0] count;

initial begin
    count <= 0;
    beg <= 0;
end
always @(posedge clk) begin
    if (count == freq * tiempo) begin
        beg = ~beg;
        count = 0;
    end else count = count +1;
end

endmodule