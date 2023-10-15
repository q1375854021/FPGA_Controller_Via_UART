module Led_Task(
    input uart_ledtask_sys_clk_wsi,             //�����ȫ��ʱ��
    input uart_ledtask_sys_rstn_wsi,           //Ledģ���ȫ�ָ�λ

    input  [7:0] LedTask_Data_wdi,               //��LED����ģ�������
    input  LedTask_Data_Trigger_wfi,              //��LED���ݶ�ȡ������
    input  LedTask_Data_Done_wfi,              //��LED����ģ�鵱ǰ���������

    (*mark_debug="true"*)output reg Led_pin_rpo                           //����LED���������
    );


// �Ĵ��������ݵļĴ���
reg [7:0] LedTask_Data_rdn;                    //�����Ledģ�������
reg LedTask_Data_Trigger_rfn;                   //�����ledģ������ݵ�ͬ���ź�
reg LedTask_Data_Done_rfn;                     //�����ledģ�����ݵĵ�ǰ�������ź�

//״̬��
reg [7:0] ledtask_current_state_rfn;          //ledģ�鵱ǰ״̬
reg [7:0] ledtask_next_state_rfn;             //ledģ����һ��״̬

// ���ݻ�����
reg [63:0] ledtask_datafifo_rdn;             //���ݻ�������8��byte
(*mark_debug="true"*)reg [63:0] ledtask_data_analysis_buffer_rdn; //���ݻ�����Ӱ�ӼĴ����������ݽ�����Ϻ����ݻ��Զ��浽����Ĵ���

// �����ź� 
reg [7:0] ledtask_datacount_rdn;            //LEDģ����ռ���
reg ledtask_data_analysis_trigger_rdn;      //���ݽ�����ϣ���ʼ�������ݽ������ź�
(*mark_debug="true"*)reg Led_Data_error_rfn;                     //�������ź�




// �����źŴ�һ��
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


//״̬��


//  ״̬����һ�Σ�״̬�л�
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi)      //�����λ
        ledtask_current_state_rfn <= 8'd0;
    else
        ledtask_current_state_rfn <= ledtask_next_state_rfn;
end     
    
// ״̬���ڶ��Σ� ״̬ת��  ����߼�
always @(*) begin
    begin
        ledtask_next_state_rfn = 8'd0;
        case (ledtask_current_state_rfn)
            8'd0: begin                                     //��ʼ״̬���ȴ� LedTask_Data_Trigger_rfn=1 ʱ���Ͷ�ȡ����
                if(LedTask_Data_Trigger_rfn == 1'b1)    //LedTask_Data_Trigger����, ��ȡ����
                    ledtask_next_state_rfn = 8'd1;  
                else
                    ledtask_next_state_rfn = 8'd0;
            end

            8'd1: begin
                if(LedTask_Data_Done_rfn == 8'd1)       //���һ���������ݶ�ȡ���ˣ���ô��ת�Ƶ�״̬2׼��һЩ�����ź�
                    ledtask_next_state_rfn = 8'd2;
                else
                    ledtask_next_state_rfn = 8'd1;     
            end

            8'd2: begin   //׼��һЩ�����ź�
                ledtask_next_state_rfn = 8'd3;    
            end

            8'd3: begin  //׼�������ź�
                ledtask_next_state_rfn = 8'd0;   
            end

            default: begin
                ledtask_next_state_rfn = 8'd0;
            end



        endcase
    end
end


// ״̬�������Σ� ��������
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi) begin     //�����λ����ûʹ��
        ledtask_datacount_rdn <= 8'd0;       //ledģ�����ݼ���
        ledtask_datafifo_rdn <= 64'd0;       //ledģ�����ݻ�����   �൱��һ��FIFO
        ledtask_data_analysis_buffer_rdn <= 64'd0;        //Ӱ�ӼĴ������������Ļ�����
        ledtask_data_analysis_trigger_rdn <= 1'b0;        //��ʼ�������ݽ������ź�
    end
    else begin
        case (ledtask_next_state_rfn) 
            8'd0: begin                    //��ʼ״̬,ûʲôҪ���ģ����дһ��ռλ��
                ledtask_datacount_rdn <= 8'd0;       //ledģ�����ݼ���
                ledtask_datafifo_rdn <= 64'd0;       //ledģ�����ݻ�����   �൱��һ��FIFO
                ledtask_data_analysis_buffer_rdn <= 64'd0;        //Ӱ�ӼĴ������������Ļ�����
                ledtask_data_analysis_trigger_rdn <= 1'b0;        //��ʼ�������ݽ������ź�
            end

            8'd1: begin
                if(LedTask_Data_Trigger_rfn == 1'b1) begin
                    ledtask_datafifo_rdn <= ( (ledtask_datafifo_rdn << 8'd8) | LedTask_Data_rdn);       //����˳��洢
                    ledtask_datacount_rdn <= ledtask_datacount_rdn + 1'b1;
                end
                else
                    ledtask_datafifo_rdn <= ledtask_datafifo_rdn;            
            end

            8'd2: begin      //��ʱ���ݶ��Ѿ�������ϣ���ʼ����һЩ�����ź�
                ledtask_data_analysis_buffer_rdn <= ledtask_datafifo_rdn;       //���浽Ӱ�ӼĴ�����Ȼ��ͨ��Ӱ�ӼĴ�����������
            end

            8'd3: begin
                ledtask_data_analysis_trigger_rdn <= 1'b1;        //һ����־��  ��1��ζ�ſ��Խ������ݽ����� ׼��һ������
                ledtask_datacount_rdn <= 8'd0;
            end

            default: begin  //û���ر�Ҫ�ŵģ�����һ��
                ledtask_data_analysis_trigger_rdn <= 1'b0;        //���ݽ��������־��0
            end

        endcase
    end
end        

// ���ݽ�����
// �����ĸ�ʽΪ 01        xx    xx    xx    xx    xx    xx    10
//             LED����   data  data  data  data  data  data  ��β�� ֻ���������β������һ��ģ�����У��
always @(posedge uart_ledtask_sys_clk_wsi or negedge uart_ledtask_sys_rstn_wsi) begin
    if(!uart_ledtask_sys_rstn_wsi) begin     //�����λ����ûʹ��
        Led_pin_rpo <= 1'd1;                //Ĭ��LED�����
        Led_Data_error_rfn <= 1'b0;              //���������ź�
    end
    else begin
        if(ledtask_data_analysis_trigger_rdn == 1'b0) begin
            Led_pin_rpo <= Led_pin_rpo;
        end
        else begin
            case(ledtask_data_analysis_buffer_rdn[63:56])    //��һλ
                8'd1: begin
                    case(ledtask_data_analysis_buffer_rdn[55:48])   //�ڶ�λ
                        8'd0: Led_pin_rpo <= 1'd1;        //��
                        8'd1: Led_pin_rpo <= 1'd0;        //��
                        default: Led_pin_rpo <= Led_pin_rpo;
                    endcase
                end

                default: Led_Data_error_rfn <= 1'b1;      //������
            endcase
        end
                            
    end
end


endmodule
