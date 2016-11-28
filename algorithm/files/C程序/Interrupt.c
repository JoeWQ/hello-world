#include<stdio.h>
int main()
{
	char *p="Hello XiaoHuaXiong !\n";
	__asm
	{
		mov ah,0x2
		mov dl,'$'
		int 21h
	}
	return 0;
}