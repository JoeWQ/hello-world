//2012/12/30/11:03
//作业调度算法,计算最高作业效益获取的作业调度序列
  #include<stdio.h>
  #include<stdlib.h>
  #define  INF_T   0x30000000
//宏函数
  #define  MIN(a,b)    (a)<(b)?(a):(b)
/**********************************/
  typedef  struct  _Job
 {
//作业要消耗的时间
       int    time;
//对作业要求的最高截止时间
       int    deadline;
//在截止时间内作业完成后，所获得的效益
       int    benefit;
  }Job;
//**************************************
  static  int  bf[8][16];
  static  int  tg[8][16];
  static  int  p[16];
/*************************************/
//在调用这个函数之间，我们已经假设对他们按(deadline,time,benefit)进行了排序
  void  job_schedule(Job  *job,int n,int  dw)
 {
       int  i,j,le,min;
       int  vp,k;
//初始化数据
       for(i=0;i<=n;++i)
           bf[i][0]=0;
       for(i=0;i<=dw;++i)
           bf[0][i]=0;
//利用动态规划求解
       for(i=1;i<=n;++i)
      {
             le=job[i].deadline;
             k=job[i-1].deadline;
             for(j=1;j<=le;++j)
            {
//如果i不能加入被调度的队列
                  bf[i][j]=bf[i-1][MIN(j,k)];
                  tg[i][j]=0;
//                  p[i]=0;
//如果第i个作业被调度，
//那么最好使其在期限时正好结束，这样能够保证i之前的作业能够在更充裕的时间内被调度,注意下面的等号
                 if(j>=job[i].time)
                {
                       min=((j-job[i].time)<k)?(j-job[i].time):k;
                       vp=bf[i-1][min]+job[i].benefit;
                       if(bf[i][j]<vp)
                      {
                            bf[i][j]=vp;
                            tg[i][j]=1;
//                            p[i]=1;
                       }
                  }
/*
for i = 1->n  
for j = 1->d[i]  
    //不调度i   
    s[i][j] = s[i-1][min(j, d[i-1])]  
    select[i][j] = false  
    //调度i   
    if j>t[i]  
        if s[i][j] < s[i-1][min(j-t[i], d[i-1])]+p[i]  
            s[i][j] = s[i-1][min(j-t[i], d[i-1])]+p[i]  
            select[i][j] = true  
*/
             }
        }

//下面是输出所有的被选中的作业

        printf(" 1  2  3  4  5  6  7  8  9  10 11 12 13 14\n");
        for(j=1;j<=dw ;++j)
       {
             printf("第%d:\n",j);
             for(i=1;i<=n;++i)
            {
                   if(tg[i][j])
                      printf(" 1 ");
                   else
                      printf(" 0 ");
             }
             printf("\n");
        }

//
        printf("效益值:\n");
        for(i=1;i<=n;++i)
       {
             printf("\n第%d行:            \n     ",i); 
             for(j=1;j<=dw;++j)
                  printf(" %d  ",bf[i][j]);
        }
        printf("\n*******************\n");
/*        for(i=1;i<16;++i)
           if(p[i])
              printf("  %d  ",i);
*/
//对tg数组进行解码,以抽取出本选中的作业
//从最后面开始解码
        printf("\n");
        for(i=n,j=dw;i && j;--i)
       {
//注意下面的代码，和上面的编码有着相反的关系
//如果i被选中
              if(tg[i][j])
             {
                   printf(" %d  ",i);
                   j=MIN(job[i-1].deadline,j-job[i].time);
              }
              else
                  j=MIN(j,job[i-1].deadline);
       }
        printf("\n最高的调度效益为:%d \n",bf[n][dw]);
  }
//
  int  main(int argc,char *argv[])
 {
//
       Job   job[7]={{0,0,0},{2,4,7},{2,4,6},{1,6,4},{5,7,12},{4,10,10},{1,14,3}};
       int   size=6;
       
       printf("最高效益值计算结果:\n");
       job_schedule(job,size,14);
       printf("\n*****************************\n");
       return 0;
  }
       
      