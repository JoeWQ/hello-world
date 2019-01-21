//为图的邻接表存储而设计的数据结构
  typedef  struct  _PostGraph
 {
//vp的后继结点
       int          vertex;
//vertex的父节点，但是严格地来说，vp,vertex只是图的两个相互邻接的顶点
       int          vp;
//记录边的权值
       int          cost;
       struct    _PostGraph    *next;
  }PostGraph;
/******************************************/
  typedef  struct  _Graph
 {
//记录和此顶点相邻接的顶点的数目
      int                   size;
//指向和其邻接的顶点的指针
      struct  _PostGraph   *front;
//这个尾指针的存在只是为了方便邻接表的创建
      struct  _PostGraph   *rear;
  }Graph;
//**************************************
//记录整个图结构的相关信息
  typedef  struct  _GraphHeader
 {
//顶点的数目
      int              size;
//
      struct  _Graph  *graph;
 }GraphHeader;