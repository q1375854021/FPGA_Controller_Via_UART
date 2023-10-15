
module UART_RX #(
        parameter Baudrate = 32'd115200,           //波特率
        parameter Uart_sysclk = 32'd100_000_000    //输入时钟100MHz
    )
    (
    input uart_sys_clk_wsi,             //uart模块全局时钟
    input uart_sys_rstn_wsi,            //uart全局复位

    input uart_rx,                        //输入全局信号
    output reg [7:0] uart_data_rxed_rdo,  //uart接收到的数据           
    output reg uart_rx_done_rfo,         //uart发送完毕信号           //脉冲
    output reg uart_rx_busy_rfo         //uart正在接收信号           //电平

    );

// 把所有信号的准备好

parameter Baud_clkcount = Uart_sysclk/Baudrate;    //在这个波特率下需要技术的时钟个数

// uart_rx边沿检测
reg uart_rx_rfn1;         
reg uart_rx_rfn2; 

// 状态机
reg [7:0] uart_rx_current_state_rfn;     //当前状态
reg [7:0] uart_rx_next_state_rfn;      //下一状态

// uart_rx检测到下降沿
wire uart_rx_trig_wfn;        //有毛刺也没有影响，最后会进同步电路
assign uart_rx_trig_wfn = (~uart_rx_rfn1)&uart_rx_rfn2 ;   //应当会有一个高脉冲，不知道会不会有毛刺，但只需要第一个脉冲即可,状态机应当没问题

// 用来计数
reg [31:0] uart_clk_cnt_rfn;   //用来计数
(*mark_debug="true"*)reg [7:0] Baud_State_count;   //用来计数的计数


// 边沿检测
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin
        uart_rx_rfn1 <= 1'b1;
        uart_rx_rfn2 <= 1'b1;
    end
    else begin
        uart_rx_rfn1 <= uart_rx;
        uart_rx_rfn2 <= uart_rx_rfn1;
    end
end

//状态机

//  状态机第一段，状态切换
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi)      //如果复位
        uart_rx_current_state_rfn <= 8'd0;
    else
        uart_rx_current_state_rfn <= uart_rx_next_state_rfn;
end     
    
// 状态机第二段， 状态转移  组合逻辑
always @(*) begin
    begin
        uart_rx_next_state_rfn = 8'd0;
        case (uart_rx_current_state_rfn)  
            8'd0: begin
                if(uart_rx_trig_wfn == 1'b1)           //如果rx_trigger来了一个脉冲,证明检测到了rx的下降沿，开始准备接收数据
                    uart_rx_next_state_rfn = 8'd1;       //转移到下一状态
                else
                    uart_rx_next_state_rfn = 8'b0;     //没来就继续等待
            end

            8'd1: begin        //准备起始信号 busy
                uart_rx_next_state_rfn <= 8'd2;   
            end

            8'd2: begin           //计数半个波特率周期, 计数
                if(Baud_State_count==8'd2)   //顺便检测一下是否起始位为0
                    uart_rx_next_state_rfn = 8'd3;
                else
                    uart_rx_next_state_rfn = 8'd2;        //没有的话就继续自加
            end

            8'd3: begin   //用于起始位检测的临时状态
                if(uart_rx_rfn1 == 1'b0)
                    uart_rx_next_state_rfn = 8'd4;    //进行起始位检测
                else
                    uart_rx_next_state_rfn = 8'd0;    //没检测到起始位，就回到状态0
            end

            8'd4: begin
                if(Baud_State_count == 8'd10)   //计数到最后一个bit
                    uart_rx_next_state_rfn = 8'd5;
                else
                    uart_rx_next_state_rfn = 8'd4;
            end
            
            8'd5: begin
                if(Baud_State_count == 8'd11)   //计数到停止中间，否则就继续计数
                    uart_rx_next_state_rfn = 8'd6;
                else
                    uart_rx_next_state_rfn = 8'd5;
            end

            8'd6: begin   //用于结束位检测的临时状态
                if(uart_rx_rfn1 == 1'b1)
                    uart_rx_next_state_rfn = 8'd7;    //进行终止位检测。
                else
                    uart_rx_next_state_rfn = 8'd0;    //没检测到起始位，就回到状态0
            end

            8'd7: begin
                if(Baud_State_count >= 8'd14)   //单个时钟计数，准备一些结束信号
                    uart_rx_next_state_rfn = 8'd8;
                else
                    uart_rx_next_state_rfn = 8'd7;
            end

            8'd8: uart_rx_next_state_rfn = 8'd0;

            default:  uart_rx_next_state_rfn = 8'd0;
        endcase
    end
end

                

// 状态机第三段， 任务驱动
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin     //如果复位或者没使能
        uart_clk_cnt_rfn <= 32'd0;
        Baud_State_count <= 8'd0;
    end
    else begin
        case (uart_rx_next_state_rfn) 
            8'd0: begin     //状态0，未开始
                uart_clk_cnt_rfn <= 32'd0;
                Baud_State_count <= 8'd0;
            end
            8'd1: begin
                Baud_State_count <= Baud_State_count + 1'b1;    //在count为1时进行busy置1
            end
            8'd2: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount)>>8'd1)    begin   //计数半个波特率周期后停止  计数到2
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd3: Baud_State_count <= Baud_State_count;   //用于状态检测的临时状态，没有啥特别要做的

            8'd4: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount))    begin   //计数一个波特率周期后停止  计数到每个bit的中间读取数据，然后一直计数到10
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd5: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount))    begin   //计数一个波特率周期后停止 计数到停止位中间，可以调整计数周期，来适应不同的终止位bit
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd6: Baud_State_count <= Baud_State_count;   //用于状态检测的临时状态，没有啥特别要做的

            8'd7: begin
                Baud_State_count <= Baud_State_count + 1'b1;
            end

            8'd8: begin   //这里已经全部结束了
                Baud_State_count <= 8'd0;
            end

            default: begin
                Baud_State_count <= 8'd0;
            end

        endcase
    end
end            

// 然后根据Baud_State_Count进行信号读取
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin     //如果复位或者没使能
        uart_rx_done_rfo <= 1'b0;       //tx 传输完毕
        uart_rx_busy_rfo <= 1'b0;       // 传输忙
        uart_data_rxed_rdo <= 8'd0;     //默认是0
    end 
    else begin
        case(Baud_State_count)
            8'd0: begin                        //还没开始
                uart_rx_done_rfo <= 1'b0;       //tx 传输完毕
                uart_rx_busy_rfo <= 1'b0;       // 传输忙
            end

            8'd1: begin     //读取起始位  
                uart_rx_busy_rfo <= 1'b1;        //rx_busy置1
            end

            8'd2: begin   //这里起始只是用来判断状态转移的临时状态，随便写个语句占位
                uart_rx_busy_rfo <= uart_rx_busy_rfo;      
            end

            8'd3: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[0] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[0] <= uart_data_rxed_rdo[0];
            end
            
            8'd4: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[1] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[1] <= uart_data_rxed_rdo[1];
            end
            
            8'd5: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[2] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[2] <= uart_data_rxed_rdo[2];
            end
            
            8'd6: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[3] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[3] <= uart_data_rxed_rdo[3];
            end
            
            8'd7: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[4] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[4] <= uart_data_rxed_rdo[4];
            end
            
            8'd8: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[5] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[5] <= uart_data_rxed_rdo[5];
            end

            8'd9: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[6] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[6] <= uart_data_rxed_rdo[6];
            end
            
            8'd10: begin
                if(uart_clk_cnt_rfn == 0)        //仅读取一次
                    uart_data_rxed_rdo[7] <= uart_rx;          //读取第n位
                else
                    uart_data_rxed_rdo[7] <= uart_data_rxed_rdo[7];
            end

            8'd11: begin             //用于状态转移判断的临时状态，
                uart_rx_busy_rfo <= uart_rx_busy_rfo;   //不做处理
            end

            8'd12: begin                       //先把busy拉下来
                uart_rx_busy_rfo <= 1'b0;
            end

            8'd13: begin                      //done拉高
                uart_rx_done_rfo <= 1'b1;
            end

            8'd14: begin                     //done拉低，形成一个脉冲
                uart_rx_done_rfo <= 1'b0;
            end

            default: begin   //其它
                uart_rx_done_rfo <= 1'b0;       //tx 传输完毕
                uart_rx_busy_rfo <= 1'b0;       // 传输忙
                uart_data_rxed_rdo <= 8'd0;     //默认是0
            end

        endcase
    end

end

endmodule
