//2013��3��6��18:52:34
//���������
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"
  #include"ͼ�ı���_ջ�Ͷ���.c"
//����������
  static  int  dfvs(GraphHeader  *,StackHeader *,int ,int);
  void    ford_fulkerson_most_flow(GraphHeader *,int (*p)[10],int ,int);
  static  void  process_argument_path(GraphHeader *,StackHeader *,Stack *,int (*p)[10]);
  static  void  remove_edge(Graph *,PostGraph *);
  static  void  add_edge(Graph *,PostGraph *);

  int  flows[10][10];
//����ͼ���ڽӱ��ʾ
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("������ͼ�Ķ�����Ŀ(>1 && <10)!\n");
       do
      {
             size=1;
             printf("���������Ҫ��Ķ�����:\n");
             scanf("%d",&size);
       }while(size<=1 || size>10);
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
       printf("�����붥��֮��Ĺ��� (-1 -1,-1)��ʾ�˳�!\n");
       do
      {
             printf("�����붥���붥��֮��Ĺ���:\n");
             i=j=0;
             weight=0;
             scanf("%d %d %d",&i,&j,&weight);
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
             pst->weight=weight;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;
             printf("%d----->%d:%d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//��ͼ���������������,��������Ŀ�궥��ʱ���˳������Ǳ���������·��
  static  int  dfvs(GraphHeader  *h,StackHeader *sh,int start,int  end)
 {
       Graph       *graph;
       PostGraph   *pst;
       int         i,flag=0,size=h->size;

       sh->size=0;
       sh->front=NULL;
//����������ж���ı����ʹ��ĺۼ�
        graph=h->graph;
        for(i=0;i<size;++i,++graph)
              graph->v=0;
//��һ����ʼ���������������
        graph=h->graph;
        pst=graph[start].front;
//����Ѿ�û���κ�·������ֱ���˳�
        if(! pst )
            return 0;
//�����ѭ����֮����� size ��
        graph[start].v=1;   //ע����һ������Ҫ
        push(sh,pst);
        graph[pst->vertex].v=1;

        while( sh->size )
       {
//��ȡջ�Ķ��������Ԫ�أ����ж�ѭ���Ƿ�Ҫ��ֹ
              pst=sh->front->pst;
              if(pst->vertex==end)
             {
                    flag=1;
                    break;
              }
//Ѱ����һ��Ŀ�궥��
              pst=graph[pst->vertex].front;
              while( pst )
             {
                     if(!graph[pst->vertex].v)
                            break;
                     pst=pst->next;
              }
//���û���ҵ�����ִ����ջ����
              if(! pst )
                     pop(sh,&pst);
//����ֱ����ջ
              else
             {
                     push(sh,pst);
                     graph[pst->vertex].v=1;
              }
         }
//���û�в��ҵ�Ŀ��·������ѭ����������ջ�Ѿ�Ϊ�գ�����ֱ���˳���
         return flag;
  }
//Ford-Fulkerson�㷨/startΪԴ�㣬endΪ���,������������д��flow������
  void  ford_fulkerson_most_flow(GraphHeader  *h,int (*flow)[10],int start,int end)
 {
        int          i,j,size;
        PostGraph    *pst;
        StackHeader  shStack,*sh=&shStack;
        Stack        *st,*it;
        Graph        *graph;
//�����ݽ���һЩ��ʼ������
        graph=h->graph;
        size=h->size;
//��ʼ����/�������������������
        for(i=0;i<size;++i)
            for(j=0;j<size;++j)
                  flow[i][j]=0;

        while( dfvs(h,sh,start,end) )
       {
//������СȨֵ��
               st=sh->front;
               it=st;
               while( st )
              {
                    if(it->pst->weight>st->pst->weight)
                          it=st;
                    st=st->next;
               }
//��������Ѿ����ҵ��ı� ��ͼ���Ѿ����ڵı߽��в���
               process_argument_path(h,sh,it,flow);
//�����е�����·���ϵıߵ�Ȩֵ���и��� && �ͷŶ�̬ջ��ռ�ݵ��ڴ�
               for(st=sh->front; st ;)
              {
                      it=st;
                      pst=st->pst;
                      st=st->next;
                      free(it);
               }
        }
  }
//���д�������·��,�����¾���
  static  void  process_argument_path(GraphHeader  *h,StackHeader *sh,Stack *low,int (*flow)[10])
 {
        Stack       *it;
        PostGraph   *pst,pgc,*pg=&pgc;
        Graph       *graph;
        int         weight=low->pst->weight;

        graph=h->graph;
        pg->weight=weight;
        for(it=sh->front; it ;it=it->next)
       {
//���������
              pst=it->pst;
              pg->vp=pst->vertex;
              pg->vertex=pst->vp;
//���¾���
              flow[pst->vp][pst->vertex]+=weight;
//���������С��
              if(pst->weight>weight)
//�ȶ��Ѿ����ڵıߵ�Ȩֵ���� weight�������ӱ�
                   pst->weight-=weight;
//������ɾ�������
              else  
                   remove_edge(graph,pst);
              add_edge(graph,pg);
         }
  }
//ɾ�������ı�
  static  void  remove_edge(Graph  *graph,PostGraph  *pst)
 {
        PostGraph  *prev=NULL,*p;

        for(p=graph[pst->vp].front; p ;p=p->next)
       {
               if(p==pst)
                   break;
               else
                   prev=p;
        }
//���������߲��Ǻ���������������
        if(!  p)
             return;

         --graph[pst->vp].count;
        if(! prev)
               graph[pst->vp].front=pst->next;
        else
               prev->next=pst->next;
        free(pst);
  }
//��ͼ�ж�Ӧ�Ķ�������һ���ߣ�����������Ѿ����ڣ��ͺϲ�������
//ע�⣬���ﲻ���ͷ�pst����Ϊ������ͼ�е��Ѿ������õıߣ����Ǻ�����̬���ɵ�/��һ��������������ͬ
  static  void  add_edge(Graph  *graph,PostGraph  *pst)
 {
        PostGraph  *p;
        
        for(p=graph[pst->vp].front; p ;p=p->next)
                if( p->vp==pst->vp  &&  p->vertex==pst->vertex )
                      break;
//��������ı߲�����
        if(! p )
       {
              p=(PostGraph *)malloc(sizeof(PostGraph));
              p->vp=pst->vp;
              p->vertex=pst->vertex;
              p->weight=pst->weight;
              p->next=graph[pst->vp].front;
              graph[pst->vp].front=p;
        }
        else
              p->weight+=pst->weight;
        ++graph[pst->vp].count;
  }
//
  int  main(int  argc,char  *argv[])
 {
        GraphHeader  hGraph,*h=&hGraph;
        int          i,j,size;

         printf("\n******************����ͼ���ڽӱ��ʾ********************\n");
         CreateGraph(h);
         printf("�����ͼ�������\n");
         ford_fulkerson_most_flow(h,flows,0,h->size-1);
         printf("������������........................\n");
         for(i=0,size=h->size;i<size;++i)
        {
                for(j=0;j<size;++j)
                      printf("%d      ",flows[i][j]);
                printf("\n");
         }
         return 0;
  }