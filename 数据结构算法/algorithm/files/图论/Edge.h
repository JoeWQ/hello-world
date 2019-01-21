//定义和边相关的数据结构
  typedef  struct  _Edge
 {
//起始顶点
       int   from;
//目的结点
       int   to;
//边的权值
       int   cost;
       struct  _Edge  *next;
  }Edge;
//记录边的相关信息的结构
  typedef  struct  _EdgeInfo
 {
//记录边的数目
       int   size;
//指向边的指针
       struct  _Edge   *front;
  }EdgeInfo;