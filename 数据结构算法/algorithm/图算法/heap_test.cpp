/*
  *@aim:CGHeap类 测试
  *@date:2014-10-31 16:01:18
  */
  #include"CGHeap.h"
  #include<stdio.h>
  #include<time.h>
  #include<stdlib.h>
  int    main(int   argc,char   *argv[] )
 {
          int               sample[65];
          int               i,size=65;
          CGVertex      *p,v;
//
          long            seed=time(NULL);
          srand(seed);
//
          for(i=0;i<size;++i)
                sample[i]=rand()%751;
//
          for(i=0;i<size;++i)
         {
                   printf("%d   ",sample[i]);
                   if( i % 6 == 0 )
                       putchar('\n');
         }
         CGHeap       heap(sample,size),*h=&heap;
//
           printf("---------------------------------------------------------------\n");
           p=&v;
//执行减值操作
           for(i=0;i<size;++i)
          {
                  p = h->findQuoteByIndex(i);
                  int     value=(p->key+7)>>1;
                  p->key=p->key - rand()%value; 
                  h->decreaseKey(p);
          }
           printf("after  insert operation ,remove min element:\n");
           for(i=0;i<size;++i)
          {
                      p=h->getMin();
                      printf("%d\n",p->key); 
                      h->removeMin();
           }
           printf("heap size is %d\n",h->getSize() );
           printf("heap total_size is %d\n",h->total_size);
          return   0;
  }
