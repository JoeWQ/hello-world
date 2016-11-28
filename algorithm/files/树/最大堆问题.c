//完全二叉树，最大堆问题，采用数组结构实现
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  
  #define  MAX_SIZE   16
  #define  INIT_SIZE  8
//创建一个最大堆
  void  CreateMaxHeap(int *);
  void  insert_item(int *,int);
  void  remove_root(int *);
  void  print_heap(int *);
  
  int main(int argc,char *argv[])
 {
     int  heap[MAX_SIZE];
     int  i,seed;
//初始化堆
     heap[0]=INIT_SIZE;
     seed=time(NULL);
     srand(seed);
     for(i=1;i<INIT_SIZE;++i)
        heap[i]=rand();

     printf("在未排序时的初始堆为:\n");
     print_heap(heap,MAX_SIZE);
     printf("排序后的堆为:\n");
     CreateMaxHeap(heap);
     print_heap(heap);
     
     seed=rand();
     printf("现在将要插入一个元素:%d \n",seed);
     insert_item(heap,seed);
     printf("插入元素后的堆为:\n");
     print_heap(heap);

     printf("删除最大堆的首元素后:\n");
     remove_root(heap);
     print_heap(heap);
     return 0;
  }
//创建最大堆
  void  CreateMaxHeap(int *heap)
 {
      int i,child,tmp,k;
      int len=heap[0];
      for(i=len;i>=1;--i)
     {
          child=i;
          while(child>=1)
         {
             k=child>>1;
             if(k>=1 && heap[child]>heap[k])
            {
                tmp=heap[k];
                heap[k]=heap[child];
                heap[child]=tmp;
             }
             child>>=1;
          }
      }
  }
//向最大堆中插入一个元素
  void  insert_item(int *heap,int item)
 {
     int  child;
     child=++heap[0];
     
     while(child>1 && item>heap[child>>1])
    {
        heap[child]=heap[child>>1];
        child>>=1;
     }
     heap[child]=item;
   }
//删除最大堆的根节点,并调整树结构
  void  remove_root(int *heap)
 {
     int  len=heap[0]--;
     int  child,parent;
     int  item=heap[len];
     child=2,parent=1;
     --len;
     while(child<=len)
    {
         if(child<len && heap[child]<heap[child+1])
            ++child;
         if(heap[child]<=item)
            break;
         heap[parent]=heap[child];
         parent=child;
         child<<=1;
      }
//注意，这一步中的parent不能改为len，两者在某些情况下可以互换,但在有些情况下，会出现错误
     heap[parent]=item;
  }
//将最大堆输出
  void  print_heap(int *heap)
 {
     int len=heap[0];
     int  i;
     for(i=1;i<=len;++i)
    {
         printf("元素%d : %d \n",i,heap[i]);
     }
     printf("****************************输出结束******************************\n");
  }