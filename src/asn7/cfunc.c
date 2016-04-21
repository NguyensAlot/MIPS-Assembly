extern void output_result(int temperature);
extern void output_line1_from_asm(int fahr);
extern void output_line2_from_asm(int cel_int, int cel_frac);
void init_uart(void)
{
// in-line assembly to initialize the uart
// MUST USE ?$? with register names
	asm ("la $t9, U1MODESET");
	asm ("li $t0, 0x8000");
	asm ("sw $t0, 0($t9)");
	asm ("la $t9, U1STASET");
	asm ("li $t0, 0x1400");
	asm ("sw $t0, 0($t9)");
// the rest of initialization follows here
// See Lab 5 Description for complete initialization sequence
}
void main(void)
{
	int fahrenheit = -40; // this number can be changed
	init_uart();
	output_result(fahrenheit);
}
void output_result_from_c(int cel_frac, int cel_int, int fahr)
{
	output_line1_from_asm(fahr);
	output_line2_from_asm(cel_int, cel_frac);
}