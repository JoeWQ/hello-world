//2012/12/17/14:33
//��ȡ�߻����Ĺؼ�·��
//ë�󶫣��ܶ���ͬ־
  #include<stdio.h>
  #include<stdlib.h>
/*******************************************/
//���ݽṹ�Ķ��壬���ﲻͬ��AOV��,��Ϊ����Ҫһ�����ڽӱ�
  typedef  struct  _PostGraph
 {
         int                  vertex;
         int                  vp;
         int                  weight;
//����ؼ�·��ʱҪ�õ���������
         struct   _PostGraph  *next;
  }PostGraph;
//ͼ����Ķ���
  typedef  struct  _Graph
 {
//���ڽӱ���ĳ��Ƚ��м���
         int                 ocount;
//���ڽӱ������Ƚ��м���
         int                 icount;
//ָ���̶��������ָ��
         struct  _PostGraph  *ofront;
//ָ��ǰ�����������ָ��
         struct  _PostGraph  *ifront;
  }Graph;
//��¼��ͼ��������ص���Ϣͷ
  typedef  struct  _GraphHeader
 {
//��¼ͼ���������Ķ������Ŀ
         int           size;
//ָ��ͼ��ָ��
         struct  _Graph    *graph;
  }GraphHeader;
/***************************************************************/
  void  CreateMatrix(int (*p)[10],int *);
//ͬʱ�����ڽӱ�����ڽӱ�
  void  CreateRAdjGraph(GraphHeader *,int (*p)[10],int);
//����ؼ�·��
  int  artical_path(GraphHeader  *);
//�ڲ�����,��������ı���,��ȡearliest�����ֵ
  static  int  modified_toplog_sort(GraphHeader *,int *,int *);
//��������ı��֣���ȡlatest�����ֵ
  static  int  modified_toplog_sort_r(GraphHeader *,int *,int);
//ɾ���ߵĲ���
  static  void  remove_edge(GraphHeader *,int,PostGraph *);
/*******************************************************************/
  static  int  matrix[10][10];
  void  CreateMatrix(int (*matx)[10],int *size)
 {
        int  i,j,n,weight;
        do
       { 
                n=-1;
                printf("������ͼ�Ķ�����Ŀ(>=2 && <=10):\n");
                scanf("%d",&n);
        }while(n>=10 || n<2);
        
        *size=n;
        for(i=0;i<n;++i)
           for(j=0;j<n;++j)
                matx[i][j]=0;
        printf("����������ͼ�Ķ���Ͷ���֮���Ȩֵ,-1 -1 -1  ��ʾ�˳�!\n");
        do
       {
              printf("�����붥���붥��֮���Ȩֵ:\n");
              i=-1,j=-1,weight=-1;
              scanf("%d %d %d",&i,&j,&weight);
              if(i==-1 && j==-1)
                    break;
              if(i<0 || i>=n || j<0 || j>=n || i==j || weight<0)
             {
                     printf("�Ƿ�������!\n");
                     continue;
              }
              printf("%d and %d -->%d\n",i,j,weight);
              matx[i][j]=weight;
        }while( 1 );
  }
//�����ڽӺ����ڽ��ڽӱ�
  void  CreateRAdjGraph(GraphHeader *h,int (*matx)[10],int n)
 {
       int  i,j;
       Graph  *graph,*rgraph;
       PostGraph   *pst;

       graph=(Graph *)malloc(sizeof(Graph)*n);
       h->graph=graph;
       h->size=n;
//��ʼ��,�ڽӱ�Ķ�������
       for(i=0;i<n;++i,++graph)
      {
             graph->ocount=0;
             graph->icount=0;
             graph->ofront=NULL;
             graph->ifront=NULL;
       }
       graph=h->graph;
       rgraph=graph;
       for(i=0;i<n;++i,++graph)
      {
            for(j=0;j<n;++j)
           {
                 if(matx[i][j])
                {
//�ȴ����ڽӱ�
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=j;
                       pst->vp=i;
                       pst->weight=matx[i][j];
                       pst->next=graph->ofront;
                       graph->ofront=pst;
//���Ӷ���j�����
                       ++rgraph[j].icount;
//���Ӷ���i�ĳ���
                       ++graph->ocount;
//�������ڽӱ�
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=i;
                       pst->vp=j;
                       pst->weight=matx[i][j];
                       pst->next=rgraph[j].ifront;
                       rgraph[j].ifront=pst;
                  }
             }
        }
  }
//����ؼ�·��,�ڼ���Ĺ����У�����ɾ����ͼh�е�һЩ��
  int  artical_path(GraphHeader *h)
 {
         int      *earliest,*latest,*stack;
         int      i,j,n,early,late;
         Graph    *graph;
         PostGraph  *pst,*p;
         
         n=h->size;
         earliest=(int *)malloc(sizeof(int)*n); 
         latest=(int *)malloc(sizeof(int)*n);
         stack=(int *)malloc(sizeof(int)*n);
//�ȵ����������������ʧ�ܣ���ֱ�ӷ���
         if(!modified_toplog_sort(h,earliest,stack))
                 return 0;
//����Ƿ��в��ɵ���Ķ���
         for(i=0,j=0;i<n;++i)
        {
               if(!earliest[i])
                   ++j;
         }
         if(j>1)
        {
               printf("ͼ���в��ɵ���Ķ��㣬��ȡ�ؼ�·��ʧ��!\n");
               return 0;
         }
         if(!modified_toplog_sort_r(h,latest,earliest[stack[n-1]]))//ע�����һ������
                  return 0;
//���濪ʼ��ȡ�ؼ�·��
         graph=h->graph;
         for(i=0;i<n;++i)
        {
              j=stack[i];
              pst=graph[j].ofront;
              while( pst )
             {
//�ȼ���ߵ�early,lateֵ������ߵ�early��late��ֵ��ͬ������ڽӱ���ɾ��������
                   early=earliest[j];
                   late=latest[pst->vertex]-pst->weight;
                   if(early!=late)
                  {
                        p=pst->next;
                        remove_edge(h,j,pst);
                        pst=p;
                   }
                   else
                        pst=pst->next;
              }
        }
//�����ڽӱ���ռ�ݵ��ڴ��ͷŵ�
       for(i=0;i<n;++i)
      {
             pst=graph[i].ifront;
             while( pst )
            {
                 p=pst;
                 pst=pst->next;
                 free(p);
             }
       }
       free(stack);
       free(earliest);
       free(latest);
       return 1;
  }
//ɾ��ͼ��һ����
  static  void  remove_edge(GraphHeader *h,int v,PostGraph  *pst)
 {
       Graph  *graph=h->graph;
       PostGraph   *p,*q=NULL;
       
       p=graph[v].ofront;
       while(p && p->vertex!=pst->vertex)
      {
            q=p;
            p=p->next;
       }
       if(! q)
            graph[v].ofront=pst->next;
       else
            q->next=pst->next;
       free(pst);
  }
          
//��������ı��֣���ȡearly��ֵ�����ɹ����򷵻�1 ���򷵻�0��ͨ�������������ͼ���ڻ�·)
  static  int  modified_toplog_sort(GraphHeader *h,int *early,int *stack)
 {
         int      i,j,top,k,m=0;
         int      n=h->size;
         Graph    *graph=h->graph;
         PostGraph   *pst;
        
         top=-1;
         for(i=0;i<n;++i)
        {
               if(!graph[i].icount)
              {
                    graph[i].icount=top;
                    top=i;
               }
               early[i]=0;
               stack[i]=0;
         }
//���㶥���earlyֵ
         for(i=0;i<n;++i)
        {
               if(top==-1)
              {
                      printf("������ͼ���ڻ�����ؼ�·��ʧ��!\n");
                      return 0;
               }
               else
              {
                      stack[m++]=top;
                      k=top;
                      pst=graph[top].ofront;
                      top=graph[top].icount;
                      for(    ;pst;pst=pst->next)
                     {
                           j=pst->vertex;
                           --graph[j].icount;
                           if(!graph[j].icount)
                          {
                                graph[j].icount=top;
                                top=j;
                           }
                           if(early[j]<early[k]+pst->weight)
                                   early[j]=early[k]+pst->weight;
                      }
               }
         }
/*
       printf("earliest��ֵ:\n");
       for(i=0;i<n;++i)
      {
            printf("vertex:%d-->earliest:%d    \n",i,early[i]);
       }
*/
        return 1;
  }
//��������������ı��֣���ȡlatest��ֵ�����ɹ����򷵻�1�����򷵻�0,�ڵ������������ǰ�Ѿ����裬
//latest�����һ��ֵ�Ѿ�����ʼ��
  static  int  modified_toplog_sort_r(GraphHeader *h,int  *latest,int iv)
 {
       int  i,j,k,top;
       int  n=h->size;
       Graph   *graph=h->graph;
       PostGraph  *pst;

       top=-1;
       for(i=0;i<n;++i)
      {
            if(!graph[i].ocount)
           {
                  graph[i].ocount=top;
                  top=i;
            }
//ע����һ������Ҫ
            latest[i]=iv;
       }
       if(top==-1)
      {
            printf("���ͼ���ڻ����������!\n"); 
            return 0;
       }
//       printf("top:%d-->iv:%d....\n",top,iv);
//       latest[top]=iv;
       for(i=0;i<n;++i)
      {
            if(top==-1)
           {
                 printf("���ͼ���ڻ�������ʧ��!\n");
                 return 0;
            }
            else
           {
                 k=top;
                 pst=graph[top].ifront;
                 top=graph[top].ocount;
                 for(  ;pst ;pst=pst->next)
                {
                       j=pst->vertex;
                       --graph[j].ocount;
                       if(!graph[j].ocount)
                      {
                            graph[j].ocount=top;
                            top=j;
                       }
                       if(latest[j]>latest[k]-pst->weight)
                              latest[j]=latest[k]-pst->weight;
                }
            } 
       }
/*
       printf("latestֵ:\n");
       for(i=0;i<n;++i)
            printf("vertex:%d->latest:%d   \n",i,latest[i]);
*/
    return 1;
  }
//*****************************************************************
  int  main(int argc,char *argv[])
 {
       GraphHeader  hg,*h;
       int          i,size;
       PostGraph    *pst,*p;
       Graph        *graph;

       h=&hg;
       printf("�����ڽӾ���......\n");
       CreateMatrix(matrix,&size);
       
       printf("����ͼ���ڽӱ�����ڽӱ��ʾ....\n");
       CreateRAdjGraph(h,matrix,size);
   
       printf("����ͼ�Ĺؼ�·��....\n");
       if(!artical_path(h))
      {
            printf("����ʧ��...\n");
            return 1;
       }

       graph=h->graph;
       for(i=0;i<size;++i)
      {
             pst=graph[i].ofront;
             if(pst)
            {
                  printf("����%d-->",i);
                  while( pst )
                 {
                        printf(":->:(vertex:%d,weight:%d)",pst->vertex,pst->weight);
                        pst=pst->next;
                  }
                  printf("\n");
            }
      }
      printf("�ͷ��ڴ�.....\n");
      for(i=0;i<size;++i)
     {
           pst=graph[i].ofront;
           while( pst )
          {
                p=pst;
                pst=pst->next;
                free(p );
           }
     }
     return 0;
  }