//2014��1��23��14:50:46
//������,���ս�������
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
//���ڲ���������
          void     sort();
     private:
//�ѵ���
          adjust(int   parent,int  ssize);
  };
  #endif