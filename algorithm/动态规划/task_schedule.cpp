/*
  *@aim:任务调度，具有贪心选择性质的调度法，采用动态规划实现
  *@date:2014-10-13
  *@author:狄建彬
  */
  #include<stdio.h>
  #include<string.h>
  #include"array.h"
   struct      Task
  {
 //任务开始时间
           int          start_time;
 //任务结束时间
           int          finish_time;
   };
  #define     infine      0x37777777
/*
  *@function:task_schedule
  *@aim:采用动态规划方法求得最大可兼容的任务调度数目
  *@param:y[i][j]表示 满足(task[i].finish_time<=task[k].start_time<=task[k].finish_time<=task[j].start_time)条件的
  *@param:--任务的数目,其中   i<k<j
  *@param:r记录被选取的最前面任务的索引,t为最后面的任务索引
  *@param:size活动的数目，注意第一个和最后一个是虚拟活动
  *@request:size>=3
  */

   void       task_schedule(Array   *y,Array    *r,Task     *task,int    size)
  {
            int     i,j,d;
            int     e,m,trace;
            int     empty;
//初始条件
            for(i=0;i<size-1;++i)  
                    y->set(i,i+1,0); 
//自底向上求解,d为跨度
            for(  d = 2;d<size;++d )
           {
                      for(i = 0;i<size-d;++i)
                     {
//     j>=i && j<i+d
                                e=-1;
//判断S(i,i+d)集合是否为空，只有为非空的情况下，才能取得最大值
                                empty=1;
//注意下面的代码实际上应该分两部分完成，现在只是为了简洁起见才写成下面的形式
                                for( j=i+1;j<i+d;++j)
                               {
//下面的判断语句的比较对象只需一个即可，原因是我们采用的自底向上的整合方式可以保证它永远可以正常工作
                                      if(   task[j].start_time>=task[i].finish_time && task[j].finish_time<=task[i+d].start_time )
                                     {
                                                 empty=0;
//比较任务对象，判断任务之间是否兼容
                                                m = y->get(i,j) + y->get(j,i+d)+1;
                                                if( e < m )
                                                {
                                                        e=m;
                                                        trace = j;
                                                }
                                       }
                                }
                               if(  ! empty  )
                              {
                                       y->set(i,i+d,e);
                                       r->set(i,i+d,trace);
                               }
                               else
                              {
                                       y->set(i,i+d,0);
                                       r->set(i,i+d,0);
                              }
                      }
           }
  }
//
  int    main(int   argc,char   *argv[])
 {
            struct      Task      task[13]={
                                                              {0,0},
                                                              {1,4},{3,5},{0,6},{5,7},
                                                              {3,8},{5,9},{6,10},{8,11},
                                                              {8,12},{2,13},{12,14},
                                                              {infine,infine}
                                                       };
           int               size=13;
//
           Array            schedule_cost(size,size);
           Array            schedule_record(size,size);
 //          Array            prev(size,size);
 //          Array            next(size,size);
           Array            *y=&schedule_cost,*r=&schedule_record;
 //
           task_schedule(y,r,task,size);
//
           int     i,j;
           for(i=0;i<size;++i)
          {
                    for(j=0;j<=i;++j)
                         printf("     "); 
                    for(j=i;j<size;++j)
                         printf("%4d",y->get(i,j));
                    putchar('\n');
           }
           printf("--------------------------------------------------------------------\n");
            for(i=0;i<size;++i)
          {
                    for(j=0;j<=i;++j)
                         printf("     "); 
                    for(j=i;j<size;++j)
                         printf("%4d",r->get(i,j));
                    putchar('\n');
           }
           return   0;
  }
