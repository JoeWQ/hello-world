/*
  *@aim:中位数问题
  *@date:2015-4-30 12:06:51
  */
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define   _OPTIMAL_  1
  //返回第target小的数字在数组y中
  //@request:target>=0 && target<size
  int          sequence(int     *y,int      size,const  int    target)
  {
            int               value,x,idx,left,right,tmp;
            left=0,right=size-1;
            while(  1 )
           {
//现在假定数组中最后一个数字就是所选取的比较对象，稍后我们会给出一个更好的解决方案
//如果使用最优的解决方案
                         #ifdef    _OPTIMAL_
//采用树形排序方法，最后导致的结果是y[left]<y[right]<y[idx]
                                    tmp=idx=(left+right)>>1;
                                    if( y[right]<y[idx] )
                                              tmp=right;
                                    if( y[tmp]<y[left])
                                    {
                                                 value=y[tmp];
                                                 y[tmp]=y[left];
                                                 y[left]=value;
                                    }
                                    if( y[right] >y[idx])
                                   {
                                                 value=y[right];
                                                 y[right]=y[idx];
                                                 y[idx]=value;
                                    }
                         #endif
                         value=y[right];
//最后一个数字不参与比较，根据我们的假设，它是将数组分割为两大部分的比较对象
                         for(x=left-1,idx=left; idx<right;++idx)
                        {
                                      if(  y[idx]<value)
                                      {
                                                    ++x;
                                                    if(  x != idx  )
                                                    {
                                                              tmp=y[idx];
                                                              y[idx]=y[x];
                                                              y[x]=tmp;
                                                    }
                                       }
                         }
//x+1处必定为讲述组分为两部分的中位数 value
                         y[right]=y[++x];
                         y[x]=value;
                         if(  target< x )
                                 right=x-1;
                         else if( target >x)
                                 left=x+1;
                         else
                                 return   y[x];
            }
            return         value;
   }
      int    main(int    argc,char    *argv[])
     {
                  int                  values[64];
                  int                  size=32;
                  int                   i=0;
                  srand((unsigned int)time(NULL));
                  
                  for(i=0;i<size;++i)
                              values[i]=rand()%1001;
                  for(i=0;i<size;++i)
                             printf("%d--------->%d\n",i,sequence(values,size,i));
                  return     0;
       }