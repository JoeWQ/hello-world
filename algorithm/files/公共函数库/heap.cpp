//������ʵ��
//2014��1��23��15:01:07
    #include"heap.h"

   heap_sort::heap_sort( int   *heap,int  size  )
  {
//ע����������������� ��֮ͬ��
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
//Ԥ����         
          for( child=size; child ; --child)
                  adjust(child,size);
          parent = size;
//���ݽ���
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
//�ѵ���
  void  heap_sort::adjust(int  child,int  ssize)
 {
           int    key,parent;
           
           parent = child ;
           key =heap[child];
           for( child<<=1   ; child<=ssize  ; parent =child,child<<=1  )
          {
//ѡȡ ��Сֵ
                   if( child<ssize && heap[child] > heap[child+1]   )
                            ++i;
//�͸��ڵ�Ƚ�
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