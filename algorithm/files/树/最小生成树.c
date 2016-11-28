//2012/12/14/9:37
//计算图的最小生成树，这里采用的是 克鲁斯卡 算法
  #include<stdio.h>
  #include<stdlib.h>
/************************************************/
//引入定义图结构的文件
  #include"GraphStructure.h"
//引入和和图中顶点相关的边的操作相关的数据结构定义文件
  #include"Edge.h"
//参数的含义:指向图信息头的指针，指向图邻接矩阵的指针，这个矩阵所包含的实际有效列数
  void  CreateGraph(GraphHeader *,int (*p)[10],int);
//和创建图的边相关的函数
  static void CreateGraphEdges(EdgeInfo *,GraphHeader *);
//检查新取出的边是否会在已经建立的边中构成回路
  static  int  find_back_edge(int  *,Edge *);
//获取最小生成树的边的集合
  int  GetMinTreeEdges(EdgeInfo *,GraphHeader *);
//创建邻接矩阵
  void  CreateMatrix(int (*p)[10],int *);
/***************************************************************/
//将边压入栈中，并对压入的边进行排序
  static void  push(EdgeInfo *,PostGraph *);
//从栈中弹出边
  static int   pop(EdgeInfo *,Edge *);
//********************************************
//对树边进行排序
  static void  sort_edge(EdgeInfo *,Edge *);
  static int  matrix[10][10];

  void  CreateGraph(GraphHeader *h,int (*matx)[10],int n)
 {
        int        i,j;
        Graph      *g;
        PostGraph  *pst;

        h->size=n;
        g=(Graph *)malloc(sizeof(Graph)*n);
        h->graph=g;
        

        for(i=0;i<n;++i,++g)
       {
              g->size=0;
              g->front=NULL;
              g->rear=NULL;
              for(j=i; j<n;++j)
             {
                    if(matx[i][j])
                   {
                           pst=(PostGraph *)malloc(sizeof(PostGraph));
                           pst->vertex=j;
                           pst->vp=i;
                           pst->next=NULL;
                           pst->cost=matx[i][j];
                           ++g->size;
                           if(! g->front)
                                g->front=pst;
                           else
                                g->rear->next=pst;
                           g->rear=pst;
                    }
              }
        }
  }
//创建图的邻接矩阵表示
  void  CreateMatrix(int (*matx)[10],int *size)
 {
        int  i,j,n,path;

        do
       {
             printf("请输入图的定点数目(>=2 && <10):\n");
             scanf("%d",&n);
        }while(n<2 || n>=10);
        for(i=0;i<n;++i)
           for(j=0;j<n;++j)
               matx[i][j]=0;
        printf("请输入顶点v与顶点w和他们的路径，\n比如 1 2 3就表示顶点1,2,的路径为3。如果两个顶点没有相邻，则他们的路径就为0\n,因此您不能为两个顶点的距离输入0\n而且，v,w的值不能相同 输入 -1 -1 表示退出!\n");
        do
       {
             printf("请输入顶点之间的路径:\n");
             i=-1,j=-1,path=-1;
             scanf("%d %d %d",&i,&j,&path);
             if(i==-1 && j==-1)
                   break;
             if(i<0 || i>=n || j<0 || j>=n || i==j || path<0)
            {
                   printf("您输入的值非法，请重新输入!\n"); 
                   continue;
             }
             printf("顶点 %d ,%d 的距离为%d\n",i,j,path);
             matx[i][j]=path;
             matx[j][i]=path;
       }while( 1 );
       *size=n;
  }
//创建图的所有的边的集合
  static void  CreateGraphEdges(EdgeInfo  *edges,GraphHeader *h)
 {
       int         i,size;
       Graph       *graph;
       PostGraph   *pst;
       Edge        edge,*e;
 
       e=&edge;
       size=h->size;
       graph=h->graph;
       edges->size=0;
       edges->front=NULL;

      for(i=0;i<size;++i,++graph)
     {
            pst=graph->front;
            while( pst )
           {
                push(edges,pst);
                pst=pst->next;
            }
     }
  }
//从已经生成的边的集合info/einfo中选取最小，且不对已经选好的边构成回路的边并写入edges中
//如果返回的边少于h->size-1个，则失败返回0，否则返回1
  int  GetMinTreeEdges(EdgeInfo *edges,GraphHeader *h)
 {
      int       i,size;
      int       n,*parent;
//      int       from,to;
      Edge      edge,*e;
      EdgeInfo  einfo,*info;
//初始化各种数据
      size=h->size;
      parent=(int *)malloc(sizeof(int)*size);
      e=&edge;

      info=&einfo;
      info->size=0;
      info->front=NULL;

      n=size-1;
      edges->size=0;
      edges->front=NULL;
//parent数组在判断两个顶点是否位于同一个集合，或者换句话说，判断已经选取的边是否构成回路方面，起着非常大的作用
      for(i=0;i<size;++i)
          parent[i]=-1;
//创建所有边的集合
     CreateGraphEdges(info,h);

//如果所选取的边少于h->size-1个，那么循环继续下去
     while( edges->size<n && info->size)
    {
           pop(info,e);
//判断所选取的边是否对已经有的边构成回路
           if(! find_back_edge(parent,e))
                sort_edge(edges,e);
     }
//释放info结构所占据的额外的内存
     while( info->size )
         pop(info,e);
     
     return edges->size==n;
  }
//和管理边的数据结构相关的数据结构
  static void  push(EdgeInfo *info,PostGraph *pst)
 {
      Edge  *tmp=(Edge *)malloc(sizeof(Edge));
      Edge  *s=NULL,*p=NULL;
      tmp->from=pst->vp;
      tmp->to=pst->vertex;
      tmp->cost=pst->cost;
      tmp->next=NULL;

      ++info->size;
      s=info->front;
//下面的结构形似于插入排序
      if(! s)
         info->front=tmp;
      else
     {
            while(s && tmp->cost>s->cost)
           {
                p=s;
                s=s->next;
            }
//如果tmp->cost的值最小
            if(! p)
           {
                  tmp->next=s;
                  info->front=tmp;
            }
//如果tmp是处于中间小的数
            else if( s )
           {
                  p->next=tmp;
                  tmp->next=s;
            }
//否则，tmp被排列在栈的末尾
            else
                  p->next=tmp;
      }
  }
//从栈中弹出栈顶元素,若成功，则返回1，否则返回0
  static  int  pop(EdgeInfo *info,Edge *e)
 {
      Edge   *s=info->front;
      
      if( s )
     {
            e->from=s->from;
            e->to=s->to;
            e->cost=s->cost;
            --info->size;
            info->front=s->next;
            free(s);
            return 1;
      }
      return 0;
  }
//判断给定的边是否对已经生成的树边构成回路，若不构成，则返回0，否则返回1
  static int  find_back_edge(int *parent,Edge *e)
 {
      int  from=e->from;
      int  to=e->to;
//vf,vt记录from,to的祖先节点
 //     int  vf,vt,flag=0;
//祖先节点的定义，以每一个树边集合中顶点的数值最小的那个数作为这个集合中所有的顶点的祖先
      for(  ;parent[from]!=-1;from=parent[from])
          ;
      for(  ;parent[to]!=-1;to=parent[to])
          ;
//如果from,to位于不同的集合，则表示from,to不在同一个集合中，则先进行集合合并操作,再返回0
      if(from!=to)
     {
            if(from>to)
                 parent[from]=to;
            else
                 parent[to]=from;
            return 0;
     }
     return 1;
  }
//对树边进行排序，这里所谓的排序，并非按照数值大小进行排序，而是按照顶点的数字标号的递增次序
  static  void  sort_edge(EdgeInfo *info,Edge *e)
 {
      int  from=e->from;
      int  to=e->to;
      Edge *s,*p=NULL,*tmp;
      
      ++info->size;
      s=info->front;

      tmp=(Edge *)malloc(sizeof(Edge));
      tmp->from=from;
      tmp->to=to;
      tmp->cost=e->cost;
      tmp->next=NULL;

      if(! s )
             info->front=tmp;
      else
     {
             while( s )
            {
                  if(s->from==from || s->from==to || s->to==from || s->to==to)
                       break;
                  p=s;
                  s=s->next;
             }
//如果没有查找到
             if(! s)
                   p->next=tmp;
             else if(s->from==tmp->to)//插在s的前面
            {
                   tmp->next=s;
                   if(s==info->front)
                        info->front=tmp;
                   else//注意，这里很有问题
                        p->next=tmp;
             }
             else//插在s的后面
            {
                  tmp->next=s->next;
                  s->next=tmp;
            }
       }
  }
//开始测试
  int  main(int argc,char *argv[])
 {
       int          size;
       GraphHeader  gh,*h;
       EdgeInfo     einfo,*info;
       Edge         edge,*e;

       h=&gh;
       info=&einfo;

       h->graph=NULL;
       h->size=0;
       info->size=0;
       info->front=NULL;

       printf("开始创建图的邻接矩阵存储表示........\n");
       CreateMatrix(matrix,&size);
//
       printf("开始创建邻接表....\n");
       CreateGraph(h,matrix,size);
  
       printf("开始获取图的最小生成树....\n");
       GetMinTreeEdges(info,h);

       printf("开始输出....\n");
       e=&edge;
       while( info->size )
      {
           pop(info,e);
           printf("顶点：%d--->%d : %d  \n",e->from,e->to,e->cost);
       }
       return 0;
  }