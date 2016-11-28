//去掉文件的后缀名,只留下前缀
#include<stdio.h>


    int       main(int    argc,char   *argv[])
   {
             char         prefix[256];
             if(argc>1)
            {
                          char       *p=argv[1];
                          int          i=0;
                          while(*p)
                               prefix[i++]=*(p++);
                          prefix[i]='\0';
                          while(--i>=0 && prefix[i]!='.')
                                       ;
                           if( i>=0 )
                                  prefix[i]='\0';
                           printf("%s",prefix);
             }
             return    0;
    }