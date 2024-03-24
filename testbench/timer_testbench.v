//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2021 09:35:37 AM
// Design Name: 
// Module Name: timer testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: check function and protocol of 8-bit timer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module timer_testbench #(
    parameter WAIT = 0
);

    wire       sys_clk, sys_reset;
    wire [7:0] cpu_paddr;
    wire       cpu_pwrite;
    wire       cpu_psel;
    wire       cpu_penable;
    wire [7:0] cpu_pwdata;
    wire [7:0] cpu_prdata;
    wire       cpu_pready, cpu_pslverr;
    
    SYSTEM_signal SYSTEM (
        .sys_clk     ( sys_clk   ),
        .sys_reset   ( sys_reset )
    );

    timer_CPU_Model #(WAIT) CPU (
        .cpu_clk     ( sys_clk     ),
        .cpu_reset   ( sys_reset   ),
        .cpu_pready  ( cpu_pready  ),
        .cpu_pslverr ( cpu_pslverr ),
        .cpu_prdata  ( cpu_prdata  ),
        .cpu_psel    ( cpu_psel    ),
        .cpu_penable ( cpu_penable ),
        .cpu_pwrite  ( cpu_pwrite  ),
        .cpu_paddr   ( cpu_paddr   ),
        .cpu_pwdata  ( cpu_pwdata  )
    );

    IP_TIMER #(WAIT) DUT (
        .PCLK        ( sys_clk     ),
        .PRESETn     ( sys_reset   ),
        .PSEL        ( cpu_psel    ),
        .PENABLE     ( cpu_penable ),
        .PWRITE      ( cpu_pwrite  ),
        .PADDR       ( cpu_paddr   ),
        .PWDATA      ( cpu_pwdata  ),
        .PRDATA      ( cpu_prdata  ),
        .PREADY      ( cpu_pready  ),
        .PSLVERR     ( cpu_pslverr )
    );

endmodule
