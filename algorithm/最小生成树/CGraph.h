/*
  *@aim:有关图的数据结构和一些基本算法
  *@date:2014-10-31 16:44:26
  *@author:狄建彬
  */
  #ifndef  __CGRAPH_H__
  #define  __CGRAPH_H__
  #include"Array.h"
//图内部使用的数据结构
    struct    CGraphEdge
   {
//边的权值
          int     weight;
//这条边的前驱顶点
		      int     from_vertex;
//这条边的后记顶点
		      int     to_vertex;
          CGraphEdge();
          ~CGraphEdge();
	private:
	        CGraphEdge(CGraphEdge &);
    };
//关于图中边的排序序列,这个结构体将会在对图中的边排序中使用
	struct   CGraphEdgeSequence
   {
//指向排序后边的序列的指针
            struct    CGraphEdge    *edge;
//标识上面的数组的大小
		      	int                     size;
            CGraphEdgeSequence();
            ~CGraphEdgeSequence();
    private:
            CGraphEdgeSequence(CGraphEdgeSequence &);
	};
//临街表的个顶点的后继顶点直接表示
          struct    CSequela
         {
//顶点的标示
                  int                           vertex_tag;
//该顶点的前驱继结点标示
                  int                           prev_vertex;
//顶点prev_vertex与vertex_tag之间的弧所表示的权值
                  int                           weight;
 //                 struct    CVertex      *prev;
                  struct    CSequela      *next;
//禁止复制构造函数
                private:
                      CSequela(  CSequela &);
          };
          struct      CVertex
         {
//当前节点的后继结点表示
                   struct          CSequela          *post_vertex;
//当前顶点的标示，不一定与所处的位置索引相等，也可能为其他值
//                   int               tag;
//当前节点的后继结点数目
                   int               post_count;
//当前节点的前驱节点数目
                   int               prev_count;
//作为临时数据而存在的域，当使用拓扑排序时会用到
                   bool             is_visited;
//禁止拷贝构造函数
               private:
                   CVertex( CVertex &);
          };
//图的临街表表示
  class    CGraph
 {
//--------------------------------------------------------------------------------------------------------
          CVertex               *vertex;//临街数组
          int                   size;   //当前顶点的数目
//禁止对象之间的复制
    private:
          CGraph(  CGraph  &);
    public:
//输入参数为图的邻接矩阵表示
         CGraph(  Array    *  );
         ~CGraph();
//获取图的顶点数目
         int            getVertexCount();
//获取图中边的数目
         int            getEdgeCount();
//返回顶点v的所有后继结点的起始数据结构地址,如果v超出顶点的有效范围，则返回NULL
         CSequela       *getSequelaVertex(int     v);
//返回有关顶点v的数据结构
         CVertex        *getCVertex(int   v);
//图的拓扑排序序列输出,如果返回值>0,说明图的可以产生一个拓扑排序序列,否则说明图中有回路，无法产生一个拓扑排序序列
//@request:size of seq >=this->size+1,and the last index contains value -1
         int            topologicSort( int      *vertexes  );
//对图中的边进行排序，以升序的方式,这个函数将会在最小生成树中使用
         void           sortGraphEdge(CGraphEdgeSequence  *seq);
  }; 
  #endif
