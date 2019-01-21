//2012/11/5/:21
//最大最小堆的相关操作
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h> 
  #define  MAX_MIN_HEAP_SIZE  48
  #define  INIT_HEAP_SIZE     31
  #define  SEED_T             0x7efdB5
/*******************************************************/
//数组的第0个元素保存数组的长度
  void  CreateMaxMinHeap(int *);
/********************************************************/
  int   insertItem(int *,int);
/*********************************************************/
  int  find_min(int *,int *);
  int  find_max(int *,int *);
/*********************************************************/
  int  removeMin(int *,int *);
  int  removeMax(int *,int *);
/***********************************************************/
//如果结点是位于最大层，则返回1，否则返回0
  static int  level(int i)
 {
       while(! (i>=1 && i<=3))
            i>>=2;
       return i==1? 0:1;
  }
/*************************************************************/
  static void  adjust_max(int *heap,int parent)
 {
        int  child,tmp;
        int  i, k;
        int  len=*heap;

        for(child=parent<<1;child<=len;  )
       {
             if(child<len && heap[child]<heap[child+1])
                   ++child;
             if(heap[parent]<heap[child])
            {
                  tmp=heap[parent];
                  heap[parent]=heap[child];
                  heap[child]=tmp;
             }
             child=parent<<2;
             if(child>len)
                  break;
             k=child+3;
             k=k>len?len:k;
             for(i=child+1;i<=k;++i)
            {
                  if(heap[child]<heap[i])
                       child=i;
             }
             if(heap[parent]<heap[child])
            {
                   tmp=heap[parent];
                   heap[parent]=heap[child];
                   heap[child]=tmp;
             }
             else
                   break;

             parent=child;
             child<<=1;
       }
  }
//注意最大，最小对调整有着不同的结构样式
  static void  adjust_min(int *heap,int parent)
 {
       int  child,len,tmp;
       int  i,k;
       len=*heap;

       for(child=parent<<1;child<=len;)
      {
//从最大层中选出较小结点
            if(child<len && heap[child]>heap[child+1])
                   ++child;
//如果父节点比选出的结点要大，则交换数据
            if(heap[parent]>heap[child])
           {
                 tmp=heap[parent];
                 heap[parent]=heap[child];
                 heap[child]=tmp;
            }

            child=parent<<2;
            if(child>len)
                 break;
            k=child+3;
            for(i=child+1;i<=k;++i)
           {
                 if(heap[i]<heap[child])
                      child=i;
            }
            if(heap[parent]>heap[child])
           {
                 tmp=heap[child];
                 heap[child]=heap[parent];
                 heap[parent]=tmp;
            }
            else
                 break;

            parent=child;
            child<<=1;
       }
  }
  void  CreateMaxMinHeap(int *heap)
 {
      int  parent;
      
      for(parent=*heap>>1;parent;--parent)
     {
//如果parent位于最小层
            if(! level(parent))
                 adjust_min(heap,parent);
            else
                 adjust_max(heap,parent);
      }
  }
/*****向最小、最大堆中插入元素*******************************/
//两个内部调用函数
  static  void  verify_max(int *heap,int child,int item)
 {
       int  gp;
       for(gp=child>>2;gp; )
      {
            if(heap[gp]<item)
                 heap[child]=heap[gp];
            else
                 break;
            child=gp;
            gp>>=2;
       }
       heap[child]=item;
  }

  static  void  verify_min(int *heap,int  child,int item)
 {
       int  grand;
       for(grand=child>>2;grand; )
      {
            if(heap[grand]>item)
                 heap[child]=heap[grand];
            else
                 break;
            child=grand;
            grand>>=2;
       }
       heap[child]=item;
  }
            
  int  insertItem(int *heap,int item)
 {
      int  parent;
      int  len;

      if(*heap>=MAX_MIN_HEAP_SIZE)
            return  0;
      len=++*heap;
      if(len==1)
          heap[len]=item;
      else
     {
             parent=len>>1;
     //如果将要插入堆中的父结点坐落在最小层       
            if(! level(parent))
           {
                  if(heap[parent]>item)
                 {
                       heap[len]=heap[parent];
                       verify_min(heap,parent,item);
                  }
                  else
                       verify_max(heap,len,item);
            }
//如果将要插入堆中的父结点坐落在最大层
            else
           {
                  if(heap[parent]<item)
                 {
                       heap[len]=heap[parent];
                       verify_max(heap,parent,item);
                  }
                  else
                       verify_min(heap,len,item);
            }
      }
	  return 1;
  }
/*************************************************************/ 
//查找堆中的最小结点,若成功，则返回1，否则返回0
  int  findMin(int  *heap,int *value)
 {
       if(! *heap)
          return 0;
       *value=heap[1];
       return 1;
  } 
//查找堆中的最大值结点,若成功，则返回1，否则返回0
  int  findMax(int  *heap,int  *value)
 {
       int  child;
       if(! *heap)
           return 0;
       if(*heap==1)
      {
            *value=heap[1];
            return 1;
       }
       child=2;
       if(child<*heap && heap[child]<heap[child+1])
                 ++child;
       *value=heap[child];
       return child;
  }
//删除堆中最小值结点,若成功，则返回1，且最小值被复制到*min中。否则返回0。
  int  removeMin(int  *heap,int *min)
 {
       int  parent,last,child,tmp;
       int  item,i,len,k,j;
       
       if(!  *heap)
           return 0;
       len=--*heap;
       *min=heap[1];
       item=heap[len+1];
       last=len>>1;

       child=0;
       for(i=1;i<=last;   )
      {
//开始查找下一个较小的值的所在结点
//如果下一个最小值结点出现在儿子结点中
           child=i<<1;
           if(child>len)
                break;
           if(child<<1 > len)
          {
                if(child<len && heap[child]>heap[child+1])
                       ++child;
                if(heap[child]>item)
                     heap[i]=item;
                else
               {
                     heap[i]=heap[child];
                     heap[child]=item;
                }
                return 1;
           }
//如果下一个最小值结点出现在孙结点中
           else
          {
                child=i<<2;
                if(child>len)
                     break;
                k=child+3;
                k=k>len?len:k;
                for(j=child+1;j<=k;++j)
               {
                     if(heap[child]>heap[j])
                          child=j;
                }
                if(heap[child]<item)
               {
                     heap[i]=heap[child];
                     i=child;
                     parent=child>>1;
                     if(heap[parent]<item)
                    {
                          tmp=heap[parent];
                          heap[parent]=item;
                          item=tmp;
                     }
                }
                else
                     break;
           }
      }
      heap[i]=item;
      return 1;
  }
//删除堆中的最大结点
  int  removeMax(int  *heap,int *max)
 {
      int  parent,child,item;
      int  i,k,j,last,len;

      if(!  *heap)
     {
           printf("删除错误,堆已经为空\n");
           return 0;
      }
      len=--*heap;
      item=heap[len+1];
      if(!  len)
     {
           *max=item;
           return 1;
      }
      if(len>=1 && len<=3)
     {
           if(len==1)
               *max=item;
           else 
          {
               child=2;
               if(child<len && heap[child]<heap[child+1])
                      ++child;
               if(item>heap[child])
                    *max=item;
               else
              {
                    *max=heap[child];
                    heap[child]=item;
               }
           }
           return 1;
      }
      child=2;
      if(heap[child]<heap[child+1])
          ++child;
      *max=heap[child];
      for(i=child,last=len>>1;i<=last;   )
     {
           child=i<<1;
           if(child>len)
               break;
//如果被选中的目标结点在儿子结点中
           if(child<<1 > len)
          {
                 if(child<len && heap[child]<heap[child+1])
                       ++child;
                 if(heap[child]<item)
                      heap[i]=item;
                 else
                {
                      heap[i]=heap[child];
                      heap[child]=item;
                 }
                 return 1;
           }
//如果目标结点在其孙子节点中
           else
          {
                child=i<<2;
                if(child>len)
                     break;
                k=child+3;
                k=k>len?len:k;
                for(j=child+1;j<=k;++j)
               {
                      if(heap[j]>heap[child])
                           child=j;
                }
               if(heap[child]<item)
                    break;
               else
              {
                     heap[i]=heap[child];
                     i=child;
                     parent=child>>1;
//比较child的父结点与item结点的关系
                    if(item<heap[parent])
                   {
                         k=heap[parent];
                         heap[parent]=item;
                         item=k;
                    }
               }
           }
     }
     heap[i]=item;
     return  1;
  }
  //**以堆结构的方式展示数组的内容*/
  void  display_heap(int *heap)
  {
	     int  len=*heap;
	     int  i,total,half;
       int  k,h;
//计算数的高度
       h=0;
       k=*heap;
       while(k)
      {
           ++h;
           k>>=1;
       }
       k=1;
	     for(i=1;i<=len;)
	    {
	       	  total=(1<<(h-k))-3;
		        for(  ;total>0;--total)
		    	        printf(" ");
            total=1<<(k-1);
		        for( ;i<=len && total;--total,++i)
			            printf("%d ",heap[i]);
            ++k;
		        printf("\n");
	     }
  }
/*********************************************************************/
  int  main(int  argc,char *argv[])
 {
       int  heap[INIT_HEAP_SIZE+1];
       int  tmp[INIT_HEAP_SIZE+1];
       int  value;
       int  seed,i;

       seed=time(NULL);
       srand(seed);
       for(i=1;i<=INIT_HEAP_SIZE;++i)
            heap[i]=rand()&0x3F;
       heap[0]=INIT_HEAP_SIZE;

       printf("堆得初始内容为:\n");
//       getchar();
       display_heap(heap);
//       getchar();
       printf("开始创建最小最大堆...\n");
       CreateMaxMinHeap(heap);
       printf("现在堆得内容如下:\n");
       display_heap(heap);
//实现把堆得内容复制下来
       for(i=0;i<=INIT_HEAP_SIZE;++i)
            tmp[i]=heap[i];      

       printf("现在开始执行按最小值方式的删除操作!\n");
       for(seed=heap[0],i=1;seed;--seed,++i)
      {
            removeMin(heap,&value);
            printf("第%d个最小值:%d\n",i,value);
       }
       printf("*******************************************************\n");
       printf("现在开始执行按最大值的方式进行的删除操作!\n");
       for(seed=tmp[0],i=1;seed;--seed,++i)
      {
            removeMax(tmp,&value);
            printf("第%d个最大值为%d\n",i,value);
       }
       return  0;
  }
        
                      