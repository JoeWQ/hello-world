/*
  *在一个有序数列中,查找是否有两个数字之和等于给定的目标数字
  &2016-2-20 17:15:20
  */
#include<stdio.h>
#include<stdlib.h>
    int        main(int    argc,char   *argv[])
   {
              int            seq[16]={};
              int            _key=17;
              const       int          size=16;
              int           i,k;
              
              for(i=0;i<size;++i)
                         seq[i]=rand()%797;
             for(i=0;i<size;++i)
            {
                       for(k=i+1;k<size;++k)
                      {
                                  if(seq[i]>seq[k])
                                 {
                                               _key=seq[i];
                                               seq[i]=seq[k];
                                               seq[k]=_key;
                                  }
                       }
             }
              for(i=0;i<size;++i)
                         printf("%d  ",seq[i]);
              printf("\n");
             _key=seq[rand()%size]+seq[rand()%size];
             printf("_key=%d\n",_key);
              for(i=0,k=size-1;i<k;    )
             {
                            int       _value=seq[i]+seq[k]-_key;
                            printf("_value remind %d\n",_value);
//有剩余
                            if(_value>0)
                                     --k;
//不足
                            else  if(_value<0)
                                     ++i;
                            else
                           {
                                    printf("(%d,%d)",i,k);
                                    break;
                            }
              }
              return     0;
    }
  