//2013年5月5日21:10:31
//作业调度问题、贪心算法
  #include<stdio.h>
  #include<stdlib.h>
/*********************************************/
  typedef  struct  _Task
 {
//作业最迟的完成时间
         int     delay;
//定义作业在没有完成时的惩罚
         int     weight;
  }Task;
/********************************************/
//在这个函数调用前，我们已经架设task数组已经按照weight域降序排好序了
//task[0]为一个虚拟任务，其并不包含在内，只是为了简化程序设计而存在
  int  task_schedule(Task  *task,int  size,int *buf)
 {
        int   i,j,k;
        int   max,t,ct;

        k=0;
        buf[k++]=0;
        max=0;
        t=0;
        for(i=1;i<=size;++i)
       {
              if(task[i].delay<=t && t==max)
                       continue;
              else
             {
//加入到作业队列中的合适位置
                      ++t;
                      if(max<task[i].delay)
                            max=task[i].delay;
                      for(j=k;j>0;--j)
                     {
                              ct=buf[j-1];
                              if(task[i].delay<task[ct].delay)
                                      buf[j]=ct;
                              else
                                      break;
                      }
                      buf[j]=i;
                      ++k;
               }
         }
         return k;
  }
//
  int  main(int argc,char *argv[])
 {
       Task   task[8]={ {0,0}, {4,70},{2,60},{4,50},{3,40},{1,30},{4,20},{6,10} };
       int    size=7;
       int    buf[8],len,i;

       for(i=0;i<=size;++i)
             buf[i]=0;
       len=task_schedule(task,size,buf);
       printf("####\n");
       for(i=1;i<len;++i)
            printf(" %d ",buf[i]);
       printf("\n#######\n");
       return 0;
  }