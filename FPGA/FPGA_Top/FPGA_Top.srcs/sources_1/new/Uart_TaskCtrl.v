module Uart_TaskCtrl(
    input uart_taskctrl_sys_clk_wsi,             //�����ȫ��ʱ��
    input uart_taskctrl_sys_rstn_wsi,           //����ģ���ȫ�ָ�λ
    input uart_taskctrl_en_wsi,                 //ģ��ʹ���ź�

    (*mark_debug="true"*)input [7:0] uart_taskctrl_data_rvd_wdi,           //��ȡ���ڽ��յ�������
    (*mark_debug="true"*)input uart_takactrl_rx_done_wfi,                //�����������
    (*mark_debug="true"*)input uart_taskctrl_rx_busy_wfi,                //����æ��Ҳ����û������

    (*mark_debug="true"*)output reg [7:0] uart_taskctrl_data_tobetxed_rdo,  //Ҫ�ô��ڷ��ͳ�ȥ������
    (*mark_debug="true"*)output reg uart_taskctrl_trigger_rfo,              //Ҫ�ô��ڷ��ͳ�ȥ�����ݵ����������ź�
    (*mark_debug="true"*)input uart_taskctrl_tx_busy_wfi,                   //����æ�ı�־
    (*mark_debug="true"*)input uart_taskctrl_tx_done_wfi,                  //���ڷ�����ϵı�־

    (*mark_debug="true"*)output reg [7:0] LedTask_Data_rdo,               //��LED����ģ�������
    (*mark_debug="true"*)output reg LedTask_Data_Trigger_rfo,              //��LED���ݶ�ȡ������
    (*mark_debug="true"*)output reg LedTask_Data_Done_rfo              //��LED����ģ�������trigger   
    );

//  ���ݳ��ȶ���
parameter LedTask_Data_Length = 8'd8;    //��LED�����ݰ��̶���8���ֽ�
parameter uart_taskctrl_data_tobetxed = 8'd3;   //���ڻظ���OK\n�ĳ���

//״̬���Ĵ���
reg [7:0] uart_taskctrl_current_state_rfn;        //��ǰ״̬
reg [7:0] uart_taskctrl_next_state_rfn;           //��һ��״̬


reg uart_taskctrl_en_rsn;                        //ʹ���ź�
reg [7:0] uart_taskctrl_data_rvd_rdn;            //�Ӵ��ڶ�ȡ��������
reg uart_takactrl_rx_done_rfn;                  //������������ź�
reg uart_taskctrl_rx_busy_rfn;                  //����æ�ź�
reg uart_taskctrl_tx_busy_rfn;                  //����æ�ź�
reg uart_taskctrl_tx_done_rfn;                  //��������ź�

// ���崮�ڻ�����
reg [8*8-1 : 0] uart_taskctrl_data_fifo_rdn;     //���ڵĻ���������100��byte
reg [7:0] LedTask_Data_Length_rdn;                //LEDTaskҪ���͵����ݳ��ȣ���ʱ�洢һ��

reg [5*8:1] String_To_Uart;             //�����ŷ��͵����ڵ��ַ�����
reg [7:0] String_To_Uart_Length;        //�洢Ҫ���͵Ĵ���

assign uart_taskctrl_rx_ready_wfn = (~uart_taskctrl_rx_busy_rfn) & uart_takactrl_rx_done_rfn;  //���û���һ�������壬�����������Ϳ����ж��Ƿ�������


// �������źŴ�һ�£�ȥ���źŶ�����ë��
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi)   begin    //�����λ
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


//״̬��

//  ״̬����һ�Σ�״̬�л�
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi)      //�����λ
        uart_taskctrl_current_state_rfn <= 8'd0;
    else
        uart_taskctrl_current_state_rfn <= uart_taskctrl_next_state_rfn;
end     

// ״̬���ڶ��Σ� ״̬ת��  ����߼�
always @(*) begin
    begin
        uart_taskctrl_next_state_rfn = 8'd0;
        case (uart_taskctrl_current_state_rfn)
            8'd0: begin
                if(uart_taskctrl_en_rsn == 1'b1)           //������ܣ������ģ����ʹ��״̬�����뵽�ȴ������ź�����״̬
                    uart_taskctrl_next_state_rfn = 8'd1;      //ʹ��״̬��׼�����մ�������
                else
                    uart_taskctrl_next_state_rfn = 8'd0;      //ûʹ���������
            end

            8'd1: begin
                if(uart_taskctrl_rx_ready_wfn == 1'b1)         //��������׼����ϣ���ô��׼����ȡ���ݵ�������
                    uart_taskctrl_next_state_rfn = 8'd2;      // �ѴӴ����յ������ݴ浽��������
                else
                    uart_taskctrl_next_state_rfn = 8'd1;      // ��������û׼���þͼ�����
            end

            //״̬2�� �յ����м���ת����״̬3 -> ˵�����հ�����  �����������
            8'd2: begin
                if(uart_taskctrl_data_rvd_rdn == 8'h10)    //���Ľ�β�̶���0x10,Ҳ���ǻ��м���  һ�����˸�byte�����һ��byteΪ10��
                    uart_taskctrl_next_state_rfn = 8'd3;    
                else
                    uart_taskctrl_next_state_rfn = 8'd1;    //Ҫ��Ȼ�ͻص�״̬1����Ϊû���յ����м���˵�����ݻ�û�н�����ϣ��������ؽ���
            end

            //  ת�Ƶ�״̬4
            // LED��Ӧ�İ��� 01 xx xx xx xx xx xx 10    01���� LED�������֧��256������ ���һ���ǰ�Χ���̶���10
            8'd3: begin  
                if(uart_taskctrl_data_fifo_rdn[63:56] == 8'd01)   //����Ҳ������case���ֳ������֧���ֱ���ת����ͬ������
                    uart_taskctrl_next_state_rfn = 8'd4;   //LED������������ͬʱ׼�����˸�LED���������
                else
                    uart_taskctrl_next_state_rfn = 8'd12;   //���ݲ���Ӧ���������������,��ʵû�н����κβ�����ֻ��״̬�ص���״̬0���ѣ������������Ūһ�¡�
            end

            8'd4: begin    //���ﴮ�ڵ����������Ѿ�ȫ��������ϣ������жϳ�����LEDģ������ݲ���׼������, Ȼ���ü���״̬׼��һЩͬ���źź͸����ź�
                uart_taskctrl_next_state_rfn <= 8'd5;     
            end

            8'd5: begin    //��Ȼ��׼�������ź�
                uart_taskctrl_next_state_rfn <= 8'd6;    //�����½���
            end

            8'd6: begin   //����Ӧ�����ж��Ƿ������
                if(LedTask_Data_Length_rdn == 8'd0)   //��������֮�󣬾�ת�Ƶ���һ״̬�� ����һ����������ϵ��źŸ�ֵ
                    uart_taskctrl_next_state_rfn = 8'd7;       //������ݷ��������
                else
                    uart_taskctrl_next_state_rfn = 8'd4;      //���򻹵ûص�״̬������׼������
            end

            8'd7: begin         //�Ա�ʾ  ���������ź�������д��� 
                uart_taskctrl_next_state_rfn = 8'd8;        //׼��Task����
            end

            8'd8: begin     //��Ȼ�ǶԱ�ʾ  ���������ź�������д��� 
                uart_taskctrl_next_state_rfn = 8'd9;      //׼��Task�����½���
            end


            8'd9: begin       //����������׼����Ϻ�һ��Ĭ����һ֡����û���⣬Ȼ���򴮿ڻط�һ�� OK\n����  �����OK\n�Ǵ��з��� ��O K \n
                uart_taskctrl_next_state_rfn = 8'd10;    //��ʼ����OK\n  ׼����������
            end

            8'd10: begin    //Ȼ�������ģ��һ������ʹ������ 
                uart_taskctrl_next_state_rfn = 8'd11;
            end

            8'd11: begin  //�ȴ�OK\n�������
                if(String_To_Uart_Length == 8'd0 && uart_taskctrl_tx_done_rfn == 1'b1)   //���������ϲ��ҷ������
                    uart_taskctrl_next_state_rfn = 8'd12;   // �ȴ�OK\n������ϣ�Ȼ��ͽ�����һ״̬�� ����Ĵ�����һЩ������Ȼ��׼����һ��
                else if(uart_taskctrl_tx_done_rfn == 1'b1)   //���������ϵ��ǲ�û����ȫ������
                    uart_taskctrl_next_state_rfn = 8'd9;   // ����ĳһ���ַ�������ɣ����ǲ�û��ȫ�����꣬�ص�״̬9������
                else
                    uart_taskctrl_next_state_rfn = 8'd11;   //��������ǣ��ͼ�����
            end 

            8'd12: begin  //�建��������Ĵ����ȵȣ�����֮��ص�״̬0
                uart_taskctrl_next_state_rfn = 8'd0;  
            end

            default: begin
              uart_taskctrl_next_state_rfn = 8'd0;
            end

        endcase
    end
end


// ״̬�������Σ� ��������
always @(posedge uart_taskctrl_sys_clk_wsi or negedge uart_taskctrl_sys_rstn_wsi) begin
    if(!uart_taskctrl_sys_rstn_wsi) begin     //�����λ����ûʹ��
        uart_taskctrl_trigger_rfo <= 1'b0;       //�����ڵ�ʹ�ܷ�������
        LedTask_Data_rdo <= 8'd0;               //���͸�LEDģ�������
        LedTask_Data_Trigger_rfo <= 1'd0;       //LED����trigger
        LedTask_Data_Done_rfo <= 1'b0;       //LED����trigger
        uart_taskctrl_data_fifo_rdn <= 64'd0;   //�������Զ�����
        uart_taskctrl_data_tobetxed_rdo <= uart_taskctrl_data_tobetxed;    //Ҫͨ�����ڷ��͵���Ƭ����ֵ
        LedTask_Data_Length_rdn <= LedTask_Data_Length;       //Ҫ���͵����ݳ��� ��ʱ�Ĵ���
        String_To_Uart <= "OK\n";
    end
    else begin
        case (uart_taskctrl_next_state_rfn) 
            8'd0: begin   //״̬0�� ��׼����ʼ�ź�
                uart_taskctrl_trigger_rfo <= 1'b0;       //�����ڵ�ʹ�ܷ�������
                LedTask_Data_rdo <= 8'd0;               //���͸�LEDģ�������
                LedTask_Data_Trigger_rfo <= 1'd0;       //LED����trigger
                LedTask_Data_Done_rfo <= 1'b0;       //LED����trigger
                uart_taskctrl_data_fifo_rdn <= 64'd0;   //�������Զ�����
                uart_taskctrl_data_tobetxed_rdo <= uart_taskctrl_data_tobetxed;    //Ҫͨ�����ڷ��͵���Ƭ����ֵ
                LedTask_Data_Length_rdn <= LedTask_Data_Length;       //Ҫ���͵����ݳ��� ��ʱ�Ĵ���
                String_To_Uart <= "OK\n";
            end

            8'd1: begin  //û��Ҫ���ģ����д�����ռλ��
                LedTask_Data_Trigger_rfo <= LedTask_Data_Trigger_rfo;
            end
            
            //״̬2��Ӧ���ѴӴ���ģ����յ������ݻ���������
            //uart_taskctrl_data_rvd_rdn��  �Ӵ��ڽ��ܵ�������
            //uart_taskctrl_data_fifo_rdn   ���ڻ�����
            8'd2: begin  //�Ѵ��ڶ��������ݴ浽������ 
                uart_taskctrl_data_fifo_rdn <= ( (uart_taskctrl_data_fifo_rdn<<8'd8) | uart_taskctrl_data_rvd_rdn );
            end

            
            8'd3: begin  //ûʲô�����ģ���������ǽ�����ռ��λ�ö���
                LedTask_Data_Trigger_rfo <= LedTask_Data_Trigger_rfo;
            end

            //״̬4�� ��ʼ��LEDģ�鷢�����ݡ�
            8'd4: begin    //����Ҳ���Ը��ݽ��յ������ݣ���case�������жϸ��ĸ�����ģ��һ������
                LedTask_Data_rdo <= (uart_taskctrl_data_fifo_rdn >> ((LedTask_Data_Length_rdn-1'b1) << 8'd3));   //�ȷ���λ
                LedTask_Data_Length_rdn <= LedTask_Data_Length_rdn - 1'b1;
            end

            //���������������Ϊ��LedTaskģ�����LedTask�����õ�
            8'd5: begin   //����Ҳ���Ը��ݽ��յ������ݣ���case��������ͬ����ĵ���bit���յ������أ�
                LedTask_Data_Trigger_rfo <= 1'b1;   //����bit�����������������
            end

            8'd6: begin
                LedTask_Data_Trigger_rfo <= 1'b0;   //����bit������������½���
            end

            // ����������������أ���Ϊ��˵�������Ѿ�ȫ����������õ�
            8'd7: begin
                LedTask_Data_Done_rfo <= 1'b1;  //������һ���������ݶ�������ϣ�Ȼ��׼�� ����������������
            end

            8'd8: begin   
                LedTask_Data_Done_rfo <= 1'b0;   //������һ���������ݶ�������ϣ�Ȼ��׼�� �����������½���
                String_To_Uart_Length <= 8'd3;   //������ΪOK\n������byte
            end

            8'd9: begin   //��OK\n˳���uart_taskctrl_data_tobetxed_rdo�� Ȼ�����η��ͣ� ������׼������
                uart_taskctrl_data_tobetxed_rdo <= (String_To_Uart >> ((String_To_Uart_Length-1'b1) << 8'd3) );   //�����ɸ�λ���λȡ8��bit
                String_To_Uart_Length <= String_To_Uart_Length - 1'b1;
            end

            8'd10: begin    //�ж��Ƿ�OK������ɣ�ͨ����鷢�͵ĸ���
                //׼���������ˣ�Ӧ����һ��tx�������塣
                uart_taskctrl_trigger_rfo <= 1'b1;      //��һ����������������
            end

            8'd11: begin   
                uart_taskctrl_trigger_rfo <= 1'b0;      //��һ�����������½���
            end 
            
            8'd12: begin  //OK\nҲ�����ˣ���ʼ�建������Ȼ����뵽״̬0������
                uart_taskctrl_data_fifo_rdn <= 64'd0;
            end

            default: begin
                uart_taskctrl_data_fifo_rdn <= 64'd0;
            end

        endcase
    end
end        

endmodule


