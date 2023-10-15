`timescale 1ns / 1ps

module UART_TX_tb(
    );
    
    reg uart_sys_clk_wsi;             //uartģ��ȫ��ʱ��
    reg uart_sys_rstn_wsi;            //uartȫ�ָ�λ
    
    reg [7:0] uart_data_tobetxed_wdi;   //uartҪ���ͳ�ȥ������
    wire  uart_tx_done_rfo;        //tx����ź�                   //����
    reg uart_tx_trigger_wfi;          //tx���񴥷��ź�               //����
    wire uart_tx_busy_rfo;        //txæ�źţ����ڷ���           //��ƽ

    
    wire uart_tx;                      //���ȫ���ź�
    
    UART_TX UART_TX_inst1(
     .uart_sys_clk_wsi(uart_sys_clk_wsi),             //uartģ��ȫ��ʱ��
     .uart_sys_rstn_wsi(uart_sys_rstn_wsi),            //uartȫ�ָ�λ
     .uart_data_tobetxed_wdi(uart_data_tobetxed_wdi),   //uartҪ���ͳ�ȥ������
     .uart_tx_done_rfo(uart_tx_done_rfo),        //tx����ź�                   //����
     .uart_tx_trigger_wfi(uart_tx_trigger_wfi),          //tx���񴥷��ź�               //����
     .uart_tx_busy_rfo(uart_tx_busy_rfo),        //txæ�źţ����ڷ���           //��ƽ
     .uart_tx(uart_tx)                      //���ȫ���ź�
     );
     
     
     initial begin
       #1 uart_sys_clk_wsi=0;
            uart_sys_rstn_wsi=0;
            uart_tx_trigger_wfi <= 1'b0;
       #4 uart_sys_rstn_wsi=1;
          uart_data_tobetxed_wdi <= 8'h55;
       #6 uart_tx_trigger_wfi <= 1'b1;
       #7 uart_tx_trigger_wfi <= 1'b0;
      end
      
always #1 uart_sys_clk_wsi=~uart_sys_clk_wsi;


endmodule
