//2013年3月13日15:04:22
//求解N维线性方程组(具有n个方程，且含有n个未知参数的方程组,亦即系数矩阵为非奇异的N阶方阵)
  #include<stdio.h>
  #include<stdlib.h>

//N阶方阵的LUP分解
//ma为输入矩阵，row为实际输入的矩阵维数，pi为 置换矩阵的一尾表现pi[i]=j表示 置换矩阵的i行j列为1
//若输入矩阵能够计算出 LPU 分解，返回1，否则返回0
  static  int  lup_decomposition(double (*ma)[10],double *value,int row,int *pi)
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

//                    e=value[k];
//                    value[k]=value[t];
//                    value[t]=e;
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
//求解线性方程组
//参数的含义
/*
  ma:输入矩阵(方程组的系数矩阵)
  row:输入矩阵实际的输入规模(方程组的未知数个数)
  value:方程组的等式右边的row维值向量
  resolved:存放结果的数组
*/
//若方程组有解返回1，否则返回0
  int   resolve_linear_quatation(double  (*ma)[10],double *value,double *resolved,int row)
 { 
        int      i,j,k;
        int      *pi;
        double   p,e;

        pi=(int *)malloc(sizeof(int)*row);
        if(! lup_decomposition(ma,value,row,pi))
       {
            free(pi);
            return 0;
        }
//下面 将对返回的矩阵ma进行解码，并求解线性方程组
        printf("**************************************\n");
        for(i=0;i<row;++i)
       {
              j=pi[i];
              if(j!=-1)
             {
                    k=i;
                    while(j!=i)
                   {
                        e=value[k];
                        value[k]=value[j];
                        value[j]=e;

                        pi[k]=-1;
                        k=j;
                        j=pi[k];
                    }
                    pi[k]=-1;
              }
        }
/*
        for(i=0;i<row;++i)
             printf("%d--->%d \n",i,pi[i]);
        for(i=0;i<row;++i)
             printf("%d--->%lf\n",i,value[i]);
*/
//先求解下三角矩阵
        for(i=0;i<row;++i)
       {
              p=value[i];
              for(j=0;j<i;++j)
                  p-=ma[i][j]*resolved[j];
              resolved[i]=p;
        }
//再求解上三角矩阵
        for(i=row-1;i>=0;--i)
       {
              p=resolved[i];
              for(j=row-1;j>i;--j)
                   p-=ma[i][j]*resolved[j];
              resolved[i]=p/ma[i][i];
        }
        free(pi);
        return 1;
  }
//测试数据
  int  main(int  argc,char *argv[])
 {

        double  ma[10][10]={ {1,5,4},
                          {2,0,3},
                          {5,8,2}
                         };
        double  value[10]={12,9,5};
/*

        double  ma[10][10]={  {2,1 ,1},
                              {3,2,4},
                              {5,1,4}
                            };
        double  value[10]={13,23,31};
*/
        int  row=3;
        int  i,j=0;
        double  resolved[10],e;
        

        if(! resolve_linear_quatation(ma,value,resolved,row))
       {
                printf("求解线性方程组失败!\n");
                return 1;
        }
        printf("线性方程组的解如下所示:\n");
        for(i=0;i<row;++i)
            printf("x(%d): %lf \n",i,resolved[i]);
        printf("------------------------------------  \n");

        e=resolved[0]+5*resolved[1]+4*resolved[2];
        printf("%lf  \n",e);
        e=resolved[0]*2+3*resolved[2];
        printf(" %lf  \n",e);
        e=resolved[0]*5+8*resolved[1]+2*resolved[2];
        printf(" %lf  \n",e);
/*
        e=2*resolved[0]+resolved[1]+resolved[2];
        printf("%lf  \n",e);
        e=3*resolved[0]+2*resolved[1]+4*resolved[2];
        printf(" %lf  \n",e);
        e=5*resolved[0]+resolved[1]+4*resolved[2];
        printf(" %lf  \n",e);
*/
        return 0;
  }