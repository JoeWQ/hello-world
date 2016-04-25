/*
  *@aim:带权的区间调度问题
  *@date:2015-5-23
  */
#include"CArray2D.h"
#include"CArray.h"
#include<stdio.h>
//带权的区间调度问题
  struct         CTask
 {
//任务开始的时间
             int              startTime;
//任务结束的时间
             int              finishTime;
//权值
             int              weight;
  };
  //@aim:求具有最大权值兼容活动集合
  //@note:task[0]位一个虚拟的任务，task[0].startTime=0,task[0].finishTime=0
  //@request:task已经按照finishTime升序排序
    int         weight_interval_schedule(CTask        *task,int      size)
   {
//theta记录着任务j的最大兼容任务索引，也就是theta(j)=max{i | task[i].finishTime<=task[j].startTime}
//如果没有这样的数字，就记为0
              CArray<int>            theta(size),*p;
//record记录截止到当前任务i所求得的总的权值的大小
              CArray<int>            record(size),*q;
              int                             i,k;
              
              i=1;
              p=&theta;
//计算与当前活动相兼容的最大活动的索引
              while(i<size)
             {
                             k=i-1;
                             while(k &&task[k].finishTime>task[i].startTime)
                                          --k;
                             p->set(i,k);
                             ++i;
;              }
               i=1;
               q=&record;
//注意下面的递归式迭代过程
               q->set(0,0);
               while(i<size)
              {
//检测，加入这个活动与不加入这个活动所能构成的总权值的大小
                               int           back;
                               back=q->get( p->get(i) )+task[i].weight;
                               int           extra=q->get(i-1);
                               q->set(i,    back>extra?back:extra);
                               ++i;
               }
               return    q->get(size-1);
    }
      int        main(int    argc,char    *argv[])
     {
               CTask                 task[6]={{0,0,0},{1,5,4},{3,8,8},{6,13,16},{12,15,9},{14,18,20}};
               int                      size=6;
               int                     weight=0;
               
               weight=weight_interval_schedule(task,size);
               printf("total weight is %d\n",weight);
               return   0;
      }