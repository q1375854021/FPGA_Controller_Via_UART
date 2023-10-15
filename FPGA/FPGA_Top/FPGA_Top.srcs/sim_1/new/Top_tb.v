`timescale 10ns / 10ps

module Top_tb();

    reg top_sys_clk;    //全局时钟
    reg top_sys_rstn;   //全局复位
    
    reg top_uart_rx;   //串口RX
    wire top_uart_tx;   //串口TX

    Top Top_Inst1(
        .top_sys_clk    (top_sys_clk),    //全局时钟
        .top_sys_rstn   (top_sys_rstn),   //全局复位
        .top_uart_rx    (top_uart_rx),   //串口RX
        .top_uart_tx    (top_uart_tx),   //串口TX
        .top_led        (top_led    )   //LED输出
    );

    initial begin
        #0  top_sys_clk=1'b1;
            top_sys_rstn = 1'b1;
            top_uart_rx = 1'b1;
        #2  top_sys_rstn = 1'b0;
        #4  top_sys_rstn = 1'b1;
        //发送01  
        
        // 01 01 00 00 00 00 00 10
        begin
        //起始位  
        #863; top_uart_rx = 1'b0;   
        //数据  
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
        //发送01  
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
        
        //发送10  
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        end
        #100000;
 
        //发送01 00 00 00 00 00 00 10 
        begin
        //起始位  
        #863; top_uart_rx = 1'b0;   
        //数据  
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
        //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
         //发送00
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        
        
        //发送10  
        //起始位
        #863; top_uart_rx = 1'b0;   
        //数据 低位在前，高位在后
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //停止位
        #1000; top_uart_rx = 1'b1;
        end

    end

always #1 top_sys_clk=~top_sys_clk;   



endmodule
