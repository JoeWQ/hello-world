//2013��4��13��11:19:38
//�ر����ǰ���㷨ʵ��,�㷨�Ļ�����Ȼ��ѹ����ر��
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"
  #include"��̬˫�˶���.c"
//
//����ͼ���ڽӱ��ʾ,�����ڽӾ����ʾ��һ��ʵ�Գƾ���
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;
       PostVertex  *adj;

       printf("������ͼ�Ķ�����Ŀ(>1 && <12)!\n");
       do
      {
             size=1;
             printf("���������Ҫ��Ķ�����:\n");
             scanf("%d",&size);
       }while(size<=1 || size>12);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->v=0;
             graph->front=NULL;
             graph->adj=NULL;
       }
       graph=h->graph;
       printf("�����붥��֮��Ĺ��� (-1 -1)��ʾ�˳�!\n");
       do
      {
             printf("�����붥���붥��֮��Ĺ���:\n");
             i=j=0;
             weight=-1;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i==j || i<0 || i>=size || j<0 || j>=size || weight<0)
            {
                    printf("�Ƿ�������!\n");
                    continue;
             }
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=j;
             pst->vp=i;
             pst->weight=weight;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;
//��̽ڵ� ����ͼ����������������,��������ǰ���㷨��ʵ��
             adj=(PostVertex *)malloc(sizeof(PostVertex));
             adj->vertex=j;
             adj->next=graph[i].adj;
             graph[i].adj=adj;
//ǰ���ڵ�
             adj=(PostVertex *)malloc(sizeof(PostVertex));
             adj->vertex=i;
             adj->next=graph[j].adj;
             graph[j].adj=adj;

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//ѹ�����/���õ�ǰ�������ǣ�e[u]>0 && c[u][v]-f[u][v]>0
  static  void  push(int u,int v,int  *e,int (*c)[12],int (*f)[12])
 {
       int  min=c[u][v]-f[u][v];

       min=min<e[u]?min:e[u];
       f[u][v]+=min;
       f[v][u]=-f[u][v];
       e[u]-=min;
       e[v]+=min;
  }
//��ǲ���
//���õ�ǰ������e[u]>0
  static  void  relabel(Graph *graph,int u,int *height,int (*c)[12],int (*f)[12])
 {
       PostVertex  *p,*q;
       
       p=graph[u].adj;
       q=NULL;
//���Ҿ�����С�߶������������Ķ���
       while( p )
      {
             if(c[u][p->vertex]>f[u][p->vertex])
            {
                   if(!q || height[p->vertex]<height[q->vertex])
                         q=p;
             }
             p=p->next;
       }
       if(q && height[u]<=height[q->vertex])
             height[u]=height[q->vertex]+1;
  }
//�ų�����/ע�⣬�������������õ�ͼ��������ǿ��ͨ�ģ��������ѭ�����������
  static  void  discharge(Graph *graph,int  u,int *height,int *e,int (*c)[12],int (*f)[12])
 {
        PostVertex  *p=graph[u].adj;
        while( e[u]>0 )
       {
//��ʱ��û���������� cf[u][v]>0 && h[u]=h[p->vertex]+1�Ľ��
                if( ! p )
               {
                       relabel(graph,u,height,c,f);
                       p=graph[u].adj;
                }
                else if(c[u][p->vertex]>f[u][p->vertex] && height[u]==height[p->vertex]+1)
                       push(u,p->vertex,e,c,f);
                else
                      p=p->next;
        }
  }
//�����ݽ��г�ʼ������
  static  void  init_preflow(GraphHeader  *h,int src,int *height,int *e,int(*c)[12],
                              int  (*f)[12])
  {
         int         i,k;
         PostGraph   *p;
         Graph       *graph=h->graph;
//��ʼ������
         for(i=0;i<h->size;++i)
        {
               height[i]=0;
               e[i]=0;
         }
         height[src]=h->size;
//�����еı�(u,v),����ȫְ�����������
         for(i=0;i<h->size;++i)
        {
               p=graph[i].front;
               while( p )
              {
                     k=p->vertex;
                     f[i][k]=0; 
                     f[k][i]=0;
                     p=p->next;
               }
         }
         p=graph[src].front;
         while( p )
        {
               k=p->vertex;
               i=p->weight;
               f[src][k]=i;
               f[k][src]=-i;
               e[k]=i;
               e[src]-=i;
               p=p->next;
         }
  }
//�����еĶ��������������(ʹ�ù����������)
  static  void  toplog_sort(GraphHeader *h,QueueHeader *hq,int  src,int dst)
 {
         int        i,size;
         PostGraph  *p,*q;
         Graph      *graph=h->graph;
//ʹ�ø��϶���(��Ϊ����ٴν������е����ݽ������ô�����Ѿ������Ľ�������ͻ)
         QueueHeader  hQueue,*queue=&hQueue;
 
         size=h->size;
//���Ƚ����еĶ�����Ϊ δ����״̬
         for(i=0;i<size;++i)
               graph[i].v=0;
//����ʹ�ù���������������еĶ����������
         queue->front=NULL;
         queue->rear=NULL;

         hq->front=NULL;
         hq->rear=NULL;
//�Ƚ�src�ĺ�Ƕ���ѹ��ջ��,����������ӵ��������� ��Ŀ�������
//��Ϊ���в���Ϊ��ָ�����Ͷ���Ƶģ����Ա���ʹ��ǿ������ת��
//Դ��ͻ�㲻����ӽ�����
         graph[src].v=1;
         graph[dst].v=1;
         p=graph[src].front;
         while( p )
        {
               graph[p->vertex].v=1;
               addElemq(hq,p->vertex); //ע��Ҫ���ֲ�ͬ�Ķ���
               addElemq(queue,(int)p);
               p=p->next;
         }
//��ʼ�������Ŀ�궥��ѭ��
         while( ! IsQueueEmpty(queue) )
        {
//�����һ����벻����
               q=(PostGraph *)removeTopq(queue);
               p=graph[q->vertex].front;
               while( p )
              {
                     if(!graph[p->vertex].v)
                    {
                           graph[p->vertex].v=1;
                           addElemq(queue,(int)p);
                           addElemq(hq,p->vertex);
                     }
                     p=p->next;
               }
         }
  }
//�����ǰ���㷨�ľ���ʵ��
  void  relabel_to_front(GraphHeader  *h,int src,int dst,int (*c)[12],int (*f)[12])
 {
         int          *height,*e;
         int          oldheight,u,size;
         QueueHeader  hQueue,*hq=&hQueue;
         Queue        *q,*t;
         Graph        *graph;

         size=h->size;
         graph=h->graph;
//��ʼ������
         hq->front=NULL;
         hq->rear=NULL;
//���붯̬�ڴ�
         height=(int *)malloc(sizeof(int)*size);
         e=(int *)malloc(sizeof(int)*size);
//��ʼ������
         init_preflow(h,src,height,e,c,f);
         toplog_sort(h,hq,src,dst);
//�鿴�����е�Ԫ��
         q=hq->front;
         while( q )
        {
                 printf("----%d  ,",q->vertex);
                 q=q->next;
         }
//��һ������ ѭ������
         q=hq->front;
         while( q )
        {
               u=q->vertex;
               oldheight=height[u];
               discharge(graph,u,height,e,c,f);
               if(oldheight<height[u])
                     moveToHead(hq,q);
               q=q->next;
          }
//������� e ��Ԫ�ص�ֵ
          printf("���� e �е�ֵΪ:\n");
         for(u=0;u<size;++u)
               printf("e[%d]---->%d\n",u,e[u]);
         printf("\n***********************************\n");
         printf("\nheight�����е�ֵ:\n");
         for(u=0;u<size;++u)
               printf("height[%d]----->%d\n",u,height[u]);
         free(e);
         free(height);
//�ͷŶ����еĽ��
         for(q=hq->front; q ;  )
        {
               t=q;
               q=q->next;
               free(t);
         }
  }

//���Դ���
  int  main(int  argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       PostGraph    *p;
       int          c[12][12],f[12][12];
       int          i,k;
/*
//�Ȳ��Զ������������
       QueueHeader   hQueue,*hq=&hQueue;
       Queue         *q;
//
       hq->front=NULL;
       hq->rear=NULL;
*/
       printf("����ͼ���ڽӱ�ʵ��!\n");
       h->size=0;
       h->graph=NULL;
       CreateGraph(h);
/*
       printf("����������������:\n");
       toplog_sort(h,hq,0,h->size-1);
       for(q=hq->front; q ;q=q->next)
              printf(" %d  ",q->vertex);
       printf("\n");
*/

       printf("��ʼ��ͼ���ڽӾ���:\n");
//����Ĵ������޹صģ�ֻ��Ϊ�����һ���� ������
       for(i=0;i<h->size;++i)
            for(k=0;k<h->size;++k)
                   c[i][k]=f[i][k]=0;
       for(i=0;i<h->size;++i)
      {
              p=h->graph[i].front;
              while( p )
             {
                      c[i][p->vertex]=p->weight;
                      p=p->next;
              }
       }
//
       printf("���ñ����ǰ�ƺ���:\n");
       relabel_to_front(h,0,h->size-1,c,f);
       printf("\n����ڸú��������ɵ�����:\n");
       for(i=0;i<h->size;++i)
      {
             for(k=0;k<h->size;++k)
                   printf("%4d ",f[i][k]);
             printf("\n");
       }
       return 0;
  }