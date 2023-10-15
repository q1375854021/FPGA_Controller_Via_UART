#  注释需要加井号
#  管脚分配
set_property PACKAGE_PIN J14 [get_ports top_led]
set_property PACKAGE_PIN W19 [get_ports top_sys_clk]
set_property PACKAGE_PIN G15 [get_ports top_uart_rx]
set_property PACKAGE_PIN G16 [get_ports top_uart_tx]
set_property PACKAGE_PIN H13 [get_ports top_sys_rstn]

#  时钟约束

#  管脚电平约束
set_property IOSTANDARD LVTTL [get_ports top_led]
set_property IOSTANDARD LVTTL [get_ports top_sys_clk]
set_property IOSTANDARD LVTTL [get_ports top_sys_rstn]
set_property IOSTANDARD LVTTL [get_ports top_uart_rx]
set_property IOSTANDARD LVTTL [get_ports top_uart_tx]


#  未使用引脚上拉
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]


set_property SLEW SLOW [get_ports top_led]


