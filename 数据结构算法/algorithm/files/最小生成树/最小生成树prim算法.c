//2013/1/22/18:44
//2013年1月22日18:52:54
//最小生成树de  Prim算法实现
//在本程序中，为了体现他的思路，并没有使用斐波那契堆，因为考虑到它的复杂性
//而且，对于小规模的图，也并不适合
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"
  #define   INT_F    0x70000000
/*************************************************/
  static  int  find_min(int *,int *,int);
//创建图的邻接表表示,它的邻接矩阵表示是一个实对称矩阵
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("请输入图的顶点数目(>1 && <17)!\n");
       do
      {
             size=1;
             printf("请输入符合要求的顶点数:\n");
             scanf("%d",&size);
       }while(size<=1 || size>16);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->v=0;
             graph->finish=0;
             graph->front=NULL;
       }
       graph=h->graph;
       printf("请输入顶点之间的关联 (-1 -1)表示退出!\n");
       do
      {
             printf("请输入顶点与顶点之间的关联:\n");
             i=j=0;
             weight=-1;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i==j || i<0 || i>=size || j<0 || j>=size || weight<0)
            {
                    printf("非法的输入!\n");
                    continue;
             }
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=j;
             pst->vp=i;
             pst->weight=weight;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;

             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=i;
             pst->vp=j;
             pst->weight=weight;
             pst->next=graph[j].front;
             graph[j].front=pst;

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
/********************最小生成树的prim算法***********************/
  void  min_span_tree_prim(GraphHeader  *h,int start)
 {
//这个数组记录 给定的结点是否已经被选中了
       int        *tag,size;
//记录与对应的索引 所对应的父结点
       int        *parent,*key;
       Graph      *graph;
       PostGraph  *pst;
       int        i,k;
/*初始化临时数据*/
       size=h->size;
       tag=(int *)malloc(sizeof(int)*size);
       parent=(int *)malloc(sizeof(int)*size);
       key=(int *)malloc(sizeof(int)*size);
       graph=h->graph;
       pst=NULL;

       for(i=0;i<size;++i)
      {
             tag[i]=0;
             parent[i]=-1;
             key[i]=INT_F;
       }
//进入循环，逐步生成 最小树,从被选中的结点开始
       key[start]=0;
       for(i=1;i<size;++i)
      {
             k=find_min(tag,key,size);
             pst=graph[k].front;
//更新 顶点之间的距离
             for(  ; pst ;pst=pst->next)
            {
//如果顶点没有被选中，且有更小的权值出现，就更新
/*注意下面在算法的思想层次上，它很类似于迪杰斯特拉算法*/
                     if(!tag[pst->vertex] && pst->weight<key[pst->vertex])
                    {
                             key[pst->vertex]=pst->weight;
                             parent[pst->vertex]=k;
                     }
             }
       }
//输出生成最小生成树
       for(i=0;i<size;++i)
      {
            if(i!=start)
                printf(" 顶点%d--->%d: \n",i,parent[i]);
            else
                printf("根顶点%d  \n",i);
       }
      free(key);
      free(parent);
      free(tag);
  }
  static  int  find_min(int *tag,int *key,int size)
 {
        int   i,k=0;
        int   min=INT_F;

        for(i=0;i<size;++i)
       {
//如果顶点i还没有被选中,且它的最小权值
              if(!tag[i] && min>key[i])
             {
                    min=key[i];
                    k=i;
              }
        }
        tag[k]=1;
        return k;
  }
//*********************************************
  int  main(int argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       printf("创建图的邻接表表示:.............\n");
       CreateGraph(h);
     
       printf("****************下面是prim算法生成的最小生成树*****************************\n");
       min_span_tree_prim(h,0);
       return 0;
  }