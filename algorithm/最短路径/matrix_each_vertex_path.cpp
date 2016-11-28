/*
  *@aim:任意两点之间的最短路径----矩阵乘法实现
  *@idea:动态规划思想
  *@date:2014-11-7 11:34:17
  *@author:狄建彬
  */
   #include"Array.h"
   #include<stdio.h>
   #include<stdlib.h>
   #define    infine      0x3FFFFFFF
/*
  *@function:matrix_multiple_method
  *@idea:矩阵乘法实现
  *@param:g代表矩阵之间任意两点的最初距离
  *@request:y,w,parent has same row and column count,and row=column
  */
   void     matrix_multiple_method(Array    *y,Array   *w,Array   *parent)
  {
               int      m,i,j,k;
               int      e,new_weight,pai;
// 
               int          row=y->getRow();
//初始，权值和一个顶点的前驱数据被复制
               pai=w->getInvalideValue();
               for(i=0;i<row;++i)
              {
                       for(j=0;j<row;++j)
                      {
                                 m=w->get(i,j);
                                 y->set(i,j,m );
//如果i,j两点存在直接可达的路径
                                 e=-1;
                                 if( i  !=  j )
                                {
                                             if( m !=  pai )
                                                   e=i;
                                 }
                                 parent->set(i,j,e);  
                       }
               }
               for(m=0;m<row-1;++m)
              {
                          for( i=0;i<row;++i)
                         {
                                      for(j=0;j<row;++j)
                                     {
                                                   if(j != i )
                                                  {
                                                              e=y->get(i,j);
                                                              pai=parent->get(i,j);
                                                              for(k=0;k<row;++k)
                                                             {
//从下面的一句代码可以看出，边的生长每次只能跨出一步
                                                                          new_weight=y->get(i,k)+w->get(k,j);
                                                                          if(  e > new_weight )
                                                                         {
                                                                                     e = new_weight;
                                                                                     pai = k;
                                                                          //           if( k == j )
                                                                           //               pai=i;
                                                                           }
                                                             }
                                                            y->set(i,j,e );
                                                            parent->set(i,j,pai);
                                                   }
                                     }
                            }
               }
   }
/*
  *@function:fast_matrix_multiple_method
  *@aim:快速矩阵乘法,将上面函数的运行时间的数量级降低为n*n*n*ln(n)
  *@request:same as above
  *@note:在使用了快速矩阵乘法之后，parent[i][j]所表示的含义就会发生重大的变化，它不在表示j的直接前驱
  *@note:而是表示i,j之间的最短路径被分成了两部分i--->parent->get(i,j) + parent->gert(i,j)---->j
  *@note:一定要注意这个区别，否则，在解析路径的时候会发生不必要的误解
  */
   void      fast_matrix_multiple_method(Array   *y,Array  *w,Array  *parent)
  {
             int        m,i,j,k;
             int        pai,e,row,new_weight;
//初始，数据复制
            row = y->getRow();
            pai=   w->getInvalideValue();
            for( i=0;i<row;++i )
           {
                    for(j=0;j<row;++j)
                   {
                               m=w->get(i,j);
                               y->set(i,j,m );
//如果i,j两点存在直接可达的路径
                               e=-1;
                               if( i  !=  j )
                              {
                                         if( m !=  pai )
                                               e=i;
                               }
                              parent->set(i,j,e);     
                     }        
            }
//
            for(m=0;  (1<<m) <row-1;++m )
           {
                          for(   i=0;i<row;  ++i  )
                         {
                                     for(j=0;j<row;++j)
                                    {
                                                if(  i != j )
                                               {
                                                             e=y->get(i,j);
                                                             pai=parent->get(i,j);
                                                             for(k=0;k<row;++k)
                                                            {
//下面的设计思想就如同单源最短路径一样,所不同的是，现在的源是变量i

                                                                                      new_weight=y->get(i,k)+y->get(k,j);
                                                                                      if(  e > new_weight )
                                                                                     {
                                                                                               e = new_weight;
                                                                                               pai = k;
                                                                                      } 
                                                              }
                                                             y->set(i,j, e );
                                                            parent->set(i,j,pai);
                                                 }
                                    } 
                          }
            }
   }
 //测试
    int     main(int    argc,char   *argv[] )
   {
              int    adj[5][5]={
                                       {0,1,20,infine,3},
                                       {infine,0,infine,50,infine},
                                       {infine,infine,0,7,infine},
                                       {20,infine,infine,0,infine},
                                       {infine,infine,5,100,0}
                                 };
              int      size=5;
              int      i,j;
//权值
              Array      weight(size,size);
              Array      *w=&weight;
              for(i=0;i<size;++i)
                      for(j=0;j<size;++j)
                          w->set(i,j,adj[i][j]);
              w->setInvalideValue(infine);
//前驱矩阵
            Array        parent(size,size);
//最短路径
            Array        dist(size,size);
//
            Array        *y,*p;
            y=&dist,p=&parent;
//矩阵乘法求任意两点之间的最短路径
//            matrix_multiple_method(y,w,p);
//快速矩阵乘法求最短路径
            fast_matrix_multiple_method(y,w,p);
//输出结果
            printf("-------------------------------- shortest distance -------------------------------\n");
            for(i=0;i<size;++i)
           {
                        for(j=0;j<size;++j)
                                    printf("%8d",y->get(i,j));
                        putchar('\n');
            }
            printf("---------------------------------previous  vertex  ------------------------------------\n");
            for(i=0;i<size;++i)
           {
                        for( j=0;j<size;++j) 
                                    printf("%8d",p->get(i,j));
                        putchar('\n');
            }
            return    0;
    }
