/*
  *@全排列
  *&2016-2-19 16:52:16
  */
#include<stdio.h>

    void        perm( int     n  )
   {
//循环的次数
             int           _count=1;
             char        symbol[32],c;
//
             int           i,j,k,m;
             for(k=1;k<=n;++k)
            {
                        _count*=k;
                        symbol[k-1]=(char)(k+'0');
             }
             symbol[n]='\0';
            printf("%s\n",symbol);
            i=1;
            while( i<=_count  )
           {
//第一步,从最后面向前遍历查找第一个不满足 symbol[k-1]>symbol[k]的索引k-1
                            for(k=n-1;k>0 && symbol[k-1]>symbol[k];--k)
                                       ;
                             j=k-1;
//从索引j开始,查找大于symbol[j]的最小的元素
                             m=j+1;
                             for(k=j+1;k<n;++k)
                            {
                                            if(symbol[k]>symbol[j] && symbol[k]<symbol[m])
                                                              m=k;
                             }
//交换两个数字j,m
                             c=symbol[m];
                             symbol[m]=symbol[j];
                             symbol[j]=c;
//从j+1开始逆转字符序列(j+1,..... n)
                             for(k=j+1,m=n-1;k<m;++k,--m)
                            {
                                            c=symbol[m];
                                            symbol[m]=symbol[k];
                                            symbol[k]=c;
                             }
                             printf("%s\n",symbol);
                             ++i;
            }
    }
//递归形式实现全排列
    void             perm_recurve(char    *symbol,int   _from,int   _to)
   {
                  int      k;
                  char   c;
                  if(_from == _to)
                              printf("%s\n",symbol);
                  else
                 {
//减治法
                              for(k=_from;k<=_to;++k)
                             {
                                         c=symbol[_from];
                                         symbol[_from]=symbol[k];
                                         symbol[k]=c;
                                         perm_recurve(symbol,_from+1,_to);
                                         symbol[k]=symbol[_from];
                                         symbol[_from]=c;
                              }
                  }
    }
    int        main(int    argc,char   *argv[])
   {
                 char    symbol[6]={'1','2','3','4','5','\0'};
                 perm(5);
                 printf("\n-------------------------------------------\n ");
                 perm_recurve(symbol,0,4);
                 return      0;
    }