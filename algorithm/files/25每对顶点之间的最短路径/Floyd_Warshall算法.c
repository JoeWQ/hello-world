//2013年3月4日19:43:32
//每对顶点之间的最短路径，Floyd-Warshall算法，它的运行时间要比矩阵乘法更快
// 这个算法的核心思想是 动态规划
  #include<stdio.h>
  #define  INF_T    0x30000000

  int  weight[5][5]={   {0,3,8,INF_T,-4},
                        {INF_T,0,INF_T,1,7},
                        {INF_T,4,0,INF_T,INF_T},
                        {2,INF_T,-5,0,INF_T},
                        {INF_T,INF_T,INF_T,6,0}
                     };
  int  lct[5][5];
  int  closure[5][5];

  void  floyd_warshall_shortest_paths(int (*weight)[5],int (*lct)[5])
 {
        int  i,j,k,row=5,lt;
        int  mat[5][5];
        int  (*p)[5]=lct,(*q)[5]=mat,(*t)[5]=NULL;
        int  *a,*b;

//        a=(int *)mat;
//        b=(int *)weight;

        for(i=0;i<row;++i)
            for(j=0;j<row;++j)
                mat[i][j]=weight[i][j];

        for(k=0;k<row;++k)
       {
              for(i=0;i<row;++i)
                 for(j=0;j<row;++j)
                {
//注意下面的代码
                       p[i][j]=q[i][j];  //注意这一步很重要
                       lt=q[i][k]+q[k][j];
                       if(q[i][j]>lt)
                             p[i][j]=lt;
                 }
              t=p;
              p=q;
              q=t;
        }
        if(t!=lct)
       {
              a=(int *)lct;
              b=(int *)mat;
              lt=row*row;
              for(i=0;i<lt;++i,++a,++b)
                  *a=*b;
        }
  }
//有向图的传递闭包,在算法的形式上，它和上面的算法是相似的，不同的是，这个方法的计算速度更快
  void  transitive_closure(int  (*weight)[5],int  (*lct)[5])
 {
        int  mat[5][5];
        int  (*p)[5]=lct,(*q)[5]=mat,(*t)[5]=NULL;
        int  i,j,k,lt,row=5;
        int  *a,*b;
 
        for(i=0;i<row;++i)
           for(j=0;j<row;++j)
          {
                 mat[i][j]=0;
                 if(i==j || weight[i][j]!=INF_T)
                       mat[i][j]=1;
           }
        for(k=0;k<row;++k)
       {
             for(i=0;i<row;++i)
                  for(j=0;j<row;++j)
                       p[i][j]=q[i][j] | (q[i][k] & q[k][j]);
                  t=p;
                  p=q;
                  q=t;
        }
        if(t!=lct)
       {
             a=(int *)lct;
             b=(int *)mat;
             lt=row*row;
             for(i=0;i<lt;++i,++a,++b)
                   *a=*b;
        }
  }
//*********************************************
  int  main(int  argc,char *argv[])
 {
        int  i,j,row=5;
        floyd_warshall_shortest_paths(weight,lct);
        for(i=0;i<row;++i)
       {
             for(j=0;j<row;++j)
                   printf("%d      ",lct[i][j]);
             printf("\n");
        }
        printf("\n***************************************\n");
        transitive_closure(weight,closure);
        for(i=0;i<row;++i)
       {
             for(j=0;j<row;++j)
                  printf("%d      ",closure[i][j]);
             printf("\n");
        }
        return 0;
  }