`timescale 10ns / 10ps

module Top_tb();

    reg top_sys_clk;    //ȫ��ʱ��
    reg top_sys_rstn;   //ȫ�ָ�λ
    
    reg top_uart_rx;   //����RX
    wire top_uart_tx;   //����TX

    Top Top_Inst1(
        .top_sys_clk    (top_sys_clk),    //ȫ��ʱ��
        .top_sys_rstn   (top_sys_rstn),   //ȫ�ָ�λ
        .top_uart_rx    (top_uart_rx),   //����RX
        .top_uart_tx    (top_uart_tx),   //����TX
        .top_led        (top_led    )   //LED���
    );

    initial begin
        #0  top_sys_clk=1'b1;
            top_sys_rstn = 1'b1;
            top_uart_rx = 1'b1;
        #2  top_sys_rstn = 1'b0;
        #4  top_sys_rstn = 1'b1;
        //����01  
        
        // 01 01 00 00 00 00 00 10
        begin
        //��ʼλ  
        #863; top_uart_rx = 1'b0;   
        //����  
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
        //����01  
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
        
        //����10  
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        end
        #100000;
 
        //����01 00 00 00 00 00 00 10 
        begin
        //��ʼλ  
        #863; top_uart_rx = 1'b0;   
        //����  
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
        //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
         //����00
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        
        
        //����10  
        //��ʼλ
        #863; top_uart_rx = 1'b0;   
        //���� ��λ��ǰ����λ�ں�
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b1;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        #863; top_uart_rx = 1'b0;
        //ֹͣλ
        #1000; top_uart_rx = 1'b1;
        end

    end

always #1 top_sys_clk=~top_sys_clk;   



endmodule
