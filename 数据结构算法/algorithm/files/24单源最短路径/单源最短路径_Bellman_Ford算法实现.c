//2013��1��26��9:48:10
//����ͼ�� ��Դ���·�� Bellman_Ford�㷨ʵ��
  #include<stdio.h>
  #include<stdlib.h>
/**************************************************/
  #include"�й�ͼ�����ݽṹ.h"
//���������
  #define  INT_F    0x3FFFFFFF
//����ͼ���ڽӱ��ʾ
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
             if(i==j || i<0 || i>=size || j<0 || j>=size )//|| weight<0)
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
//Bellman_Ford�㷨ʵ��/����Ӷ���start�������������̾��룬�Լ����·��
//parent��¼���� s->v������·��,d��¼����s����Ӧ����v�ľ���,������ͼ�д��ڸ�Ȩ��·���򷵻�0,���򷵻�1
  int  bellman_ford_shortest_path(GraphHeader  *h,int  *parent,int *d,int  start)
 {
       int          i,k,size=h->size;
       int          len;
       Graph        *graph=h->graph;
       PostGraph    *pst;
//�������ݵĳ�ʼ������
       for(i=0;i<size;++i)
      {
              d[i]=INT_F;
              parent[i]=-1;
       }
       d[start]=0;
       len=size-1;
//�����еıߣ������ɳڲ���size��
       for(i=0;i<len;++i)
      {
             for(k=0;k<size;++k)
            {
                   pst=graph[k].front;
                   for(  ; pst ;pst=pst->next)
                  {
                           if(d[pst->vertex]>d[pst->vp]+pst->weight)
                          {
                                  d[pst->vertex]=d[pst->vp]+pst->weight;
                                  parent[pst->vertex]=pst->vp;
                           }
                   }
            }
       }
//����Ƿ��и�Ȩ��·
      for(i=0;i<size;++i)
     {
            for(pst=graph[i].front; pst ;pst=pst->next)
           {
                         if(d[pst->vertex]>d[pst->vp]+pst->weight)
                                return 0;
            }
      }
      return 1;
  }
/***********************************************************/
  int  main(int  argc,char *argv[])
 {
      GraphHeader  hGraph,*h=&hGraph;
      int          *parent,*d;
      int          i,j;

      printf("����ͼ���ڽӱ��ʾ..........\n");
      CreateGraph(h);
      printf("\n�������ɵ�ͼ�ĵ�Դ���·��.........\n");
      parent=(int *)malloc(sizeof(int)*h->size);
      d=(int *)malloc(sizeof(int)*h->size);

      if(!bellman_ford_shortest_path(h,parent,d,0))
	  {
		  printf("���ͼ�д��ڸ�Ȩ��·!\n");
		  return 1;
	  }
//���������������Ľ��
      for(i=0;i<h->size;++i)
     {
           printf("\n-------------------------------------------------\n");
           printf("����0----->%d ��·������Ϊ%d\n",i,d[i]);
           printf("·��:");
           j=i;
           do
          {
                printf("  %d   ",j);
                j=parent[j];
           }while(j!=-1);
      }
      free(parent);
      free(d);
      return 0;
  }