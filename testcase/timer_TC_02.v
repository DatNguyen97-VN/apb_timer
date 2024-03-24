//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2021 04:10:13 PM
// Design Name: 
// Module Name: testcase write read TCR and check clock.
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

`define WAIT 7

module timer_TC_02;
  
  reg [1:0] err_flg_clk2, err_flg_clk4, err_flg_clk8, err_flg_clk16;
  reg [1:0] err_flg_TCR2, err_flg_TCR4, err_flg_TCR8, err_flg_TCR16;
  reg [7:0] cnt2, cnt4, cnt8, cnt16;
  reg       step2, step4, step8, step16;

  timer_testbench #(`WAIT) tb ();

  initial begin
        #100;
        //initial counter
            cnt2    = 8'h00;
            cnt4    = 8'h00;
            cnt8    = 8'h00;
            cnt16   = 8'h00;
            step2   = 1'b0;
            step4   = 1'b0;
            step8   = 1'b0;
            step16  = 1'b0;
        //Check PCLK/2
            tb.CPU.NORMAL_WRITE(8'h01, 8'h00);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h00, 8'h01, err_flg_TCR2);
            $display("Start check PCLK/2 \n");
            step2 = 1'b1;
            repeat (100) @(posedge tb.CPU.cpu_clk);
            $display("Start check counter at PCLK/2 in 100 PCLK clock");
            CHECK_CLOCK(cnt2, 8'h32, err_flg_clk2);
        //Check PCLK/4
            tb.CPU.NORMAL_WRITE(8'h01, 8'h01);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h01, 8'h01, err_flg_TCR4);
            $display("Start check PCLK/4 in 100 PCLK clock\n");
            step4 = 1'b1;
            repeat (100) @(posedge tb.CPU.cpu_clk);
            CHECK_CLOCK(cnt4, 8'h19, err_flg_clk4);
        //Check PCLK/8
            tb.CPU.NORMAL_WRITE(8'h01, 8'h02);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h02, 8'h01, err_flg_TCR8);
            $display("Start check PCLK/8 in 104 PCLK clock\n");
            repeat (104) begin
               @(posedge tb.CPU.cpu_clk);
               step8 = 1'b1;
            end
            step8 = 1'b0;
            CHECK_CLOCK(cnt8, 8'h0D, err_flg_clk8);
        //Check PCLK/16
            tb.CPU.NORMAL_WRITE(8'h01, 8'h03);  
            tb.CPU.READ(8'h01); 
            tb.CPU.CHECK_READ(8'h03, 8'h01, err_flg_TCR16);
            $display("Start check PCLK/16 in 112 PCLK clock\n");
            repeat (112) begin
               @(posedge tb.CPU.cpu_clk);
               step16 = 1'b1;
            end
            CHECK_CLOCK(cnt16, 8'h07, err_flg_clk16);
        //Check pass/fail
        tb.CPU.CHECK_BY_PASS(err_flg_clk2 | err_flg_clk4 | err_flg_clk8 | err_flg_clk16 |
                             err_flg_TCR2 | err_flg_TCR4 | err_flg_TCR8 | err_flg_TCR16 );
        #10 $finish;   
    end
  
  initial begin
       tb.CPU.cpu_psel    = 1'b0;
       tb.CPU.cpu_penable = 1'b0;
       tb.CPU.cpu_pwrite  = 1'b0;
  end
    
  //Count with PCLK/2
  always @(posedge tb.DUT.clk_div) begin
    cnt2 = cnt2 + step2;
  end
  //Count with PCLK/4
  always @(posedge tb.DUT.clk_div) begin
    cnt4 = cnt4 + step4;
  end 
  //Count with PCLK/8
  always @(posedge tb.DUT.clk_div) begin
    cnt8 = cnt8 + step8;
  end 
  //Count with PCLK/16
  always @(posedge tb.DUT.clk_div) begin
    cnt16 = cnt16 + step16;
  end
  //Check mod clock.  
  task CHECK_CLOCK;
         input  [7:0] data , CNT;
         output [1:0] err_flg;

         begin
         if (data == CNT) begin
           $display ("Data = %h, Expected = %h\n", data, CNT);
           $display ("##################################################################");
           $display ("##################################################################");
           $display ("############################ PADSSED #############################");
           $display ("##################################################################");
           $display ("##################################################################\n");
           err_flg = 2'b01;
         end else begin
           $display ("Data = %h, Expected = %h\n", data, CNT);
           $display ("##################################################################");
           $display ("##################################################################");
           $display ("########################### FAILED ###############################");
           $display ("##################################################################");
           $display ("##################################################################\n");
           err_flg = 2'b10;
         end
        $display("Check data finished\n");
         end
    endtask
endmodule