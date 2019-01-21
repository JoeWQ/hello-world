//2013/1/20/10:18
//��ͼ(����������ͼ,�Ҳ��ܴ��ڻ�)�еĶ��������������,ʹ�������������
  #include<stdio.h>
  #include<stdlib.h>
/******************************************/
//��һά������ж�ά���� ��Ҫ�õ��� ��
  #define  SET_ARRAY(m,i,j,s,n)   *(m+(i)*(s)+(j))=n
  #define  GET_ARRAY(m,i,j,s)     *(m+(i)*(s)+(j))
//ͼ���ڽӱ��ʾ
  typedef  struct  _PostGraph
 {
        int               vertex;
        int               vp;
        struct  _PostGraph   *next;
  }PostGraph;
//�������ͼ�Ľṹ
  typedef  struct  _Graph
 {
        int   count;
//��¼�Ƿ��Ѿ�������,0��ʾδ�����ʣ�1��ʾ�Ѿ�������
        int   v;
        struct  _PostGraph   *front;
  } Graph;
//����ṹͷ �����Ź���ͼ�ĳ��ȣ��Լ�ͷָ��
  typedef  struct  _GraphHeader
 {
        int    size;
        struct   _Graph  *graph;
  }GraphHeader;
//��ά�����������
  typedef  struct  _RowCol
 {
       int           *rt;
       int           row;
       int           col;
  }RowCol;
 #include"ͼ�ı���_ջ�Ͷ���.c"
//�����ڽӾ���
  void  CreateMatrix(RowCol  *r)
 {
       int  i,j,n,weight;
       int  *rt;

       do
      {
              n=-1;
              printf("������ͼ���������Ķ�����(n>1 && n<=16) !\n");
              scanf("%d",&n);
       }while(n<=1 || n>16);
       printf("n--->%d\n",n);
       r->row=n;
       r->col=n;

       j=n*n;
       rt=(int *)malloc(sizeof(int)*j);
       r->rt=rt;
//��ʼ����
       for(i=0;i<j;++i,++rt)
            *rt=0;
       rt=r->rt;
       printf("������;�ж����붥��֮���Ȩֵ( weight>0 )(-1 -1)��ʾ��������! \n");
       do
      {
               i=j=weight=-1;
               printf("������ i j weight��ֵ:\n");
               scanf("%d %d",&i,&j);
               if(i==j || i<0 || i>=n || j<0 || j>=n)
              {
                      printf("�Ƿ�������,i ,j weight ��������ȶ���Լ��!\n");
                      continue;
               }
               printf("%d-->%d\n",i,j);
               SET_ARRAY(rt,i,j,n,1);
       }while(i!=-1 && j!=-1);
  }
  void  CreateGraph(GraphHeader  *h,RowCol *r)
 {
        int  i,j,weight;
        int  *rt=r->rt;
        Graph  *graph;
        PostGraph   *pst;

        h->size=r->row;
        graph=(Graph *)malloc(sizeof(Graph)*r->row);
        h->graph=graph;
        
        for(i=0;i<r->row;++i)
       {
               graph[i].front=NULL;
               graph[i].count=0;
               graph[i].v=0;
               for(j=0;j<r->row;++j)
              {
                      weight=GET_ARRAY(rt,i,j,r->row);
                      if( weight )
                     {
                             pst=(PostGraph *)malloc(sizeof(PostGraph));
                             pst->vertex=j;
                             pst->vp=i;
                             pst->next=graph[i].front;
                             graph[i].front=pst;
                             ++graph[i].count;
                      }
              }
        }
//�ͷ��Ѿ�ռ�õ��ڴ棬��Ϊ���Ѿ�������
       free(rt);
       r->rt=NULL;
  }
//�����������
  void  deep_visit_first(GraphHeader  *h)
 {
       Graph  *graph=h->graph;
       int    index=0,w;
       StackHeader  hstack,*ht=&hstack;
       PostGraph  *pst;
//��¼������߼�˳��
       int    *d=(int *)malloc(sizeof(int)*h->size);
//��¼����ʱ��
//��ʼ��ĳЩ����Ҫ�õ�������
//��ʼ��ջ
       ht->size=0;
       ht->front=NULL;
//��¼��ǰҪ�õ���ͼ����
       pst=graph[0].front;
//���������������
       graph[0].v=1;
       d[index++]=0;
       printf("###################\n");
       while( pst )
      {
             push(ht,pst);
             pst=pst->next;
       }
       while(! IsStackEmpty(ht))
      {
            pop(ht,&pst);
            d[index++]=pst->vertex;
            graph[pst->vertex].v=1;
            pst=graph[pst->vertex].front;
//Ѱ��û�б����ʵĶ���
            for(   ;pst ;pst=pst->next)
           {
                  if(! graph[pst->vertex].v)
                        push(ht,pst);
            }
      }
//�������������з��ʵĶ�������
      for(w=0;w<index;++w)
          printf("%d  ",d[w]);
      printf("\n");
      free(d);
  }
  int  main(int argc,char *argv[])
 {
       GraphHeader  hgraph,*h=&hgraph;
       RowCol       rc;
       h->size=0;
       h->graph=NULL;
      
       printf("��ʼ�����ڽӾ���.....\n");
       CreateMatrix(&rc);
       printf("�����ڽӱ�...\n");
       CreateGraph(h,&rc);
       printf("��ͼ�еĶ��������������.....\n");
       deep_visit_first(h);
       return 0;
  }