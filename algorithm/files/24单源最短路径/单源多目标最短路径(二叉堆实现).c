//2013年4月9日12:47:55
//单源多目标的最短路径算法
//这里，我们采用 迪杰斯特拉算法,但是采用的是 最小堆实现
  #include<stdio.h>
  #include<stdlib.h>
//用INF_T表示无穷大，表示两个顶点不可达
  #define   INF_T   0x10000000

  typedef   struct  _VertexInfo
 {
         int       vertex;
//记录vertex顶点的距离
         int       disc;
  }VertexInfo;

//调整最小堆
  static  void  adjust(VertexInfo  *info,int *rindex,int  parent,int  size)
 {
         int          child,index;
         VertexInfo   key;

         key=info[parent];
         index=rindex[parent];
         for(child=parent<<1;  child<=size ;    )
        {
                if(child<size && info[child].disc>info[child+1].disc)
                         ++child;
                if(key.disc>info[child].disc)
               {
                         info[parent]=info[child];
                         rindex[parent]=rindex[child];
                }
                else
                         break;
                parent=child;
                child<<=1;
         }
         rindex[parent]=index;
         info[parent]=key;
  }
//对给定的目标索引，根据它的值向堆的顶部上升
  static  void  bubble_fly(VertexInfo  *info,int *rindex,int  child)
 {
         int          parent,index;
         VertexInfo   key;

         key=info[child];
         index=rindex[child];
         for(parent=child>>1; parent>=1 ;    )
        {
                 if(info[parent].disc>key.disc)
                {
                         info[child]=info[parent];
                         rindex[child]=rindex[parent];
                 }
                 else
                         break;
                 child=parent;
                 parent>>=1;
         }
         info[child]=key;
         rindex[child]=index;
  }
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
//rindex记录着info数组中，各记录所在的索引
       int         *found,*rindex;
       int         i,j,cost,u=0;
       int         info_size=size;
       VertexInfo  *info;

       found=(int *)malloc(sizeof(int)*size);
       rindex=(int *)malloc(sizeof(int)*(size+1));
       info=(VertexInfo *)malloc(sizeof(VertexInfo)*(size+1));
       
       for(i=0;i<size;++i)
      {
              rindex[i]=i+1;
              found[i]=0;
//顶点i到顶点v的距离
              distance[i]=matx[v][i];
       }
//注意下面的赋值操作 一定要注意是正确的
       distance[v]=0;
       for(i=1;i<=size;++i)
      {
              info[i].vertex=i-1;
              info[i].disc=distance[i-1];
       }
//调整堆结构
       for(i=info_size>>1;i>=1;--i)
              adjust(info,rindex,i,info_size);
/*
       for(i=1;i<=size;++i)
            printf("vertex:%d -->disc:%d  \n",info[i].vertex,info[i].disc);
       printf("\n");
       for(i=0;i<size;++i)
            printf("rindex:%d--->vertex %d \n",i,rindex[i]);
*/
       for(i=0;i<size-1;++i)
      {
//寻找下一个路径距离更小的顶点u
              u=info[1].vertex;
              found[u]=1;
              info[1]=info[info_size];
              rindex[info[1].vertex]=1;
              adjust(info,rindex,1,--info_size);
//如果采用邻接表 ，那么整个函数的运行时间的数量级 将会进一步降低到 (V*lnV+E)
              for(j=0;j<size;++j)
             {
                  cost=matx[u][j];
//如果cost为INF_T那么后面的小于运算就不可能通过
                  if(!found[j] && distance[u]+cost<distance[j])
                 {
                        distance[j]=distance[u]+cost;
                        v=rindex[j];
                        info[v].disc=distance[j];
//注意下面的这一步操作
                        bubble_fly(info,rindex,v);
                  }
              }
       }
       free(info);
       free(rindex);
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