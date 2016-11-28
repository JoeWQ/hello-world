#include<stdio.h>
int   main(int  argc,char *argv[])
{
        char          *p="Éµ±Æ´ó»Æ";
        while(*p)
                printf("%0x  ",(unsigned char)*(p++));
//c9  b5  b1  c6  b4  f3  bb  c6
        return  0;
}