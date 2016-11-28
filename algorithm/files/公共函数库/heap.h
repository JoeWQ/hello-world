//2014年1月23日14:50:46
//堆排序,按照降序排序
    #ifndef   __HEAP_H
    #define  __HEAP_H
   class    heap_sort
  {
      private:
           int         *heap;
           int          size;
      public:
           heap_sort(int  *heap,int  size);
           ~heap_sort();
//对内部数据排序
          void     sort();
     private:
//堆调整
          adjust(int   parent,int  ssize);
  };
  #endif