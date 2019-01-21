/*
 *@aim:Kruskal-prim��С�������㷨ʵ��
 *@date:2014��11��9��20:30:00
 *@author:�ҽ���
 *@request:Other Cpp file CGHeap.h CGHeap.cpp CGraph.h CGraph.cpp
 */
 #include "CGHeap.h"
 #include "CGraph.h"
 #include<stdio.h>
 #include<stdlib.h>
 #define    infine      0x3FFFFFFF
#pragma -----------------------------------Kruskal algorithm----------------------------
/*
 *@aim:������������֮��Ĺ�ϵ,�������������Ƿ�ͬ����һ��������
 *@aim:�������������ͬһ�������ڣ��ͽ�������鲢��ͬһ��������
 *@request:���һ������û��ǰ���������ڲ���������ʾΪ-1 
 */
   bool    is_vertex_same_set(int  *set,int  v1,int  v2);
   void    merge_vertex_same_set(int  *set,int  v1,int  v2);
//���ϻ������Ƚڵ�
   bool        is_vertex_same_set(int    *set,int   v1,int   v2)
  {
            while( v1>=0 && set[v1]>=0)
                    v1=set[v1];
            while( v2>=0 && set[v2]>=0 )
                    v2=set[v2];
            return     v1 == v2;
   }
//����������ѹ�뼯����,��������������һ����
//@request:v1��v2������������ͬ�ļ���
   void    merge_vertex_same_set(int   *set,int  v1,int  v2)
  {
//�Ȼ��ݲ��Ҹ������������������
            while(v1>=0 && set[v1]>=0 )
                     v1=set[v1];
            while( v2>=0 && set[v2]>=0 )
                     v2=set[v2];
//�ô���������������������,v1 != v2,���򣬽������
            if(  v1<v2 )
                   set[v2]=v1;
            else
                   set[v1]=v2;
   }
//Kruskal algorithm
//������Ľ�����ߵ���Ŀ����size-1�����򷵻�true�����򷵻�false
//@request:size of set >=g->getVertexCount()
   bool          kruskal_spanning_tree(CGraph    *g,int    *set)
  {
//�ߵ����м���
               CGraphEdgeSequence    sequence,*seq=&sequence;
//
                int         i,weight,size=g->getVertexCount();
                int         *parent=(int *)malloc(sizeof(int)*size);
//��һ���ߵ�����
                CGraphEdge          *e;
//
                g->sortGraphEdge( seq );
//���������Ľ��
            #ifdef   _SORT_
                for(i=0;i<seq->size;++i)
               {
                          printf("%d------>%d: weight=%d\n",seq->edge[i].from_vertex,seq->edge[i].to_vertex,seq->edge[i].weight);
                }
            #endif
//��ʼ�������еĶ����ǰ������Ϊ-1
                for(i=0;i<size;++i)
               {
                         set[i]=-1;
                         parent[i]=-1;
                }
//
                weight=0;
                size=0;
                for(i=0;i<seq->size;++i)
               { 
                           e=seq->edge+i;
//�Եõ��ıߵ����ζ�������ж��Ƿ����ʹ��ͬ�����еģ������ǣ�����ѹ�뼯����
                           if(  ! is_vertex_same_set(parent,e->from_vertex,e->to_vertex) )
                          {
                                         weight+=e->weight;
                                         ++size;
                                         merge_vertex_same_set(parent,e->from_vertex,e->to_vertex);
                                         set[e->to_vertex]=e->from_vertex;
                           }
                }
                free(parent);
                return   size == g->getVertexCount()-1;
   }
//Prim algorithm
//@request:size of set >=g->getVertexCount()
//@request:��������֮�������ǵ���ͨ��
    bool        prim_spanning_tree(CGraph    *g,int      *set)
   {
//
                int                    i,size=g->getVertexCount();
                int                    vertex=0;
//                int                    *parent=(int  *)malloc(sizeof(int)*size);
//����ͼ���ٽֱ�ṹ������
                CSequela          *q;
                CGVertex          cgvertex,*p=&cgvertex;
//
                for(i=0;i<size;++i)
                       set[i]=-1;
//���ߵ�Ȩֵ������
                CGHeap    heap(size),*h=&heap;
//�Ӷ���0��ʼ������
                q=g->getSequelaVertex(vertex);
//
                while( q  )
               {
//����һ����ʱ���ݴ洢
                           p->key=q->weight;
//ʹ��ǿ������ת��
                           p->vertex=q->vertex_tag;
//ѹ�����
                           h->insert( p  );
//������һ���ڵ�
                           q=q->next;
                }
//������������
                i=0;
                set[i]=vertex;
                ++i;
                while( i <size && h->getSize())
               {
                           p = h->getMin();
                           vertex=p->vertex;
                           h->removeMin();
//
                           set[i]=vertex;
                           ++i;
//��һ�������µõ��ı�ѹ�����
                          q=g->getSequelaVertex(vertex);
                          p=&cgvertex;
                          while( q )
                         {
                                     p->key=q->weight;
                                     p->vertex=q->vertex_tag;
                                     h->insert(p);
                                     q=q->next;
                         }
                }
//               free(parent);
               return    i == size-1;
   }
//����
   int    main(int    argc,char    *argv[])
  {
              int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {20,0,0,0,0},
                                       {0,0,5,100,0}
                                 };
              int      size=5;
              int      set[5];
              int      i,j;
//Ȩֵ
              Array      weight(size,size);
              Array      *w=&weight;
              for(i=0;i<size;++i)
                      for(j=0;j<size;++j)
                          w->set(i,j,adj[i][j]);
              w->setInvalideValue(0);
              CGraph     graph(w),*g=&graph;          
//Kruskal�㷨
         #ifdef   _KRUSKAL_
             bool    flag= kruskal_spanning_tree(g,set);
         #else
//Prim�㷨
             bool    flag= prim_spanning_tree(g,set);
         #endif
             for(i=0;i<size;++i)
                    printf("%6d",set[i]);
             putchar('\n');
             return    0;
   }
 
