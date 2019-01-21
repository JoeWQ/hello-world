//2013��1��26��15:16:48
//��Դ���·���㷨����������������˼�ǿ������������ֻ�·������������ָ�Ȩ��
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"
  #define  INT_F    0x3FFFFFFF
/***************************************/
//����ͼ���ڽӱ��ʾ,ע������һ������ͼ
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("������ͼ�Ķ�����Ŀ(>1 && <17)!\n");
       do
      {
             size=1;
             printf("���������Ҫ��Ķ�����:\n");
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
       printf("�����붥��֮��Ĺ��� (-1 -1)��ʾ�˳�!\n");
       do
      {
             printf("�����붥���붥��֮��Ĺ���:\n");
             i=j=0;
             weight=-1;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i==j || i<0 || i>=size || j<0 || j>=size)// || weight<0)
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
             ++graph[j].count;
/*
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=i;
             pst->vp=j;
             pst->weight=weight;
             pst->next=graph[j].front;
             graph[j].front=pst;
*/

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
/******************��ͼ�еĶ��������������**************/
//������ͼ���ڻ����򷵻�0�����򷵻�1
  static int  toplogical_sort(GraphHeader   *h,int  *toplog)
 {
       int     i,k,top;
       Graph   *graph=h->graph;
       PostGraph   *pst;
//��ʼ����������ջ�ṹ
       top=-1;
       for(i=0;i<h->size;++i)
      {
             if(!graph[i].count)
            {
                    graph[i].count=top;
                    top=i;
             }
       }
//��ʼ��������
       k=0;
       for(i=0;i<h->size;++i)
      {
             if(top==-1)
                 return 0;
             toplog[k++]=top;
             pst=graph[top].front;
             top=graph[top].count;
             for(  ; pst ;pst=pst->next)
            {
                    --graph[pst->vertex].count;
//��������������Ϊ0��ʱ�򣬾Ϳ��Խ�����ջ
                    if(!graph[pst->vertex].count)
                   {
                           graph[pst->vertex].count=top;
                           top=pst->vertex;
                    }
             }
       }
       return 1;
  }
//���㵥Դ���·��
  int  dag_shortest_path(GraphHeader  *h,int  *parent,int *d,int start)
 {
       int          i,k;
       int          *toplog;
       Graph        *graph=h->graph;
       PostGraph    *pst;
       
//���ͼ���Ƿ���ڻ�
       toplog=(int *)malloc(sizeof(int)*h->size);
       if(!toplogical_sort(h,toplog))
      {
            free(toplog);
            return 0;
       }
//�����ݽ��г�ʼ��
       for(i=0;i<h->size;++i)
      {
              parent[i]=-1;
              d[i]=INT_F;
       }
       d[start]=0;
//��ʼ�������·��
       for(i=0;i<h->size;++i)
      {
              k=toplog[i];
//�����Ƕ����еıߵ��ɳڲ���
              for(pst=graph[k].front; pst ;pst=pst->next)
             {
                      if(d[pst->vertex]>d[pst->vp]+pst->weight)
                     {
                              d[pst->vertex]=d[pst->vp]+pst->weight;
                              parent[pst->vertex]=pst->vp;
                      }
              }
       }
       free(toplog);
       return 1;
  }
// 
  int  main(int  argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       int          *parent,*d;
       int          i,k,start=0;
     
       printf("����ͼ���ڽӱ��ʾ..........\n");
       CreateGraph(h);
       printf("����ͼ�ĵ�Դ���·��.......\n");

       parent=(int *)malloc(sizeof(int)*h->size);
       d=(int *)malloc(sizeof(int)*h->size);
       if(!dag_shortest_path(h,parent,d,start))
	   {
		   printf("���ͼ���ڻ��������������·��������!\n");
		   return 1;
	   }
       
       printf("\n****************�������Ľ��****************\n");
       for(i=0;i<h->size;++i)
      {
             printf("\n----------------------------------------\n");
             printf("%d----->%d : %d  \n",start,i,d[i]);
             
             k=i;
             do
            {
                    printf(" %d ",k);
                    k=parent[k];
             }while(k!=-1);
       }
       free(parent);
       free(d);
       return 0;
  }