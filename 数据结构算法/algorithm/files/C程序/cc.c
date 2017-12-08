#include<windows.h>
#include<stdio.h>
int main()
{
	char *p="Hello World Of Linux ! \n \0";
	int hand=(int)GetStdHandle(STD_OUTPUT_HANDLE);
	if(!hand)
		printf("______________________________\n");
	__asm{
		push p
			call printf
			add esp,4
			xor eax,eax
			mov ecx,eax
			dec ecx
			mov edi,p
			cld
			repnz scasb
			sub edi,p
			dec edi
			push 0
			push 0
			push edi
			push p
			push hand
	    	call WriteConsole
            push hand
			call CloseHandle
	}
	return 0;
}
