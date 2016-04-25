/*
  *@aim:求最优二叉查找树
  *@date:2014-9-26
  *@author:狄建彬
  */
  #include"Array.h"
  #include<stdio.h>
//正无穷大
  #define    infine        0x3FFFFFFF 
/*
  *@func:optimal_tree
  *@param: p为树节点的代价，
  *@param: d为p所代表的节点的叶子节点的代价
  *@param: e为 计算最有代价的数据盛放位置
  *@param: w为 另一个计算 d[i]--d[j]代价的公共子问题的数据盛放位置
  *@note:d的长度为size+1
  *@request:p是升序排序的
  */
//       p0      p1       p2       p3        p4        p5        p6         p7
//  d0      d1        d2       d3       d4        d5        d6        d7         d8
   void      optimal_tree(Array   *e,Array   *w,Array   *r,int    *p,int    *d,int   size)
  {
            int       i,j,k,m;
            int       f,t,trace;
//初始，对公共子问题重叠的部分进行第一轮的数据填充
            for( i= 1;i<=size+1; ++ i )
           {
                     e->set(i,i-1,d[i-1]);
                     w->set(i,i-1,d[i-1]);
            }
//以下的过程都是建立在重叠子问题上，并由以前的子问题构造当前的最优解
//每次递进，求取子问题总序列的长度
            for( i= 1;i<=size;++i )
           {
//基址
                     for( j=1; j <=size-i+1; ++j  )
                    {
                              f=infine;
                              trace=0;
//右边界
                              m=i+j-1;
//设置 (j,m)的值,注意，这里面的索引，p中的数据从索引0开始有效,所以在使用时，必须用m-1
                              w->set(j,m,  w->get(j,m-1) + p[m-1] +d[m]);
//求 i--j 之间的最优二叉查找树
                              for( k=j; k<=m;++k)
                             {
                                       t =  e->get(j,k-1) + e->get(k+1,m) +w->get(j,m); 
                                       if(   f > t )
                                      {
                                               f=t;
                                               trace=k;
                                       }
                              }
                              e->set(j,  m,  f );
                              r->set(j,  m,  trace);
                     }
            }
   }
    int      main(int   argc,char    *argv[])
   {

            int       p[5]={5, 15, 25, 27 , 30};
            int       d[6]={7,6,12,20,16,18};
            int       size=5;
            Array      ee(size+2,size+2);
            Array      ww(size+2,size+2);
            Array      rr(size+2,size+2);
            Array      *e=&ee,*w=&ww,*r=&rr;
//
           int         i,j;
           for(i=0;i < size+2;++i)
          {
                  for(j=0;j<size+2;++j)
                 {
                           e->set(i,j,0);
                           w->set(i,j,0);
                           r->set(i,j,0);
                  }
          }
         optimal_tree(e,w,r,p,d,size);
         printf("-----------------------------e--------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("        ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d " ,e->get(i,j) );
                 putchar('\n');
         }
         printf("---------------------w------------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("          ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d" ,w->get(i,j) );
                 putchar('\n');
         }
         printf("-----------------------r----------------------------\n");
         for(i=1;i<size+2;++i)
        {
                 for( j=0;j<i-1;++j)
                        printf("        ");
                 for( j =i-1;j < size+2;++j)
                        printf("%8d" ,r->get(i,j) );
                 putchar('\n');
         }
         return  0;
    }
