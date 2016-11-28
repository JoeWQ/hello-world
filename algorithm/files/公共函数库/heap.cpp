//堆排序实现
//2014年1月23日15:01:07
    #include"heap.h"

   heap_sort::heap_sort( int   *heap,int  size  )
  {
//注意堆排序和其他排序的 不同之处
          this->heap = --heap;
          this->size = size;
  }
  heap_sort::~heap_sort( )
 {
          
 }
  void   heap_sort::sort(   )
 {
          int    child,parent;
          int    key;
//预调整         
          for( child=size; child ; --child)
                  adjust(child,size);
          parent = size;
//数据交换
          int    *t=heap+1;
          for( child = size;child>1 ;     )
         {
                   key = *r;
                   *r = heap[child];
                   heap[child]=key;
                   
                   adjust( 1,  --child );
          }
          size = parent;
 }
//堆调整
  void  heap_sort::adjust(int  child,int  ssize)
 {
           int    key,parent;
           
           parent = child ;
           key =heap[child];
           for( child<<=1   ; child<=ssize  ; parent =child,child<<=1  )
          {
//选取 最小值
                   if( child<ssize && heap[child] > heap[child+1]   )
                            ++i;
//和父节点比较
                  if( key>heap[child]   )
                 {
                          heap[parent]=heap[child];
                          parent=child;
                  }
                  else
                          break;
           }
           heap[parent]=key;
 }