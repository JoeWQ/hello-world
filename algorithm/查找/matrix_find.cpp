/*
  *@aim:��һ���к����ϸ�����ľ����в��Ҹ���������
  &2016-2-20 16:49:28
  */
#include<stdio.h>
  int     main(int    argc,char   *argv[])
 {
               int           matrix[16][16];
               const      int         size=16;
               int           i,k;
               
               int           _key=0;
//�Ӿ����һ�����㿪ʼ����(i=0,k=size-1Ҳ����,����Ҫ�޸���Ӧ��ѭ������)
               for(i=0;i<size;++i)
                          for(k=0;k<size;++k)
                                        matrix[i][k]=++_key;
               _key=81;
               i=size-1;
               k=0;
               
               while(i>=0 && k<size)
              {
                                int          _value=matrix[i][k];
                                if(_value>_key)
                                           --i;
                                else if(_value<_key)
                                           ++k;
                                else
                                            break;
               }
               if(i>=0 && k<size)
                                printf("find  position at(%d,%d)\n",i,k);
               return  0;
  }