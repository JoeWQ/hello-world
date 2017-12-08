/*
  *@aim:Bellman-Ford�㷨ʵ��
  *@date:2014-11-3 12:00:11
  *@author:�ҽ���
  */
  #include<stdio.h>
  #include"CGraph.h"
  #include"Array.h"
  #ifndef     infinite     
      #define    infinite  0x3FFFFFFF
  #endif

/*
  *@func:bellman_ford�㷨
  *@param:g����ͼ���ٽֱ��ʾ,d��ʾ����������·����parent�������·���и������ǰ��
  *@param:sΪԭ��
  *@output:������false�������ͼ�д��ڸ�Ȩ��·,true��ʾ����ɹ�
  *@request:size of d or parent >=g->getVertexCount()
  *@note:���ĳһ������vû��ǰ��������Ӧ��parent[v]=-1
  */
   bool      bellman_ford(CGraph   *g,int  s,int    *d,int   *parent)
  {
            int                 i,j,e;
            CSequela      *p;
            int                size=g->getVertexCount();
//��ʼ�����������
            for(i=0;i<size;++i)
           {
                     d[i]=infinite;
                     parent[i]=-1;
            }
            d[s]=0;
//����ÿ��һ������չ,�κ���������֮�������size-1����
            for( i=0;i<size-1;++i)
           {
                    for(j=0;j<size;++j)
                   {
                              p = g->getSequelaVertex(j );
                              while( p )
                             {
//j��p->vertex_tag��ǰ��
                                       e = d[j] + p->weight;
                                       if(  d[p->vertex_tag] > e )
                                      {
                                                d[p->vertex_tag]=e;
                                                parent[p->vertex_tag]=j;
                                       }
                                       p=p->next;
                              }
                    }
            }
//��⣬�Ƿ���ڸ�Ȩ��·
            for(i=0;i<size;++i)
           {
                       p=g->getSequelaVertex(i);
                       while( p )
                      {
//��������·����չ�������size-1��֮���ٴμ�����·��ʱ��Ȼ����Ȼ�в��������·���ĵ����
//˵����ʱ���ڸ�Ȩ��·
                                 if(  d[p->vertex_tag] > d[i] + p->weight )
                                          return   false;
                                 p=p->next;
                       }
            }
            return    true;
   }
//����
    int     main(int    argc,char   *argv[])
   {
           int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {-200,0,0,0,0},
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
          if( bellman_ford( &graph,0,d,parent) )
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
                   printf("there is  some negative cycle in the graph !\n");
         }
          return  0;
    }
