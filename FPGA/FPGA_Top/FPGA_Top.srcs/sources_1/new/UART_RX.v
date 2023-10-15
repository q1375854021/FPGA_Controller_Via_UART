
module UART_RX #(
        parameter Baudrate = 32'd115200,           //������
        parameter Uart_sysclk = 32'd100_000_000    //����ʱ��100MHz
    )
    (
    input uart_sys_clk_wsi,             //uartģ��ȫ��ʱ��
    input uart_sys_rstn_wsi,            //uartȫ�ָ�λ

    input uart_rx,                        //����ȫ���ź�
    output reg [7:0] uart_data_rxed_rdo,  //uart���յ�������           
    output reg uart_rx_done_rfo,         //uart��������ź�           //����
    output reg uart_rx_busy_rfo         //uart���ڽ����ź�           //��ƽ

    );

// �������źŵ�׼����

parameter Baud_clkcount = Uart_sysclk/Baudrate;    //���������������Ҫ������ʱ�Ӹ���

// uart_rx���ؼ��
reg uart_rx_rfn1;         
reg uart_rx_rfn2; 

// ״̬��
reg [7:0] uart_rx_current_state_rfn;     //��ǰ״̬
reg [7:0] uart_rx_next_state_rfn;      //��һ״̬

// uart_rx��⵽�½���
wire uart_rx_trig_wfn;        //��ë��Ҳû��Ӱ�죬�����ͬ����·
assign uart_rx_trig_wfn = (~uart_rx_rfn1)&uart_rx_rfn2 ;   //Ӧ������һ�������壬��֪���᲻����ë�̣���ֻ��Ҫ��һ�����弴��,״̬��Ӧ��û����

// ��������
reg [31:0] uart_clk_cnt_rfn;   //��������
(*mark_debug="true"*)reg [7:0] Baud_State_count;   //���������ļ���


// ���ؼ��
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

//״̬��

//  ״̬����һ�Σ�״̬�л�
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi)      //�����λ
        uart_rx_current_state_rfn <= 8'd0;
    else
        uart_rx_current_state_rfn <= uart_rx_next_state_rfn;
end     
    
// ״̬���ڶ��Σ� ״̬ת��  ����߼�
always @(*) begin
    begin
        uart_rx_next_state_rfn = 8'd0;
        case (uart_rx_current_state_rfn)  
            8'd0: begin
                if(uart_rx_trig_wfn == 1'b1)           //���rx_trigger����һ������,֤����⵽��rx���½��أ���ʼ׼����������
                    uart_rx_next_state_rfn = 8'd1;       //ת�Ƶ���һ״̬
                else
                    uart_rx_next_state_rfn = 8'b0;     //û���ͼ����ȴ�
            end

            8'd1: begin        //׼����ʼ�ź� busy
                uart_rx_next_state_rfn <= 8'd2;   
            end

            8'd2: begin           //�����������������, ����
                if(Baud_State_count==8'd2)   //˳����һ���Ƿ���ʼλΪ0
                    uart_rx_next_state_rfn = 8'd3;
                else
                    uart_rx_next_state_rfn = 8'd2;        //û�еĻ��ͼ����Լ�
            end

            8'd3: begin   //������ʼλ������ʱ״̬
                if(uart_rx_rfn1 == 1'b0)
                    uart_rx_next_state_rfn = 8'd4;    //������ʼλ���
                else
                    uart_rx_next_state_rfn = 8'd0;    //û��⵽��ʼλ���ͻص�״̬0
            end

            8'd4: begin
                if(Baud_State_count == 8'd10)   //���������һ��bit
                    uart_rx_next_state_rfn = 8'd5;
                else
                    uart_rx_next_state_rfn = 8'd4;
            end
            
            8'd5: begin
                if(Baud_State_count == 8'd11)   //������ֹͣ�м䣬����ͼ�������
                    uart_rx_next_state_rfn = 8'd6;
                else
                    uart_rx_next_state_rfn = 8'd5;
            end

            8'd6: begin   //���ڽ���λ������ʱ״̬
                if(uart_rx_rfn1 == 1'b1)
                    uart_rx_next_state_rfn = 8'd7;    //������ֹλ��⡣
                else
                    uart_rx_next_state_rfn = 8'd0;    //û��⵽��ʼλ���ͻص�״̬0
            end

            8'd7: begin
                if(Baud_State_count >= 8'd14)   //����ʱ�Ӽ�����׼��һЩ�����ź�
                    uart_rx_next_state_rfn = 8'd8;
                else
                    uart_rx_next_state_rfn = 8'd7;
            end

            8'd8: uart_rx_next_state_rfn = 8'd0;

            default:  uart_rx_next_state_rfn = 8'd0;
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
        case (uart_rx_next_state_rfn) 
            8'd0: begin     //״̬0��δ��ʼ
                uart_clk_cnt_rfn <= 32'd0;
                Baud_State_count <= 8'd0;
            end
            8'd1: begin
                Baud_State_count <= Baud_State_count + 1'b1;    //��countΪ1ʱ����busy��1
            end
            8'd2: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount)>>8'd1)    begin   //����������������ں�ֹͣ  ������2
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd3: Baud_State_count <= Baud_State_count;   //����״̬������ʱ״̬��û��ɶ�ر�Ҫ����

            8'd4: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount))    begin   //����һ�����������ں�ֹͣ  ������ÿ��bit���м��ȡ���ݣ�Ȼ��һֱ������10
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd5: begin
                if(uart_clk_cnt_rfn >= (Baud_clkcount))    begin   //����һ�����������ں�ֹͣ ������ֹͣλ�м䣬���Ե����������ڣ�����Ӧ��ͬ����ֹλbit
                    Baud_State_count <= Baud_State_count + 1'b1;
                    uart_clk_cnt_rfn <= 32'd0;   
                end
                else begin
                    uart_clk_cnt_rfn <= uart_clk_cnt_rfn + 1'b1;
                end
            end

            8'd6: Baud_State_count <= Baud_State_count;   //����״̬������ʱ״̬��û��ɶ�ر�Ҫ����

            8'd7: begin
                Baud_State_count <= Baud_State_count + 1'b1;
            end

            8'd8: begin   //�����Ѿ�ȫ��������
                Baud_State_count <= 8'd0;
            end

            default: begin
                Baud_State_count <= 8'd0;
            end

        endcase
    end
end            

// Ȼ�����Baud_State_Count�����źŶ�ȡ
always @(posedge uart_sys_clk_wsi or negedge uart_sys_rstn_wsi) begin
    if(!uart_sys_rstn_wsi) begin     //�����λ����ûʹ��
        uart_rx_done_rfo <= 1'b0;       //tx �������
        uart_rx_busy_rfo <= 1'b0;       // ����æ
        uart_data_rxed_rdo <= 8'd0;     //Ĭ����0
    end 
    else begin
        case(Baud_State_count)
            8'd0: begin                        //��û��ʼ
                uart_rx_done_rfo <= 1'b0;       //tx �������
                uart_rx_busy_rfo <= 1'b0;       // ����æ
            end

            8'd1: begin     //��ȡ��ʼλ  
                uart_rx_busy_rfo <= 1'b1;        //rx_busy��1
            end

            8'd2: begin   //������ʼֻ�������ж�״̬ת�Ƶ���ʱ״̬�����д�����ռλ
                uart_rx_busy_rfo <= uart_rx_busy_rfo;      
            end

            8'd3: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[0] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[0] <= uart_data_rxed_rdo[0];
            end
            
            8'd4: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[1] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[1] <= uart_data_rxed_rdo[1];
            end
            
            8'd5: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[2] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[2] <= uart_data_rxed_rdo[2];
            end
            
            8'd6: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[3] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[3] <= uart_data_rxed_rdo[3];
            end
            
            8'd7: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[4] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[4] <= uart_data_rxed_rdo[4];
            end
            
            8'd8: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[5] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[5] <= uart_data_rxed_rdo[5];
            end

            8'd9: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[6] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[6] <= uart_data_rxed_rdo[6];
            end
            
            8'd10: begin
                if(uart_clk_cnt_rfn == 0)        //����ȡһ��
                    uart_data_rxed_rdo[7] <= uart_rx;          //��ȡ��nλ
                else
                    uart_data_rxed_rdo[7] <= uart_data_rxed_rdo[7];
            end

            8'd11: begin             //����״̬ת���жϵ���ʱ״̬��
                uart_rx_busy_rfo <= uart_rx_busy_rfo;   //��������
            end

            8'd12: begin                       //�Ȱ�busy������
                uart_rx_busy_rfo <= 1'b0;
            end

            8'd13: begin                      //done����
                uart_rx_done_rfo <= 1'b1;
            end

            8'd14: begin                     //done���ͣ��γ�һ������
                uart_rx_done_rfo <= 1'b0;
            end

            default: begin   //����
                uart_rx_done_rfo <= 1'b0;       //tx �������
                uart_rx_busy_rfo <= 1'b0;       // ����æ
                uart_data_rxed_rdo <= 8'd0;     //Ĭ����0
            end

        endcase
    end

end

endmodule
