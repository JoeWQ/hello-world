//2013/1/20/16:40
//关于图的数据结构
  typedef  struct  _PostVertex
 {
        int        vertex;
        struct  _PostVertex  *next;
  }PostVertex;
  typedef  struct  _PostGraph
 {
//记录该节点的前驱结点
        int   vp;
//记录该节点的标示
        int   vertex;
//权值
        int   weight;
        struct  _PostGraph   *next;
  }PostGraph;
  typedef   struct  _Graph
 {
//记录它的后继结点
       int                    count;
//记录顶点被访问的情况
       int                    v;
//记录该结点离开栈时的时间戳
       struct   _PostGraph    *front;
//记录和这个顶点有前后继关系的顶点
       struct   _PostVertex   *adj;
  }Graph;
//图的信息头
  typedef  struct  _GraphHeader
 {
//记录图中顶点的数目
       int   size;
//记录邻接表表示的图的起始指针
       struct  _Graph    *graph;
  }GraphHeader;
        