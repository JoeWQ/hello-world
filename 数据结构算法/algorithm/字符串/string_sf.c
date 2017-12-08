/*
  *@aim:计算以某个字符起始,某个字符终止的所有子字符串的数目
  *@时间复杂度O(n)
  */
#include<stdio.h>
     
     int      main(int    argc,char   *argv[])
    {
                int             a,b;
                int             sum=0;//子字符串的总和
                int             i=0,j;
                const        char      *str="ARGJKBCFGSDRAHIHFBVIUFGBBRTUOHABYRFF";
                
                a=0,b=0;
                while( str[i])
               {
                            if(str[i]=='A')
                                       ++a;
                            else if(str[i]=='B')
                                       sum+=a;
                             ++i;
                }
                printf("substring count is %d\n",sum);
//下面是朴素的算法
                 sum=0;
                for(i=0;str[i];++i)
               {
                           if(str[i]=='A')
                          {
                                        j=i+1;
                                        while(str[j] )
                                       {
                                                    if(str[j]=='B')
                                                               ++sum;
                                                    ++j;
                                        }
                           }
                }
                printf("prim algorithm is %d\n",sum);
                return    0;
     }