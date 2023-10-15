// ��������  ģ��_����_abc
// a:  w:wire   r:reg
// b: s:system, d:data  ,f:flag, 
// c: i:input,  o:otuput, n: internal
// û��abc����IO�ź�

module UART_TX#(
        parameter Baudrate = 32'd115200,       //������
        parameter Uart_sysclk = 32'd100_000_000    //����ʱ��100MHz
    )
    (
    input uart_sys_clk_wsi,             //uartģ��ȫ��ʱ��
    input uart_sys_rstn_wsi,            //uartȫ�ָ�λ
    
    input [7:0] uart_data_tobetxed_wdi,   //uartҪ���ͳ�ȥ������
    output reg uart_tx_done_rfo,        //tx����ź�                   //����
    input uart_tx_trigger_wfi,          //tx���񴥷��ź�               //����
    output reg uart_tx_busy_rfo,        //txæ�źţ����ڷ���           //��ƽ

    
    output reg uart_tx                      //���ȫ���ź�

    );


parameter Baud_clkcount = Uart_sysclk/Baudrate;    //���������������Ҫ������ʱ�Ӹ���


reg [7:0] uart_tx_current_state_rfn;     //��ǰ״̬
reg [7:0] uart_tx_next_state_rfn;      //��һ״̬

reg [31:0] uart_clk_cnt_rfn;         //���ڷ�Ƶ����
reg [7:0] Baud_State_count;         //���ڼ�����Ƶ�����ļ����� ����״̬�ж�


reg [7:0] uart_data_tobetxed_rdi;   //uartҪ���ͳ�ȥ������
reg uart_tx_trigger_rfi;          //tx���񴥷��ź�


// �����źŴ�һ��
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
   


//  ״̬����һ�Σ�״̬�л�
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi)      //�����λ����ûʹ��
        uart_tx_current_state_rfn <= 8'd0;
    else
        uart_tx_current_state_rfn <= uart_tx_next_state_rfn;
end     
    
// ״̬���ڶ��Σ� ״̬ת��  ����߼�
always @(*) begin
    begin
        uart_tx_next_state_rfn = 8'd0;
        case (uart_tx_current_state_rfn)
            8'd0: begin
                if(uart_tx_trigger_rfi == 1'b1)          //���tx_trigger����һ�����壬��׼������������   //�����ȼ���һ��ʱ�ӣ�׼��busy�ź�
                    uart_tx_next_state_rfn = 8'b1;       //ת�Ƶ���һ״̬
                else
                    uart_tx_next_state_rfn = 8'b0;        //û���ͼ����ȴ�
            end

            8'd1: begin
                uart_tx_next_state_rfn = 8'd2;           // ׼��busy�źţ�Ȼ��Ϳ�ʼ�����������ڼ�����
            end

            8'd2: begin
                if(Baud_State_count == 8'd11)            //����ֱ��11   ���ﶼ�ǰ����������ڼ�����Ȼ���͵���bit
                    uart_tx_next_state_rfn = 8'd3;
                else
                    uart_tx_next_state_rfn = 8'd2;       //����ͼ��������������ڼ���
            end

            8'd3: begin
                if(Baud_State_count >= 8'd13)             //����ֱ��13 �������Ϊһ��ʱ�����ڣ�Ȼ��׼�������źţ���done��busy
                    uart_tx_next_state_rfn = 8'd0;
                else
                    uart_tx_next_state_rfn = 8'd3;       //����ά��ԭ��
            end
            default: uart_tx_next_state_rfn = 8'd0;       //�ص���ʼ״̬
        endcase
    end
end

                

// ״̬�������Σ� ��������
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin     //�����λ����ûʹ��
        uart_clk_cnt_rfn <= 32'd0;
        Baud_State_count <= 8'd0;
    end
    else begin
        case (uart_tx_next_state_rfn) 
            8'd0: begin     //״̬0��δ��ʼ
                uart_clk_cnt_rfn <= 32'd0;
                Baud_State_count <= 8'd0;
            end

            8'd1: begin    //״̬1�������ǰ�ʱ�����ڼ����ģ�׼�� busy�ź�
                    uart_clk_cnt_rfn <= 32'd0;       
                    Baud_State_count <= Baud_State_count + 1'b1;
            end

            8'd2: begin
                if(uart_clk_cnt_rfn < Baud_clkcount)   //Ȼ��ʼ�����ؼ�����׼����������
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;   //��ʼ����
                else begin
                    uart_clk_cnt_rfn <= 32'd0;       //����������ֹͣ
                    Baud_State_count <= Baud_State_count + 1'b1;   //�Լ�
                end
            end

            8'd3: begin
                    uart_clk_cnt_rfn <= 32'd0;       //�����ǰ�ʱ�����ڼ�����Ȼ��׼����β�źţ���busy��done��Ȼ��ûɶ��
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
    if(!uart_sys_rstn_wsi) begin     //�����λ����ûʹ��
        uart_tx_done_rfo <= 1'b0;       //tx �������
        uart_tx_busy_rfo <= 1'b0;       // ����æ
        uart_tx <= 1'b1;               // �ߵ�ƽ
    end 
    else begin 
        case(Baud_State_count)
            8'd0: begin
                uart_tx_done_rfo <= 1'b0;       //tx �������
                uart_tx_busy_rfo <= 1'b0;       // ����æ
                uart_tx <= 1'b1;               // �ߵ�ƽ
            end
            8'd1: begin
                uart_tx_busy_rfo <= 1'b1;    //��ʼæ������
                uart_tx <= 1'b0;             //��ʼλ�ź�
            end
            8'd2: uart_tx <= uart_data_tobetxed_rdi[0];   //����bit0
            8'd3: uart_tx <= uart_data_tobetxed_rdi[1];   //����bit1
            8'd4: uart_tx <= uart_data_tobetxed_rdi[2];   //����bit2
            8'd5: uart_tx <= uart_data_tobetxed_rdi[3];   //����bit3
            8'd6: uart_tx <= uart_data_tobetxed_rdi[4];   //����bit4
            8'd7: uart_tx <= uart_data_tobetxed_rdi[5];   //����bit5
            8'd8: uart_tx <= uart_data_tobetxed_rdi[6];   //����bit6
            8'd9: uart_tx <= uart_data_tobetxed_rdi[7];   //����bit7
            8'd10:uart_tx <= 1'b1;   //ֹͣλ
            8'd11: begin          
                uart_tx <= 1'b1;   //ֹͣλ����
            end
            8'd12: begin
                uart_tx_busy_rfo <= 1'b0;   //����busy
            end
            8'd13: begin
                uart_tx_done_rfo <= 1'b1;    //����done
            end
            8'd14: begin
                uart_tx_done_rfo <= 1'b0;      //����done
            end
            default: begin
                uart_tx_done_rfo <= 1'b0;       //tx �������
                uart_tx_busy_rfo <= 1'b0;       // ����æ
                uart_tx <= 1'b1;               // �ߵ�ƽ
            end
        endcase
    end
end



    
endmodule





/*
//Ŀǰ��Щ��û�õ�
parameter Stopbits = 8'd1;             //һ��ֹͣλ
parameter Databits = 8'd8;             //�˸�����λ
parameter Checkbits = 8'd0;            //0������У��
*/ 

