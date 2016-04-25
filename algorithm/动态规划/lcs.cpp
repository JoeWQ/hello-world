/*
  *@aim:最长公共子序列
  *@time:2014-9-23
  *@author:狄建彬
  */
//
   #include"array.h"
   #include<string.h>
   #include<stdio.h>
/*
  *@func:longest_common_sequence
  *@aim:最长公共最序列，动态规划实现
  *@param:@s原字符串，d目标字符串，x[i][j],记录s,d中前缀(i,j)(i>0,j>0)的最长公共子序列
  *@param:@y记录对于x[i][j]，对于最长公子序列，上一个最长子序列的索引
  */
//如果当前行i,列j
  enum    SequenceOption
 {
         SO_MIDDLE,//前面的中间一个，即i-1,j-1
         SO_UP,       //选取 上侧i-1,j
         SO_LEFT  //选取左侧 i,j-1
  };
   void      longest_common_sequence(char    *s,char    *d,Array    *x,Array   *y)
  {
           int      i,j,k;
           int      ssize,dsize;
//下面的代码是不用求出字符串的长度
           for(i=0; s[i] ; ++i)
                 x->set(i,0,0);
           ssize=i;
           for(j=0; d[j];++j )
                 x->set(0,j,0);
           dsize=j;
//最长公共子序列求取，注意，他的核心思想是 使用他们的前缀子序列构造当前的最长公共子序列
           for(i=1; i <=ssize;++i)
          {
                    for(j=1;j<=dsize;++j)
                   {
                             if( s[i-1] == d[j-1] )
                            {
                                    x->set(i,j, x->get(i-1,j-1) +1   );
                                    y->set(i,j, SO_MIDDLE );
                            }
                             else if(  x->get(i-1,j) >=  x->get(i,j-1)  )
                            {
                                    x->set(i,j,x->get(i-1,j) );
                                    y->set(i,j, SO_UP );
                             }
                             else 
                            {
                                     x->set(i,j, x->get(i,j-1) );
                                     y->set(i,j, SO_LEFT );
                             }
                    }
           }
   }
    int    main(int    argc,char    *argv[])
  {
         char        *p="hello xiao huaxiong";
         char        *q="mxwthlhuangdrgq";
         int           psize=strlen(p);
         int           qsize=strlen(q);
         Array       xx(psize+1,qsize+1);
         Array       rr(psize+1,qsize+1);
//
         Array       *x=&xx;
         Array       *r=&rr;
         int            i,j;
//
         for(i=0;i<=psize;++i)
        {
                for(j=0;j<=qsize;++j)
               {
                       x->set(i,j,0);
                       r->set(i,j,0);
                }
         }
         longest_common_sequence(p,q,x,r);
//最长长度
         printf("longest common sequence is :%d\n",x->get(psize,qsize) );
//
         for(i=1;i<=psize;++i)
        {
 //                 for(j=0;j<i;++j)
  //                       printf("%3c",' ');
                  for(j=1;j<=qsize;++j)
                         printf("%3d",x->get(i,j));
                  putchar('\n');
         }
         printf("--------------------------------------------\n");
         for(i=1;i<=psize;++i)
        {
  //                for(j=0;j<i;++j)
 //                        printf("%3c",' ');
                  for(j=1;j<=qsize;++j)
                         printf("%3d",r->get(i,j));
                  putchar('\n');
         }
         return    0;
   }
