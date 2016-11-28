//2012/12/11/20:45
  #include<stdio.h>
  #include<stdlib.h>
/*************************************/

//定义和图相关的数据结构
  typedef  struct  _PostGraph
 {
       int                   vertex;
       int                   vp;
       struct   _PostGraph   *next;
  }PostGraph;
  typedef  struct  _Graph
 {
//定义该节点的标示
       struct  _PostGraph       *front;
//指向下一个图结构的指针
       struct  _PostGraph       *rear;
//一个额外的数据域吧，记录该节点的深度优先访问的父结点
//       int                      vgp;
       int                      len;
  }Graph;
  
  typedef  struct  _GraphHeader
 {
       int              size;
       struct  _Graph   *graph;
  }GraphHeader;
//*************************************
  typedef  struct  _Stack
 {
       struct  _PostGraph  *pst;
       int                 vgp;//记录该节点的父节点的在图中的索引
       struct  _Stack      *next;
  }Stack;
  typedef  struct  _StackInfo
 {
       struct  _Stack   *front;

       int              size;
  }StackInfo;
//定义公共的矩阵
  static int  matrix[10][10];
  static int  low[32];
  static int  dfn[32];
//记录一个节点的父结点的索引下标
  static int  parent[32];
  static int  count=0;

  void  CreateGraph(GraphHeader *,int (*p)[10],int);
//计算图的关节点，并写入vbuf数组中，vbuf[0]返回数组的长度，后面紧跟节点的标示
  void  atic_point(GraphHeader *,int *vbuf);
//计算图顶点的dfn值和low值，但是这个是一个内部函数s
  static  void  dfnlow(Graph *,PostGraph  *,int);
//和动态栈的相关函数
  static  void  push(StackInfo *,PostGraph *,int);
  static  void  pop(StackInfo *,Stack *);
/***********************************************************/
  void  CreateGraph(GraphHeader *h,int (*matx)[10],int size)
 {
        Graph       *g;
        PostGraph   *p;
        int    i,j,tmp;
        h->size=size;
        g=(Graph *)malloc(sizeof(Graph)*size);
        h->graph=g;

        for(i=0;i<size;++i,++g)
       {
              g->front=NULL;
              g->rear=NULL;
              g->len=0;
             for(j=0;j<size;++j)
            {
                   tmp=matx[i][j];
                   if(tmp)
                  {
                         ++g->len;
                         p=(PostGraph *)malloc(sizeof(PostGraph));
                         p->vertex=j;
                         p->vp=i;
                         p->next=NULL;
                         if(!g->front)
                             g->front=p;
                         else
                             g->rear->next=p;
                         g->rear=p;
                   }
             }
         }
  }
//和动态栈相关的函数,注意这个动态栈在逻辑操作上是不合常规的
  static  void  push(StackInfo *info,PostGraph *p,int vgp)
 {
        Stack  *s=(Stack *)malloc(sizeof(Stack));
        s->pst=p;
        s->vgp=vgp;
        ++info->size;
        s->next=info->front;
        info->front=s;
  }
  static  void  pop(StackInfo *info,Stack *item)
 {
        Stack  *s=info->front;
        if( s )
       {
              item->pst=s->pst;
              item->vgp=s->vgp;
              --info->size;
              info->front=s->next;
              free(s);
        }
        else
              item->pst=NULL;
  }
/****************************计算图的关节点***************************/
  void  artic_point(GraphHeader  *h,int *vbuf)
 {
        PostGraph    *p;
        Graph        *g;
        int          i,size,j;
//初始化
       
        size=h->size;
        for(i=0;i<size;++i)
       {
              dfn[i]=-1;
              low[i]=-1;
              parent[i]=-1;
        }
//进入循环处理,从节点0开始处理
        count=0;
        dfn[0]=0;
        low[0]=0;
        vbuf[0]=0;

        g=h->graph;
        p=g->front;
//之所以传递参数g，是因为下面要使用到这个参数，但是不会改变它
        parent[p->vertex]=0;
        dfnlow(g,p,0);

        if(count+1<size)
       {
             vbuf[++vbuf[0]]=0;
             p=p->next;
             while( p )
            {
                  if(dfn[p->vertex]==-1)
                 {
                      parent[p->vertex]=0;
                      dfnlow(g,p,0); 
                  }
                  p=p->next;
             }
        }
//下面开始集中判断一个节点是否是关节点,这里没有判断是否有重复的写入，在实际应用中，会产生重复写入的可能
       for(i=size-1;i>=0;--i)
      {
             j=parent[i];
//之所以为0，是因为我们是从节点0开始进行计算的，它是根节点，所以不能参与此运算
             if(j && j!=-1)
            {
                   if(low[i]>=dfn[j])
                  {
                         vbuf[++*vbuf]=j;
                   }
             }
       }
//
       printf("dfn 和low 值如下:\n");
       for(i=0;i<size;++i)
      {
           printf("结点 %d ->parent:%d,:dfn: %d ,low :%d\n",i,parent[i],dfn[i],low[i]);
       }
  }
  static  void dfnlow(Graph  *graph,PostGraph *pst,int v)//v代表着祖先节点
 {
       PostGraph    *p;
       StackInfo    sinfo,*info;
       Stack        stack;
       int          w,j;
 //      int          min;
       
       info=&sinfo;
       info->front=NULL;
       info->size=0;

       j=pst->vertex;
       p=graph[j].front;
//       parent[j]=v;

       dfn[j]=++count;
       low[j]=count;
//v记录着在深度优先访问所形成的遍历树中p的祖先节点
       push(info,p,v);
       while( info->size )
      {
            pop(info,&stack);
            v=stack.vgp;
            p=stack.pst;
            if(dfn[p->vertex]>0 && parent[p->vertex]==p->vp)
                 low[p->vp]=low[p->vp]<low[p->vertex]?low[p->vp]:low[p->vertex];
            
//            printf("顶点p->vp:%d,p->vertex:%d.vgp->:%d\n",p->vp,p->vertex,v);
           for(  ; p ;p=p->next)
          {
                 w=p->vertex;
                 j=p->vp;
                 if(dfn[w]<0)
                {
                      dfn[w]=++count;
                      low[w]=count;
                      parent[w]=p->vp;

                      low[j]=low[j]<low[w]?low[j]:low[w];
                      push(info,p,v);
                      push(info,graph[w].front,p->vp); 
                      break;
                 }
                 else if(w!=v )//如果这是一条回边,且不是相互式的父子关系
//                {
//                      low[j]=low[j]<low[w]?low[j]:low[w];
                      low[j]=low[j]<dfn[w]?low[j]:dfn[w];
//                 }
//                 printf("***********节点 %d 的low值:low:%d ************\n",p->vp,low[p->vp]);
           }
       }
  }
  void  read_vertex(int (*matx)[10],int *size)
 {
       int   i,j;
       int   n,*p;

       do
      { 
             n=-1;
             printf("请输入图的节点的总数(>1 && <=10):\n");
             scanf("%d",&n);
       }while(n<1);
//初始清零
       p=(int *)matx;
       for(i=0;i<100;++i)
             *p=0;
//***************************
       printf("下面请输入向关联的节点，每次输入一对(-1,-1)退出!\n");
       do
      {
            i=-1,j=-1;
            printf("请输入两个顶点!\n");
            scanf("%d %d",&i,&j);
            if(i==-1 && j==-1)
                break; 
            if(i<0 || i>=n || j<0 || j>=n || i==j)
           {
                  printf("您输入的值非法!,必须在(0-%d)之间,且不能相等\n",n);
                  continue;
            }
            printf("%d and %d已经建立了关联!\n",i,j);
            matx[i][j]=1;
            matx[j][i]=1;
       }while( 1 );
       *size=n;
  }
/********************************************/
  int  main(int argc,char *argv[])
 {
       GraphHeader  h;
       int          size,i;
       int          vbuf[16];
       h.size=0;
       h.graph=NULL;
  
       printf("开始创建邻接矩阵.....\n");
       read_vertex(matrix,&size);
       
       printf("开始创建邻接表.....\n");
       CreateGraph(&h,matrix,size);
      
       printf("开始计算关节点....\n");
       artic_point(&h,vbuf);
       size=vbuf[0];
       for(i=1;i<=size;++i)
             printf("关节点:%d\n",vbuf[i]);
       
//这里没有释放内存的代码
       return 0;
  }