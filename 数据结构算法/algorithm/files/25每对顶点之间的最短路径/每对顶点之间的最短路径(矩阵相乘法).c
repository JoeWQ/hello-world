//2013年3月4日17:11:01
//使用矩阵相乘法计算每对顶点之间的最短路径
//在使用图的表示时，我们使用的是临邻接矩阵
  #include<stdio.h>
//定义无穷大数
  #define   INF_T    0x30000000
//*********************************
  int   weight[5][5]={{0,3,8,INF_T,-4},
                        {INF_T,0,INF_T,1,7},
                        {INF_T,4,0,INF_T,INF_T},
                        {2,INF_T,-5,0,INF_T},
                        {INF_T,INF_T,INF_T,6,0}
                       };
  int   lct[5][5];
//mat作为一个L(n-1)的矩阵输入，而lct作为L(n)的矩阵输入，weight是一个各个顶点之间的权值矩阵
//矩阵相乘法的含义是，每次循环，将会将最短路径至少向外扩展一条边
  static  void  shortest_paths(int (*mat)[5],int (*lct)[5],int (*weight)[5])
 {
       int  i,j,k,result;
       int   row=5,t;
//一下是矩阵相乘法的步骤
       for(i=0;i<row;++i)
      {
              for(j=0;j<row;++j)
             {
                    result=INF_T;
                    for(k=0;k<row;++k)
                   {
                           t=mat[i][k]+weight[k][j];
                           if(result>t)
                                 result=t;
                    }
                    lct[i][j]=result;
              }
        }
   }
//计算最短路径的总调度算法
   void  all_pairs_shortest_paths(int (*weight)[5],int (*lct)[5])
  {
        int  mat1[5][5];
        int  mat2[5][5];
        int  i,j,k;
        int  (*p)[5],(*q)[5],(*t)[5];
        
        p=mat1,q=mat2;
        k=5;
//首先对mat1矩阵进行初始化
        for(i=0;i<k;++i)
            for(j=0;j<k;++j)
                   mat1[i][j]=weight[i][j];
//开始计算最短路径
        --k;
//注意，两个顶点的最短路径之间最多有(n-1)条边
        t=NULL;
        for(i=0;i<k;++i)
       {
              shortest_paths(p,q,weight);
              t=p;
              p=q;
              q=t;
        }
        k=5;
        for(i=0;i<k;++i)
             for(j=0;j<k;++j)
                 lct[i][j]=t[i][j];
  }
//另一种矩阵乘法算法 但是它的计算速度要快一些
  static  int  lg2(int i)
 {
        int  k=0;
        while( i>>=1 )
           ++k;
        return k;
  }
  void  fast_all_pairs_shortest_paths(int (*weight)[5],int (*lct)[5])
 {
        int    i,k,row,len;
        int    mat1[5][5],mat2[5][5];
        int    *a,*b,*c;

        c=(int *)weight;
        a=(int *)mat1;
        b=(int *)mat2;

        row=5;
        len=25;
//初始赋值
        for(i=0;i<len;++i,++a,++b,++c)
       {
             *a=*c;
             *b=*c;
        }
//对数级别的运算量
        
        for(i=1;i<=row;i<<=1)
       {
              shortest_paths(mat1,mat2,weight);
              a=(int *)mat1;
              b=(int *)mat2;
              for(k=0;k<len;++k,a++,b++)
                   *a=*b;
        }
//将最终的计算结果复制到目标缓存中
        c=(int *)lct;
        for(k=0;k<len;++k,++b,++c)
             *c=*b;
  }
//********************************************
  int  main(int  argc,char *argv[])
 {
        int  i,j,k=5;

        all_pairs_shortest_paths(weight,lct);
//打印
        for(i=0;i<k;++i)
       {
              for(j=0;j<k;++j)
                      printf("%d       ",lct[i][j]);
              printf("\n");
        }

        printf("********************************************\n");
        fast_all_pairs_shortest_paths(weight,lct);
//打印快速计算的矩阵内容
        for(i=0;i<k;++i)
       {
              for(j=0;j<k;++j)
                      printf("%d       ",lct[i][j]);
              printf("\n");
        }        
        return 0;
  }