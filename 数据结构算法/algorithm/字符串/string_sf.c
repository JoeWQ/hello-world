/*
  *@aim:������ĳ���ַ���ʼ,ĳ���ַ���ֹ���������ַ�������Ŀ
  *@ʱ�临�Ӷ�O(n)
  */
#include<stdio.h>
     
     int      main(int    argc,char   *argv[])
    {
                int             a,b;
                int             sum=0;//���ַ������ܺ�
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
//���������ص��㷨
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