//2013年3月19日12:42:42
//线性规划的单纯形算法实现
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _Linear
 {
//记录存储基变量的数组长度
       int         bsize;
       int         *base;
//记录存储非基变量数组的长度
       int         nsize;
       int         *nbase;
//记录线规划中 松弛形 中的常数项,注意它的长度就是 bsize
       double      *bcst;
//记录目标函数中 各个基变量的系数
       double      *aimc;
//记录目标函数中的常数项
       double      v;
//记录线性规划中各个非基变量的系数，注意，它和松弛形中的系数刚好相反
//它的行的数目为 nsize
       double      (*ma)[10];
  } Linear;
//定义正无穷大
  static  double   E_INF=0xFFFFFFFF;
  void  print_relax_type(Linear  *p);
//建立主元，亦即选取一个非基变量 和 一个基变量，并做交换
/*
  *所有的元素都包含在一个矩阵中，对这个矩阵的所有操作,都是依据基变量集合和非基变量集合
  *中所包含的索引来进行的
  *e:换入变量的索引(它的本身是一个非基变量)
  *b:换出变量的索引(它的本身是一个基变量)
 */
  static  void  pivot(Linear  *p,int  e,int  b)
 {
       int        i,j,k,m;
       double        (*ma)[10];
       double     ie,t;
       
       ma=p->ma;
//更新 松弛形等式中的常数项
	     ie=ma[b][e];
       p->bcst[e]=p->bcst[b]/ie;
//更新 新生成的松弛等式中，各个非基变量的系数
       for(i=0;i<p->nsize;++i)
      {
              k=p->nbase[i];
              if(  k!=e  )
                    ma[e][k]=ma[b][k]/ie;
       }
       ma[e][b]=1/ie;
//将新生成的 松弛表达式 带入各个方程中
       t=p->bcst[e];/**************************/
       for(i=0;i<p->bsize;++i)
      {
             k=p->base[i];
             if(k==b)
                continue;
//更新 松弛形等始终的常数项
             p->bcst[k]-=t*ma[k][e];
//处理和非基变量有关的数据
             ie=ma[k][e];
             for(j=0;j<p->nsize;++j)
            {
                   m=p->nbase[j];
                   if( m==e )
                        continue;
                   
                   ma[k][m]-=ma[e][m]*ie;
             }
             ma[k][b]=-ma[e][b]*ie;
        }
//下一步，更新目标函数中的表达式
        ie=p->aimc[e];
        p->v+=p->bcst[e]*ie;  //更新常数项
   //更新里面的非基变量前的系数
        for(i=0;i<p->nsize;++i)
       {
              k=p->nbase[i];
              if(k==e)
                  continue;
              p->aimc[k]-=ie*ma[e][k];
        }
    //添加新的非基变量
        p->aimc[b]=-ie*ma[e][b];
//对基变量和非基变量集合进行更新
        for(i=0;i<p->bsize;++i)
       {
              if(p->base[i]==b)
                  break;
        }
        p->base[i]=e;
        for(i=0;i<p->nsize;++i)
       {
              if(p->nbase[i]==e)
                   break;
        }
        p->nbase[i]=b;
  }
  static  int  judge_const(Linear  *p,int *max)
 {
        int       i,k,j=0;
        double    e=-E_INF; 
        for(i=0;i<p->nsize;++i)
       {
              k=p->nbase[i];
              if(p->aimc[k]>e)
             {
                    e=p->aimc[k];
                    j=k;
              }
        }
        i=0;
        if(e>0)
       { 
             i=1;
             *max=j;
        }
        return i;
  }  
/**********************************************************/
  #include"标准型转换为松弛型.c"
/************************************************************/
//总跳调度作，是用单纯形算法求解 线性规划
//若求解成功，返回非0，否则返回0
  int   simplex(Linear  *p)
 {
        int       imax,k,i;
        double    e,*limit;
		    double    (*ma)[10]=p->ma;

        limit=(double *)malloc(sizeof(double)*p->bsize);
        while(  judge_const(p,&imax) )
       {
//             ++j;
//             printf("max:%d\n",imax);
//寻找一个对 非基变量 i 的限制最紧的那个松弛表达式
             for(i=0;i<p->bsize;++i)
            {
                   k=p->base[i];
                   e=ma[k][imax];
                   if(e>0 )
                        limit[i]=p->bcst[k]/e;
                    else
                        limit[i]=E_INF;
             }
       //寻找限制最为严格的那个索引
             e=E_INF;
             k=0;
             for(i=0;i<p->bsize;++i)
            {
                   if(e>limit[i])
                  {
                        k=p->base[i];
                        e=limit[i];
                   }
             }
             if(e==E_INF) //此时，这个线性规划将是一个无界的
            {
                   printf("无界的表达式，%d松弛表达式输入错误!\n");
                   free(limit);
                   return 0;
             }
             else
                   pivot(p,imax,k);
        }
        free(limit);
        return 1;
  }
//将长生的松弛型输出
  void  print_relax_type(Linear  *p)
 {
        int        i,j,k,t;
        double     e,(*ma)[10]=p->ma;

        for(i=0;i<p->bsize;++i)
       {
              k=p->base[i];
              printf("\n第%d行  :常系数:  %lf\n",k,p->bcst[k]);
              for(j=0;j<p->nsize;++j)
             {
                     t=p->nbase[j];
                     printf("%d :%8lf   ",t,ma[k][t]); 
              }
        }
  }
  int  main(int  argc,char *argv[])
 {
        int       i,k;
/*
        double    ma[6][10]={ {0,0,0},{0,0,0},{0,0,0},
                               {1,2,3},
                               {2,2,5},
                               {4,1,2}
                         };
        int       nbase[3]={0,1,2};
        int       base[3]={3,4,5};
        double    bcst[10]={0,0,0,30,24,36};
        double    v=0;
        double    aimc[10]={3,1,2,0,0,0};
        Linear  pg,*p=&pg;

        p->bsize=3;
        p->base=base;
        p->nsize=3;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("开始计算......\n");
        if(simplex(p))
       {
               printf("最大值为:%lf  \n",p->v);
               printf("各个变量的取值如下所示:\n");
               for(i=0;i<p->bsize;++i)
              {
                      k=p->base[i];
                      printf("X(%d):%lf\n",k,p->bcst[k]);
               }
        }
        else
            printf("计算发生错误!\n");
*/
/*
       double    ma[6][10]={
                               {1,2,3},
                               {2,2,5},
                               {4,1,2}
                         };
        int       nbase[3]={0,1,2};
        int       base[3]={3,4,5};
        double    bcst[10]={30,24,36};
        double    v=0;
        double    aimc[10]={3,1,2,0,0,0};
        Linear  pg,*p=&pg;

        p->bsize=3;
        p->base=base;
        p->nsize=3;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("开始计算标准型!\n");
        formal_to_relax_type(p);
        print_relax_type(p);
*/
        double    ma[6][10]={
                               {2,-1},
                               {1,-5},
                         };
        int       nbase[3]={0,1};
        int       base[3]={2,3};
        double    bcst[10]={2,-4};
        double    v=0;
        double    aimc[10]={2,-1};
        Linear  pg,*p=&pg;

        p->bsize=2;
        p->base=base;
        p->nsize=2;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("开始计算标准型!\n");
        if(!formal_to_relax_type(p))
       {
               printf("转换失败!\n");
               return 1;
        }
        print_relax_type(p);
        printf("\n");
        return 0;
  }