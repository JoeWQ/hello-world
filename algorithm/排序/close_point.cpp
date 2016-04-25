/*
  *@im:平面最近点对
  *&2016-2-25 15:47:50
  */
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<time.h>
  struct       Point
 {
             float        x,y;
  };
 //插入排序
  void         _insert_sorty(Point     **y,const     int      size)
 {
             Point      *x;
             int           k,j;
             
             for(j=1;j<size;++j)
            {
                          x=y[j];
                          k=j-1;
                          while(k>=0 && x->y<y[k]->y)
                         {
                                         y[k+1]=y[k];
                                         --k;
                          }
                          if(  k+1 != j  )
                                        y[k+1]=x;
             }
  }
//假设点已经是按照x轴升序排列好了,并且size是2的整次幂
//实验证明,对数数据量为40240的平面点,快速算法的时间为29毫秒
//朴素算法的时间为:19017毫秒
  float        close_point(Point        *_point,const    int    size)
 {
                 float        *_distance=new    float[size>>1];
                 Point        **_object=(Point   **)malloc(sizeof(Point  *)*(size+1)>>1);
//记录被选中的点的数目
                 int                           _object_count;
                 int                           k,_step,j;
                 float                        _near1,_near2;
                 float                        x,y;
 //                int                           _origin,_final;
//首先,将两个相邻的点的距离计算出来
                 for(k=0;k<size;k+=2)
                {
                               x=_point[k].x-_point[k+1].x;
                               y=_point[k].y-_point[k+1].y;
                               _distance[k>>1]=sqrt(x*x+y*y);
                 }
//分段计算最小两点间最小距离
                  for(_step=2;(1<<_step)<=size;_step=_step+1)
                 {
                                  for(k=0;k   <size;k+=(1<<_step))
                                 {
                                                int         _origin=k;//左边界
                                                int         _final=k+(1<<_step);//右恻边界
                                                _near1=_distance[k>>_step-1];//上一次在左边界所取得的最小值
                                                _near2=_distance[(k>>_step-1)+1];//上一次在右边界所取得的最小值
                                                
                                                float     _min=_near1<_near2?_near1:_near2;
                                                int        _boundary=_origin+(1<<(_step-1));
                                                _object_count=0;
                                                x = (_point[_boundary-1].x+_point[_boundary].x)/2;//以x为中心进行遍历
                                                for(j=_boundary-1;j>=_origin && x-_point[j].x <=_min ;--j)//左侧
                                                                  _object[_object_count++]=_point+j;
                                                for(j=_boundary;j<_final && _point[j].x-x<=_min;++j)
                                                                  _object[_object_count++]=_point+j;
                                                _insert_sorty(_object,_object_count);//对所得到的数组按照y坐标进行升序排序
                                                for(j=0;j<_object_count-1;++j)
                                               {
                                                                _boundary=j+6<_object_count?j+6:_object_count;
                                                                for(_origin=j+1;_origin<_boundary;++_origin)
                                                               {
                                                                               x=_object[j]->x-_object[_origin]->x;
                                                                               y=_object[j]->y-_object[_origin]->y;
                                                                               _near1=sqrt(x*x+y*y);
                                                                               if(_min>_near1)
                                                                                         _min=_near1;
                                                                }
                                                }
                                                _distance[k>>_step]=_min;
                                  }
                  }
                  _near1=_distance[0];
                 delete     _distance;
                 free(_object);
                 return   _near1;
  }
//朴素的算法
    float             prim_close_point(const      Point    *_point,const    int    size)
  {
                  float         x,y;
                  float         _min=1e8;
  
                  for(int   i=0;i<size;++i)
                 {
                               for(int   k=i+1;k<size;++k)
                              {
                                           x=_point[i].x-_point[k].x;
                                           y=_point[i].y-_point[k].y;
                                           float      _near=sqrt(x*x+y*y);
                                           if(_min>_near)
                                                       _min=_near;
                               }
                  }
                  return     _min;
   }
   int              main(int    argc,char    *argv[])
  {
                Point                *_point=(Point  *)malloc(sizeof(Point)*40240);
                const        int          size=40240;
                int                    i,k,j=0;
                Point                 _temp;
                
                srand((int)time(NULL));
                for(i=0;i<size;++i)
               {
                          _point[i].x=rand();
                          _point[i].y=rand();
                }
                
                for(i=0;i<size;++i  )
               {
                            j=i;
                            for(k=i+1;k<size;++k)
                           {
                                         if(_point[k].x<_point[j].x)
                                                       j=k;
                            }
                            if(j  !=   i)
                           {
                                           _temp=_point[j];
                                           _point[j]=_point[i];
                                           _point[i]=_temp;
                            }
                }
 //               for(i=0;i<size;++i)
 //                           printf("%d------------->%f\n",i,_point[i].x);
//测试两者需要耗费的时间
       #ifdef    __TEST__
                time_t        _start,_final;
                _start=clock();
                float          _near1=close_point(_point,size);
                _final=clock();
                printf("fast method cost time %f\n",difftime(_final,_start));
                
                _start=clock();
                float          _near2=prim_close_point(_point,size);
                _final=clock();
                printf("prim method cost time: %f\n",difftime(_final,_start));
    #endif            
                printf("close_point result is :%f\n",_near1);
                printf("prim_close_point result is :%f\n",_near2);
                return    0;
   }