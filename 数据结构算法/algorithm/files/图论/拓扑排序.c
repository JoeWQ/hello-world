//2013/1/20/10:18
//对图(必须是有向图,且不能存在环)中的顶点进行拓扑排序,使用深度优先搜索
  #include<stdio.h>
  #include<stdlib.h>
/******************************************/
//对一维数组进行二维操作 所要用到的 宏
  #define  SET_ARRAY(m,i,j,s,n)   *(m+(i)*(s)+(j))=n
  #define  GET_ARRAY(m,i,j,s)     *(m+(i)*(s)+(j))
//图的邻接表表示
  typedef  struct  _PostGraph
 {
        int               vertex;
        int               vp;
        struct  _PostGraph   *next;
  }PostGraph;
//定义关于图的结构
  typedef  struct  _Graph
 {
        int   count;
//记录是否已经被访问,0表示未被访问，1表示已经被访问
        int   v;
        struct  _PostGraph   *front;
  } Graph;
//这个结构头 包含着关于图的长度，以及头指针
  typedef  struct  _GraphHeader
 {
        int    size;
        struct   _Graph  *graph;
  }GraphHeader;
//二维数组的行与列
  typedef  struct  _RowCol
 {
       int           *rt;
       int           row;
       int           col;
  }RowCol;
 #include"图的遍历_栈和队列.c"
//创建邻接矩阵
  void  CreateMatrix(RowCol  *r)
 {
       int  i,j,n,weight;
       int  *rt;

       do
      {
              n=-1;
              printf("请输入图中所包含的顶点数(n>1 && n<=16) !\n");
              scanf("%d",&n);
       }while(n<=1 || n>16);
       printf("n--->%d\n",n);
       r->row=n;
       r->col=n;

       j=n*n;
       rt=(int *)malloc(sizeof(int)*j);
       r->rt=rt;
//初始清零
       for(i=0;i<j;++i,++rt)
            *rt=0;
       rt=r->rt;
       printf("请输入途中顶点与顶点之间的权值( weight>0 )(-1 -1)表示结束输入! \n");
       do
      {
               i=j=weight=-1;
               printf("请输入 i j weight的值:\n");
               scanf("%d %d",&i,&j);
               if(i==j || i<0 || i>=n || j<0 || j>=n)
              {
                      printf("非法的输入,i ,j weight 必须满足既定的约束!\n");
                      continue;
               }
               printf("%d-->%d\n",i,j);
               SET_ARRAY(rt,i,j,n,1);
       }while(i!=-1 && j!=-1);
  }
  void  CreateGraph(GraphHeader  *h,RowCol *r)
 {
        int  i,j,weight;
        int  *rt=r->rt;
        Graph  *graph;
        PostGraph   *pst;

        h->size=r->row;
        graph=(Graph *)malloc(sizeof(Graph)*r->row);
        h->graph=graph;
        
        for(i=0;i<r->row;++i)
       {
               graph[i].front=NULL;
               graph[i].count=0;
               graph[i].v=0;
               for(j=0;j<r->row;++j)
              {
                      weight=GET_ARRAY(rt,i,j,r->row);
                      if( weight )
                     {
                             pst=(PostGraph *)malloc(sizeof(PostGraph));
                             pst->vertex=j;
                             pst->vp=i;
                             pst->next=graph[i].front;
                             graph[i].front=pst;
                             ++graph[i].count;
                      }
              }
        }
//释放已经占用的内存，因为他已经无用了
       free(rt);
       r->rt=NULL;
  }
//深度优先搜索
  void  deep_visit_first(GraphHeader  *h)
 {
       Graph  *graph=h->graph;
       int    index=0,w;
       StackHeader  hstack,*ht=&hstack;
       PostGraph  *pst;
//记录顶点的逻辑顺序
       int    *d=(int *)malloc(sizeof(int)*h->size);
//记录结束时间
//初始化某些当下要用到的数据
//初始化栈
       ht->size=0;
       ht->front=NULL;
//记录当前要用到的图顶点
       pst=graph[0].front;
//进入深度优先搜索
       graph[0].v=1;
       d[index++]=0;
       printf("###################\n");
       while( pst )
      {
             push(ht,pst);
             pst=pst->next;
       }
       while(! IsStackEmpty(ht))
      {
            pop(ht,&pst);
            d[index++]=pst->vertex;
            graph[pst->vertex].v=1;
            pst=graph[pst->vertex].front;
//寻找没有被访问的顶点
            for(   ;pst ;pst=pst->next)
           {
                  if(! graph[pst->vertex].v)
                        push(ht,pst);
            }
      }
//输出在深度搜索中访问的顶点序列
      for(w=0;w<index;++w)
          printf("%d  ",d[w]);
      printf("\n");
      free(d);
  }
  int  main(int argc,char *argv[])
 {
       GraphHeader  hgraph,*h=&hgraph;
       RowCol       rc;
       h->size=0;
       h->graph=NULL;
      
       printf("开始创建邻接矩阵.....\n");
       CreateMatrix(&rc);
       printf("创建邻接表...\n");
       CreateGraph(h,&rc);
       printf("对图中的顶点进行拓扑排序.....\n");
       deep_visit_first(h);
       return 0;
  }