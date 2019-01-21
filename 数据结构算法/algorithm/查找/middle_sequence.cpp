/*
  *@aim:中位数问题，获取当前数组中第i小(大)的值
  *@idea:快速排序
  *@date:2014-11-13 10:08:29
  *@author:狄建彬
  */
 /*
   *@function:middle_sequence
   *@aim:选择数组中第i小的数字
   *@request:aim>=0 and aim<size
   */
   #include<stdio.h>
   #include<stdlib.h>
   #include<time.h>
   int    middle_sequence(int   *d,int  size,int  aim)
  {
//递归运算时需要的指针
 //           int      *p;
//记录两端的边界值
            int      origin,bottom;
//中间值
            int      middle_index,middle_value;
            int      left,right;
            int      a,b;
//
            left=0,right=size-1;
            while(   true )
          {
                        origin=left;
                        bottom=right;
                        middle_index=(left+right)>>1;
//所选取的middle_value必须是一个中间值，以避免极端的序列出现
                        middle_value=d[middle_index];
                        a=d[origin];
                        b=d[bottom];
//假设a=max(a,b), b=min(a,b)
                        if(    a<b )
                       {
                                a=d[bottom];
                                b=d[origin];
                       }
                       if(    middle_value<b )
                      {
                                size=b;
                                b=middle_value;
                                middle_value=size;
                       }
//将middle_value修正成中间值
                       if(  middle_value > a )
                      {
                                size=middle_value;
                                middle_value=a;
                                a=size;
                       }
//值重排列,这个序列非常重要，他是决定是否能正确返回所求的目标值的关键所在
                       d[origin]=b;
                       d[bottom]=middle_value;
                       d[middle_index]=a;
//将7
//在形式上，下面的文法形似于快速排序的子程序
                        for (    ;origin <bottom ; )
                       { 
                                  while( origin<bottom && d[origin]<=middle_value)
                                               ++origin;
                                  while( bottom>origin && d[bottom] >=middle_value)
                                              --bottom;
                                  if(  origin < bottom )
                                 {
                                            a=d[origin];
                                            d[origin]=d[bottom];
                                            d[bottom]=a;
                                            ++origin;
                                             --bottom;
                                  }
                        }
                        a=d[right];
                        d[right]=d[origin];
                        d[origin]=a;
 //                       printf("origin=%d, bottom=%d\n",origin,bottom);
//将origin,bottom与aim作比较,可以肯定的是，此时origin=bottom,或者 origin=bottom+1
                        if(    aim<origin )
                                 right=origin-1;
                        else if( aim>origin )
                                 left=origin+1;
                        else
                                  return   middle_value;
           }
           return   -1;
   }
//中位数的另一种实现，代码更加紧凑，但是理解起来更困难
//@request:same as above
   int       other_middle_sequence(int   *d,int   size,int  aim)
  {
            int      left,right;
            int      middle,e;
            int      origin,bottom;
//
           left=0,right=size-1;
           while( true )
          {
//调整d[left],d[right],d[(left+right)/2]处的值
                    middle=(left+right)>>1;
//3在middle,right中选择出较小值,使用的方法是树形排序
                    size=right;
                    if(   d[middle] <= d[right] )
                             size=middle;   
                    if( d[left] > d[size] )
                   {
                            e=d[left];
                            d[left]=d[size];
                            d[size]=e;
                   }
//e为d[left],d[middle],d[right]的中间值
                   e=d[right];   //假定e为中间值，且d[right]=e
                   if(  d[middle]< d[right] ) //如果现在d[right]为最大值,就将其与d[middle]交换数据
                  {
                            e=d[middle];
                            d[middle]=d[right];
                            d[right]=e;
                   }
                   origin=left-1;
//注意，下面的代码在四个集合上进行操作
                   for(bottom=left;bottom<right-1;++bottom)
                  {
                            if(  d[bottom] <=e )
                           {
                                      ++origin;
                                      if(  origin != bottom )
                                     {
                                               middle=d[bottom];
                                               d[bottom]=d[origin];
                                               d[origin]=middle;
                                     }
                            }
                   }
//善后
                   ++origin;
                   d[right]=d[origin];
                   d[origin]=e;
//作为限定left,right的决策
                   if(  aim<origin )
                         right=origin-1;
                   else  if( aim>origin )
                         left=origin+1;
                   else
                         return   e;
           }
           return   -1;
   }
    int    main(int    argc,char   *argv[])
  {
           int    d[16];
           int    size=6;
           int    i;
//去随机函数
           srand((int) time(NULL));
//
          for(i=0;i<size;++i)
               d[i]=rand()%153;
          for(i=0;i<size;++i)
               printf("%d\n",d[i]);
          printf("------------------------middle_sequence----------------------------\n");
          for(i=0;i<size;++i)
         {
             printf("%d----------------->%d \n",i,middle_sequence(d,size,i));
 //            printf("%d----------------->%d \n",i,other_middle_sequence(d,size,i));
         }
//当前的数组内容
          for(i=0;i<size;++i)
               printf("%d\n",d[i]);
         return  0;
  }
