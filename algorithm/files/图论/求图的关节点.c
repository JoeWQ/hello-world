//2012/12/11/20:45
  #include<stdio.h>
  #include<stdlib.h>
/*************************************/

//�����ͼ��ص����ݽṹ
  typedef  struct  _PostGraph
 {
       int                   vertex;
       int                   vp;
       struct   _PostGraph   *next;
  }PostGraph;
  typedef  struct  _Graph
 {
//����ýڵ�ı�ʾ
       struct  _PostGraph       *front;
//ָ����һ��ͼ�ṹ��ָ��
       struct  _PostGraph       *rear;
//һ�������������ɣ���¼�ýڵ��������ȷ��ʵĸ����
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
       int                 vgp;//��¼�ýڵ�ĸ��ڵ����ͼ�е�����
       struct  _Stack      *next;
  }Stack;
  typedef  struct  _StackInfo
 {
       struct  _Stack   *front;

       int              size;
  }StackInfo;
//���幫���ľ���
  static int  matrix[10][10];
  static int  low[32];
  static int  dfn[32];
//��¼һ���ڵ�ĸ����������±�
  static int  parent[32];
  static int  count=0;

  void  CreateGraph(GraphHeader *,int (*p)[10],int);
//����ͼ�Ĺؽڵ㣬��д��vbuf�����У�vbuf[0]��������ĳ��ȣ���������ڵ�ı�ʾ
  void  atic_point(GraphHeader *,int *vbuf);
//����ͼ�����dfnֵ��lowֵ�����������һ���ڲ�����s
  static  void  dfnlow(Graph *,PostGraph  *,int);
//�Ͷ�̬ջ����غ���
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
//�Ͷ�̬ջ��صĺ���,ע�������̬ջ���߼��������ǲ��ϳ����
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
/****************************����ͼ�Ĺؽڵ�***************************/
  void  artic_point(GraphHeader  *h,int *vbuf)
 {
        PostGraph    *p;
        Graph        *g;
        int          i,size,j;
//��ʼ��
       
        size=h->size;
        for(i=0;i<size;++i)
       {
              dfn[i]=-1;
              low[i]=-1;
              parent[i]=-1;
        }
//����ѭ������,�ӽڵ�0��ʼ����
        count=0;
        dfn[0]=0;
        low[0]=0;
        vbuf[0]=0;

        g=h->graph;
        p=g->front;
//֮���Դ��ݲ���g������Ϊ����Ҫʹ�õ�������������ǲ���ı���
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
//���濪ʼ�����ж�һ���ڵ��Ƿ��ǹؽڵ�,����û���ж��Ƿ����ظ���д�룬��ʵ��Ӧ���У�������ظ�д��Ŀ���
       for(i=size-1;i>=0;--i)
      {
             j=parent[i];
//֮����Ϊ0������Ϊ�����Ǵӽڵ�0��ʼ���м���ģ����Ǹ��ڵ㣬���Բ��ܲ��������
             if(j && j!=-1)
            {
                   if(low[i]>=dfn[j])
                  {
                         vbuf[++*vbuf]=j;
                   }
             }
       }
//
       printf("dfn ��low ֵ����:\n");
       for(i=0;i<size;++i)
      {
           printf("��� %d ->parent:%d,:dfn: %d ,low :%d\n",i,parent[i],dfn[i],low[i]);
       }
  }
  static  void dfnlow(Graph  *graph,PostGraph *pst,int v)//v���������Ƚڵ�
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
//v��¼����������ȷ������γɵı�������p�����Ƚڵ�
       push(info,p,v);
       while( info->size )
      {
            pop(info,&stack);
            v=stack.vgp;
            p=stack.pst;
            if(dfn[p->vertex]>0 && parent[p->vertex]==p->vp)
                 low[p->vp]=low[p->vp]<low[p->vertex]?low[p->vp]:low[p->vertex];
            
//            printf("����p->vp:%d,p->vertex:%d.vgp->:%d\n",p->vp,p->vertex,v);
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
                 else if(w!=v )//�������һ���ر�,�Ҳ����໥ʽ�ĸ��ӹ�ϵ
//                {
//                      low[j]=low[j]<low[w]?low[j]:low[w];
                      low[j]=low[j]<dfn[w]?low[j]:dfn[w];
//                 }
//                 printf("***********�ڵ� %d ��lowֵ:low:%d ************\n",p->vp,low[p->vp]);
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
             printf("������ͼ�Ľڵ������(>1 && <=10):\n");
             scanf("%d",&n);
       }while(n<1);
//��ʼ����
       p=(int *)matx;
       for(i=0;i<100;++i)
             *p=0;
//***************************
       printf("����������������Ľڵ㣬ÿ������һ��(-1,-1)�˳�!\n");
       do
      {
            i=-1,j=-1;
            printf("��������������!\n");
            scanf("%d %d",&i,&j);
            if(i==-1 && j==-1)
                break; 
            if(i<0 || i>=n || j<0 || j>=n || i==j)
           {
                  printf("�������ֵ�Ƿ�!,������(0-%d)֮��,�Ҳ������\n",n);
                  continue;
            }
            printf("%d and %d�Ѿ������˹���!\n",i,j);
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
  
       printf("��ʼ�����ڽӾ���.....\n");
       read_vertex(matrix,&size);
       
       printf("��ʼ�����ڽӱ�.....\n");
       CreateGraph(&h,matrix,size);
      
       printf("��ʼ����ؽڵ�....\n");
       artic_point(&h,vbuf);
       size=vbuf[0];
       for(i=1;i<=size;++i)
             printf("�ؽڵ�:%d\n",vbuf[i]);
       
//����û���ͷ��ڴ�Ĵ���
       return 0;
  }