module Top(
    input top_sys_clk,    //ȫ��ʱ��
    input top_sys_rstn,   //ȫ�ָ�λ
    
    (*mark_debug="true"*)input top_uart_rx,   //����RX
    (*mark_debug="true"*)output top_uart_tx,   //����TX

    output top_led      //led�����
    );

wire top_rst_n;
wire [7:0] uart_data_rxed_rdo_wire;         //ģ�������
wire [7:0] uart_taskctrl_data_tobetxed_rdo_wire;  
wire [7:0] LedTask_Data_rdo_wire;

assign top_rst_n = (top_sys_rstn && locked);    //����locked������λ�ź�

    pll_clock pll_clock_inst1 
    (
    .clk_100mhz (clk_100mhz),
    .resetn     (top_sys_rstn),
    .locked     (locked),
    .sys_clk    (top_sys_clk)
    );
    

    Uart_TaskCtrl Uart_TaskCtrl_Inst1(
    //ģ���������֣�ʱ�Ӹ�λɶ��
    .uart_taskctrl_sys_clk_wsi       (clk_100mhz      ),             //�����ȫ��ʱ��
    .uart_taskctrl_sys_rstn_wsi      (top_rst_n     ),           //����ģ���ȫ�ָ�λ
    .uart_taskctrl_en_wsi            (1'b1           ),                 //ģ��ʹ��

    //���ڲ�������
    .uart_taskctrl_data_rvd_wdi      (uart_data_rxed_rdo_wire     ),           //��ȡ���ڽ��յ�������
    .uart_takactrl_rx_done_wfi       (uart_takactrl_rx_done_wfi      ),                 //�����������
    .uart_taskctrl_rx_busy_wfi       (uart_taskctrl_rx_busy_wfi      ),                //����æ��Ҳ��

    .uart_taskctrl_data_tobetxed_rdo (uart_taskctrl_data_tobetxed_rdo_wire),  //Ҫ���͵�����
    .uart_taskctrl_trigger_rfo       (uart_taskctrl_trigger_rfo      ),              //Ҫ�ô��ڷ��ͳ�ȥ������
    .uart_taskctrl_tx_busy_wfi       (uart_taskctrl_tx_busy_wfi      ),                   //����æ�ı�־
    .uart_taskctrl_tx_done_wfi       (uart_taskctrl_tx_done_wfi      ),                  //���ڷ���

    // LED����ģ�鲿��
    .LedTask_Data_rdo                (LedTask_Data_rdo_wire               ),               //��LED����ģ�������
    .LedTask_Data_Trigger_rfo        (LedTask_Data_Trigger_rfo       ),              //��LED���ݶ�ȡ������
    .LedTask_Data_Done_rfo        (LedTask_Data_Done_rfo       )              //��LED����ģ�������trigger
    );

    UART UART_Inst1(
    .uart_sys_clk_wsi        (clk_100mhz       ),             //�����ȫ��ʱ��
    .uart_sys_rstn_wsi       (top_rst_n      ),                      //����ģ�鸴λ�ź�

    .uart_data_tobetxed_wdi  (uart_taskctrl_data_tobetxed_rdo_wire ),            //uartҪ���ͳ�ȥ������
    .uart_tx_done_rfo        (uart_taskctrl_tx_done_wfi       ),              //tx����ź�                   //����
    .uart_tx_trigger_wfi     (uart_taskctrl_trigger_rfo    ),                //tx���񴥷��ź�               //����
    .uart_tx_busy_rfo        (uart_taskctrl_tx_busy_wfi       ),              //txæ�źţ����ڷ���           //��ƽ
    .uart_tx                 (top_uart_tx                ),                      //���

    .uart_rx                 (top_uart_rx                ),                        //����ȫ���ź�
    .uart_data_rxed_rdo      (uart_data_rxed_rdo_wire     ),  //uart���յ�������           
    .uart_rx_done_rfo        (uart_takactrl_rx_done_wfi       ),         //uart��������ź�           //����
    .uart_rx_busy_rfo        (uart_taskctrl_rx_busy_wfi       ) //uart���ڽ����ź�           //��ƽ
    );


    Led_Task Led_Task_Inst1(
    .uart_ledtask_sys_clk_wsi   (clk_100mhz) ,             //�����ȫ��ʱ��
    .uart_ledtask_sys_rstn_wsi  (top_rst_n) ,           //Ledģ���ȫ�ָ�λ

    .LedTask_Data_wdi           (LedTask_Data_rdo_wire) ,               //��LED����ģ�������
    .LedTask_Data_Trigger_wfi   (LedTask_Data_Trigger_rfo) ,              //��LED���ݶ�ȡ������
    .LedTask_Data_Done_wfi      (LedTask_Data_Done_rfo) ,              //��LED����ģ�鵱ǰ���������

    .Led_pin_rpo                (top_led)           //����LED���������
    );
    
endmodule
