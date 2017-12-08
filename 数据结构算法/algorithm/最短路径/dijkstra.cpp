/*
  *@aim:Dijkstra���·���㷨ʵ��
  *@date:2014-11-5 19:09:24
  *@author:�ҽ���
  */
  #include"CGHeap.h"
  #include"Array.h"
  #include"CGraph.h"
  #include<stdio.h>
  #include<stdlib.h>
  #define    infine    0x3FFFFFFF
/*
  *@function:dijkstra_shortest_path
  *@idea:̰���㷨
  *@param:gͼ���ٽֱ��ʾ
  *@param:sԴ��
  *@param:d�����㵽Դ��ľ���
  *@param:parent��������������Ķ����ʾ��ǰ�������һ������û��ǰ������Ϊ-1
  *@request:ͼ��û�и�Ȩֵ��������ƻ���̰��˼��Ļ�������
  *@request:size of d and parent >=g->getVertexCount()
  */
   void    dijkstra_shortest_path(CGraph   *g,int    s,int   *d,int   *parent)
  {
             int         size=g->getVertexCount();
             int         x,y;
 //һ�����еײ�Ԫ�ص���ʱָ��
             CGVertex      *p;
//ͼ���ٽֱ��̵�ָ��
             CSequela       *q;
//��ʼ����������Ԫ��
             for(x=0;x<size;++x)
            {
                        d[x]=infine;
                        parent[x]=-1;
             }
             d[s]=0;
//����һ�������
             CGHeap        heap(d,size),*h=&heap;
             while(  h->getSize() )
            {
//��ȡ��ǰ���е�װ����СԪ�صĶ�ָ��
                       p = h->getMin();
                       y = p->vertex;
//ע�⣬��ɾ��֮������Ͳ�����ʹ��p�ˣ�����ԭ����μ�CGHeap���ڲ�ʵ��
                       h->removeMin();
//��y�ĺ�̽������ɳ�
                       q = g->getSequelaVertex( y );
                       while( q )
                      {
//ע�����������Ĵ��룬���ݼ���q->weightʼ�մ���0���ſ��Ա�֤�����������κβ��������������ǰһ�����е���СԪ��
//��С��Ԫ��d[q->vertex_tag],��̰���㷨�п��Խ��ͳɣ����µĲ���������ǰ���Ѿ���������⣬
//���������ڽ����д����������
                                    x = d[y]+q->weight;
                                    if( d[q->vertex_tag] > x )
                                   {
                                               d[q->vertex_tag]=x;
                                               parent[q->vertex_tag] = y;
//�Զ��е����Ԫ�ؽ��е���
                                               p = h->findQuoteByIndex(q->vertex_tag);
//��ֵ����������Ƕ���������������Ҫ��һ������
                                               p->key=x;
//�����ѵĽṹ
                                               h->decreaseKey(p);
                                    }
                                    q=q->next;
                       }
             }
  }
    int    main(int    argc,char   *argv[])
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
          dijkstra_shortest_path(&graph,0,d,parent);
         
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
          return   0;
  }
