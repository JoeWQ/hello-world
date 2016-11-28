//2012/12/10:14:49
//图的深度优先搜索和广度优先搜索,本程序中图的存储采用邻接表的形式
  #include<stdio.h>
  #include<stdlib.h>
//定义和图相关的数据结构
  typedef  struct  _PostGraph
 {
      int                  vertex;
      struct  _PostGraph   *next;
  }PostGraph;
  typedef  struct  _Graph
 {
//记录和此顶点相关联的所有顶点的数目
      int                  len;
//记录指向和此顶点相关联的邻接表的头指针
      struct  _PostGraph   *front;
      struct  _PostGraph   *rear;
  }Graph;
//为了方便图的管理而设计的额外的数据结构，而实际上，它是可以舍去的
  typedef  struct  _GraphInfo
 {
//指向图中顶点所组成的数组
      struct  _Graph   *graph;
//记录图的顶点的数目
      int              len;
  }GraphInfo;
//在访问图时，需要使用动态队列，下面是关于动态 队列的相关数据结构
  typedef  struct  _Stack
 {
//记录下一个将要访问的和当前顶点相关联的后继结点
      struct  _PostGraph   *vet;
      struct  _Stack       *next;
  }Stack;
  typedef  struct  _StackInfo
 {
//记录动态队列/栈的首结点的指针
      struct   _Stack      *front;
      struct   _Stack      *rear;
//当前队列/栈的长度
      int                  len;
  }StackInfo;
//参数的含义分别表示:管理图信息结构指针，邻接矩阵的地址，矩阵的行/列宽
  void  CreateGraph(GraphInfo *,int *,int );
//深度优先搜索
  void  deep_vf(GraphInfo  *);
//广度优先搜索
  void  breath_vf(GraphInfo *);
//动态堆栈的创建
  static void  push(StackInfo *,Stack *);
  static int  pop(StackInfo  *,Stack *);
//动态队列的创建
  static  void  pushq(StackInfo *,Stack *);
  static  int  popq(StackInfo  *,Stack *);
/**************************************************************/
  int  main(int argc,char *argv[])
 {
       int  i,j,n;
       int  *mx;
       GraphInfo   info;

       n=-1;
       do
      {
             printf("请输入将要创建的图所包含的顶点的数目(>1)!\n");
             scanf("%d",&n);
       }
       while(n<1);
       j=n*n;
//清零操作
       mx=(int *)malloc(j<<2);
       for(i=0;i<j;++i)
            mx[i]=0;
//首先建立邻接矩阵
       printf("请输入相关联的顶点(每次两个)(-1,-1)将结束输入\n");
       do
      {
            i=-1,j=-1;
            printf("请输入两个相关联的顶点:\n");
            scanf("%d %d",&i,&j);
            if(i==-1 && j==-1)
                break;
            if(i>=n || i<0 ||  j>=n || j<0)
           {
                 printf("您输入的值%d,%d大于顶点的数目，请重新输入!\n");
//                 system("cls");
                 continue;
            }
            mx[i*n+j]=1;
            mx[j*n+i]=1;
            printf("顶点%d和顶点%d建立关联\n",i,j);
      }while( 1 );
//输出矩阵

      info.graph=NULL;
      info.len=0;
//创建图的邻接表存储
      CreateGraph(&info,mx,n);
//进行深度优先搜索
      printf("\n*******************深度优先搜索************************\n");
      deep_vf(&info);
      _sleep(10);
      printf("\n*******************广度优先搜索************************\n");
      breath_vf(&info);
//释放已经申请的内存
      free(mx);
      return 0;
  }
//创建图的邻接表存储
  void  CreateGraph(GraphInfo *info,int *mx,int n)
 {
      int  i,j;
      Graph       *graph;
      PostGraph   *post;

      info->len=n;
      graph=(Graph *)malloc(sizeof(Graph)*n);
      info->graph=graph;
      
      for(i=0;i<n;++i,++graph)
     {
           graph->len=0;
           graph->front=NULL;
           graph->rear=NULL;
           for(j=0;j<n;++j,++mx)
          {
                 if( *mx )
                {
                        post=(PostGraph *)malloc(sizeof(PostGraph));
                        post->next=NULL;
                        post->vertex=j;
                        if(!graph->front)
                              graph->front=post;
                        else
                              graph->rear->next=post;
                        graph->rear=post;
                        ++graph->len;
                 }
           }
      }
/*
//输出邻接表的内容
      for(i=0,graph=info->graph;i<len;++i,++graph)
     {
             post=graph->front;
             printf("顶点%d：->:",i);
             while( post )
            {
                   printf("  %d  ",post->vertex);
                   post=post->next;
             }
             printf("\n");
      }
*/
  }
//为深度优先搜索而创建的队列
  static  void  pushq(StackInfo *info,Stack *s)
 {
       Stack  *item=(Stack *)malloc(sizeof(Stack));
       item->vet=s->vet;
       item->next=NULL;
       
       if(!info->front)
            info->front=item;
       else
            info->rear->next=item;
       info->rear=item;
       ++info->len;
  }
//从队列中删除队首结点元素
  static  int  popq(StackInfo *info,Stack *s)
 {
       Stack  *item=info->front;
       
       if(info->len)
      {
              --info->len;
              s->vet=item->vet;
              info->front=item->next;
              if(info->rear==item)
                   info->rear=NULL;
              free(item);
              return 1;
       }
       else
              s->vet=NULL;
       return 0;
  }
//为广度优先搜索而建立的动态栈,注意，这里面没有参数的检查
  static  void  push(StackInfo *info,Stack *s)
 {
       Stack  *item=(Stack *)malloc(sizeof(Stack));
       item->next=NULL;
       item->vet=s->vet;
       
       ++info->len;
       item->next=info->front;
       info->front=item;
  }
//从栈中探出结点元素
  static  int  pop(StackInfo *info,Stack *s)
 {
       Stack *item=info->front;

       if(item)
      {
             --info->len;
             s->vet=item->vet;
             info->front=item->next;
             free(item);
             return 1;
       }
       return 0;
  }
//深度优先搜索
  void  deep_vf(GraphInfo  *info)
 {
       int         len=info->len;
       Graph       *graph=info->graph;
       PostGraph   *post,*tmp;
       StackInfo   stack;
       Stack       item;
       int         *visit,i;
//深度优先搜索所要使用的数据结构就是队列
       visit=(int *)malloc(sizeof(int)*len);//保存各个顶点的状态，为0则表示违背访问，否则表示被访问
       for(i=0;i<len;++i)
           visit[i]=0;
       
       stack.front=NULL;
       stack.rear=NULL;
       stack.len=0;
       if(! len)
           return;
//初始化动态队列
       post=(PostGraph *)malloc(sizeof(PostGraph));
       post->vertex=0;
       post->next=graph->front;
       item.vet=post;
       tmp=post;
       push(&stack,&item);
//下一步开始进行深度搜索
       while(  stack.len )
      {
           pop(&stack,&item);
           post=item.vet;
//           printf(" %d  ",stack.len);
           i=post->vertex;
           if(!visit[i])
          {
                printf("结点%d被访问!\n",i);
                visit[i]=1;

                post=graph[i].front;
                while( post )
               {
                     if(!visit[post->vertex])
                    {
                         item.vet=post;
                         push(&stack,&item);
                     }
                    post=post->next;
               }
           }
       }
       free(tmp);
       free(visit);
       printf("\n");
  }
//广度优先搜索,注意这里面没有 对参数的合法性进行检查
  void  breath_vf(GraphInfo  *info)
 {
       Graph       *graph=info->graph;
       int        len=info->len;
       int        i,*visit;
       Stack      item;
       StackInfo  queue;
       PostGraph  *post;

       visit=(int *)malloc(sizeof(int)*len);
       for(i=0;i<len;++i)
            visit[i]=0;
       
       printf("顶点%d已经被访问!\n",0); 
       visit[0]=1;
       
       queue.len=0;
       queue.front=NULL;
       queue.rear=NULL;
       post=graph->front;

       while( post )
      {
              item.vet=post;
              pushq(&queue,&item);
              post=post->next;
       }
       while( queue.len)
      {
             popq(&queue,&item);
             post=item.vet;
             i=post->vertex;
             if(!visit[i])
            {
                  printf("顶点%d已经被访问!\n",post->vertex);
                  visit[i]=1;
             
                  post=graph[i].front;
                  while( post )
                 {
                       if(!visit[post->vertex])
                      {
                            item.vet=post;
                            pushq(&queue,&item);
                      }
                      post=post->next;
                 }
            }
       }
        free(visit);
       printf("\n");
  }