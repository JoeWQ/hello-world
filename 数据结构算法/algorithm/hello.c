#include<stdio.h>
 
   int   main(int  argc,char  *argv[])
  {           
           printf("Hello World !\n");
           return 0;
   };
   
   char     _buffer[256]={0};
   char     _new_buffer[128];
   char     *_format[2]={"%d!+","%d!"};
   int        i=1;
   for(i=1;i<=n;)
   {
            sprintf(_new_buffer,_format[i == n],i);
            strcat(_buffer,_new_buffer);
   }
   printf("%s = %ld\n",_buffer,sum(n));