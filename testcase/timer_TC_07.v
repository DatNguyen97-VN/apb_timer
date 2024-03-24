//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 04:27:30 PM
// Design Name: 
// Module Name: testcase check reserved bit of TCR, TSR and confirm TSR[1:0] is only set by hardware..
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define WAIT 0

module timer_TC_07;
  
  reg [1:0] err_flg_TCR, err_flg_TSR, err_flg_UDF, err_flg_OVF, err_flg_CLR;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            // Set TSR[7:0]
            tb.CPU.NORMAL_WRITE(8'h02, 8'hFF);  
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h00, 8'h02, err_flg_TSR);
            // Set full bit of TCR[6:0] for count down
            tb.CPU.NORMAL_WRITE(8'h01, 8'h7F);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h33, 8'h01, err_flg_TCR);
            repeat (50) @(posedge tb.CPU.cpu_clk);
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h02, 8'h02, err_flg_UDF);
            if (err_flg_UDF[1]) begin
              $display ("##################################################################");
              $display (" Timer counter underflow when counter 8’h00 down               #");
              $display (" to 8’hff is not active.                                       #");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################");
              $display (" Timer counter underflow when counter 8'h00 down               #");
              $display (" to 8'hff is active.                                           #");
              $display ("##################################################################\n");
            end
            // Set full bit of TCR[6:0] for count up
            tb.CPU.NORMAL_WRITE(8'h01, 8'h10);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h10, 8'h01, err_flg_TCR);
            repeat (503) @(posedge tb.CPU.cpu_clk);
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h03, 8'h02, err_flg_OVF);
            if (err_flg_OVF[1]) begin
              $display ("##################################################################");
              $display (" Timer counter overflow when counter 8'hFF up                  #");
              $display (" to 8'h00 is not active.                                       #");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################");
              $display (" Timer counter overflow when counter 8'hFF up                  #");
              $display (" to 8'h00 is active.                                           #");
              $display ("##################################################################\n");
            end
            // Clear TSR[1:0]
            tb.CPU.NORMAL_WRITE(8'h02, 8'hFF);  
            tb.CPU.READ(8'h02); 
            tb.CPU.CHECK_READ(8'h00, 8'h02, err_flg_CLR);
            if (err_flg_TCR[1] | err_flg_TSR[1] | err_flg_UDF[1] | err_flg_OVF[1] | err_flg_CLR[1]) begin
              $display ("##################################################################");
              $display ("This reserved bit of TSR[7:2], TCR[6] and TCR[3:2] is not clear#");
              $display (" by software, TSR[1] is not set by hardware.                   #");
              $display ("##################################################################\n");
            end else begin
              $display ("##################################################################");
              $display ("This reserved bit of TSR[7:2], TCR[6] and TCR[3:2] is only     #");
              $display (" clear by software, TSR[1] is only set by hardware.            #");
              $display ("##################################################################\n");
            end
            tb.CPU.CHECK_BY_PASS(err_flg_TCR | err_flg_TSR | err_flg_UDF | err_flg_OVF | err_flg_CLR);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule