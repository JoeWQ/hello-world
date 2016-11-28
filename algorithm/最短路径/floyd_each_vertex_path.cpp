/*
  *@aim:Floyd最短路径算法实现
  *@date:2014-11-8 17:42:17
  *@author:狄建彬
  *@idea:动态规划
  */
   #include"Array.h"
   #include<stdio.h>
   #include<stdlib.h>
   #define      infine      0x3FFFFFFF
//
/*
  *@function:floyd_shortest_path
  *@idea:假设每次任意两之间的中间顶点都落在0---k之间,当前的运算完全可以使用上次计算的结果
  *@param:y最短路径输出,w最初的权值分布,parent各个顶点的前驱
  *@note:parent中的数据所表示的含义请参见matrix_each_vertex_path.cpp fast_matrix_multiple函数的说明
  */
   void    floyd_shortest_path(Array    *y,Array   *w,Array   *parent)
  {
           int     i,j,k;
           int     e,new_weight,pai;
           int     row=w->getRow();
//没有顶点之间直接向链接的值
           pai = w->getInvalideValue();
           for(i=0;i <row;++i )
          {
                      for(j=0;j<row;++j)
                     {
                                e=w->get(i,j);
                                y->set(i,j,e);
                                k=-1;
                                if(  e != pai );
                               {
                                         if( i != j )
                                               k = i;
                                }
                                parent->set(i,j,k);
                      }
            }
//Robot-Floyd
           for( k=0; k<row;++k)
          {
                     for(i=0;i<row;++i)
                    {
                              for(j=0;j<row;++j)
                             {
                                       if( j !=i )
                                      {
                                                  new_weight = y->get(i,k)+y->get(k,j);
                                                  if(  y->get(i,j) >new_weight )
                                                 {
                                                              y->set(i,j,new_weight);
                                                              parent->set(i,j,k);
                                                  }
                                        }
                              }
                     }
           }
   }