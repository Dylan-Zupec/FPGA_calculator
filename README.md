# FPGA-calculator
Simple calculator for the Basys 3 FPGA development board written in VHDL. 
 
This is my first larger-scale project having multiple components. Includes 
a prescaler, debounce, 7-segment controller, and ALU. The following arithmetic \
and bitwise operations can be performed:
 - add
 - add with carry
 - subtract
 - subtract with borrow
 - NOT, AND, OR, XOR
 - rotate left and right
 - pass through
 
The two 8-bit binary operands are input using the 16 switches on the Basys 3.
The result is output on the 4 digit 7-segment display. The first and second
digits are the result in hexadecimal. The third digit represents the carry or
borrow. The top and bottom push-buttons are used to select the operation, the 
currently selected one being indicated by the first 4 LEDS. The operations listed 
above are listed in the order they appear in selection. When everything is ready, 
press the right push-button to latch and the result will appear at output. Left 
push-button is reset. 
