module Led_Task(
    input uart_ledtask_sys_clk_wsi,             //输入的全局时钟
    input uart_ledtask_sys_rstn_wsi,           //Led模块的全局复位

    input  [7:0] LedTask_Data_wdi,               //给LED控制模块的命令
    input  LedTask_Data_Trigger_wfi,              //给LED数据读取的脉冲
    input  LedTask_Data_Done_wfi,              //给LED控制模块当前包接收完毕

    (*mark_debug="true"*)output reg Led_pin_rpo                           //连接LED的输出引脚
    );


// 寄存输入数据的寄存器
reg [7:0] LedTask_Data_rdn;                    //输入进Led模块的数据
reg LedTask_Data_Trigger_rfn;                   //输入进led模块的数据的同步信号
reg LedTask_Data_Done_rfn;                     //输入进led模块数据的当前包结束信号

//状态机
reg [7:0] ledtask_current_state_rfn;          //led模块当前状态
reg [7:0] ledtask_next_state_rfn;             //led模块下一个状态

// 数据缓冲区
reg [63:0] ledtask_datafifo_rdn;             //数据缓冲区，8个byte
(*mark_debug="true"*)reg [63:0] ledtask_data_analysis_buffer_rdn; //数据缓冲区影子寄存器，当数据接收完毕后数据会自动存到这个寄存器

// 辅助信号 
reg [7:0] ledtask_datacount_rdn;            //LED模块接收计数
reg ledtask_data_analysis_trigger_rdn;      //数据接收完毕，开始进行数据解析的信号
(*mark_debug="true"*)reg Led_Data_error_rfn;                     //包错误信号




// 输入信号打一下
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi) begin
        LedTask_Data_rdn <= 8'd0;
        LedTask_Data_Trigger_rfn <= 1'b0;
        LedTask_Data_Done_rfn <= 1'b0;

        end
    else begin
        LedTask_Data_rdn <= LedTask_Data_wdi;
        LedTask_Data_Trigger_rfn <= LedTask_Data_Trigger_wfi;
        LedTask_Data_Done_rfn <= LedTask_Data_Done_wfi;  
    end
end


//状态机


//  状态机第一段，状态切换
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi)      //如果复位
        ledtask_current_state_rfn <= 8'd0;
    else
        ledtask_current_state_rfn <= ledtask_next_state_rfn;
end     
    
// 状态机第二段， 状态转移  组合逻辑
always @(*) begin
    begin
        ledtask_next_state_rfn = 8'd0;
        case (ledtask_current_state_rfn)
            8'd0: begin                                     //初始状态，等待 LedTask_Data_Trigger_rfn=1 时，就读取数据
                if(LedTask_Data_Trigger_rfn == 1'b1)    //LedTask_Data_Trigger来了, 读取数据
                    ledtask_next_state_rfn = 8'd1;  
                else
                    ledtask_next_state_rfn = 8'd0;
            end

            8'd1: begin
                if(LedTask_Data_Done_rfn == 8'd1)       //如果一个包的数据读取完了，那么就转移到状态2准备一些辅助信号
                    ledtask_next_state_rfn = 8'd2;
                else
                    ledtask_next_state_rfn = 8'd1;     
            end

            8'd2: begin   //准备一些辅助信号
                ledtask_next_state_rfn = 8'd3;    
            end

            8'd3: begin  //准备辅助信号
                ledtask_next_state_rfn = 8'd0;   
            end

            default: begin
                ledtask_next_state_rfn = 8'd0;
            end



        endcase
    end
end


// 状态机第三段， 任务驱动
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi) begin     //如果复位或者没使能
        ledtask_datacount_rdn <= 8'd0;       //led模块数据计数
        ledtask_datafifo_rdn <= 64'd0;       //led模块数据缓冲区   相当于一个FIFO
        ledtask_data_analysis_buffer_rdn <= 64'd0;        //影子寄存器，缓冲区的缓冲区
        ledtask_data_analysis_trigger_rdn <= 1'b0;        //开始进行数据解析的信号
    end
    else begin
        case (ledtask_next_state_rfn) 
            8'd0: begin                    //初始状态,没什么要做的，随便写一点占位置
                ledtask_datacount_rdn <= 8'd0;       //led模块数据计数
                ledtask_datafifo_rdn <= 64'd0;       //led模块数据缓冲区   相当于一个FIFO
                ledtask_data_analysis_buffer_rdn <= 64'd0;        //影子寄存器，缓冲区的缓冲区
                ledtask_data_analysis_trigger_rdn <= 1'b0;        //开始进行数据解析的信号
            end

            8'd1: begin
                if(LedTask_Data_Trigger_rfn == 1'b1) begin
                    ledtask_datafifo_rdn <= ( (ledtask_datafifo_rdn << 8'd8) | LedTask_Data_rdn);       //按照顺序存储
                    ledtask_datacount_rdn <= ledtask_datacount_rdn + 1'b1;
                end
                else
                    ledtask_datafifo_rdn <= ledtask_datafifo_rdn;            
            end

            8'd2: begin      //此时数据都已经缓冲完毕，开始完善一些辅助信号
                ledtask_data_analysis_buffer_rdn <= ledtask_datafifo_rdn;       //缓存到影子寄存器，然后通过影子寄存器解析数据
            end

            8'd3: begin
                ledtask_data_analysis_trigger_rdn <= 1'b1;        //一个标志，  置1意味着可以进行数据解析， 准备一个脉冲
                ledtask_datacount_rdn <= 8'd0;
            end

            default: begin  //没有特别要放的，随便放一点
                ledtask_data_analysis_trigger_rdn <= 1'b0;        //数据解析允许标志置0
            end

        endcase
    end
end        

// 数据解析，
// 解析的格式为 01        xx    xx    xx    xx    xx    xx    10
//             LED任务   data  data  data  data  data  data  包尾， 只不过这个包尾是在上一个模块进行校验
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi) begin     //如果复位或者没使能
        Led_pin_rpo <= 1'd1;                //默认LED是灭的
        Led_Data_error_rfn <= 1'b0;              //解析错误信号
    end
    else begin
        if(ledtask_data_analysis_trigger_rdn == 1'b0) begin
            Led_pin_rpo <= Led_pin_rpo;
        end
        else begin
            case(ledtask_data_analysis_buffer_rdn[63:56])    //第一位
                8'd1: begin
                    case(ledtask_data_analysis_buffer_rdn[55:48])   //第二位
                        8'd0: Led_pin_rpo <= 1'd1;        //关
                        8'd1: Led_pin_rpo <= 1'd0;        //开
                        default: Led_pin_rpo <= Led_pin_rpo;
                    endcase
                end

                default: Led_Data_error_rfn <= 1'b1;      //出错了
            endcase
        end
                            
    end
end


endmodule
