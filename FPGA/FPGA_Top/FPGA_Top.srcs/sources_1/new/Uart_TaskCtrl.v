module Uart_TaskCtrl(
    input uart_taskctrl_sys_clk_wsi,             //输入的全局时钟
    input uart_taskctrl_sys_rstn_wsi,           //串口模块的全局复位
    input uart_taskctrl_en_wsi,                 //模块使能信号

    (*mark_debug="true"*)input [7:0] uart_taskctrl_data_rvd_wdi,           //读取串口接收到的数据
    (*mark_debug="true"*)input uart_takactrl_rx_done_wfi,                //接收数据完毕
    (*mark_debug="true"*)input uart_taskctrl_rx_busy_wfi,                //接收忙，也就是没接收完

    (*mark_debug="true"*)output reg [7:0] uart_taskctrl_data_tobetxed_rdo,  //要用串口发送出去的数据
    (*mark_debug="true"*)output reg uart_taskctrl_trigger_rfo,              //要用串口发送出去的数据的脉冲驱动信号
    (*mark_debug="true"*)input uart_taskctrl_tx_busy_wfi,                   //串口忙的标志
    (*mark_debug="true"*)input uart_taskctrl_tx_done_wfi,                  //串口发送完毕的标志

    (*mark_debug="true"*)output reg [7:0] LedTask_Data_rdo,               //给LED控制模块的命令
    (*mark_debug="true"*)output reg LedTask_Data_Trigger_rfo,              //给LED数据读取的脉冲
    (*mark_debug="true"*)output reg LedTask_Data_Done_rfo              //给LED控制模块的任务trigger   
    );

//  数据长度定义
parameter LedTask_Data_Length = 8'd8;    //给LED的数据包固定是8个字节
parameter uart_taskctrl_data_tobetxed = 8'd3;   //串口回复的OK\n的长度

//状态机寄存器
reg [7:0] uart_taskctrl_current_state_rfn;        //当前状态
reg [7:0] uart_taskctrl_next_state_rfn;           //下一个状态


reg uart_taskctrl_en_rsn;                        //使能信号
reg [7:0] uart_taskctrl_data_rvd_rdn;            //从串口读取到的数据
reg uart_takactrl_rx_done_rfn;                  //接收数据完毕信号
reg uart_taskctrl_rx_busy_rfn;                  //接收忙信号
reg uart_taskctrl_tx_busy_rfn;                  //发送忙信号
reg uart_taskctrl_tx_done_rfn;                  //发送完毕信号

// 定义串口缓存区
reg [8*8-1 : 0] uart_taskctrl_data_fifo_rdn;     //串口的缓存区，共100个byte
reg [7:0] LedTask_Data_Length_rdn;                //LEDTask要发送的数据长度，临时存储一下

reg [5*8:1] String_To_Uart;             //用来放发送到串口的字符串的
reg [7:0] String_To_Uart_Length;        //存储要发送的次数

assign uart_taskctrl_rx_ready_wfn = (~uart_taskctrl_rx_busy_rfn) & uart_takactrl_rx_done_rfn;  //正好会有一个尖脉冲，根据这个脉冲就可以判断是否接收完成


// 把输入信号打一下，去掉信号抖动与毛刺
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi)   begin    //如果复位
        uart_taskctrl_en_rsn <= 8'd0;
        uart_taskctrl_data_rvd_rdn <= 8'd0;
        uart_takactrl_rx_done_rfn <= 1'b0;
        uart_taskctrl_rx_busy_rfn <= 1'b0;
        uart_taskctrl_tx_busy_rfn <= 1'b0;
        uart_taskctrl_tx_done_rfn <= 1'b0;
    end
    else begin
        uart_taskctrl_en_rsn <= uart_taskctrl_en_wsi;
        uart_taskctrl_data_rvd_rdn <= uart_taskctrl_data_rvd_wdi;
        uart_takactrl_rx_done_rfn <= uart_takactrl_rx_done_wfi;
        uart_taskctrl_rx_busy_rfn <= uart_taskctrl_rx_busy_wfi;
        uart_taskctrl_tx_busy_rfn <= uart_taskctrl_tx_busy_wfi;
        uart_taskctrl_tx_done_rfn <= uart_taskctrl_tx_done_wfi;
    end
end     


//状态机

//  状态机第一段，状态切换
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi)      //如果复位
        uart_taskctrl_current_state_rfn <= 8'd0;
    else
        uart_taskctrl_current_state_rfn <= uart_taskctrl_next_state_rfn;
end     

// 状态机第二段， 状态转移  组合逻辑
always @(*) begin
    begin
        uart_taskctrl_next_state_rfn = 8'd0;
        case (uart_taskctrl_current_state_rfn)
            8'd0: begin
                if(uart_taskctrl_en_rsn == 1'b1)           //如果是能，代表该模块是使能状态，进入到等待串口信号来临状态
                    uart_taskctrl_next_state_rfn = 8'd1;      //使能状态，准备接收串口数据
                else
                    uart_taskctrl_next_state_rfn = 8'd0;      //没使能则继续等
            end

            8'd1: begin
                if(uart_taskctrl_rx_ready_wfn == 1'b1)         //串口数据准备完毕，那么就准备读取数据到缓冲区
                    uart_taskctrl_next_state_rfn = 8'd2;      // 把从串口收到的数据存到缓冲区内
                else
                    uart_taskctrl_next_state_rfn = 8'd1;      // 串口数据没准备好就继续等
            end

            //状态2： 收到换行键就转换到状态3 -> 说明接收包结束  否则继续接收
            8'd2: begin
                if(uart_taskctrl_data_rvd_rdn == 8'h10)    //包的结尾固定是0x10,也就是换行键，  一个包八个byte，最后一个byte为10，
                    uart_taskctrl_next_state_rfn = 8'd3;    
                else
                    uart_taskctrl_next_state_rfn = 8'd1;    //要不然就回到状态1，因为没有收到换行键，说明数据还没有接收完毕，继续返回接收
            end

            //  转移到状态4
            // LED对应的包： 01 xx xx xx xx xx xx 10    01代表 LED任务，最高支持256个任务， 最后一个是包围，固定是10
            8'd3: begin  
                if(uart_taskctrl_data_fifo_rdn[63:56] == 8'd01)   //这里也可以用case，分出多个分支，分别跳转到不同的任务
                    uart_taskctrl_next_state_rfn = 8'd4;   //LED任务处理，在这里同时准备好了给LED任务的数据
                else
                    uart_taskctrl_next_state_rfn = 8'd12;   //数据不对应，进入后续处理环节,其实没有进行任何操作，只是状态回到了状态0而已，这里后续可以弄一下。
            end

            8'd4: begin    //这里串口的所有数据已经全部接收完毕，并且判断出了是LED模块的数据并且准备好了, 然后用几个状态准备一些同步信号和辅助信号
                uart_taskctrl_next_state_rfn <= 8'd5;     
            end

            8'd5: begin    //仍然是准备辅助信号
                uart_taskctrl_next_state_rfn <= 8'd6;    //脉冲下降沿
            end

            8'd6: begin   //这里应该是判断是否发送完成
                if(LedTask_Data_Length_rdn == 8'd0)   //发送完了之后，就转移到下一状态， 对这一个包接收完毕的信号赋值
                    uart_taskctrl_next_state_rfn = 8'd7;       //如果数据发送完毕了
                else
                    uart_taskctrl_next_state_rfn = 8'd4;      //否则还得回到状态四重新准备数据
            end

            8'd7: begin         //对表示  包结束的信号脉冲进行处理。 
                uart_taskctrl_next_state_rfn = 8'd8;        //准备Task脉冲
            end

            8'd8: begin     //仍然是对表示  包结束的信号脉冲进行处理。 
                uart_taskctrl_next_state_rfn = 8'd9;      //准备Task脉冲下降沿
            end


            8'd9: begin       //包结束脉冲准备完毕后，一般默认这一帧数据没问题，然后向串口回发一个 OK\n即可  这里的OK\n是串行发的 发O K \n
                uart_taskctrl_next_state_rfn = 8'd10;    //开始发送OK\n  准备好了数据
            end

            8'd10: begin    //然后给串口模块一个发射使能脉冲 
                uart_taskctrl_next_state_rfn = 8'd11;
            end

            8'd11: begin  //等待OK\n发送完毕
                if(String_To_Uart_Length == 8'd0 && uart_taskctrl_tx_done_rfn == 1'b1)   //如果发送完毕并且发送完成
                    uart_taskctrl_next_state_rfn = 8'd12;   // 等待OK\n发送完毕，然后就进入下一状态， 清除寄存器等一些东西，然后准备下一次
                else if(uart_taskctrl_tx_done_rfn == 1'b1)   //如果发送完毕但是并没有完全发送完
                    uart_taskctrl_next_state_rfn = 8'd9;   // 仅仅某一个字符发送完成，但是并没有全部发完，回到状态9继续发
                else
                    uart_taskctrl_next_state_rfn = 8'd11;   //如果都不是，就继续等
            end 

            8'd12: begin  //清缓冲区，清寄存器等等，清完之后回到状态0
                uart_taskctrl_next_state_rfn = 8'd0;  
            end

            default: begin
              uart_taskctrl_next_state_rfn = 8'd0;
            end

        endcase
    end
end


// 状态机第三段， 任务驱动
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi) begin     //如果复位或者没使能
        uart_taskctrl_trigger_rfo <= 1'b0;       //给串口的使能发送脉冲
        LedTask_Data_rdo <= 8'd0;               //发送给LED模块的数据
        LedTask_Data_Trigger_rfo <= 1'd0;       //LED数据trigger
        LedTask_Data_Done_rfo <= 1'b0;       //LED任务trigger
        uart_taskctrl_data_fifo_rdn <= 64'd0;   //缓冲区自动清零
        uart_taskctrl_data_tobetxed_rdo <= uart_taskctrl_data_tobetxed;    //要通过串口发送到单片机的值
        LedTask_Data_Length_rdn <= LedTask_Data_Length;       //要发送的数据长度 临时寄存器
        String_To_Uart <= "OK\n";
    end
    else begin
        case (uart_taskctrl_next_state_rfn) 
            8'd0: begin   //状态0， 就准备初始信号
                uart_taskctrl_trigger_rfo <= 1'b0;       //给串口的使能发送脉冲
                LedTask_Data_rdo <= 8'd0;               //发送给LED模块的数据
                LedTask_Data_Trigger_rfo <= 1'd0;       //LED数据trigger
                LedTask_Data_Done_rfo <= 1'b0;       //LED任务trigger
                uart_taskctrl_data_fifo_rdn <= 64'd0;   //缓冲区自动清零
                uart_taskctrl_data_tobetxed_rdo <= uart_taskctrl_data_tobetxed;    //要通过串口发送到单片机的值
                LedTask_Data_Length_rdn <= LedTask_Data_Length;       //要发送的数据长度 临时寄存器
                String_To_Uart <= "OK\n";
            end

            8'd1: begin  //没有要做的，随便写个语句占位置
                LedTask_Data_Trigger_rfo <= LedTask_Data_Trigger_rfo;
            end
            
            //状态2，应当把从串口模块接收到的数据缓存起来。
            //uart_taskctrl_data_rvd_rdn：  从串口接受到的数据
            //uart_taskctrl_data_fifo_rdn   串口缓冲区
            8'd2: begin  //把串口读到的数据存到缓冲区 
                uart_taskctrl_data_fifo_rdn <= ( (uart_taskctrl_data_fifo_rdn<<8'd8) | uart_taskctrl_data_rvd_rdn );
            end

            
            8'd3: begin  //没什么好做的，下面这个是仅仅是占个位置而已
                LedTask_Data_Trigger_rfo <= LedTask_Data_Trigger_rfo;
            end

            //状态4， 开始给LED模块发送数据。
            8'd4: begin    //这里也可以根据接收到的数据，用case来做出判断给哪个人物模块一个脉冲
                LedTask_Data_rdo <= (uart_taskctrl_data_fifo_rdn >> ((LedTask_Data_Length_rdn-1'b1) << 8'd3));   //先发高位
                LedTask_Data_Length_rdn <= LedTask_Data_Length_rdn - 1'b1;
            end

            //这个脉冲上升沿是为了LedTask模块采样LedTask数据用的
            8'd5: begin   //这里也可以根据接收到的数据，用case来做出不同任务的单个bit接收的上升沿，
                LedTask_Data_Trigger_rfo <= 1'b1;   //单个bit接收完成脉冲上升沿
            end

            8'd6: begin
                LedTask_Data_Trigger_rfo <= 1'b0;   //单个bit接收完成脉冲下降沿
            end

            // 这个任务脉冲上升沿，是为了说明数据已经全部传送完毕用的
            8'd7: begin
                LedTask_Data_Done_rfo <= 1'b1;  //这里是一个包的内容都接收完毕，然后准备 包结束脉冲上升沿
            end

            8'd8: begin   
                LedTask_Data_Done_rfo <= 1'b0;   //这里是一个包的内容都接收完毕，然后准备 包结束脉冲下降沿
                String_To_Uart_Length <= 8'd3;   //这是因为OK\n是三个byte
            end

            8'd9: begin   //把OK\n顺序给uart_taskctrl_data_tobetxed_rdo， 然后依次发送， 这里先准备数据
                uart_taskctrl_data_tobetxed_rdo <= (String_To_Uart >> ((String_To_Uart_Length-1'b1) << 8'd3) );   //依次由高位向低位取8个bit
                String_To_Uart_Length <= String_To_Uart_Length - 1'b1;
            end

            8'd10: begin    //判断是否OK发送完成，通过检查发送的个数
                //准备好数据了，应当给一个tx发送脉冲。
                uart_taskctrl_trigger_rfo <= 1'b1;      //给一个发射脉冲上升沿
            end

            8'd11: begin   
                uart_taskctrl_trigger_rfo <= 1'b0;      //给一个发射脉冲下降沿
            end 
            
            8'd12: begin  //OK\n也发完了，开始清缓冲区，然后进入到状态0就行了
                uart_taskctrl_data_fifo_rdn <= 64'd0;
            end

            default: begin
                uart_taskctrl_data_fifo_rdn <= 64'd0;
            end

        endcase
    end
end        

endmodule


