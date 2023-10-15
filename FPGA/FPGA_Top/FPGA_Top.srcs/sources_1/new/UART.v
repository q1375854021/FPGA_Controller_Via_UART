//工作条件
// 波特率115200
// 模块时钟100MHz
// 模块是低电平复位
// 8个数据位
// 无校验位
// 1.5个或2个停止位

module UART(
    //为什么没有reg了呢？因为底层已经实现了reg，上层仅仅是封装一下，所以用wire
    input uart_sys_clk_wsi,             //输入的全局时钟
    input uart_sys_rstn_wsi,           //串口模块的全局复位

    // 发送端口
    input [7:0] uart_data_tobetxed_wdi,        //uart要发送出去的数据
    output uart_tx_done_rfo,              //tx完毕信号                   //脉冲
    input uart_tx_trigger_wfi,                //tx任务触发信号               //脉冲
    output  uart_tx_busy_rfo,              //tx忙信号，正在发送           //电平
    output  uart_tx,                      //输出全局信号

    //接收端口
    (*mark_debug="true"*)input uart_rx,                        //输入全局信号
    (*mark_debug="true"*)output  [7:0] uart_data_rxed_rdo,  //uart接收到的数据           
    (*mark_debug="true"*)output  uart_rx_done_rfo,         //uart发送完毕信号           //脉冲
    (*mark_debug="true"*)output  uart_rx_busy_rfo         //uart正在接收信号           //电平
    );

parameter Baudrate = 32'd115200;       //波特率
parameter Uart_sysclk = 32'd100_000_000;    //输入时钟100MHz

    UART_RX#(
        .Baudrate(Baudrate),       //波特率
        .Uart_sysclk(Uart_sysclk)    //输入时钟100MHz 
    ) 
    UART_RX_Inst1
    (
    .uart_sys_clk_wsi(uart_sys_clk_wsi),             //uart模块全局时钟
    .uart_sys_rstn_wsi(uart_sys_rstn_wsi),            //uart全局复位

    .uart_rx(uart_rx),                        //输入全局信号
    .uart_data_rxed_rdo(uart_data_rxed_rdo),  //uart接收到的数据           
    .uart_rx_done_rfo(uart_rx_done_rfo),         //uart发送完毕信号           //脉冲
    .uart_rx_busy_rfo(uart_rx_busy_rfo)         //uart正在接收信号       
    );

    UART_TX #(
        .Baudrate(Baudrate),       //波特率
        .Uart_sysclk(Uart_sysclk)    //输入时钟100MHz 
    )
    UART_TX_Inst1
    (
    .uart_sys_clk_wsi        (uart_sys_clk_wsi),             //uart模块全局时钟
    .uart_sys_rstn_wsi       (uart_sys_rstn_wsi),            //uart全局复位

    .uart_data_tobetxed_wdi  (uart_data_tobetxed_wdi),   //uart要发送出去的数据
    .uart_tx_done_rfo        (uart_tx_done_rfo),        //tx完毕信号                   //脉冲
    .uart_tx_trigger_wfi     (uart_tx_trigger_wfi),          //tx任务触发信号               //脉冲
    .uart_tx_busy_rfo        (uart_tx_busy_rfo),        //tx忙信号，正在发送           //电平

    .uart_tx (uart_tx)                     //输出全局信号
    );


endmodule
