/*
  *@aim:有关图的数据结构，这里是专门为标记与前移算法儿设定的
  @date:2015-6-2
  */
 #ifndef    __GRAPH_H__
 #define   __GRAPH_H__
 //必须打开这个宏
 #define     _GRAPH_      1
 #include"CArray2D.h"
//邻接顶点(前驱和后继的集合)
   struct      CAdjoinVertex
  {
//邻接顶点的标示符
                int                                              adjoinVertex;
//
                struct      CAdjoinVertex         *next;
   };
//顶点的后继顶点，以及权值的集合
   struct      CSequelaVertex
  {
//当前顶点的后继顶点
                int                                              sequelaVertex;
//当前顶点,保持这一冗余是为了在算法进行中可以避免不必要的查找
                int                                              actualVertex;
//当前顶点与后继顶点之间所构成的边的权值
                int                                              weight;
//指向下一个同级的后继节点
                struct     CSequelaVertex         *next;
//指向前一个，方便删除操作
//                struct     CSequelaVertex         *prev;
   };
//每一个顶点数据结构
   struct       CVertex
  {
 //顶点的后继顶点
                CSequelaVertex          *m_sequelaVertex;
//顶点的所有邻接顶点
                CAdjoinVertex            *m_adjoinVertex;
//顶点的标识符,实际上这个数据不是必须的因为在邻接表的索引已经暗示了她的值,这里只是一个摆设
//或者使用者也可以将这个数据用于其他目的
                int                         m_vertex;
//后继顶点数目                
                int                         m_sequelaCount;
   };
   class    CGraph
  {
private:
//指向CVertex结构数组的指针
                CVertex                *m_vertex;
//数组的大小
                int                         m_size;
private:
                CGraph(CGraph &);
public:
//由邻接矩阵输入，但是函数不会检查参数的有效性
                CGraph(CArray2D<int>   *);
                ~CGraph();
                int               size();
//输出图的拓扑排序，注意，函数不会自动将源和目标顶点排除掉，这个需要使用者
//自己去做
               int               topologicSort(int     *);
//返回给定的顶点的有关数据结构,注意使用者尽可能不要擅自修改里面的数据,
//除非对里面的运作非常了解,
               CVertex       *getVertex(int   *);
   };
 #endif
 