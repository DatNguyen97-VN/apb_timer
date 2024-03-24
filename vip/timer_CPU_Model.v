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

module timer_CPU_Model #(
    parameter WAIT = 0
)(
    input            cpu_clk, cpu_reset, cpu_pready, cpu_pslverr,
    input      [7:0] cpu_prdata,
    output reg       cpu_psel, cpu_penable, cpu_pwrite,
    output reg [7:0] cpu_paddr, cpu_pwdata
);
    //read data from register
    task READ;
       input [7:0] address;

       begin
         @(posedge cpu_clk);
         #1;
         cpu_psel = 1'b1;
         cpu_pwrite = 1'b0;
         cpu_paddr = address;
         $display ("Start read at address = %h", address, "\n");
         @(posedge cpu_clk);
         #1;
         cpu_penable = 1'b1;
         //If enable wait state
         repeat (WAIT) @(posedge cpu_clk);
         //turn off control signal
         @(posedge cpu_clk);
         #1;
         cpu_psel = 1'b0;
         cpu_pwrite = 1'b0;
         cpu_penable = 1'b0;
         cpu_paddr = 8'b0;
         @(posedge cpu_clk);
         #1;  
         $display ("Read transfer finished ", "\n");
       end
    endtask
    
    // Write data to register
    task NORMAL_WRITE;
       input [7:0] address, data;

       begin
         @(posedge cpu_clk);
         #1;
         cpu_psel = 1'b1;
         cpu_pwrite = 1'b1;
         cpu_paddr = address;
         cpu_pwdata = data;
         $display ("Start write to address = %h, data = %h\n", address, data);
         @(posedge cpu_clk);
         #1;
         cpu_penable = 1'b1;
         //If enable wait state
         repeat (WAIT) @(posedge cpu_clk);   
         //turn off control signal
         @(posedge cpu_clk);
         #1;
         cpu_penable = 1'b0;
         cpu_psel = 1'b0;
         cpu_pwrite = 1'b0;
         cpu_paddr = 8'b0;
         cpu_pwdata = 8'b0;
         @(posedge cpu_clk);
         #1;  
         $display ("Write transfer finished\n");
       end
    endtask
    
    //check register
    task CHECK_READ;
        input [7:0]  data, address;
        output [1:0] err_flg;
        
        if (data == cpu_prdata) begin
          $display ("##################################################################");
          $display ("############################ DATA: %h ############################", cpu_prdata);
          $display ("##################################################################");
          $display ("############################ PADSSED  ############################");
          $display ("##################################################################\n");
          err_flg[0] = 1'b1;
        end else if((data != cpu_prdata) && (address > 8'h07)) begin
          $display ("##################################################################");
          $display ("######################## DATA: %h, EXPECTED: %h ##################", cpu_prdata, data);
          $display ("##################################################################");
          $display ("############################ FAILED ##############################");
          $display ("##################################################################\n");
          err_flg[0] = 1'b1;
        end else begin
          $display ("##################################################################");
          $display ("##################################################################");
          $display ("######################## DATA: %h, EXPECTED: %h ##################", cpu_prdata, data);
          $display ("########################## FAILED READ ###########################");
          $display ("##################################################################");
          $display ("##################################################################\n");
          err_flg[1] = 1'b1;
        end
    endtask

    task CHECK;
        input  [7:0] data;
        input  [7:0] out;
        output [1:0] err_flg;
        
        if (data == out) begin
          $display ("##################################################################");
          $display ("##################################################################");
          $display ("############################ PADSSED #############################");
          $display ("##################################################################");
          $display ("##################################################################\n");
          err_flg[0] = 1'b1;
        end else begin
          $display ("##################################################################");
          $display ("##################################################################");
          $display ("############################ FAILED  #############################");
          $display ("##################################################################");
          $display ("##################################################################\n");
          err_flg[1] = 1'b1;
        end
    endtask

    task CHECK_WRITE;
        input  [7:0] address, data;
        input  [7:0] A, B, C, D, E, F, G, H;
        output [1:0] err_flg;

        case (address)
          8'h0 : CHECK(data, A, err_flg);
          8'h1 : CHECK(data, B, err_flg);
          8'h2 : CHECK(data, C, err_flg);
          8'h3 : CHECK(data, D, err_flg);
          8'h4 : CHECK(data, E, err_flg);
          8'h5 : CHECK(data, F, err_flg);
          8'h6 : CHECK(data, G, err_flg);
          8'h7 : CHECK(data, H, err_flg);
          default: begin
                 $display ("##################################################################");
                 $display ("##################################################################");
                 $display ("######################### ERROR ADDRESS ##########################");
                 $display ("##################################################################");
                 $display ("##################################################################\n");
          end
        endcase
    endtask
    
    // Check TCNT
    task CHECK_CNT;
         input  [7:0] data_TDR, CNT;
         output [1:0] err_flg;

         begin
            $display("Start check data between TDR register and initial vaue of CNT\n");
         if (data_TDR == CNT) begin
           $display ("Data = %h, Expected = %h\n", data_TDR, CNT);
           $display ("##################################################################");
           $display ("##################################################################");
           $display ("############################ PADSSED #############################");
           $display ("##################################################################");
           $display ("##################################################################\n");
           err_flg = 2'b01;
         end else begin
           $display ("Data = %h, Expected = %h\n", data_TDR, CNT);
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

    // Check pass/fail
    task CHECK_BY_PASS;
        input [1:0] err_flg;
        begin
          if (err_flg[1]) begin
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~ TEST FAIL  ~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #####     ##     #####  #      ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #        #  #      #    #      ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #       #    #     #    #      ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #####   ######     #    #      ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #       #    #     #    #      ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~ #       #    #   #####  ###### ~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        end else if (err_flg[0]) begin
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TEST PASS  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("                 PPPPPPPPPPPPPPPPP        AAA                 SSSSSSSSSSSSSSS    SSSSSSSSSSSSSSS                 ");
          $display("                 P::::::::::::::::P      A:::A              SS:::::::::::::::S SS:::::::::::::::S                ");
          $display("                 P::::::PPPPPP:::::P    A:::::A            S:::::SSSSSS::::::SS:::::SSSSSS::::::S                ");
          $display("                 PP:::::P     P:::::P  A:::::::A           S:::::S     SSSSSSSS:::::S     SSSSSSS                ");
          $display("                   P::::P     P:::::P A:::::::::A          S:::::S            S:::::S                    ");
          $display("                   P::::P     P:::::PA:::::A:::::A         S:::::S            S:::::S                 ");
          $display("                   P:::::::::::::PPA:::::A   A:::::A         SS::::::SSSSS      SS::::::SSSSS                 ");
          $display("                   P::::PPPPPPPPP A:::::A     A:::::A          SSS::::::::SS      SSS::::::::SS                 ");
          $display("                   P::::P        A:::::AAAAAAAAA:::::A            SSSSSS::::S        SSSSSS::::S                ");
          $display("                   P::::P       A:::::::::::::::::::::A                S:::::S            S:::::S                ");
          $display("                   P::::P      A:::::AAAAAAAAAAAAA:::::A               S:::::S            S:::::S                ");
          $display("                 PP::::::PP   A:::::A             A:::::A  SSSSSSS     S:::::SSSSSSSS     S:::::S                ");
          $display("                 P::::::::P  A:::::A               A:::::A S::::::SSSSSS:::::SS::::::SSSSSS:::::S                ");
          $display("                 P::::::::P A:::::A                 A:::::AS:::::::::::::::SS S:::::::::::::::SS                 ");
          $display("                 PPPPPPPPPPAAAAAAA                   AAAAAAASSSSSSSSSSSSSSS    SSSSSSSSSSSSSSS                ");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
        end
        end
    endtask
endmodule
    
