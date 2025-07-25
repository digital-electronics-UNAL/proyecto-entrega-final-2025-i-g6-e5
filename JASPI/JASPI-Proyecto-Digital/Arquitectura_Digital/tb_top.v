`timescale 1ns/1ps //(unidad de tiempo)/(resolución)
`include "RTC_Analisis/master.v"
`include "RTC_Analisis/top.v"
`include "RTC_Analisis/beg_com.v"
`include "RTC_Analisis/listen.v"
`include "RTC_Analisis/BCD.v"
`include "RTC_Analisis/BCDtoSSeg.v"
`include "RTC_Analisis/lcddin_mod.v"
`include "RTC_Analisis/alarm_led.v"

module tb_top ();

wire scl;
wire sda;

reg clk = 0;

always #10 clk = ~clk; // se simula un clock de 50MHz

top top(
    .clk(clk),
    .scl(scl),
    .sda(sda)
);

initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(-1,top);
    #8000000 $finish;
end

endmodule
