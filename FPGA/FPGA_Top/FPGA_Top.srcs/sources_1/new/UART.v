//��������
// ������115200
// ģ��ʱ��100MHz
// ģ���ǵ͵�ƽ��λ
// 8������λ
// ��У��λ
// 1.5����2��ֹͣλ

module UART(
    //Ϊʲôû��reg���أ���Ϊ�ײ��Ѿ�ʵ����reg���ϲ�����Ƿ�װһ�£�������wire
    input uart_sys_clk_wsi,             //�����ȫ��ʱ��
    input uart_sys_rstn_wsi,           //����ģ���ȫ�ָ�λ

    // ���Ͷ˿�
    input [7:0] uart_data_tobetxed_wdi,        //uartҪ���ͳ�ȥ������
    output uart_tx_done_rfo,              //tx����ź�                   //����
    input uart_tx_trigger_wfi,                //tx���񴥷��ź�               //����
    output  uart_tx_busy_rfo,              //txæ�źţ����ڷ���           //��ƽ
    output  uart_tx,                      //���ȫ���ź�

    //���ն˿�
    (*mark_debug="true"*)input uart_rx,                        //����ȫ���ź�
    (*mark_debug="true"*)output  [7:0] uart_data_rxed_rdo,  //uart���յ�������           
    (*mark_debug="true"*)output  uart_rx_done_rfo,         //uart��������ź�           //����
    (*mark_debug="true"*)output  uart_rx_busy_rfo         //uart���ڽ����ź�           //��ƽ
    );

parameter Baudrate = 32'd115200;       //������
parameter Uart_sysclk = 32'd100_000_000;    //����ʱ��100MHz

    UART_RX#(
        .Baudrate(Baudrate),       //������
        .Uart_sysclk(Uart_sysclk)    //����ʱ��100MHz 
    ) 
    UART_RX_Inst1
    (
    .uart_sys_clk_wsi(uart_sys_clk_wsi),             //uartģ��ȫ��ʱ��
    .uart_sys_rstn_wsi(uart_sys_rstn_wsi),            //uartȫ�ָ�λ

    .uart_rx(uart_rx),                        //����ȫ���ź�
    .uart_data_rxed_rdo(uart_data_rxed_rdo),  //uart���յ�������           
    .uart_rx_done_rfo(uart_rx_done_rfo),         //uart��������ź�           //����
    .uart_rx_busy_rfo(uart_rx_busy_rfo)         //uart���ڽ����ź�       
    );

    UART_TX #(
        .Baudrate(Baudrate),       //������
        .Uart_sysclk(Uart_sysclk)    //����ʱ��100MHz 
    )
    UART_TX_Inst1
    (
    .uart_sys_clk_wsi        (uart_sys_clk_wsi),             //uartģ��ȫ��ʱ��
    .uart_sys_rstn_wsi       (uart_sys_rstn_wsi),            //uartȫ�ָ�λ

    .uart_data_tobetxed_wdi  (uart_data_tobetxed_wdi),   //uartҪ���ͳ�ȥ������
    .uart_tx_done_rfo        (uart_tx_done_rfo),        //tx����ź�                   //����
    .uart_tx_trigger_wfi     (uart_tx_trigger_wfi),          //tx���񴥷��ź�               //����
    .uart_tx_busy_rfo        (uart_tx_busy_rfo),        //txæ�źţ����ڷ���           //��ƽ

    .uart_tx (uart_tx)                     //���ȫ���ź�
    );


endmodule
