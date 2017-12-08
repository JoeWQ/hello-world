/*
  *@aim:矩阵链乘法的动态规划思想实现
  *@time:2014-9-22
  *@author:狄建彬
  */

  #include"array.h"
  #include<stdio.h>
  #define       infine       0x3FFFFFFF
/*
  *@func:matrix_line_multiply
  *@aim:计算矩阵乘法的最小代价
  */
/*
  *@param:r,记录每次分裂矩阵的最小代价，r[i][j]表示矩阵i,i+1.....j之间乘法的最小计算量
  *@param:s,记录每次分裂矩阵最小代价处的索引
  *@param p:矩阵序列的维数，注意p[i]表示表示矩阵i的列数，i=1,2,3,....size,p[0]表示矩阵1的行数,关于矩阵乘法的规则，请参见高等代数
  */
  void    matrix_line_multiply(Array   *r,Array     *s,int     *p,int    size)
 {
        int             d;//每次矩阵链的长度
        int             i,j;
//临时数据
        int             e,t;
//初始，对角线元素赋值为0，因为单个矩阵是不用做任何乘法运算的
        for(i=1;i<=size;++i)
       {
                r->set(i,i,0);
                s->set(i,i,0);
        }
//自底向上重构
//长度递进,注意这个长度是一个增量长度，如果i是基址，d就表示从(i,到i+d的范围)
        for(  d=1;d<size;++d)
       {
//计算矩阵链(i,i+1,i+2,....   i+d)的最小计算代价
                for( i=1; i<=size-d;++i  )
               {
                         e=infine;
                         for(  j=i ; j<i+d;++j  )
                        {
                                    t = r->get(i,j) + r->get(j+1,i+d) +p[i-1] *p[j]*p[i+d];
                                    if(   t  <   e )
                                   {
                                           e=t;
                                           s->set(i,i+d,j);
                                   }
                         }
                         r->set(i,i+d,e);
                }
        }
   }
   int      main(int   argc,char    *argv[])
  {
        int     p[5]={100,10,80,9,50};      
        int     size=4;
        Array     a(size,size),b(size,size);
        Array     *r=&a,*s=&b;
//
        matrix_line_multiply(r,s,p,size);
//输出计算结果
        int        i=0,j=0;
        printf("output value of min   quantity of multiply :\n");
        for(i=1;i<=size;++i)
       {
             for(j=1;j<i;++j)
                    printf("      ");
             for( j=i ; j<= size ;++j)
                    printf("%6d",r->get(i,j));
             putchar('\n');
       }
//
        printf("output index of min quantity of multiply:\n");
        for(i=  1;  i <=size;++i)
       {
                  for(  j=1; j<i;++j)
                        printf("      ");
                  for(j=i;j<=size;++j)
                        printf(" %6d",s->get(i,j));
                  putchar('\n');
        }
        return   0;
   }
