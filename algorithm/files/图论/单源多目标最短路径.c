//2012/12/15/15:10
//单源多目标的最短路径算法
//这里，我们采用 迪杰斯特拉算法,但是在邻接矩阵的表示中，我们不采用 用一个较大的数字拉表示两个顶点
//不能直达的情况，而是用数字0来表示，因此算法的本身的某些部分需要修改
//但是，这样的修改，会使程序的本身更易于理解
//后来我们发现，这种思路是不行的
  #include<stdio.h>
  #include<stdlib.h>
//用INF_T表示无穷大，表示两个顶点不可达
  #define   INF_T   0x10000000

//在静态区中使用二维数组直接实现邻接矩阵
  static  int  matrix[10][10];
  static  int   distance[10];
//创建图的邻接矩阵表示
  void  CreateAdjMatrix(int (*matx)[10],int *size)
 {
       int  i,j,weight,n;
       
       do
      {   
           n=-1;
           printf("请输入图的顶点数(>=2 && <=10:\n");
           scanf("%d",&n);
       }while(n<1 || n>10);

       *size=n;
       for(i=0;i<n;++i)
          for(j=0;j<n;++j)
              matx[i][j]=INF_T;
 
       printf("请输入顶点与顶点之间的权值,比如1 2 3就表示顶点1,2 之间的权值为3，输入-1 -1 -1表示退出!\n");
       do
      {
             i=-1,j=-1,weight=-1;
             printf("请输入顶点与顶点权值:\n");
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                 break;
             if(i<0 || i>=n || i==j || j<0 || j>=n || weight<0)
            {
                   printf("非法的输入,请重新输入数据!\n");
                   continue;
             }
             printf("顶点%d-->%d ,weight:%d\n",i,j,weight);
             matx[i][j]=weight;
             matx[j][i]=weight;
      }while( 1 );
  }
//计算单源多目标的最短路径,distance表示存储最短距离的数组缓冲区,v表示源顶点
  void  ShortestPath(int (*matx)[10],int size,int v,int *distance)
 {
       int    *found;
       int    i,j,cost,u=0;
       int    n=size-1,min;

       found=(int *)malloc(sizeof(int)*size);
       for(i=0;i<size;++i)
      {
              found[i]=0;
//顶点i到顶点v的距离
              distance[i]=matx[v][i];
       }

       found[v]=1;
       distance[v]=0;
 
       for(i=0;i<n;++i)
      {
//寻找下一个路径距离更小的顶点u
              min=INF_T;
              for(j=0;j<size;++j)
             {
                    if(!found[j]  && min>distance[j])
                   {
                           min=distance[j];
                           u=j;
                    }
              }
              if(min==INF_T)
             {
                  printf("未知的异常发生!\n");
                  break;
              }
              found[u]=1;
              for(j=0;j<size;++j)
             {
                  cost=matx[u][j];
//如果cost为INF_T那么后面的小于运算就不可能通过
                  if(!found[j] && distance[u]+cost<distance[j])
                 {
                        distance[j]=distance[u]+cost;
                  }
              }
       }
       free(found);
  }
//*********************************************************************************
  int  main(int argc,char *argv[])
 {
      int   size,i;
//
      printf("创建邻接矩阵...........\n");
      CreateAdjMatrix(matrix,&size);
      printf("计算图结点的最小路径(从顶点0开始)...\n");
      ShortestPath(matrix,size,0,distance);
      for(i=0;i<size;++i)
     {
           if(distance[i]!=INF_T)
          {
                printf("顶点0--->%d  :%d\n",i,distance[i]);
           }
      }
      return 0;
  }