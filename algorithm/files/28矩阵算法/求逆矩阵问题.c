//2013年3月14日11:59:03
//求 非奇异矩阵的逆矩阵
  #include<stdio.h>
  #include<stdlib.h>
//利用矩阵的LUP分解，求解矩阵的逆矩阵问题
  static  int  lup_decomposition(double (*ma)[10],int *pi,int row)
 {
        int      i,j,k,t;
        double   p,e;

//先对数据进行必要的初始化
        for(i=0;i<row;++i)
             pi[i]=i;
//分解输入矩阵,计算后直接写入原来的输入矩阵ma中，并且解码有上层的调用函数进行
        t=0;
        for(k=0;k<row;++k)
       {
              p=0;
              for(i=k;i<row;++i)
             {
                    e=ma[i][k];
                    e=e>0?e:-e;
                    if(e>p)
                   {
                         p=e;
                         t=i;
                    }
              }
              if(p==0)
             {
                    printf("非法的参数，输入矩阵为奇异矩阵!\n");
                    return 0;
              }
//在满足给定的条件下交换数据,注意下面的代码之间的区别，以及它们包含的不同的思想
              if(k!=t)
             {
                    i=pi[t];
                    pi[t]=pi[k];
                    pi[k]=i;
                    for(i=0;i<row;++i)
                   {
                           e=ma[k][i];
                           ma[k][i]=ma[t][i];
                           ma[t][i]=e;
                    }
              }
//更新矩阵中的数据
              p=ma[k][k];
              for(i=k+1;i<row;++i)
             {
                    ma[i][k]/=p;
                    for(j=k+1;j<row;++j)
                          ma[i][j]-=ma[i][k]*ma[k][j];
              }
        }
        return 1;
  }
//设X为所求矩阵A的逆矩阵,则A*X=I(n);又X为n个n维向量构成的，所以可以解n个n阶方程组的解
//使用矩阵的LUP分解，可以在O(n*n)的渐进时间内接触这N个向量
  int  reverse_matrix(double (*ma)[10],double (*rever)[10],int  row)
 {
        int       *pi,*tag;
        int       i,j,k,t;
        double    *value;
        double    *resolve;
        double    p;
        
        pi=(int *)malloc(sizeof(int)*row);
        tag=(int *)malloc(sizeof(int)*row);
        value=(double *)malloc(sizeof(double)*row);
        resolve=(double *)malloc(sizeof(double)*row);

        if(!  lup_decomposition(ma,pi,row))
       {
               free(pi);
               free(tag);
               free(value);
               free(resolve);
               return  0;
        }
        for(k=0;k<row;++k)
       {
//令方程组等式右边的值 为一个单位向量(第K个元素为1)
              for(i=0;i<row;++i)
                    value[i]=0;
              value[k]=1;
//对数据进行一些必要的初始化
              for(i=0;i<row;++i)
                    tag[i]=0;
//调整单位向量中元素1的位置
              for(i=0;i<row;++i)
             {
                    j=pi[i];
//如果第i个数组元素还没有被访问过
                    if(! tag[j])
                   {
                         t=i;
                         while(j!=i)
                        {
                               p=value[t];
                               value[t]=value[j];
                               value[j]=p;
//注意下面的标记顺序，它的步骤顺序非常重要
                               tag[t]=1;
                               t=j;
                               j=pi[t];
                          }
                          tag[t]=1;
                     }
               }
//使用下三角矩阵求解
              for(j=0;j<row;++j)
             {
                   p=value[j];
                   for(i=0;i<j;++i)
                       p-=ma[j][i]*resolve[i];
                   resolve[j]=p;
              }
//使用上三角矩阵求解
              for(j=row-1;j>=0;--j)
             {
                   p=resolve[j];
                   for(i=row-1;i>j;--i)
                       p-=ma[j][i]*resolve[i];
                   resolve[j]=p/ma[j][j];
              }
//复制到目标矩阵的第k列中
              for(i=0;i<row;++i)
                   rever[i][k]=resolve[i];
       }
       free(pi);
       free(tag);
       free(value);
       free(resolve);
       return 1;
  }
  int  main(int argc,char *argv[])
 {
       double  ma[10][10]={   {2,1,1},
                              {3,2,4},
                              {5,1,4}
                           };
       double  tmp[10][10];
       double  resolve[10][10],p;
       int     i,j,k,row=3;
       for(i=0;i<row;++i)
           for(j=0;j<row;++j)
                tmp[i][j]=ma[i][j];
 
       printf("开始求解逆矩阵....\n");
       reverse_matrix(ma,resolve,row);
       printf("\n验证求解的结果...\n");

       for(i=0;i<row;++i)
      {
            for(j=0;j<row;++j)
                  printf(" %8lf ",resolve[i][j]);
            printf("\n");
       }
       printf("\n*************************************************\n");
       for(i=0;i<row;++i)
      {
            for(j=0;j<row;++j)
           {
                  p=0;
                  for(k=0;k<row;++k)
                        p+=tmp[i][k]*resolve[k][j];
                  printf(" %8lf ",p);
            }
            printf("\n");
       }
       return 0;
  }