/*
  *@aim:双调排序
  *@date:2014-10-27 17:06:06
  *@author:狄建彬
  */
 #include<stdio.h>
/*
  *@function:bitonic_sort
   *@aim:双调排序,自顶向下
   *@principle:双调排序基于0-1原理，并且输入的数据必须是双调的，否则它不能正确排序
   *@cost:Space:O(1),Time:O(n)
   *request:none
   */
    void      bitonic_sort(int     *y,int    size)
   {
            int       i,m,j,t,r,k;
            int       *p=y;
//最外环的循环
            int         cycle;
//cycle代表着比较的跨度
            for(m=0; (1<<m ) <size;++m )
           {
//折半的长度
                     cycle=size>>m;
//i为基址
                     for(i=0;i<size;i+=cycle)
                    {
//t为中间点
                              t = i+(cycle>>1);
//j为右半侧的开始索引
                              j=t;
                              for(k=i ; k<t;++k,++j)
                             {
                                        if( p[k]>p[j] ) 
                                        {
                                                  r = p[k];
                                                  p[k]=p[j];
                                                  p[j]=r;
                                        }
                                        ++k;
                                        ++j;
                              }
                     }
            }
   }
  int    main(int   argc,char  *argv[])
 {
//双调序列
           int     bitonic[8]={7,8,12,13,15,9,5,4};
           int      size=8;
           bitonic_sort(bitonic,size);
//
           int      i=0;
           printf("after bitonic sort:\n");
           for(   ;i<size;++i)
                 printf("%4d",bitonic[i]);
           printf("\n");
           return    0;
  }
