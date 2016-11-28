//2013/1/20/18:20
//������������ı��֡�����ʱ���,.ע�⣬������Ҫ��Ե�������ͼ
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"
  #include"ͼ�ı���_ջ�Ͷ���.c"
//ͼ���������
  static  void  deep_visit(GraphHeader *,int ,int *);
//��������ڽӱ�����ڽӱ��ʾ
  void  reverse_adj_list(GraphHeader  *h,GraphHeader  *rh);

  void  deep_visit_first(GraphHeader  *h)
 {
        int          i,j,time;
        Graph        *g;
//��ʼ�����ݽṹ,��ͼ�еı�ʾ�����
       j=h->size;
       for(g=h->graph,i=0;i<j;++i,++g)
              g->v=0;
//ȫ��ʱ���
       time=0;
       for(g=h->graph,i=0;i<j;++g,++i)
      {
//�����û�б����ʣ���ʼ���������������
            if(! g->v)
                 deep_visit(h,i,&time);
       }
  }
  static  void  deep_visit(GraphHeader *h,int  start,int *time)
 {
      Graph  *graph;
      PostGraph  *pst;
      StackHeader  hStack,*hsk=&hStack;
      int  *vertex,index,i,count=*time;
//��ʼ�����ݽṹ
      hsk->size=0;
      hsk->front=NULL;
      pst=NULL;
      graph=h->graph;

      vertex=(int *)malloc(sizeof(int)*h->size);
      index=0;
//��ʼ�����������
      graph[start].v=1;
      ++count;
      pst=graph[start].front;
      vertex[index++]=start;
      while( pst )
     {
             if(! graph[pst->vertex].v)
            {
                  graph[pst->vertex].v=1;
                  push(hsk,pst);
             }
             pst=pst->next;
      }
//����ѭ������
      while( hsk->size )
     {
             ++count;
             pop(hsk,&pst);
             vertex[index++]=pst->vertex;
             pst=graph[pst->vertex].front;
//ע�⣬����������㷨�У����ܲ��ù�������Ĳ���
             for(  ;pst ;pst=pst->next)
            {
                    if(! graph[pst->vertex].v)
                   {
                          graph[pst->vertex].v=1;
                          push(hsk,pst);
                    }
             }
      }
//����ʱ���
     if(index>h->size)
           printf("����Խ��.....%d\n",index);

     for(i=index-1;i>=0;--i)
           graph[vertex[i]].finish=++count;
//���ʱ���
     for(i=0;i<index;++i)
           printf("����%d--->ʱ��:  %d \n",vertex[i],graph[vertex[i]].finish);
     *time=count;
     free(vertex);
     printf("\n******************$$$$$$$$$$$$$$$$$$$$$$$**************************\n");
  }
//����ͼ���ڽӱ��ʾ
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j;
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
             scanf("%d %d",&i,&j);
             if(i==-1 && j==-1)
                  break;
             if(i<0 || i>=size || j<0 || j>=size)
            {
                    printf("�Ƿ�������!\n");
                    continue;
             }
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=j;
             pst->vp=i;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;
             printf("%d----->%d\n",i,j);
       }while(i!=-1 && j!=-1);
  }
//��һ��ͼ���ڽӱ��ʾ�� ���ڽӱ�
  void  reverse_adj_list(GraphHeader  *h,GraphHeader  *rh)
 {
       int         i,size;
       PostGraph   *pst,*p;
       Graph       *graph,*g;
//��ʼ������
       size=h->size;
       g=(Graph *)malloc(sizeof(Graph)*size);
       rh->graph=g;
       rh->size=size;
       graph=h->graph;
//����
       for(i=0;i<size;++i,++g)
      {
             g->count=0;
             g->v=0;
             g->finish=0;
             g->front=NULL;
       }
       g=rh->graph;
//��ʼ�������ڽӱ�
      for(i=0;i<size;++i)
     {
             pst=graph[i].front;
             while(  pst )
            {
                    p=(PostGraph *)malloc(sizeof(Graph));
                    p->vertex=pst->vp;
                    p->vp=pst->vertex;
                    p->next=g[pst->vertex].front;
                    g[pst->vertex].front=p;
                    ++g[pst->vertex].count;
          
                    pst=pst->next;
             }
      }
  }
//����ڽӱ�
  void  print_graph(GraphHeader  *h)
 {
      PostGraph  *pst;
      Graph  *graph=h->graph;
      int         i=0;
      for(   ;i<h->size;++i,++graph)
     {
             printf("����%d -->",i);
             pst=graph->front;

             while(  pst )
            {
                     printf("  %d   ",pst->vertex);
                     pst=pst->next;
             }
             printf("\n");
      }
  }
      
  int  main(int argc,char *argv[])
 {
       GraphHeader  hStack,*h=&hStack;
       GraphHeader  rhStack,*rh=&rhStack;
       
       h->size=0;
       h->graph=NULL;
       rh->size=0;
       rh->graph=NULL;

       printf("�����ڽӱ�........\n");
       CreateGraph(h);
       printf("����������ڽӱ�...........\n");
       print_graph(h);

       printf("\n***************�������ڽӱ�*****************\n");
       reverse_adj_list(h,rh);
       printf("������ڽӱ�.......\n");
       print_graph(rh);

       printf("\n****************************���ڽӱ���������������**********************\n");
       deep_visit_first(h);
       printf("\n*****************************�����ڽӱ���������������*****************\n");
       deep_visit_first(rh);
       exit(0);
  }
 