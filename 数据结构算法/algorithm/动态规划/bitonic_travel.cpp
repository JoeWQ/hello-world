/*
  *@aim:双调欧几里得旅行商问题
  *@date:2015-6-16 19:00:52
  */
  #include"CArray2D.h"
  #include<math.h>
  #include<stdio.h>
//@request:size>=3
    struct           Point
   {
               float             x,y;
    };
    float               bitonic_travel(Point         *p,int    size)
   {
               int           i,k;
               float        value;
               float         x,y;
               CArray2D<float>             aeach_distance(size,size);
               CArray2D<float>             *y=&aeach_distance;
               
               y->set(0,0,0.0f);
               x=p->x-p[1].x,   y=p->y-p[1].y;
               value=sqrt(x*x+y*y),  y->set(0,1,value);
               x=p[1].x-p[2].x, y=p[1].y-p[2].y;
               value=sqrt(x*x+y*y),  y->set(1,2,);
               for(i=3;i<size;++i)
              {
                           float           inf=1e8;
                           int              j=-1;
                           for(k=1;k<=i;++k)
                          {
                                        if(k<i-1 )
                                       {
                                                    x=p[k-1].x-p[k].x;
                                                    y=p[k-1].y-p[k].y;
                                                     value=y->get(k-1,i-1)+sqrt(x*x+y*y);
                                                     if( inf <value )
                                                    {
                                                              inf=value;
                                                              j=k;
                                                     }
                                        }
                                        else if(k == i-1)
                                       {
                                                    x=p[j].x-p[i].x;
                                                    y=p[j].y-p[i].y;
                                                    value=inf+sqrt(x*x+y*y);
                                                    y->set(i-1,i,value);
                                        }
                                        else if( k== size-1 )//只计算最后一个双调序列即可
                                       {
//比较,当链接点P(i-1)-->P(i),和点Pk(k<i-1)-->P(i)时所能构成的最小双调序列
                                                    inf=1e8;
                                                   for(j=0;j<size-1;++j)
                                                  {
                                                               x=p[j].x-p[i].x;
                                                               y=p[j].y-p[i].y;
                                                               value=y->get(j,i)+sqrt(x*x+y*y);
                                                               if(value<inf)
                                                                        inf=value;
                                                   }
                                                   y->set(k,k,inf);
                                        }
                           }
               }
               return    y->get(size-1,size-1);
    }