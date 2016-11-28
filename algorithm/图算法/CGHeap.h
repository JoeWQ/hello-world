/*
  *@aim:最小堆的C++实现
  *@date:2014-10-30 19:56:25
  *@author:狄建彬
  */
 #ifndef    __CGHEAP_H__
#define    __CGHEAP_H__
//堆中所装载的数据结构
   struct     CGVertex
  {
//定点的关键字，这里可以表示任何含义
            int       key;
//在图中所对应的定点，或者说关节点的标示
            int       vertex;
   };
   class      CGHeap
  {
     private:
     public:
//底层所使用的动态数组
            CGVertex       *root;
//维护一张顶点的标示与其在堆中所处的位置的索引，以便于程序可以快速查找
            int                 *vertex_index;
//数组的实际长度
            int                 size;
//当前数组的总长度
            int                 total_size;
     private:
            CGHeap(CGHeap   &);
     public:
            CGHeap();
            CGHeap(int    *,int    size);
            ~CGHeap();
//向堆中插入元素,返回
            void             insert(CGVertex   *);
//获取堆的实际大小
            int                getSize();
//获取堆中的最小元素,但是不删除,如果当前已经没有任何的节点存在，则返回NULL
            CGVertex       *getMin();
//删除最小堆的根节点,如果堆中已经没有任何的元素，则不执行任何操作
            void               removeMin();
//对堆中的一个节点执行减值操作
            void               decreaseKey( CGVertex    * );
//对堆执行快速查找，输入类型为顶点的标示(索引)，返回堆中存储该标示的堆节点元素的地址，
//这个函数将会在上面的函数被调用的时候被使用到
            CGVertex       *findQuoteByIndex(int    vertex_tag);
//
     private:
//从索引child处以自顶向下的方式调整堆,这个函数只能在集中式计算中使用
            void               adjust_top_bottom(int    parent);
//自底向上的对堆的结构进行调整,这个函数只能在非集中式计算中使用
            void               adjust_bottom_top(int    child);
//堆的底层数组扩张
            void               expand(   );
//堆的底层实现数组规模缩减
            void               shrink(   );
   };
#endif
