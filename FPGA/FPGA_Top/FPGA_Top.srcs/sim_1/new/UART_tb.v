`timescale 1ns / 1ps

module UART_tb();

    reg uart_sys_clk_wsi;             //输入的全局时钟
    reg uart_sys_rstn_wsi;           //串口模块的全局复位

    // 发送端口
    reg [7:0] uart_data_tobetxed_wdi;        //uart要发送出去的数据
    wire  uart_tx_done_rfo;              //tx完毕信号                   //脉冲
    reg uart_tx_trigger_wfi;                //tx任务触发信号               //脉冲
    wire  uart_tx_busy_rfo;              //tx忙信号，正在发送           //电平
    wire  uart_tx;                      //输出全局信号
    
    //接收端口
    reg uart_rx;                        //输入全局信号
    wire  [7:0] uart_data_rxed_rdo;  //uart接收到的数据           
    wire  uart_rx_done_rfo;         //uart发送完毕信号           //脉冲
    wire  uart_rx_busy_rfo;        //uart正在接收信号           //电平


reg [7:0] temp_i;

    UART UART_Inst1(
    .uart_sys_clk_wsi       (uart_sys_clk_wsi),             //输入的全局时钟
    .uart_sys_rstn_wsi      (uart_sys_rstn_wsi),           //串口模块送端口

    .uart_data_tobetxed_wdi (uart_data_tobetxed_wdi),        //uart要发送出去的数据
    .uart_tx_done_rfo       (uart_tx_done_rfo),              //tx完毕信号                   //脉冲
    .uart_tx_trigger_wfi    (uart_tx_trigger_wfi),                //tx任务触发信号               //脉冲
    .uart_tx_busy_rfo       (uart_tx_busy_rfo),              //tx忙信号，正在发送           //电平
    .uart_tx                (uart_tx),                      //输出端口

    .uart_rx                (uart_rx),                        //输入全局信号
    .uart_data_rxed_rdo     (uart_data_rxed_rdo),  //uart接收到的数据           
    .uart_rx_done_rfo       (uart_rx_done_rfo),         //uart发送完毕信号           //脉冲
    .uart_rx_busy_rfo       (uart_rx_busy_rfo)  //uart正在接收信号         
    );
    
   initial begin
       #1 uart_sys_clk_wsi=0;
            uart_sys_rstn_wsi=0;
            uart_rx = 1'b1;
            uart_tx_trigger_wfi <= 1'b0;
       #4 uart_sys_rstn_wsi=1;
          uart_data_tobetxed_wdi <= 8'h55;
       #6 uart_tx_trigger_wfi <= 1'b1;
       #7 uart_tx_trigger_wfi <= 1'b0;
      
      
      for (temp_i = 8'd0; temp_i < 8'd10; temp_i = temp_i + 1'b1)
             begin
                 #1700 uart_rx=~uart_rx;
             end
             
       end

always #1 uart_sys_clk_wsi=~uart_sys_clk_wsi;



    
endmodule
