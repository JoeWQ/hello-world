/*
  *@aim:ͼ�������������·���㷨
  *@date:2014-11-3 12:37:58
  *@author:�ҽ���
  */
//
  #include"CGHeap.h"
  #include"Array.h"
  #include"CGraph.h"
  #include<stdio.h>
  #include<stdlib.h>
  #define    infine      0x3FFFFFFF
/*
  *@func:topologic_shortest_path
  *@request:ͼ�в��ܴ��ڻ�
  *@param:gͼ���ڽӱ��ʾ
  *@param:d�洢�������㵽Դ��s�����·�� 
  *@param:parent���������ǰ�������¼����û��ǰ������Ϊ-1
  *@request:size of d and parent >=g->getSize()
  */
   bool       topologic_shortest_path(CGraph    *g,int  s,int    *d,int    *parent)
  {
           int       size=g->getVertexCount();
           int       *vertex=(int *)malloc(sizeof(int)*size);
           int       i,e;
           CSequela     *q;
//�ж��Ƿ��л�
           if( g->topologicSort(vertex) <=0)
          {
                     free(vertex);
                     return   false;
           }
//���Ѿ�����Ķ���Ը����߽����ɳ�
//�ɳ�ǰ��׼��
          for( i=0;i<size;++i)
         {
                   d[i]=infine;
                   parent[i]=-1;
          }
          d[s]=0;
          for( i=0    ;i<size;++i )
         {
//�˴�����������s
                        s=vertex[i];
                        q = g->getSequelaVertex( s );
                        while(  q  )
                       {
                                 e=d[ s] + q->weight;
                                 if( d[q->vertex_tag] > e )
                                {
                                        d[q->vertex_tag] = e;
                                        parent[q->vertex_tag]=s;
                                 }
                                 q = q->next;
                       }
          }
          free(vertex);
          return   true;
  }
//
   int     main(int   argc,char    *argv[])
  {
           int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {0,0,0,0,0},
                                       {0,0,5,100,0}
                                 };
           int      size=5;
           int      i,j;
           int      d[6];
           int      parent[6];
           Array      garray(size,size),*y=&garray;
           for(i=0;i<size;++i)
                 for(j=0;j<size;++j)
                          y->set(i,j,adj[i][j]);
//������Чֵ
          y->setInvalideValue(0);
//����ͼ���ٽֱ��ʾ
          CGraph     graph(y);
          if( topologic_shortest_path( &graph,0,d,parent) )
         {
                   printf("We have solved the shortest path:\n");
                   for( i=0;i<size;++i)
                  {
                         printf("0------->%d: %d  ,path is:  ",i,d[i]);
                         j=i;
                         while(j>=0  )
                        {
                                 printf("%d ",j);
                                 j=parent[j];
                         }
                         putchar('\n');
                   }
         }
         else
        {
                   printf("there is  some  cycle in the graph !\n");
         }
          return  0;
  }
