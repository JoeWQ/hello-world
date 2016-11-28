//2013��4��11��10:15:51
//�������ѹ�����ر���㷨ʵ��
  #include<stdio.h>
  #include<stdlib.h>
  #include"Ϊѹ�������㷨����ƵĶ���.c"
  #include"�й�ͼ�����ݽṹ.h"
  #define   MIN(a,b)   a<b?a:b
//������̬��ά�����������ݽṹ
  typedef  struct  _dl2array
 {
//��¼��ά������׵�ַ
        int          **dlary;
//��¼��ά������е���Ŀ
        int          row;
//��¼��ά������е���Ŀ
        int          col;
  }dlarray;
//
//  static  int  height[16];
static void init_preflow(GraphHeader *,QueueHeader *,int,int (*c)[12],int (*f)[12],int  *,int*);
//����ͼ���ڽӱ��ʾ,�����ڽӾ����ʾ��һ��ʵ�Գƾ���
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("������ͼ�Ķ�����Ŀ(>1 && <=12)!\n");
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

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//ѹ���㷨
//����c������������У���¼��(u,v)��Ȩֵ����
  static void  push(int  u,int  v,int(*c)[12],int (*f)[12],int  *e)
 {
         int    min;
//���¸����������е�����
         min=c[u][v]-f[u][v];//�ȼ������������ 
         min=MIN(e[u],min);
         f[u][v]+=min;
         f[v][u]=-f[u][v];
         e[u]-=min;
         e[v]+=min;
  }
//�ر�ǲ���
//e��¼�Ÿ���������������ֵ
//��¼�Ÿ�������ĸ߶�
//���õ�ǰ������e[u]>0 && ����u���еĺ�̽��v c[u][v]-f[u][v]>0 &&  height[u]<=height[v]
  static  int  relabel(GraphHeader  *h,int  u,int  *height,int (*c)[12],int (*f)[12])
 {
         PostGraph   *p,*q;
         p=h->graph[u].front;
         q=NULL;
         while( p )
        {
//�������ֵ ����0
               if(c[u][p->vertex]-f[u][p->vertex]>0)
              {

                     if(! q || height[p->vertex]<height[q->vertex])
                            q=p;
               }
//��u�ĺ�̶����У����Ҹ߶���С�Ķ���
               p=p->next;
         }
//��ֹuû�к�̽��
         if( q && height[u]<=height[q->vertex])
        {
               height[u]=height[q->vertex]+1;
               return 1;
         }
         return 0;
  }
//ѹ�����ر���㷨   �Ľ��
//src������Դ��
//dst�����Ż��
//dlcָ��̬��ά�����ͷ�ṹ(�����Ų��������б��Ȩֵ����)
//dlf������ͼ�и����ߵ� ǰ��������
  int  *push_relabel(GraphHeader  *h,int (*c)[12],int (*f)[12],int  src,int dst)
 {
         int     *height,*e;
         int     k,u;
         PostGraph    *p;
         Graph    *graph;
         QueueHeader  hqueue,*hq=&hqueue;

//�ȶ����е����ݽ��г�ʼ��
         height=(int *)malloc(sizeof(int)*h->size);
         e=(int *)malloc(sizeof(int)*h->size);
         initQueue(hq,h->size);
         graph=h->graph;
         init_preflow(h,hq,src,c,f,height,e);
//���潫����ѹ�����ر�ǲ����� ѭ��������
         while( hq->size>0 )
        {
               u=removeQueue(hq);
               graph[u].v=0;
//���Զ��� u Ӧ��ѡ����һ�ֲ���
               p=graph[u].front;
               while( p )
              {
                      k=p->vertex;
                      if(c[u][k]-f[u][k]>0 && height[u]==height[k]+1)
                     {
                           push(u,k,c,f,e);
                      
                           if(!graph[k].v && k!=src && k!=dst)
                          {
                                  addQueue(hq,k);
                                  graph[k].v=1;
                           }
                      }
                     p=p->next;
               }
//�������ر�ǲ���
               if(e[u]>0 && u!=src && u!=dst)
              {
//���Ҿ�����С�߶ȵ� ����
                     if( relabel(h,u,height,c,f) )
                    {
                          graph[u].v=1;
                          addQueue(hq,u);
                     }
//                     printf("^^^^^^^^^^^^^^\n");
                }
         }
         for(k=0;k<h->size;++k)
                printf("height[%d]--->%d\n",k,height[k]);
         return e;
   }
//����ѹ�����ر���㷨 ��ص����ݽ��г�ʼ��
   static  void  init_preflow(GraphHeader  *h,QueueHeader *hq,int src,int (*c)[12],int (*f)[12],
                               int  *height,int *e)
  {
         Graph  *graph=h->graph;
         PostGraph   *p;
         int    i,k;
         
         for(i=0;i<h->size;++i)
        {
                height[i]=0;
                e[i]=0;
                graph[i].v=0;
         }
         for(i=0;i<h->size;++i)
        {
                for(k=0;k<h->size;++k)
                      f[i][k]=0;
         }
//��ʼ����Դ��src���ڽӵĶ��㣬������ǰ����f
         height[src]=h->size;
         graph[src].v=1;
         p=graph[src].front;

         while( p )
        {
                k=p->vertex;
                e[k]=p->weight;
                e[src]-=p->weight;
                i=c[src][k];
                f[src][k]=i;
                f[k][src]=-i;
                graph[k].v=1;
                addQueue(hq,k);
                p=p->next;
         }
  }
//
  int  main(int  argc,char  *argv[])
 {
/*
//���Զ���
         QueueHeader  hqueue,*h=&hqueue;
         int          length=16;
         int          i,k;
         initQueue(h,length);

         for(i=0;i<length;++i)
               addQueue(h,i);
         printf("�������!\n");
         while( h->size )
        {
               i=removeQueue(h);
               printf(" %d ",i);
         }
         return 0;
*/

         GraphHeader    hGraph,*h=&hGraph;
         PostGraph      *p;
         int            i,j,*e;
         int           c[12][12],f[12][12];
//������̬����
         printf("����ͼ���ٽֱ��ʾ:\n");
         CreateGraph(h);
         for(i=0;i<h->size;++i)
        {
            for(j=0;j<h->size;++j)
                      c[i][j]=0;
         }
         for(i=0;i<h->size;++i)
        {
                p=h->graph[i].front;
                while( p )
               {
                       c[i][p->vertex]=p->weight;
                       p=p->next;
                }
         }
         printf("ִ��ѹ�����ر���㷨.......\n");
         e=push_relabel(h,c,f,0,h->size-1);
//��ӡ��ִ�н��
         for(i=0;i<h->size;++i)
        {
               for(j=0;j<h->size;++j)
                      printf("%4d ",f[i][j]);
               printf("\n");
         }
         printf("������������:\n");
         for(i=0;i<h->size;++i)
               printf("%d----->%d\n",i,e[i]);
         printf("������ͼ�������Ϊ: %d\n",e[h->size-1]);
         return 0;
  }