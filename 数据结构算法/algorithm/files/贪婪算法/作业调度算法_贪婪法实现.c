//2013/1/3/14:09
//贪婪算法实现的作业调度，注意，这里面的调度和动态规划中的调度有着质的区别
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _Greed_Job 
 {
//作业开始的时间
        int   start;
//作业的期限
        int   delay;
  }Greed_Job;
 
//这个函数的被调用的前提是，job里面的内容是已经按照delay域排好序的
//job[0].delay=0,且job的长度=n+1,buf为要写入的目标地址
  void  greed_job_select(Greed_Job  *job,int n,int  *buf)
 {
        int  i,k,m,size;
       
        k=1;
        m=1;
        i=1;
        size=0;
        while(  i<=n  )
       {
//注意下面比较的对象
/*
             if(job[i].start>=job[m].delay)
            {
                   buf[k++]=i; 
                   m=i;
             }
*/
//注意下面的这一行代码,这一行代码不是为了对付本问题，而是为了对付具有一般贪婪选择性质的问题
             if(size+job[i].start<=job[i].delay)
            {
                   buf[k++]=i;
                   size+=job[i].start;
                   m=i;
                  
             }
             ++i;
        }
        *buf=k-1;
  }
/***********************************************************************************/
  int  main(int argc,char *argv[])
 {
//注意，以下的数据是已经排好序的(按.delay,.start排序)
/*
        Greed_Job   job[12]={{0,0},{1,4},{3,5},{0,6},{5,7},{3,8},{5,9},{6,10},{8,11},{8,12},{2,13},{12,14}};
        int         size=11,i;
        int         vbuf[12]
*/
//第二个数据测试
        Greed_Job   job[12]={{0,0},{1,6},{3,6},{4,7},{5,9},{4,14},{3,14},{6,20},{7,20}};
        int         size=8,i;
        int         vbuf[12];
        printf("使用贪婪法进行作业选择\n");
        greed_job_select(job,size,vbuf);
        size=vbuf[0];
        
        for(i=1;i<=size;++i)
            printf("  %d  ",vbuf[i]);
        printf("\n");
        return 0;
  }