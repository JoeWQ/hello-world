//2013��3��5��10:17:18
//ϡ��ͼ�ϵ�Johnson�㷨,�ڵײ�����ʹ����С��ʵ��
//���㷨�� Dijkstra �� Bellman-Ford�㷨Ϊ����
  #include<stdio.h>
  #include<stdlib.h>
  #include"�й�ͼ�����ݽṹ.h"

  #define   INF_T    0x30000000
  int    paths[10][10];
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
//ͨ���Ա����¸����µ�Ȩֵ��ȷ�����еı߾�Ϊ�Ǹ�ֵ��Ȼ�����еϽ�˹������ Bellman-Ford �㷨
   static void  CreateOtherWeightGraph(GraphHeader  *h,GraphHeader  *gh)
  {
        int  size=h->size,i;
        PostGraph  *pst=NULL,*p;
        Graph   *graph=h->graph;
        Graph   *g,*tg;
      
        gh->size=size+1;
        g=(Graph *)malloc(sizeof(Graph)*(size+1));
        gh->graph=g;
//����Ĵ��������½���������ͼ����һ��Ȩֵͼ/������ӵĶ������������ĩβ
        tg=g+size;
        tg->count=size;
        tg->front=NULL;

        for(i=0;i<size;++i)
       {
               pst=(PostGraph *)malloc(sizeof(PostGraph));
               pst->vertex=i;
               pst->vp=size;
               pst->weight=0;
               pst->next=tg->front;
               tg->front=pst;
        }
//��ʼ���и��Ʋ���
        for(i=0;i<size;++i,++graph,++g)
       {
               pst=graph->front;
               g->count=graph->count;
               g->front=NULL;
               while(  pst  )
              {
                     p=(PostGraph *)malloc(sizeof(PostGraph));
                     p->vertex=pst->vertex;
                     p->vp=pst->vp;
                     p->weight=pst->weight;
                     p->next=g->front;
                     g->front=p;

                     pst=pst->next;
               }
         }
  }
//Bellman-Ford�㷨
  static  int  bellman_ford(GraphHeader  *h,int *dstc,int  start)
 {
        int    i,j,lt,flag=1,size=h->size;
        int    **weight,*w;
        Graph  *gh=h->graph;
        PostGraph  *pst;

//        printf("444444444444444444444444\n");
        size=h->size;
//��ʼ������·���ľ���
        for(i=0;i<size;++i)
             dstc[i]=INF_T;
        dstc[start]=0;
//����Ȩֵ�Ķ�ά�洢����
        weight=(int **)malloc(sizeof(int *)*size);
        for(i=0;i<size;++i)
       {
               w=(int *)malloc(sizeof(int)*size);
               weight[i]=w;
               for(j=0;j<size;++j,++w)
              {
                     *w=INF_T;
                     if(j==i)
                        *w=0;
               }
        }
//��Ȩֵд���������    
        for(i=0;i<size;++i)
       {
               pst=gh[i].front;
               while( pst )
              {
                     w=weight[pst->vp];
                     w[pst->vertex]=pst->weight;
                     pst=pst->next;
               }
        }
//�����еı߽����ɳ� (size-1)��
        for(j=0;j<size-1;++j)
       {
             for(i=0;i<size;++i)
            {
                   pst=gh[i].front;
                   while(  pst  )
                  {
                         w=weight[pst->vp];
                         lt=w[pst->vertex];
                         if(dstc[pst->vertex]>dstc[pst->vp]+lt)
                                 dstc[pst->vertex]=dstc[pst->vp]+lt;
                          pst=pst->next;
                   }
              }
        }
//����Ƿ���ڸ�Ȩ��·
        for(i=0;i<size;++i)
       {
              pst=gh[i].front;
              while( pst )
             {
                    w=weight[pst->vp];
                    lt=w[pst->vertex];
                    if(dstc[pst->vertex]>dstc[pst->vp]+lt)
                   {
                          flag=0;
                          goto label;
                    }
                    pst=pst->next;
              }
        }
    label:
//�ͷ��ڴ�
        for(i=0;i<size;++i)
             free(weight[i]);
        free(weight);
//        printf("55555555555555555555555555555555555\n");
        return flag;
  }
//Dijkstra�㷨
   static  void  dijkstra_shortest_path(GraphHeader  *h,int  *distc,int start)
  {
         int   *tag,size;
         int   i,j,k,min;
         Graph  *graph=h->graph;
         PostGraph  *pst;

         size=h->size;
         tag=(int *)malloc(sizeof(int)*size);
         for(i=0;i<size;++i)
        {
              tag[i]=0;
              distc[i]=INF_T;
         }
         for(pst=graph[start].front; pst ;pst=pst->next)
               distc[pst->vertex]=pst->weight;
         distc[start]=0;

         for(i=0;i<size-1;++i)
        {
//Ѱ����С����
               min=INF_T;
               k=0;
               for(j=0;j<size;++j)
              {
                     if(!tag[j] &&   min>=distc[j])
                    {
                            min=distc[j];
                            k=j;
                     }
               }
//�ҵ������ϱ��,���Զ���k�ı߽����ɳڲ���
               tag[k]=1;
               for(pst=graph[k].front; pst ; pst=pst->next)
              {
                      min=distc[k]+pst->weight;
                      if(distc[pst->vertex]>min)
                              distc[pst->vertex]=min;
               }
         }
         free(tag);
  }
//Johnson�㷨���������ϸ����㷨���ۺ�����
  void  johnson_all_pairs_shortest_paths(GraphHeader  *h,int  (*path)[10])
 {
         int    i,j,k,size;
         int    *distc,*dt;
         Graph  *graph;
         PostGraph  *pst,*p;
         GraphHeader  hGraph,*gh=&hGraph;

         gh->size=0;
         gh->graph=NULL;
//��������ͼ���Ƿ��и�Ȩֵ����
         graph=h->graph;
         size=h->size;
         k=0;
         distc=(int *)malloc(sizeof(int)*(size+1));
         for(i=0;i<size;++i)
        {
               pst=graph[i].front;
               while( pst )
              {
                      if(pst->weight<0)
                     {
                            k=1;
                            goto label;
                      }
                      pst=pst->next;
               }
          }
    label:
//          printf("\n11111111111111111111111111\n");
//����и�Ȩֵ���ڣ��ͽ��д��������ͼ���㷨
          if(  k  )
         {
//�����µ�ͼ
                 CreateOtherWeightGraph(h,gh);
                 printf("gh->size:%d\n",gh->size);
                 if(!bellman_ford(gh,distc,size))
                {
                         printf("���ͼ�а�����Ȩֵ�Ļ�·!\n");
//����Ĳ������ͷ�ԭ����ռ�ݵ��ڴ�
                         for(i=0;i<gh->size;++i)
                        {
                                pst=gh->graph[i].front;
                                while( pst )
                               {
                                       p=pst;
                                       pst=pst->next;
                                       free(p);
                                }
                          }
                         free(gh->graph);
                 }
                 else
                {
//�����еı߽������¸����µ�Ȩֵ
                         for(i=0;i<size;++i)
                              printf("%d--->%d\n",i,distc[i]);
                            
                         graph=gh->graph;
                         size=gh->size;
                         for(i=0;i<size;++i)
                        {
                                pst=graph[i].front;
                                while(  pst  )
                               {
//ע���������һ����������Ҫ����һ����֤�����еıߵ�Ȩֵ��Ϊ����
                                       pst->weight+=(distc[pst->vp]-distc[pst->vertex]);
                                       pst=pst->next;
                                }
                          }
//�����������ɵ��µ�Ȩֵͼ�������� ��ÿ������ֱ����� Dijkstra�㷨
                          dt=(int *)malloc(sizeof(int)*size);
                          for(i=0;i<size;++i)
                         {
                                dijkstra_shortest_path(gh,dt,i);
                                for(j=0;j<size;++j)
                                      path[i][j]=dt[j]+distc[j]-distc[i];
                          }
//����Ĳ������ͷ�ԭ����ռ�ݵ��ڴ�
                         for(i=0;i<gh->size;++i)
                        {
                                pst=gh->graph[i].front;
                                while( pst )
                               {
                                       p=pst;
                                       pst=pst->next;
                                       free(p);
                                }
                          }
                         free(gh->graph);
                         free(dt);
                  }
       }
       else
      {
//��ԭ����ͼ�ϵ�ÿ���������õϽ�˹�����㷨
                  for(i=0;i<size;++i)
                 {
                         dijkstra_shortest_path(h,distc,i);
                         dt=path[i];
                         for(j=0;j<size;++j)
                              dt[j]=distc[j];
                  }
       }
       free(distc);
  }
//***********************************************************
  int  main(int argc,char *argv[]) 
 {
       int  i,j,k;
       PostGraph   *pst,*p;
       GraphHeader  hGraph,*h=&hGraph;
       CreateGraph(h);

       printf("\n*****************��ʼ�������·��*****************\n");
       johnson_all_pairs_shortest_paths(h,paths);
       printf("\n�������!\n");
       printf("\n");
       k=h->size;
       for(i=0;i<k;++i)
      {
              for(j=0;j<k;++j)
                    printf("%d      ",paths[i][j]);
              printf("\n");
       }
//�ͷ��Ѿ�������ڴ�     
       for(i=0;i<h->size;++i)
      {
              pst=h->graph[i].front;
              while( pst )
             {
                   p=pst;
                   pst=p->next;
                   free(p);
              }
        }
        return 0;
  }      