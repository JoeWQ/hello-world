//2012/12/16/14:28
//AOV������������
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _PostGraph
 {
       int      vertex;
       int      vp;
       struct   _PostGraph   *next;
  }PostGraph;
//*********************************************
  typedef  struct  _Graph
 {
//��¼����ڵ�����
       int                   count;
       struct  _PostGraph   *link;
  }Graph;
  typedef  struct  _GraphInfo
 {
       int                size;
       struct  _Graph    *graph;
  }GraphInfo; 
//***********************************************/
  void  CreateDirectedGraph(GraphInfo *,int (*p)[10],int );
  void  CreateMatrix(int (*p)[10],int *);
//��;�еĽ�����������������
  int  toplogic_sort(GraphInfo *,int *);
  
  static  int  matrix[10][10];
  static  int  vbuf[32];
  
  void  CreateMatrix(int (*matx)[10],int *size)
 {
       int  i,j,n;
       do
      {
             n=-1;
             printf("�������ڽӾ����ʵ���е���Ŀ\n");
             scanf("%d",&n);
       }while(n<2 || n>10);
       *size=n;

       for(i=0;i<n;++i)
          for(j=0;j<n;++j)
              matx[i][j]=0;

       printf("����������ͼ�Ľڵ��ǰ���ͺ�̹�ϵ,-1 -1��ʾ�˳�:\n");
       
       do
      {
            i=-1,j=-1;
            printf("������ǰ���ڵ�ͺ�̽ڵ�:\n");
            scanf("%d %d",&i,&j); 
            if(i==-1 && j==-1)
                break; 
            if(i<0 || j<0 || i>=n || j>=n)
           {
                 printf("�Ƿ�������!\n"); 
                 continue;
            }
            printf(" %d and %d ��������\n",i,j);
            matx[i][j]=1;
       }while( 1 );
  }
//��������ͼ���ڽӱ��ʾ
  void  CreateDirectedGraph(GraphInfo *info,int (*matx)[10],int n)
 {
       Graph       *graph,*g;
       PostGraph   *pst;
       int         i,j;

       info->size=n;
       graph=(Graph *)malloc(sizeof(Graph)*n);
       g=graph;
       info->graph=graph;
//��ʼ��
       for(i=0;i<n;++i,++graph)
      {
           graph->count=0;
           graph->link=NULL;
       }
       graph=g;
       for(i=0;i<n;++i,++graph)
      {
            for(j=0;j<n;++j)
           {
                 if(matx[i][j])
                {
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=j;
                       pst->vp=i;
//��¼���j�����,Ϊ�˱����㷨���ȶ��ԣ�ʹ�õ���ʽջ�ṹ
                       ++g[j].count;
                       pst->next=graph->link;
                       graph->link=pst;
                 }
            }
       }
  }
//������ͼ�Ľڵ��������������,���ɹ����򷵻�1�����򷵻�0
  int  toplogic_sort(GraphInfo *info,int *vbuf)
 {
       int     i,k,n;
       int     top;
       Graph   *graph;
       PostGraph   *pst=NULL;;
//ע�⣬������������˼·�ŵ㸴�ӣ�������������ŵ����ѣ��������Ǹ�Ч��
       top=-1;
       k=0;
       n=info->size;
       graph=info->graph;
//�����Ϊ0�Ľڵ㰴count�����ʵ�������ջ
       for(i=0;i<n;++i,++graph)
      {
           if(!graph->count)
          {
                graph->count=top;
                top=i;
           }
       }
//
       graph=info->graph;
       for(i=0;i<n;++i)
      {
           if(top==-1)
          {
                printf("�������ͼ�к��л�����������ʧ��!\n");
                return 0;
          }
          else
         {
                vbuf[k++]=top;
                pst=graph[top].link;
                top=graph[top].count;
                for( ;pst ;pst=pst->next)
               {
                      --graph[pst->vertex].count;
                      if(!graph[pst->vertex].count)
                     {
                           graph[pst->vertex].count=top;
                           top=pst->vertex;
                      }
                }
          }
      }
      return 1;
  }
//****************************************************************
  int  main(int argc,char *argv[])
 {
      GraphInfo   ginfo,*info;
      PostGraph   *pst,*p;
      Graph       *graph;
      int         size,i;

      info=&ginfo;
      size=0;
      info->graph=NULL;
      info->size=0;

      printf("��������ͼ���ڽӾ����ʾ..........\n");
      CreateMatrix(matrix,&size);
      printf("��������ͼ���ڽӱ��ʾ.....\n");
      CreateDirectedGraph(info,matrix,size);

      printf("���ڼ���ͼ����������...\n");
 
      if(!toplogic_sort(info,vbuf))
            printf("������������ʧ��!\n");
      else
     {
            for(i=0;i<size;++i)
                printf("%d------>",vbuf[i]);
      }
      printf("\n���ڿ�ʼ�ͷ��ڴ�...\n");
      graph=info->graph;
      for(i=0;i<size;++i,++graph)
     {
           pst=graph->link;
           while( pst )
          {
               p=pst;
               pst=pst->next;
               free(p); 
           }
     }
     free(info->graph);
     return 0;
  }
      