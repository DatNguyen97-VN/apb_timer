//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2021 03:14:20 PM
// Design Name: 
// Module Name: testcase check function enable of TCNT
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

module timer_TC_04;
  
  reg [1:0] err_flg_TCNT1, err_flg_TCNT2;
  reg [1:0] err_flg_TCR1, err_flg_TCR2;
  reg [7:0] temp;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
            // Set EN is HIGH
            tb.CPU.NORMAL_WRITE(8'h01, 8'h10);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h10, 8'h01, err_flg_TCR1);
            repeat (10) @(posedge tb.CPU.cpu_clk);
            //-----------------------------------------------------------  
            // Set EN is LOW 
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h00, 8'h01, err_flg_TCR1);
            //Check value of TCNT is greater than zero
            if (tb.DUT.CNT) begin
              $display (" Enable function of TCNT is active when EN is HIGH.\n");
              err_flg_TCNT1[0] = 1;
              temp = tb.DUT.CNT;
            end else begin
              $display (" Enable function of TCNT is not active when EN is HIGH.\n");
              err_flg_TCNT1[1] = 1;
              temp = 8'h00;
            end
            //-----------------------------------------------------------            
            repeat (10) @(posedge tb.CPU.cpu_clk);
            //Check value of TCNT is not change
            if (tb.DUT.CNT == temp) begin
              $display (" Enable function of TCNT is active when EN is LOW.\n");
              err_flg_TCNT2[0] = 1;
            end else begin
              $display (" Enable function of TCNT is not active when EN is LOW.\n");
              err_flg_TCNT2[1] = 1;
            end
            tb.CPU.CHECK_BY_PASS(err_flg_TCNT1 | err_flg_TCNT2 | err_flg_TCR1 | err_flg_TCR2);
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
endmodule

