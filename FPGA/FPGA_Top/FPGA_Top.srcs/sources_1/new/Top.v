module Top(
    input top_sys_clk,    //全局时钟
    input top_sys_rstn,   //全局复位
    
    (*mark_debug="true"*)input top_uart_rx,   //串口RX
    (*mark_debug="true"*)output top_uart_tx,   //串口TX

    output top_led      //led口输出
    );

wire top_rst_n;
wire [7:0] uart_data_rxed_rdo_wire;         //模块间连线
wire [7:0] uart_taskctrl_data_tobetxed_rdo_wire;  
wire [7:0] LedTask_Data_rdo_wire;

assign top_rst_n = (top_sys_rstn && locked);    //利用locked产生复位信号

    pll_clock pll_clock_inst1 
    (
    .clk_100mhz (clk_100mhz),
    .resetn     (top_sys_rstn),
    .locked     (locked),
    .sys_clk    (top_sys_clk)
    );
    

    Uart_TaskCtrl Uart_TaskCtrl_Inst1(
    //模块驱动部分，时钟复位啥的
    .uart_taskctrl_sys_clk_wsi       (clk_100mhz      ),             //输入的全局时钟
    .uart_taskctrl_sys_rstn_wsi      (top_rst_n     ),           //串口模块的全局复位
    .uart_taskctrl_en_wsi            (1'b1           ),                 //模块使能

    //串口操作部分
    .uart_taskctrl_data_rvd_wdi      (uart_data_rxed_rdo_wire     ),           //读取串口接收到的数据
    .uart_takactrl_rx_done_wfi       (uart_takactrl_rx_done_wfi      ),                 //接收数据完毕
    .uart_taskctrl_rx_busy_wfi       (uart_taskctrl_rx_busy_wfi      ),                //接收忙，也就

    .uart_taskctrl_data_tobetxed_rdo (uart_taskctrl_data_tobetxed_rdo_wire),  //要发送的数据
    .uart_taskctrl_trigger_rfo       (uart_taskctrl_trigger_rfo      ),              //要用串口发送出去的数据
    .uart_taskctrl_tx_busy_wfi       (uart_taskctrl_tx_busy_wfi      ),                   //串口忙的标志
    .uart_taskctrl_tx_done_wfi       (uart_taskctrl_tx_done_wfi      ),                  //串口发送

    // LED控制模块部分
    .LedTask_Data_rdo                (LedTask_Data_rdo_wire               ),               //给LED控制模块的命令
    .LedTask_Data_Trigger_rfo        (LedTask_Data_Trigger_rfo       ),              //给LED数据读取的脉冲
    .LedTask_Data_Done_rfo        (LedTask_Data_Done_rfo       )              //给LED控制模块的任务trigger
    );

    UART UART_Inst1(
    .uart_sys_clk_wsi        (clk_100mhz       ),             //输入的全局时钟
    .uart_sys_rstn_wsi       (top_rst_n      ),                      //串口模块复位信号

    .uart_data_tobetxed_wdi  (uart_taskctrl_data_tobetxed_rdo_wire ),            //uart要发送出去的数据
    .uart_tx_done_rfo        (uart_taskctrl_tx_done_wfi       ),              //tx完毕信号                   //脉冲
    .uart_tx_trigger_wfi     (uart_taskctrl_trigger_rfo    ),                //tx任务触发信号               //脉冲
    .uart_tx_busy_rfo        (uart_taskctrl_tx_busy_wfi       ),              //tx忙信号，正在发送           //电平
    .uart_tx                 (top_uart_tx                ),                      //输出

    .uart_rx                 (top_uart_rx                ),                        //输入全局信号
    .uart_data_rxed_rdo      (uart_data_rxed_rdo_wire     ),  //uart接收到的数据           
    .uart_rx_done_rfo        (uart_takactrl_rx_done_wfi       ),         //uart发送完毕信号           //脉冲
    .uart_rx_busy_rfo        (uart_taskctrl_rx_busy_wfi       ) //uart正在接收信号           //电平
    );


    Led_Task Led_Task_Inst1(
    .uart_ledtask_sys_clk_wsi   (clk_100mhz) ,             //输入的全局时钟
    .uart_ledtask_sys_rstn_wsi  (top_rst_n) ,           //Led模块的全局复位

    .LedTask_Data_wdi           (LedTask_Data_rdo_wire) ,               //给LED控制模块的命令
    .LedTask_Data_Trigger_wfi   (LedTask_Data_Trigger_rfo) ,              //给LED数据读取的脉冲
    .LedTask_Data_Done_wfi      (LedTask_Data_Done_rfo) ,              //给LED控制模块当前包接收完毕

    .Led_pin_rpo                (top_led)           //连接LED的输出引脚
    );
    
endmodule
