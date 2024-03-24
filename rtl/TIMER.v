//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dat Nguyen
// 
// Create Date: 10/20/2021 10:31:50 AM
// Design Name: 8 BIT TIMER
// Module Name: 8 BIT TIMER
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This IP CORE can be used as a 8-bit Counter/Timer with Overflow/Underflow detect ability
// 
// Dependencies: 
// 
// Revision:
//          0.1 - 20th Oct 2021
//                + Initial version.
//          0.2 - 21th Oct 2021
//                + Create top level of  IP TIMER.
//                + Modify R/W Controller connect with S_TMR_UDF, S_TMR_OVF.
//          0.3 - 22th Oct 2021
//                + Added synchronous clock of Adder block.
//                + Modify TCNT block.
//          0.4 - 24th Oct 2021
//                + Implemented processed reserved bit of TDR, TCR and TSR.
//          0.5 - 29th Oct 2021
//                + Modify bit width of select register signal for Mux and pslerr.
//          0.6 - 31th Oct 2021
//                + Implemented bit width is a parameter for IP.
//          1.0 - 31th Oct 2021
//                + Released Version.
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          █████╗       ██████╗ ██╗████████╗    ████████╗██╗███╗   ███╗███████╗██████╗     ██╗██████╗                        //
//                         ██╔══██╗      ██╔══██╗██║╚══██╔══╝    ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗    ██║██╔══██╗                       //
//                         ╚█████╔╝█████╗██████╔╝██║   ██║          ██║   ██║██╔████╔██║█████╗  ██████╔╝    ██║██████╔╝                       //
//                         ██╔══██╗╚════╝██╔══██╗██║   ██║          ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗    ██║██╔═══╝                        //
//                         ╚█████╔╝      ██████╔╝██║   ██║          ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║    ██║██║                            //
//                          ╚════╝       ╚═════╝ ╚═╝   ╚═╝          ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝╚═╝                            //                                                                                                                                                                                                     //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module IP_TIMER #(
    parameter WAIT = 0,
    parameter WIDTH = 8
)(
    input               PCLK,
    input               PRESETn,
    input               PSEL,
    input               PENABLE,
    input               PWRITE,
    input  [WIDTH-1:0]  PADDR,
    input  [WIDTH-1:0]  PWDATA,
    output [WIDTH-1:0]  PRDATA,
    output              PREADY,
    output              PSLVERR
);

   wire [WIDTH-1:0]  TDR;
   wire [WIDTH-1:0]  TCR;
   wire [WIDTH-1:0]  CNT;
   wire              S_TMR_UDF;
   wire              S_TMR_OVF;
   wire              clk_div;
   
// ══════════════════════════════════════════════════════════════════════════════════════════════                                                                                      
   // APB BUS READ/WRITE CONTROLLER
   RW_Controller #(
       WAIT,
       WIDTH
    ) CU (
    /************ INPUT ************/   
       .PCLK      ( PCLK      ),
       .PRESETn   ( PRESETn   ),
       // from user
       .PSEL      ( PSEL      ),
       .PENABLE   ( PENABLE   ),
       .PWRITE    ( PWRITE    ),
       .PADDR     ( PADDR     ),
       .PWDATA    ( PWDATA    ),
       // from SFR
       .S_TMR_UDF ( S_TMR_UDF ),
       .S_TMR_OVF ( S_TMR_OVF ),
    /*********** OUTPUT ***********/
       // to user
       .PRDATA    ( PRDATA    ),
       .PREADY    ( PREADY    ),
       .PSLVERR   ( PSLVERR   ),
       // to  generate clock div
       .TDR       ( TDR       ),
       // to TCNT and SFR
       .TCR       ( TCR       )
   );
// ══════════════════════════════════════════════════════════════════════════════════════════════
   // GENERATE MOD CLOCK FROM SYSTEM CLOCK
   Generate_clock Clock_Div (
    /******** INPUT *******/   
       .clk   ( PCLK     ),
       .rst   ( PRESETn  ),
       // from TCR
       .sel   ( TCR[1:0] ),
    /******** OUTPUT *******/   
       // to TCNT
       .clk_o ( clk_div  )
   );
// ══════════════════════════════════════════════════════════════════════════════════════════════
   // TIMER COUNTER
   TCNT #(
       WIDTH
   ) COUNTER (
    /******** INPUT *******/
       .PCLK    ( PCLK    ),
       .PRESETn ( PRESETn ),
       // from Generate Clock
       .CLK_in  ( clk_div ),
       // from TDR
       .TDR     ( TDR     ),
       // from TCR
       .EN      ( TCR[4]  ),
       .LOAD    ( TCR[7]  ),
       .DOWN    ( TCR[5]  ),
    /******** OUTPUT *******/
       // to SFR
       .CNT     ( CNT     )
   );
// ══════════════════════════════════════════════════════════════════════════════════════════════
   // SPECIAL FUNCTION REGISTER
   SFR #(
       WIDTH
    ) ACC (
    /*          INPUT         */
       .PCLK      ( PCLK      ),
       .PRESETn   ( PRESETn   ),
       // from TCR
       .EN        ( TCR[4]    ),
       .LOAD      ( TCR[7]    ),
       .DOWN      ( TCR[5]    ),
       // from TCNT
       .CNT       ( CNT       ),
    /*          OUTPUT        */
       // to TSR
       .S_TMR_UDF ( S_TMR_UDF ),
       .S_TMR_OVF ( S_TMR_OVF )
   );
endmodule

//////////////////////////////////
// ███████╗  ███████╗  ██████╗  //
// ██╔════╝  ██╔════╝  ██╔══██╗ //
// ███████╗  █████╗    ██████╔╝ //
// ╚════██║  ██╔══╝    ██╔══██╗ //
// ███████║  ██║       ██║  ██║ //
// ╚══════╝  ╚═╝       ╚═╝  ╚═╝ //
//////////////////////////////////

module SFR #(
    parameter WIDTH = 8
)(
    input             PCLK,
    input             PRESETn,
    input             EN,
    input             LOAD,
    input             DOWN,
    input [WIDTH-1:0] CNT,
    output            S_TMR_UDF,
    output            S_TMR_OVF
);
    
    wire             inst0;
    wire [WIDTH-1:0] lastCNT;
    wire             udf_eq_00;
    wire             udf_eq_ff;
    wire             ovf_eq_00;
    wire             ovf_eq_ff;

    assign #1 inst0 = EN & (~LOAD);
    //Set last CNT
    FF #(
        WIDTH
    ) ff_CNT (
        .clk ( PCLK    ), 
        .rst ( PRESETn ), 
        .q   ( CNT     ), 
        .D   ( lastCNT )
    );

    //Check occur condition Underflow
    assign #1 udf_eq_00 = (lastCNT == 8'h00) ? 1'b1 : 1'b0;
    assign #1 udf_eq_ff = (CNT     == 8'hFF) ? 1'b1 : 1'b0;
    assign #1 S_TMR_UDF = inst0 & DOWN & udf_eq_00 & udf_eq_ff;
    //Check occur condition Overflow
    assign #1 ovf_eq_00 = (lastCNT == 8'hFF) ? 1'b1 : 1'b0;
    assign #1 ovf_eq_ff = (CNT     == 8'h00) ? 1'b1 : 1'b0;
    assign #1 S_TMR_OVF = inst0 & (~DOWN) & ovf_eq_00 & ovf_eq_ff;
endmodule

////////////////////////////////////////////////
// ████████╗   ██████╗  ███╗   ██╗  ████████╗ //
// ╚══██╔══╝  ██╔════╝  ████╗  ██║  ╚══██╔══╝ //
//    ██║     ██║       ██╔██╗ ██║     ██║    //
//    ██║     ██║       ██║╚██╗██║     ██║    //
//    ██║     ╚██████╗  ██║ ╚████║     ██║    //
//    ╚═╝      ╚═════╝  ╚═╝  ╚═══╝     ╚═╝    //
////////////////////////////////////////////////

module TCNT #(
    parameter WIDTH = 8
)(
    input              PCLK,
    input              PRESETn,
    input              CLK_in,
    input  [WIDTH-1:0] TDR,
    input              EN,
    input              LOAD,
    input              DOWN,
    output [WIDTH-1:0] CNT
);
    wire [WIDTH-1:0] next_count, initial_value;
    reg  [WIDTH-1:0] sum;
    wire [WIDTH-1:0] MOD;
    wire             enCLK;

    //Mod Add/Sub for Adder
    localparam MODADD = 8'h01;
    localparam MODSUB = 8'hFF;

    //Set value of counter
    assign #1 next_count    = EN   ? sum : CNT;
    assign #1 initial_value = LOAD ? TDR  : next_count;

    //Set mod of counter
    assign #1 MOD = DOWN ? (MODSUB & {8{EN}}) : (MODADD & {8{EN}});

    //Save current value of counter
    FF #(
        WIDTH
    ) ff_CNT (
        .clk ( PCLK          ), 
        .rst ( PRESETn       ), 
        .q   ( initial_value ), 
        .D   ( CNT           )
    );

    //Add current value of counter with one when enCLK is HIGH
    always @(posedge PCLK) begin
        if (enCLK) begin
            sum <= #1 CNT + MOD;
        end else begin
            sum <= sum;
        end
    end

    //Detect Rising Edge synchronous between PCLK and CLK internal
    Syn_CLK SynCLK (
        .pclk_i ( PCLK    ),
        .rst_i  ( PRESETn ),
        .clk_i  ( CLK_in  ),
        .clk    ( enCLK   )
    );
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ███████╗ ██╗   ██╗ ███╗   ██╗  ██████╗ ██╗  ██╗ ██████╗   ██████╗  ███╗   ██╗  ██████╗  ██╗   ██╗ ███████╗                              //
// ██╔════╝ ╚██╗ ██╔╝ ████╗  ██║ ██╔════╝ ██║  ██║ ██╔══██╗ ██╔═══██╗ ████╗  ██║ ██╔═══██╗ ██║   ██║ ██╔════╝                              //
// ███████╗  ╚████╔╝  ██╔██╗ ██║ ██║      ███████║ ██████╔╝ ██║   ██║ ██╔██╗ ██║ ██║   ██║ ██║   ██║ ███████╗                              //
// ╚════██║   ╚██╔╝   ██║╚██╗██║ ██║      ██╔══██║ ██╔══██╗ ██║   ██║ ██║╚██╗██║ ██║   ██║ ██║   ██║ ╚════██║                              //
// ███████║    ██║    ██║ ╚████║ ╚██████╗ ██║  ██║ ██║  ██║ ╚██████╔╝ ██║ ╚████║ ╚██████╔╝ ╚██████╔╝ ███████║                              //
// ╚══════╝    ╚═╝    ╚═╝  ╚═══╝  ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝  ╚═════╝  ╚═╝  ╚═══╝  ╚═════╝   ╚═════╝  ╚═════╝                               //
//                                                                                                                                         //
//                                                                                          ██████╗ ██╗      ██████╗   ██████╗ ██╗   ███╗  //
//                                                                                         ██╔════╝ ██║     ██╔═══██╗ ██╔════╝ ██║ ███╔═╝  //
//                                                                                         ██║      ██║     ██║   ██║ ██║      █████╔═╝    //
//                                                                                         ██║      ██║     ██║   ██║ ██║      ██╔═███╗    //
//                                                                                         ╚██████╗ ███████╗╚██████╔╝ ╚██████╗ ██║  ╚███╗  //
//                                                                                          ╚═════╝ ╚══════╝ ╚═════╝   ╚═════╝ ╚═╝   ╚══╝  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Syn_CLK(
    input  pclk_i,
    input  rst_i,
    input  clk_i,
    output clk
);
    wire not_in;
    assign #1 clk = clk_i & (~not_in);
    FF ff0 (.clk(pclk_i), .rst(rst_i), .q(clk_i), .D(not_in));
endmodule

  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  ██████╗  ███████╗ ███╗   ██╗ ███████╗ ██████╗  █████╗   ████████╗ ███████╗         ██████╗ ██╗      ██████╗   ██████╗ ██╗   ███╗ //
// ██╔════╝  ██╔════╝ ████╗  ██║ ██╔════╝ ██╔══██╗ ██╔══██╗ ╚══██╔══╝ ██╔════╝        ██╔════╝ ██║     ██╔═══██╗ ██╔════╝ ██║ ███╔═╝ //
// ██║  ███╗ █████╗   ██╔██╗ ██║ █████╗   ██████╔╝ ███████║    ██║    █████╗          ██║      ██║     ██║   ██║ ██║      █████╔═╝   //
// ██║   ██║ ██╔══╝   ██║╚██╗██║ ██╔══╝   ██╔══██╗ ██╔══██║    ██║    ██╔══╝          ██║      ██║     ██║   ██║ ██║      ██╔═███╗   // 
// ╚██████╔╝ ███████╗ ██║ ╚████║ ███████╗ ██║  ██║ ██║  ██║    ██║    ███████╗        ╚██████╗ ███████╗╚██████╔╝ ╚██████╗ ██║  ╚███╗ //
//  ╚═════╝  ╚══════╝ ╚═╝  ╚═══╝ ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝    ╚══════╝         ╚═════╝ ╚══════╝ ╚═════╝   ╚═════╝ ╚═╝   ╚══╝ //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Generate_clock(
    input       clk,
    input       rst,
    input [1:0] sel,
    output      clk_o
);

    wire in0, in1, in2, in3;
    wire q0, q1, q2, q3;

    //div 2
    assign #1 in0 = ~q0;
    FF ff0 (.clk(clk), .rst(rst), .q(in0), .D(q0));
    //div 4
    assign #1 in1 = ~q1;
    FF ff1 (.clk(q0),  .rst(rst), .q(in1), .D(q1));
    //div 8
    assign #1 in2 = ~q2;
    FF ff2 (.clk(q1),  .rst(rst), .q(in2), .D(q2));
    //div 16
    assign #1 in3 = ~q3;
    FF ff3 (.clk(q2),  .rst(rst), .q(in3), .D(q3));
    //select clock
    assign #1 clk_o = sel[1] ? sel[0] ? q3 : q2 
                             : sel[0] ? q1 : q0;
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////
// ██████╗  ██╗ ███████╗ ██╗ ███╗   ██╗  ██████╗      ███████╗ ██████╗  ██████╗   ███████╗ //
// ██╔══██╗ ██║ ██╔════╝ ██║ ████╗  ██║ ██╔════╝      ██╔════╝ ██╔══██╗ ██╔════╝  ██╔════╝ //
// ██████╔╝ ██║ ███████╗ ██║ ██╔██╗ ██║ ██║  ███╗     █████╗   ██║  ██║ ██║  ███╗ █████╗   //
// ██╔══██╗ ██║ ╚════██║ ██║ ██║╚██╗██║ ██║   ██║     ██╔══╝   ██║  ██║ ██║   ██║ ██╔══╝   //
// ██║  ██║ ██║ ███████║ ██║ ██║ ╚████║ ╚██████╔╝     ███████╗ ██████╔╝ ╚██████╔╝ ███████╗ //
// ╚═╝  ╚═╝ ╚═╝ ╚══════╝ ╚═╝ ╚═╝  ╚═══╝  ╚═════╝      ╚══════╝ ╚═════╝   ╚═════╝  ╚══════╝ //
/////////////////////////////////////////////////////////////////////////////////////////////

module FF #(
    parameter WIDTH = 1
)(
    input                  clk,
    input                  rst,
    input      [WIDTH-1:0] q,
    output reg [WIDTH-1:0] D
);
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            D <= #1 0;
        end else begin
            D <= #1 q;
        end
    end
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// █████╗   ██████╗  ██████╗        ██████╗  ██╗   ██╗ ███████╗                                                                                   //
// ██╔══██╗ ██╔══██╗ ██╔══██╗       ██╔══██╗ ██║   ██║ ██╔════╝                                                                                   //
// ███████║ ██████╔╝ ██████╔╝       ██████╔╝ ██║   ██║ ███████╗                                                                                   //
// ██╔══██║ ██╔═══╝  ██╔══██╗       ██╔══██╗ ██║   ██║ ╚════██║                                                                                   //
// ██║  ██║ ██║      ██████╔╝       ██████╔╝ ╚██████╔╝ ███████║                                                                                   //
// ╚═╝  ╚═╝ ╚═╝      ╚═════╝        ╚═════╝   ╚═════╝  ╚══════╝                                                                                   //
//                                                                                                                                                //
//          ██████╗          ██╗ ██╗    ██╗        ██████╗  ██████╗  ███╗   ██╗ ████████╗ ██████╗   ██████╗  ██╗      ██╗      ███████╗ ██████╗   //
//          ██╔══██╗       ██╔═╝ ██║    ██║       ██╔════╝ ██╔═══██╗ ████╗  ██║ ╚══██╔══╝ ██╔══██╗ ██╔═══██╗ ██║      ██║      ██╔════╝ ██╔══██╗  //
//          ██████╔╝     ██╔═╝   ██║ █╗ ██║       ██║      ██║   ██║ ██╔██╗ ██║    ██║    ██████╔╝ ██║   ██║ ██║      ██║      █████╗   ██████╔╝  //
//          ██╔══██╗   ██╔═╝     ██║███╗██║       ██║      ██║   ██║ ██║╚██╗██║    ██║    ██╔══██╗ ██║   ██║ ██║      ██║      ██╔══╝   ██╔══██╗  //
//          ██║  ██║ ██╔═╝       ╚███╔███╔╝       ╚██████╗ ╚██████╔╝ ██║ ╚████║    ██║    ██║  ██║ ╚██████╔╝ ███████╗ ███████╗ ███████╗ ██║  ██║  //
//          ╚═╝  ╚═╝ ╚═╝          ╚══╝╚══╝         ╚═════╝  ╚═════╝  ╚═╝  ╚═══╝    ╚═╝    ╚═╝  ╚═╝  ╚═════╝  ╚══════╝ ╚══════╝ ╚══════╝ ╚═╝  ╚═╝  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module RW_Controller #(
    parameter WAIT = 0,
    parameter WIDTH = 8
)(
    input               PCLK,
    input               PRESETn,
    input               PSEL,
    input               PENABLE,
    input               PWRITE,
    input  [WIDTH-1:0]  PADDR,
    input  [WIDTH-1:0]  PWDATA,
    // INTERNAL DATA FROM STATUS REGISTER
    input               S_TMR_UDF,
    input               S_TMR_OVF,
    // APB OUTPUT
    output [WIDTH-1:0]  PRDATA,
    output              PREADY,
    output              PSLVERR,
    // INTERNAL OUTPUT To Peripherals 
    output [WIDTH-1:0]  TDR,
    output [WIDTH-1:0]  TCR
);
    reg  [1:0]        TSR;
    wire [WIDTH-1:0]  TSR_buf;
    wire [2:0]        sel_reg;
    wire              err;
    wire [WIDTH-1:0]  RBPWDATA;
    wire              TSR_OVF, TSR_UDF;
    
    //select register TDR, TCR and TSR
    Mux #(
        WIDTH
    ) multiplexer (
        .paddr      ( PADDR   ),
        .select_reg ( sel_reg )
    );
    //initial register TDR, TCR and TSR
    Reg #(
        WIDTH
    ) Reg_TDR (
                .clk     ( PCLK          ),  
                .rstn    ( PRESETn       ), 
                .psel    ( PSEL          ), 
                .pwrite  ( PWRITE        ),  
                .penable ( PENABLE       ), 
                .pready  ( PREADY        ), 
                .sel_reg ( sel_reg[0]    ), 
                .pwdata  ( RBPWDATA      ),   
                .out     ( TDR           ) 
    );
    Reg #(
        WIDTH
    ) Reg_TCR (
                .clk     ( PCLK          ),  
                .rstn    ( PRESETn       ), 
                .psel    ( PSEL          ), 
                .pwrite  ( PWRITE        ),  
                .penable ( PENABLE       ), 
                .pready  ( PREADY        ), 
                .sel_reg ( sel_reg[1]    ), 
                .pwdata  ( RBPWDATA      ),   
                .out     ( TCR           ) 
    );
    Reg #(
        WIDTH
    ) Reg_TSR (
                .clk     ( PCLK          ),  
                .rstn    ( PRESETn       ), 
                .psel    ( PSEL          ), 
                .pwrite  ( PWRITE        ),  
                .penable ( PENABLE       ), 
                .pready  ( PREADY        ), 
                .sel_reg ( sel_reg[2]    ), 
                .pwdata  ( RBPWDATA      ),   
                .out     ( TSR_buf       ) 
    );
    // Processed reserved bit
    assign #1 RBPWDATA = sel_reg[0] ? PWDATA :
                         sel_reg[1] ? {PWDATA[7], 1'h0, PWDATA[5:4], 2'h0, PWDATA[1:0]} :
                         sel_reg[2] ? {6'h0, (PWDATA[1:0] ? 2'h0 : PWDATA[1:0])} : 8'h0;
    // Set value TSR register when T_TMR_UDF, T_TMR_OVF are HIGH
    always @(posedge PCLK, negedge PRESETn) begin
        // Trigger S_TMR_OVF when counter overflow from 8'hFF to 8'h00
        if (!PRESETn) begin
            TSR[0] <= #1 1'b0;
        end else if (S_TMR_OVF) begin
            TSR[0] <= #1 1'b1;
        end else if (PWRITE && PENABLE && PREADY && sel_reg[2]) begin // update when reg_TSR[0] has assigned
            TSR[0] <= #1 TSR_buf[0];
        end
        // Trigger S_TMR_UDF when counter underflow from 8'h00 to 8'hFF
        if (!PRESETn) begin
            TSR[1] <= #1 1'b0;
        end else if (S_TMR_UDF) begin
            TSR[1] <= #1 1'b1;
        end else if (PWRITE && PENABLE && PREADY && sel_reg[2]) begin // update when reg_TSR[1] has assigned
            TSR[1] <= #1 TSR_buf[1];
        end
    end
    //read data TDR, TCR and TSR
    Prd #(
        WAIT, 
        WIDTH 
    ) read_reg (
                .clk    ( PCLK           ),
                .rstn   ( PRESETn        ),
                .pready ( PREADY         ),
                .psel   ( PSEL           ),
                .pwrite ( PWRITE         ),
                .penable( PENABLE        ),
                .paddr  ( PADDR          ),
                .TDR    ( TDR            ), 
                .TCR    ( TCR            ), 
                .TSR    ( {TSR_buf[WIDTH-1:2], TSR} ),
                .out    ( PRDATA         )
    );

    //compute pready signal
    Pre #(
        WAIT
        ) pready_signal (
        .clk     ( PCLK    ),
        .rstn    ( PRESETn ),
        .psel    ( PSEL    ),
        .penable ( PENABLE ),
        .pready  ( PREADY  )
    );

    //compute pslerr signal
    Psl pslerr_signal (
        .clk        ( PCLK    ),
        .rstn       ( PRESETn ),
        .select_reg ( sel_reg ),
        .pslverr    ( err     )
    );
    assign #1 PSLVERR = err & PREADY;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////
// ███╗   ███╗ ██╗   ██╗ ██╗   ████████╗ ██╗ ██████╗  ██╗      ███████╗ ██╗  ██╗ ███████╗ ██████╗  //
// ████╗ ████║ ██║   ██║ ██║   ╚══██╔══╝ ██║ ██╔══██╗ ██║      ██╔════╝ ╚██╗██╔╝ ██╔════╝ ██╔══██╗ //
// ██╔████╔██║ ██║   ██║ ██║      ██║    ██║ ██████╔╝ ██║      █████╗    ╚███╔╝  █████╗   ██████╔╝ //
// ██║╚██╔╝██║ ██║   ██║ ██║      ██║    ██║ ██╔═══╝  ██║      ██╔══╝    ██╔██╗  ██╔══╝   ██╔══██╗ //
// ██║ ╚═╝ ██║ ╚██████╔╝ ███████╗ ██║    ██║ ██║      ███████╗ ███████╗ ██╔╝ ██╗ ███████╗ ██║  ██║ //
// ╚═╝     ╚═╝  ╚═════╝  ╚══════╝ ╚═╝    ╚═╝ ╚═╝      ╚══════╝ ╚══════╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ //
/////////////////////////////////////////////////////////////////////////////////////////////////////

module Mux #(
    parameter WIDTH = 8
)(
    input      [WIDTH-1:0]  paddr,
    output reg [2:0]        select_reg
);
    always @(paddr) begin
        case (paddr)
            8'h0 : select_reg <= #1 8'b001;
            8'h1 : select_reg <= #1 8'b010;
            8'h2 : select_reg <= #1 8'b100;             
        default  : select_reg <= #1 8'b000;
        endcase
    end
endmodule

//////////////////////////////////////////////////////////////////////////
// ██████╗  ███████╗  ██████╗  ██╗ ███████╗ ████████╗ ███████╗ ██████╗  //
// ██╔══██╗ ██╔════╝ ██╔════╝  ██║ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗ //
// ██████╔╝ █████╗   ██║  ███╗ ██║ ███████╗    ██║    █████╗   ██████╔╝ //
// ██╔══██╗ ██╔══╝   ██║   ██║ ██║ ╚════██║    ██║    ██╔══╝   ██╔══██╗ //
// ██║  ██║ ███████╗ ╚██████╔╝ ██║ ███████║    ██║    ███████╗ ██║  ██║ //
// ╚═╝  ╚═╝ ╚══════╝  ╚═════╝  ╚═╝ ╚══════╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝ //
//////////////////////////////////////////////////////////////////////// /

module Reg #(
    parameter WIDTH = 8
)(
    input                   clk,
    input                   rstn,
    input                   psel,
    input                   pwrite,
    input                   penable,
    input                   pready,
    input                   sel_reg,
    input      [WIDTH-1:0]  pwdata,
    output reg [WIDTH-1:0]  out
);
    wire sel_mux;
    wire [WIDTH-1:0] bus;

    assign sel_mux = psel & pwrite & penable & pready & sel_reg;
    assign bus = sel_mux ? pwdata : out;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            out <= #1 8'h0;
        end else begin
            out <= #1 bus;
        end
    end
endmodule

////////////////////////////////////////////////////////////////////////////
// ██████╗ ███████╗ █████╗ ██████╗     ██████╗  █████╗ ████████╗ █████╗   //   
// ██╔══██╗██╔════╝██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗  //   
// ██████╔╝█████╗  ███████║██║  ██║    ██║  ██║███████║   ██║   ███████║  //  
// ██╔══██╗██╔══╝  ██╔══██║██║  ██║    ██║  ██║██╔══██║   ██║   ██╔══██║  //   
// ██║  ██║███████╗██║  ██║██████╔╝    ██████╔╝██║  ██║   ██║   ██║  ██║  //  
// ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝  //
////////////////////////////////////////////////////////////////////////////

module Prd #(
    parameter WAIT = 0,
    parameter WIDTH = 8
)(
    input                   clk,
    input                   rstn,
    input                   pready,
    input                   psel,
    input                   pwrite,
    input                   penable,
    input      [WIDTH-1:0]  paddr,
    input      [WIDTH-1:0]  TDR, 
    input      [WIDTH-1:0]  TCR, 
    input      [WIDTH-1:0]  TSR,
    output reg [WIDTH-1:0]  out
);
    wire ready1, ready2, en;
    reg  [2:0] count;

    assign ready1 = psel & !pwrite & !penable;
    assign en = WAIT ? ready2 : ready1;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            out <= #1 8'h0;
        end else if (en) begin
            case (paddr)
                8'h0 : out <= #1 TDR;
                8'h1 : out <= #1 TCR;
                8'h2 : out <= #1 TSR;
                default: begin
                       out <= #1 8'h0;
                end
            endcase
        end else begin
            out <= #1 out;
        end
    end
    
    //check wait state
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            count <= #1 4'b0;
        end else if (!count) begin
            count <= #1 (ready1 & (|WAIT)) ? 4'b1 : 4'b0;
        end else begin
            count <= #1 ready2 ? 4'b0 : count + 1'b1;
        end
    end
    //check final clock
    assign #1 ready2 = (count == WAIT);
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////
// ██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗    ███████╗██╗ ██████╗ ███╗   ██╗ █████╗ ██╗      //
// ██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝    ██╔════╝██║██╔════╝ ████╗  ██║██╔══██╗██║      //
// ██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝     ███████╗██║██║  ███╗██╔██╗ ██║███████║██║      //
// ██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝      ╚════██║██║██║   ██║██║╚██╗██║██╔══██║██║      //
// ██║  ██║███████╗██║  ██║██████╔╝   ██║       ███████║██║╚██████╔╝██║ ╚████║██║  ██║███████╗ //
// ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝       ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝ //
/////////////////////////////////////////////////////////////////////////////////////////////////

module Pre #(
    parameter WAIT = 0
)(
    input      clk,
    input      rstn,
    input      psel,
    input      penable,
    output reg pready
);
    wire ready;
    //initial counter
    reg [2:0] count;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            pready <= #1 1'b0;
        end else begin
            pready <= #1 WAIT ? ready : (psel & !penable);
        end
    end
    
    //check wait state
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            count <= #1 4'b0;
        end else if (!count) begin
            count <= #1 (psel & !penable & (|WAIT)) ? 4'b1 : 4'b0;
        end else begin
            count <= #1 ready ? 4'b0 : count + 1'b1;
        end
    end
    //check final clock
    assign #1 ready = (count == WAIT);
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
// ██████╗ ███████╗██╗      █████╗ ██╗   ██╗███████╗    ███████╗██████╗ ██████╗  ██████╗ ██████╗  //
// ██╔══██╗██╔════╝██║     ██╔══██╗██║   ██║██╔════╝    ██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗ //
// ██████╔╝███████╗██║     ███████║██║   ██║█████╗      █████╗  ██████╔╝██████╔╝██║   ██║██████╔╝ //
// ██╔═══╝ ╚════██║██║     ██╔══██║╚██╗ ██╔╝██╔══╝      ██╔══╝  ██╔══██╗██╔══██╗██║   ██║██╔══██╗ //
// ██║     ███████║███████╗██║  ██║ ╚████╔╝ ███████╗    ███████╗██║  ██║██║  ██║╚██████╔╝██║  ██║ //
// ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ //
////////////////////////////////////////////////////////////////////////////////////////////////////

module Psl(
    input               clk,
    input               rstn,
    input  [2:0]       select_reg,
    output reg          pslverr
);
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            pslverr <= #1 0;
        end else begin
            pslverr <= #1 |select_reg ? 0 : 1;
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////
// ███████╗ ███╗   ██╗ ██████╗         ██████╗  ███████╗       ███████╗ ██╗ ██╗      ███████╗   //
// ██╔════╝ ████╗  ██║ ██╔══██╗       ██╔═══██╗ ██╔════╝       ██╔════╝ ██║ ██║      ██╔════╝   //
// █████╗   ██╔██╗ ██║ ██║  ██║       ██║   ██║ █████╗         █████╗   ██║ ██║      █████╗     //
// ██╔══╝   ██║╚██╗██║ ██║  ██║       ██║   ██║ ██╔══╝         ██╔══╝   ██║ ██║      ██╔══╝     //
// ███████╗ ██║ ╚████║ ██████╔╝       ╚██████╔╝ ██║            ██║      ██║ ███████╗ ███████╗   //
// ╚══════╝ ╚═╝  ╚═══╝ ╚═════╝         ╚═════╝  ╚═╝            ╚═╝      ╚═╝ ╚══════╝ ╚══════╝   //
//////////////////////////////////////////////////////////////////////////////////////////////////