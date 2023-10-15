// 命名规则  模块_功能_abc
// a:  w:wire   r:reg
// b: s:system, d:data  ,f:flag, 
// c: i:input,  o:otuput, n: internal
// 没有abc代表IO信号

module UART_TX#(
        parameter Baudrate = 32'd115200,       //波特率
        parameter Uart_sysclk = 32'd100_000_000    //输入时钟100MHz
    )
    (
    input uart_sys_clk_wsi,             //uart模块全局时钟
    input uart_sys_rstn_wsi,            //uart全局复位
    
    input [7:0] uart_data_tobetxed_wdi,   //uart要发送出去的数据
    output reg uart_tx_done_rfo,        //tx完毕信号                   //脉冲
    input uart_tx_trigger_wfi,          //tx任务触发信号               //脉冲
    output reg uart_tx_busy_rfo,        //tx忙信号，正在发送           //电平

    
    output reg uart_tx                      //输出全局信号

    );


parameter Baud_clkcount = Uart_sysclk/Baudrate;    //在这个波特率下需要技术的时钟个数


reg [7:0] uart_tx_current_state_rfn;     //当前状态
reg [7:0] uart_tx_next_state_rfn;      //下一状态

reg [31:0] uart_clk_cnt_rfn;         //用于分频计数
reg [7:0] Baud_State_count;         //用于计数分频计数的计数， 用于状态判断


reg [7:0] uart_data_tobetxed_rdi;   //uart要发送出去的数据
reg uart_tx_trigger_rfi;          //tx任务触发信号


// 输入信号打一下
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin
        uart_data_tobetxed_rdi <= 8'd0;
        uart_tx_trigger_rfi <= 1'b0;
        end
    else begin
        uart_data_tobetxed_rdi <= uart_data_tobetxed_wdi;
        uart_tx_trigger_rfi <= uart_tx_trigger_wfi;      
    end
end
   


//  状态机第一段，状态切换
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi)      //如果复位或者没使能
        uart_tx_current_state_rfn <= 8'd0;
    else
        uart_tx_current_state_rfn <= uart_tx_next_state_rfn;
end     
    
// 状态机第二段， 状态转移  组合逻辑
always @(*) begin
    begin
        uart_tx_next_state_rfn = 8'd0;
        case (uart_tx_current_state_rfn)
            8'd0: begin
                if(uart_tx_trigger_rfi == 1'b1)          //如果tx_trigger来了一个脉冲，就准备发送数据了   //这里先计数一个时钟，准备busy信号
                    uart_tx_next_state_rfn = 8'b1;       //转移到下一状态
                else
                    uart_tx_next_state_rfn = 8'b0;        //没来就继续等待
            end

            8'd1: begin
                uart_tx_next_state_rfn = 8'd2;           // 准备busy信号，然后就开始按波特率周期计数了
            end

            8'd2: begin
                if(Baud_State_count == 8'd11)            //计数直到11   这里都是按波特率周期计数，然后发送单个bit
                    uart_tx_next_state_rfn = 8'd3;
                else
                    uart_tx_next_state_rfn = 8'd2;       //否则就继续按波特率周期计数
            end

            8'd3: begin
                if(Baud_State_count >= 8'd13)             //计数直到13 记数间隔为一个时钟周期，然后准备结束信号，如done和busy
                    uart_tx_next_state_rfn = 8'd0;
                else
                    uart_tx_next_state_rfn = 8'd3;       //否则维持原样
            end
            default: uart_tx_next_state_rfn = 8'd0;       //回到初始状态
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
        case (uart_tx_next_state_rfn) 
            8'd0: begin     //状态0，未开始
                uart_clk_cnt_rfn <= 32'd0;
                Baud_State_count <= 8'd0;
            end

            8'd1: begin    //状态1，这里是按时钟周期计数的，准备 busy信号
                    uart_clk_cnt_rfn <= 32'd0;       
                    Baud_State_count <= Baud_State_count + 1'b1;
            end

            8'd2: begin
                if(uart_clk_cnt_rfn < Baud_clkcount)   //然后开始按波特计数，准备发送数据
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;   //开始计数
                else begin
                    uart_clk_cnt_rfn <= 32'd0;       //计数结束后停止
                    Baud_State_count <= Baud_State_count + 1'b1;   //自加
                end
            end

            8'd3: begin
                    uart_clk_cnt_rfn <= 32'd0;       //这里是按时钟周期计数，然后准备收尾信号，如busy和done，然后没啥了
                    Baud_State_count <= Baud_State_count + 1'b1;
            end

            default: begin
                uart_clk_cnt_rfn <= 32'd0;
                Baud_State_count <= 8'd0;
            end

        endcase
    end
end            


always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin     //如果复位或者没使能
        uart_tx_done_rfo <= 1'b0;       //tx 传输完毕
        uart_tx_busy_rfo <= 1'b0;       // 传输忙
        uart_tx <= 1'b1;               // 高电平
    end 
    else begin 
        case(Baud_State_count)
            8'd0: begin
                uart_tx_done_rfo <= 1'b0;       //tx 传输完毕
                uart_tx_busy_rfo <= 1'b0;       // 传输忙
                uart_tx <= 1'b1;               // 高电平
            end
            8'd1: begin
                uart_tx_busy_rfo <= 1'b1;    //开始忙起来了
                uart_tx <= 1'b0;             //起始位信号
            end
            8'd2: uart_tx <= uart_data_tobetxed_rdi[0];   //发送bit0
            8'd3: uart_tx <= uart_data_tobetxed_rdi[1];   //发送bit1
            8'd4: uart_tx <= uart_data_tobetxed_rdi[2];   //发送bit2
            8'd5: uart_tx <= uart_data_tobetxed_rdi[3];   //发送bit3
            8'd6: uart_tx <= uart_data_tobetxed_rdi[4];   //发送bit4
            8'd7: uart_tx <= uart_data_tobetxed_rdi[5];   //发送bit5
            8'd8: uart_tx <= uart_data_tobetxed_rdi[6];   //发送bit6
            8'd9: uart_tx <= uart_data_tobetxed_rdi[7];   //发送bit7
            8'd10:uart_tx <= 1'b1;   //停止位
            8'd11: begin          
                uart_tx <= 1'b1;   //停止位结束
            end
            8'd12: begin
                uart_tx_busy_rfo <= 1'b0;   //拉低busy
            end
            8'd13: begin
                uart_tx_done_rfo <= 1'b1;    //拉高done
            end
            8'd14: begin
                uart_tx_done_rfo <= 1'b0;      //拉低done
            end
            default: begin
                uart_tx_done_rfo <= 1'b0;       //tx 传输完毕
                uart_tx_busy_rfo <= 1'b0;       // 传输忙
                uart_tx <= 1'b1;               // 高电平
            end
        endcase
    end
end



    
endmodule





/*
//目前这些都没用到
parameter Stopbits = 8'd1;             //一个停止位
parameter Databits = 8'd8;             //八个数据位
parameter Checkbits = 8'd0;            //0代表无校验
*/ 

