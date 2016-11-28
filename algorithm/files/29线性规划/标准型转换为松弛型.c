//2013年3月20日19:55:10
//函数声明
    static  void  operate_and_move_data(Linear  *p);
    static  int  solve_new_exp(Linear  *p);
    static  void  operate_relax_exp(Linear  *p );
//线性规划，标准型转换为松弛型,若成功，返回1，失败返回0
  int   formal_to_relax_type(Linear   *p)
 {
         int  i,j,k;
         int  min;
         double   e;
         double  (*ma)[10]=p->ma,*exp,*save;
//检测原来的线性规划中的最小常数值

         e=E_INF;
         k=0;
         for(i=0;i<p->bsize;++i)  //p->bsize为方程的个数
        {
               if(e>p->bcst[i])
              {
                      k=i;
                      e=p->bcst[i];
               }
         }
         if(e>0)    //此时，因为所有的常数都大于0，所以在经过数据的移动后就可以直接返回1
        {
               operate_and_move_data(p);
               return 1;
         }
         min=k;
//如果在原来的标准型中含有负常数，就将其转换冲另一种和它等价的形式
         k=p->bsize+p->nsize+1;
         exp=(double  *)malloc(sizeof(double)*k);
         for(i=0;i<k;++i)
              exp[i]=0;
         exp[k-1]=-1;
//将原来表达式中保存下来
         save=p->aimc;
         p->aimc=exp;
//创建新的松弛型
//在系数矩阵中增加新的项,之后转移数据
         operate_and_move_data(p);
         p->nbase[p->nsize]=k-1;
         p->nsize+=1;
         for(i=0;i<p->bsize;++i)
        {
               j=p->base[i];
               ma[j][k-1]=-1;
         }
//选取新的主元
//重新选取最小值
         min+=p->bsize;
         printf("\nmin:%d  \n",min);
         pivot(p,k-1,min);
         print_relax_type(p);
         printf("\n****************************************\n");
//对新生成的松弛表达式进行求解
         if( !solve_new_exp(p) )
        {
                p->aimc=save;
                free(exp);
                return 0;
         }
         printf("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
         print_relax_type(p);
         printf("\n****************************************\n");
//查看最终的求解集合
         j=0;
         for(i=0;i<p->nsize;++i)
        {
                if(p->nbase[i]==(k-1))//如果 k-1 是一个非基变量，那么它的最终的值一定为0
               {
//此时 就可以再次进行转换了
                     j=1;
                     break;
                }
         }
         free(exp);
         p->aimc=save;
         if( ! j )
        {
                printf("这个线性规划无可行解!\n");
                return 0;
         }
//转换原来的松弛型的目标表达式
         operate_relax_exp(p);
//将 (k-1)删除掉
         for(i=0;i<p->nsize;++i)
        {
              if(p->nbase[i]==(k-1))
                     break;
         }
         for(++i;i<p->nsize;++i)
                  p->nbase[i-1]=p->nbase[i];
         --p->nsize;
         return 1;     
  }
  static  void  operate_and_move_data(Linear  *p)
 {
         int   i,j,k;
		     double  (*ma)[10]=p->ma;
//增加基变量  && 首先移动矩阵中的数据
         for(i=0;i<p->bsize;++i)
        {
               j=p->bsize+i;
               p->base[i]=p->nsize+i;
               p->bcst[j]=p->bcst[i];
               for(k=0;k<p->nsize;++k)
                     ma[j][k]=ma[i][k];
         }
  }
//求解给定的松弛型
  static  int  solve_new_exp(Linear  *p)
 {
         int      max,i,k;
         double   e,*limit;
         double   (*ma)[10]=p->ma;
         limit=(double *)malloc(sizeof(double)*p->bsize);
 
         while( judge_const(p,&max) )
        {
                for(i=0;i<p->bsize;++i)
               {
                       k=p->base[i];
                       e=ma[k][max];
                       if( e>0 )
                             limit[i]=p->bcst[k]/e;
                       else
                             limit[i]=E_INF;
                }
     //查找最小元素
                e=E_INF;
                k=0;
                for(i=0;i<p->bsize;++i)
               {
                       if( e>limit[i] )
                      {
                             e=limit[i];
                             k=p->base[i];
                       }
                }
                if( e==E_INF )
               {
                        printf("这个线性规划是无界的!\n");
                        free(limit);
                        return 0;
                }
                else
                        pivot(p,max,k);
         }
         free(limit);
         return 1;
  }
//处理最后的松弛表达式的目标函数
  static  void  operate_relax_exp(Linear  *p )
 {
         int  k=p->nsize-1;
         int  i,j,m,n;
         double   e;
         double  (*ma)[10]=p->ma;

//先对表达式进行处理
         for(i=0;i<p->bsize;++i)
        {
//如果表达式包含基变量，就将它代换掉
                j=p->base[i];
                if(j<k && p->aimc[j]!=0)
               {
//更新常数项
                       e=p->aimc[j];
                       p->v+=p->bcst[j]*e;
//更新目标表达式中非基变量的系数,将第 j 行表达式代入
                       for(m=0;m<p->nsize;++m)
                      {
                             n=p->nbase[m];
                             p->aimc[n]-=ma[j][n]* e;
                       }
                }
         }       
  }