/*
 *@aim:Kruskal-prim最小生成树算法实现
 *@date:2014年11月9日20:30:00
 *@author:狄建彬
 *@request:Other Cpp file CGHeap.h CGHeap.cpp CGraph.h CGraph.cpp
 */
 #include "CGHeap.h"
 #include "CGraph.h"
 #include<stdio.h>
 #include<stdlib.h>
 #define    infine      0x3FFFFFFF
#pragma -----------------------------------Kruskal algorithm----------------------------
/*
 *@aim:处理两个顶点之间的关系,查找两个顶点是否同处于一个集合内
 *@aim:或者如果不处于同一个集合内，就将两个点归并到同一个集合中
 *@request:如果一个顶点没有前驱，则其内部的索引表示为-1 
 */
   bool    is_vertex_same_set(int  *set,int  v1,int  v2);
   void    merge_vertex_same_set(int  *set,int  v1,int  v2);
//向上回溯祖先节点
   bool        is_vertex_same_set(int    *set,int   v1,int   v2)
  {
            while( v1>=0 && set[v1]>=0)
                    v1=set[v1];
            while( v2>=0 && set[v2]>=0 )
                    v2=set[v2];
            return     v1 == v2;
   }
//将两个顶点压入集合中,这两个顶点后成了一条边
//@request:v1与v2分属于两个不同的集合
   void    merge_vertex_same_set(int   *set,int  v1,int  v2)
  {
//先回溯查找各个顶点所代表的祖先
            while(v1>=0 && set[v1]>=0 )
                     v1=set[v1];
            while( v2>=0 && set[v2]>=0 )
                     v2=set[v2];
//用代表顶点来代表这两个集合,v1 != v2,否则，将会出错
            if(  v1<v2 )
                   set[v2]=v1;
            else
                   set[v1]=v2;
   }
//Kruskal algorithm
//如果求解的结果，边的数目等于size-1条，则返回true，否则返回false
//@request:size of set >=g->getVertexCount()
   bool          kruskal_spanning_tree(CGraph    *g,int    *set)
  {
//边的序列集合
               CGraphEdgeSequence    sequence,*seq=&sequence;
//
                int         i,weight,size=g->getVertexCount();
                int         *parent=(int *)malloc(sizeof(int)*size);
//对一条边的引用
                CGraphEdge          *e;
//
                g->sortGraphEdge( seq );
//输出所排序的结果
            #ifdef   _SORT_
                for(i=0;i<seq->size;++i)
               {
                          printf("%d------>%d: weight=%d\n",seq->edge[i].from_vertex,seq->edge[i].to_vertex,seq->edge[i].weight);
                }
            #endif
//初始，将所有的顶点的前驱都置为-1
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
//对得到的边的连段顶点进行判断是否可以使不同集合中的，若不是，可以压入集合中
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
//@request:任意两点之间至少是单连通的
    bool        prim_spanning_tree(CGraph    *g,int      *set)
   {
//
                int                    i,size=g->getVertexCount();
                int                    vertex=0;
//                int                    *parent=(int  *)malloc(sizeof(int)*size);
//关于图中临街表结构的引用
                CSequela          *q;
                CGVertex          cgvertex,*p=&cgvertex;
//
                for(i=0;i<size;++i)
                       set[i]=-1;
//按边的权值来生长
                CGHeap    heap(size),*h=&heap;
//从顶点0开始生长边
                q=g->getSequelaVertex(vertex);
//
                while( q  )
               {
//建立一个临时数据存储
                           p->key=q->weight;
//使用强制类型转换
                           p->vertex=q->vertex_tag;
//压入堆中
                           h->insert( p  );
//遍历后一个节点
                           q=q->next;
                }
//顶点依次生长
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
//下一步，将新得到的边压入堆中
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
//测试
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
//权值
              Array      weight(size,size);
              Array      *w=&weight;
              for(i=0;i<size;++i)
                      for(j=0;j<size;++j)
                          w->set(i,j,adj[i][j]);
              w->setInvalideValue(0);
              CGraph     graph(w),*g=&graph;          
//Kruskal算法
         #ifdef   _KRUSKAL_
             bool    flag= kruskal_spanning_tree(g,set);
         #else
//Prim算法
             bool    flag= prim_spanning_tree(g,set);
         #endif
             for(i=0;i<size;++i)
                    printf("%6d",set[i]);
             putchar('\n');
             return    0;
   }
 
