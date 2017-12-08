/*
  *@aim:分段的最小二乘法
  *@date:2015-5-25
  */
  #include"CArray2D.h"
  #include<stdio.h>
  //n重分段最小二乘法
    struct           Point
   {
                float              x;
                float              y;
    };
    //@param:points  点的集合,全部按照x坐标升序排序
    //@param:every_cost代表着每一分段的代价
    //@return:返回最小的代价
    //@request:size>=3
     float             mutiple_least_square(Point           *points,int          size,float       every_cost)
    {
                 float                               cost;
//记录在点集合i,j中，最小二乘误差的值
                 CArray2D<float>         every_least_square(size,size);
                 CArray2D<float>         *e=&every_least_square;
//记录在求解集合i,j之间，所能话费的最小n重分段二乘法的花费
                 CArray2D<float>         every_least_cost(size,size);
                 CArray2D<float>         *p=&every_least_cost;
                 CArray2D<int>            every_least_cost_trace(size,size);
                 CArray2D<int>            *trace=&every_least_cost_trace;
                 int                                  i,k,j;
//求解的过程稍后会给出，这里假设已经求得every_least_square
                 for(i=0;i<size;++i)//只有一个点，此时无需进行最小二乘逼近
                           e->set(i,i,every_cost); 
                for(i=0;i<size-1;++i)//两个点时也无需求解
                           e->set(i,i+1,every_cost);
                for(i=1;i<size;++i)
                           e->set(i-1,i,every_cost);
                p->fillWith(0.0f);
                trace->fillWith(0);
//迭代求解的过程
                 for(i=2;i<size-1;++i)//步长从3开始,i代表着索引的递增幅度
                {
//对连续的i个点进行最小二乘拟合
                                 for(j=0;j<size-i;++j)
                                {
                                              float         x=0,y=0,xy=0,xx=0;
                                             for(k=j;k<=j+i;++k)
                                            {
                                                       x+=points[k].x;
                                                       y+=points[k].y;
                                                       xy+=x*y;
                                                       xx+=x*x;
                                             }
                                             float    a=(i*xy-x*y)/(i*xx-x*x);
                                             float    b=(y-a*x)/i;
                                             xy=0;
                                             for(k=j;k<=j+i;++k)
                                            {
                                                            x=points[k].x;
                                                            y=points[k].y;
                                                            xy+=(y-a*x-b)*(y-a*x-b);
                                             }
                                             e->set(j,j+i,xy+every_cost);
                                 }
                                for(j=0;j<size-i;++j)
                               {
                                               cost=1e8;
                                               int         goal=-1;
                                               for(k=j+1;k<j+i;++k)
                                              {
                                                             float          weight=e->get(j,k)+e->get(k+1,j+i);
                                                             if(cost > weight)
                                                            {
                                                                         cost=weight;
                                                                         goal=k;
                                                             }
                                               }
                                               p->set(j,j+i,cost);
                                               trace->set(j,j+i,goal);
                                }
                 }
                  for(i=0;i<size;++i)
                {
                             for(j=0;j<size;++j)
                                      printf("%.4f   ",p->get(i,j));
                             printf("\n");
                 }
                 printf("---------------------------------------------------\n");
                 for(i=0;i<size;++i)
                {
                             for(j=0;j<size;++j)
                                      printf("%d  ",trace->get(i,j));
                             printf("\n");
                 }
                 return     p->get(0,size-2);
     }
   //
       int        main(int    argc,char    *argv[])
      {
                 Point                 point[18]={ {3.0,3.0},{3.1,3.05},{3.15,3.1},{3.2,3.15},
                                                             {3.25,3.20},{3.3,3.25},{3.4,3.30},{3.5,3.5},
                                                             {3.55,3.7},{3.57,3.9},{3.8,4.0},{3.9,4.3},
                                                             {3.95,4.6},{4.2,4.65},{4.4,3.95,},{4.6,4.8},
                                                             {4.8,4.8},{5.0,4.9}
                                                            };
                  int                   size=18;
                  float   cost=mutiple_least_square(point,size,0.5f);
                  printf("final cost  is %f\n",cost);
                 return      0;
       }
  