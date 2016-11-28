//2012/12/14/9:37
//����ͼ����С��������������õ��� ��³˹�� �㷨
  #include<stdio.h>
  #include<stdlib.h>
/************************************************/
//���붨��ͼ�ṹ���ļ�
  #include"GraphStructure.h"
//����ͺ�ͼ�ж�����صıߵĲ�����ص����ݽṹ�����ļ�
  #include"Edge.h"
//�����ĺ���:ָ��ͼ��Ϣͷ��ָ�룬ָ��ͼ�ڽӾ����ָ�룬���������������ʵ����Ч����
  void  CreateGraph(GraphHeader *,int (*p)[10],int);
//�ʹ���ͼ�ı���صĺ���
  static void CreateGraphEdges(EdgeInfo *,GraphHeader *);
//�����ȡ���ı��Ƿ�����Ѿ������ı��й��ɻ�·
  static  int  find_back_edge(int  *,Edge *);
//��ȡ��С�������ıߵļ���
  int  GetMinTreeEdges(EdgeInfo *,GraphHeader *);
//�����ڽӾ���
  void  CreateMatrix(int (*p)[10],int *);
/***************************************************************/
//����ѹ��ջ�У�����ѹ��ı߽�������
  static void  push(EdgeInfo *,PostGraph *);
//��ջ�е�����
  static int   pop(EdgeInfo *,Edge *);
//********************************************
//�����߽�������
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
//����ͼ���ڽӾ����ʾ
  void  CreateMatrix(int (*matx)[10],int *size)
 {
        int  i,j,n,path;

        do
       {
             printf("������ͼ�Ķ�����Ŀ(>=2 && <10):\n");
             scanf("%d",&n);
        }while(n<2 || n>=10);
        for(i=0;i<n;++i)
           for(j=0;j<n;++j)
               matx[i][j]=0;
        printf("�����붥��v�붥��w�����ǵ�·����\n���� 1 2 3�ͱ�ʾ����1,2,��·��Ϊ3�������������û�����ڣ������ǵ�·����Ϊ0\n,���������Ϊ��������ľ�������0\n���ң�v,w��ֵ������ͬ ���� -1 -1 ��ʾ�˳�!\n");
        do
       {
             printf("�����붥��֮���·��:\n");
             i=-1,j=-1,path=-1;
             scanf("%d %d %d",&i,&j,&path);
             if(i==-1 && j==-1)
                   break;
             if(i<0 || i>=n || j<0 || j>=n || i==j || path<0)
            {
                   printf("�������ֵ�Ƿ�������������!\n"); 
                   continue;
             }
             printf("���� %d ,%d �ľ���Ϊ%d\n",i,j,path);
             matx[i][j]=path;
             matx[j][i]=path;
       }while( 1 );
       *size=n;
  }
//����ͼ�����еıߵļ���
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
//���Ѿ����ɵıߵļ���info/einfo��ѡȡ��С���Ҳ����Ѿ�ѡ�õı߹��ɻ�·�ı߲�д��edges��
//������صı�����h->size-1������ʧ�ܷ���0�����򷵻�1
  int  GetMinTreeEdges(EdgeInfo *edges,GraphHeader *h)
 {
      int       i,size;
      int       n,*parent;
//      int       from,to;
      Edge      edge,*e;
      EdgeInfo  einfo,*info;
//��ʼ����������
      size=h->size;
      parent=(int *)malloc(sizeof(int)*size);
      e=&edge;

      info=&einfo;
      info->size=0;
      info->front=NULL;

      n=size-1;
      edges->size=0;
      edges->front=NULL;
//parent�������ж����������Ƿ�λ��ͬһ�����ϣ����߻��仰˵���ж��Ѿ�ѡȡ�ı��Ƿ񹹳ɻ�·���棬���ŷǳ��������
      for(i=0;i<size;++i)
          parent[i]=-1;
//�������бߵļ���
     CreateGraphEdges(info,h);

//�����ѡȡ�ı�����h->size-1������ôѭ��������ȥ
     while( edges->size<n && info->size)
    {
           pop(info,e);
//�ж���ѡȡ�ı��Ƿ���Ѿ��еı߹��ɻ�·
           if(! find_back_edge(parent,e))
                sort_edge(edges,e);
     }
//�ͷ�info�ṹ��ռ�ݵĶ�����ڴ�
     while( info->size )
         pop(info,e);
     
     return edges->size==n;
  }
//�͹���ߵ����ݽṹ��ص����ݽṹ
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
//����Ľṹ�����ڲ�������
      if(! s)
         info->front=tmp;
      else
     {
            while(s && tmp->cost>s->cost)
           {
                p=s;
                s=s->next;
            }
//���tmp->cost��ֵ��С
            if(! p)
           {
                  tmp->next=s;
                  info->front=tmp;
            }
//���tmp�Ǵ����м�С����
            else if( s )
           {
                  p->next=tmp;
                  tmp->next=s;
            }
//����tmp��������ջ��ĩβ
            else
                  p->next=tmp;
      }
  }
//��ջ�е���ջ��Ԫ��,���ɹ����򷵻�1�����򷵻�0
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
//�жϸ����ı��Ƿ���Ѿ����ɵ����߹��ɻ�·���������ɣ��򷵻�0�����򷵻�1
  static int  find_back_edge(int *parent,Edge *e)
 {
      int  from=e->from;
      int  to=e->to;
//vf,vt��¼from,to�����Ƚڵ�
 //     int  vf,vt,flag=0;
//���Ƚڵ�Ķ��壬��ÿһ�����߼����ж������ֵ��С���Ǹ�����Ϊ������������еĶ��������
      for(  ;parent[from]!=-1;from=parent[from])
          ;
      for(  ;parent[to]!=-1;to=parent[to])
          ;
//���from,toλ�ڲ�ͬ�ļ��ϣ����ʾfrom,to����ͬһ�������У����Ƚ��м��Ϻϲ�����,�ٷ���0
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
//�����߽�������������ν�����򣬲��ǰ�����ֵ��С�������򣬶��ǰ��ն�������ֱ�ŵĵ�������
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
//���û�в��ҵ�
             if(! s)
                   p->next=tmp;
             else if(s->from==tmp->to)//����s��ǰ��
            {
                   tmp->next=s;
                   if(s==info->front)
                        info->front=tmp;
                   else//ע�⣬�����������
                        p->next=tmp;
             }
             else//����s�ĺ���
            {
                  tmp->next=s->next;
                  s->next=tmp;
            }
       }
  }
//��ʼ����
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

       printf("��ʼ����ͼ���ڽӾ���洢��ʾ........\n");
       CreateMatrix(matrix,&size);
//
       printf("��ʼ�����ڽӱ�....\n");
       CreateGraph(h,matrix,size);
  
       printf("��ʼ��ȡͼ����С������....\n");
       GetMinTreeEdges(info,h);

       printf("��ʼ���....\n");
       e=&edge;
       while( info->size )
      {
           pop(info,e);
           printf("���㣺%d--->%d : %d  \n",e->from,e->to,e->cost);
       }
       return 0;
  }