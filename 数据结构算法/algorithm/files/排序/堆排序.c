//堆排序,采用最大堆结构
  #include<stdio.h>
  #include<stdlib.h>
  #define  SEED_T       0x1000
  #define  ARRAY_SIZE   9

  void  adjust(int *,int,int);
  void  heap_sort(int *);

  int  main(int argc,char *argv[])
 {
      int  heap[ARRAY_SIZE+1];
      int  i,k;
      printf("正在产生随机函数!\n");
      srand(SEED_T);

      printf("用随机数字进行初始化!\n");
      for(i=1;i<=ARRAY_SIZE;++i) 
           heap[i]=rand();
      printf("\n初始内容如下:\n");
      for(i=1;i<=ARRAY_SIZE;++i)
           printf("%d  \n",heap[i]);
      putchar('\n');
 
      printf("开始排序!\n");
      heap[0]=ARRAY_SIZE;
      heap_sort(heap);

      printf("\n排序后的内容如下:\n");
      for(i=1;i<=ARRAY_SIZE;++i)
          printf("%d  \n",heap[i]);
      putchar('\n');
 
      return 0;
  }
//调整堆的结构
  void  adjust(int *heap,int parent,int n)
 {
      int  child;
      int  tmp;
       
      tmp=heap[parent];
      for(child=parent<<1;child<=n;child<<=1)
     {
           if(child<n && heap[child]<heap[child+1])
                   ++child;
           if(tmp<heap[child])
                   heap[parent]=heap[child];
           else
                   break;
           parent=child;
      }
      heap[parent]=tmp;
  }
//排序
  void  heap_sort(int *heap)
 {
      int  nsize;
      int  i,tmp;
  
      nsize=heap[0];
      for(i=nsize>>1;i>0;--i)
          adjust(heap,i,nsize);

      for(i=nsize-1;i>=1;--i)
     {
           tmp=heap[1];
           heap[1]=heap[i+1];
           heap[i+1]=tmp;
           adjust(heap,1,i);
      }
  }