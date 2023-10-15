`timescale 1ns / 1ps

module UART_tb();

    reg uart_sys_clk_wsi;             //�����ȫ��ʱ��
    reg uart_sys_rstn_wsi;           //����ģ���ȫ�ָ�λ

    // ���Ͷ˿�
    reg [7:0] uart_data_tobetxed_wdi;        //uartҪ���ͳ�ȥ������
    wire  uart_tx_done_rfo;              //tx����ź�                   //����
    reg uart_tx_trigger_wfi;                //tx���񴥷��ź�               //����
    wire  uart_tx_busy_rfo;              //txæ�źţ����ڷ���           //��ƽ
    wire  uart_tx;                      //���ȫ���ź�
    
    //���ն˿�
    reg uart_rx;                        //����ȫ���ź�
    wire  [7:0] uart_data_rxed_rdo;  //uart���յ�������           
    wire  uart_rx_done_rfo;         //uart��������ź�           //����
    wire  uart_rx_busy_rfo;        //uart���ڽ����ź�           //��ƽ


reg [7:0] temp_i;

    UART UART_Inst1(
    .uart_sys_clk_wsi       (uart_sys_clk_wsi),             //�����ȫ��ʱ��
    .uart_sys_rstn_wsi      (uart_sys_rstn_wsi),           //����ģ���Ͷ˿�

    .uart_data_tobetxed_wdi (uart_data_tobetxed_wdi),        //uartҪ���ͳ�ȥ������
    .uart_tx_done_rfo       (uart_tx_done_rfo),              //tx����ź�                   //����
    .uart_tx_trigger_wfi    (uart_tx_trigger_wfi),                //tx���񴥷��ź�               //����
    .uart_tx_busy_rfo       (uart_tx_busy_rfo),              //txæ�źţ����ڷ���           //��ƽ
    .uart_tx                (uart_tx),                      //����˿�

    .uart_rx                (uart_rx),                        //����ȫ���ź�
    .uart_data_rxed_rdo     (uart_data_rxed_rdo),  //uart���յ�������           
    .uart_rx_done_rfo       (uart_rx_done_rfo),         //uart��������ź�           //����
    .uart_rx_busy_rfo       (uart_rx_busy_rfo)  //uart���ڽ����ź�         
    );
    
   initial begin
       #1 uart_sys_clk_wsi=0;
            uart_sys_rstn_wsi=0;
            uart_rx = 1'b1;
            uart_tx_trigger_wfi <= 1'b0;
       #4 uart_sys_rstn_wsi=1;
          uart_data_tobetxed_wdi <= 8'h55;
       #6 uart_tx_trigger_wfi <= 1'b1;
       #7 uart_tx_trigger_wfi <= 1'b0;
      
      
      for (temp_i = 8'd0; temp_i < 8'd10; temp_i = temp_i + 1'b1)
             begin
                 #1700 uart_rx=~uart_rx;
             end
             
       end

always #1 uart_sys_clk_wsi=~uart_sys_clk_wsi;



    
endmodule
