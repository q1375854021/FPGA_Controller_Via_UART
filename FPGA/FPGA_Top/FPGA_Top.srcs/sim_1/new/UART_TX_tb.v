`timescale 1ns / 1ps

module UART_TX_tb(
    );
    
    reg uart_sys_clk_wsi;             //uart模块全局时钟
    reg uart_sys_rstn_wsi;            //uart全局复位
    
    reg [7:0] uart_data_tobetxed_wdi;   //uart要发送出去的数据
    wire  uart_tx_done_rfo;        //tx完毕信号                   //脉冲
    reg uart_tx_trigger_wfi;          //tx任务触发信号               //脉冲
    wire uart_tx_busy_rfo;        //tx忙信号，正在发送           //电平

    
    wire uart_tx;                      //输出全局信号
    
    UART_TX UART_TX_inst1(
     .uart_sys_clk_wsi(uart_sys_clk_wsi),             //uart模块全局时钟
     .uart_sys_rstn_wsi(uart_sys_rstn_wsi),            //uart全局复位
     .uart_data_tobetxed_wdi(uart_data_tobetxed_wdi),   //uart要发送出去的数据
     .uart_tx_done_rfo(uart_tx_done_rfo),        //tx完毕信号                   //脉冲
     .uart_tx_trigger_wfi(uart_tx_trigger_wfi),          //tx任务触发信号               //脉冲
     .uart_tx_busy_rfo(uart_tx_busy_rfo),        //tx忙信号，正在发送           //电平
     .uart_tx(uart_tx)                      //输出全局信号
     );
     
     
     initial begin
       #1 uart_sys_clk_wsi=0;
            uart_sys_rstn_wsi=0;
            uart_tx_trigger_wfi <= 1'b0;
       #4 uart_sys_rstn_wsi=1;
          uart_data_tobetxed_wdi <= 8'h55;
       #6 uart_tx_trigger_wfi <= 1'b1;
       #7 uart_tx_trigger_wfi <= 1'b0;
      end
      
always #1 uart_sys_clk_wsi=~uart_sys_clk_wsi;


endmodule
