/*
  *最优二叉查找树
  &2016-4-21
  */
#include<stdio.h>
#define     __MAX_OPTIMAL__      32
//计算最优二叉查找树的权值,_weight的有效值从1开始
  int              most_optimal_tree(const   int    *_weight,const  int    _size)
 {
              int          _optimal[__MAX_OPTIMAL__][__MAX_OPTIMAL__];
              int          _w[__MAX_OPTIMAL__][__MAX_OPTIMAL__];
              int          i,k,j,d;
              for(i=1;i<=_size;++i)
             {
                        _w[i][i]=_weight[i];
                        _w[i][i-1]=0;
                        _optimal[i][i-1]=0;
                        for(k=i+1;k<=_size;++k)
                       {
                                  _w[i][k]=_weight[k]+_w[i][k-1];
                        }
              }
              _w[_size][_size+1]=0;//最右的边缘
              _optimal[_size+1][_size]=0;
              for(d=1;d<=_size-1;++d)//跨过的步长
             {
                         for(i=1;i<=_size-d;++i)//起始索引 
                        {
                                   j=i+d;
                                   int           value=0x3FFFFFFF;
                                   for(k=i;k<=j;++k)
                                  {
                                               int         _temp=_optimal[i][k-1]+_optimal[k+1][j]+_w[i][j];
                                               if(value>_temp)
                                                             value=_temp;
                                   }
                                   _optimal[i][j]=value;
                         }
              }
              return     _optimal[1][_size];
  }
  int       main(int  argc,char  *argv[])
 {
              int           weight[15]={0,19,27,94,33,16,25,17,37,26,5,7,89,32};
              printf("most_optimal_tree is %d\n",most_optimal_tree(weight,14));
              return   0;
  }