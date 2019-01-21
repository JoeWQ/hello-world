//实现最大最小堆的插入与删除操作
  #include<stdio.h>
  #include<stdlib.h>
  #define  MAX_SIZE   9
  #define  LIMIT_N    16
  #define  SEED_T     0x1234
//判断当前给定节点所在层是最大还是最小层  
  int   level(int);
//向当前对中插入一个元素
  void  insert(int *,int *,int);
//创建一个最大最小堆
  void  CreateMaxMinHeap(int *,int);
//删除最大最小堆的最小元素
  int  delete_min(int *,int *);
//删除最大最小堆的最大元素
  int  delete_max(int *,int *);
//向最大最小堆种种添加元素
  void  verify_max(int *,int,int);
  void  verify_min(int *,int,int);
//**********************************************************
  int  level(int index)
 {
      int i=0;
      while(index>0)
     {
           index>>=1;
           ++i;
      }
//如果是最大层就返回0，否则返回1
      return i&0x1;
  }
//调整堆结构
  void  adjust(int *heap,int nsize,int i)
 {
      int  child,parent,grand;
      int  len=nsize-1,tmp;
//如果该节点是最大层
      if(!level(i))
     {
          child=i;
//先排最大层
          while(child>0)
         {
               grand=child>>2;
               if(child<=len && heap[child]<heap[child+1])  //找到较大值
                     ++child;
               tmp=heap[child];
               if(grand>0 && heap[grand]<tmp)
              {
                     heap[child]=heap[grand];
                     heap[grand]=tmp;
               }
               child=grand;
           }
           child=i;
//调整
           while(child>0)
          {
               parent=child>>1;
               if(child<=len && heap[child]>heap[child+1])  //找到一个最小的节点和其父节点
                    ++child;                               //做比较
               if(parent>0 && heap[parent]>heap[child])
              {
                    tmp=heap[child];
                    heap[child]=heap[parent];
                    heap[parent]=tmp;
               }
               child=parent>>1;
           }
      }
//如果该节点是最小层
      else
     {
           child=i;
           while(child>0)
          {
               grand=child>>2;
               if(child<=len && heap[child]>heap[child+1])  //找到较小值
                    ++child;
               if(grand>0 && heap[grand]>heap[child])
              {
                    tmp=heap[child];
                    heap[child]=heap[grand];
                    heap[grand]=tmp;
               }
               child=grand;
           }
           child=i;
//调整最大最小堆的结构
           while(child>0)
          {
               parent=child>>1;
//找到一个最大节点和其父节点左比较
               if(child<=len && heap[child]<heap[child+1])  
                      ++i;
               if(parent>0 && heap[parent]<heap[child])
              {
                    tmp=heap[parent];
                    heap[parent]=heap[child];
                    heap[child]=tmp;
               }
               child=parent>>1;
           }
      }
  }
  void  CreateMaxMinHeap(int *heap,int nsize)
 {
      int  len=nsize-1;
      int  i;

      len=nsize>>1;
      for(i=nsize;i>len;--i)
           adjust(heap,nsize,i);
  }
//向最大最小堆中插入一个元素
  void  insert(int *heap,int *nsize,int key)
 {
      int  parent,len;
      if(*nsize>=LIMIT_N)
     {
          printf("堆结构已经满，请重新构建!\n"); 
          return;
      }
      len=++(*nsize);
//如果要插入的节点坐落在最大层
      if(!level(len))
     {
           parent=len>>1;
           if(key<heap[parent])
          {
               heap[len]=heap[parent];
               verify_min(heap,parent,key);
           }
           else
               verify_max(heap,len,key);
      }
      else
     {
           parent=len>>1;
           if(key>heap[parent])
          {
                heap[len]=heap[parent];
                verify_max(heap,parent,key);
           }
           else
               verify_min(heap,len,key);
      }
  }
//向最大最小堆中嵌入元素
  void  verify_min(int *heap,int n,int key)
 {
      int  grand=n>>2;
      while(grand>0)
     {
          if(heap[grand]>key)
         {
              heap[n]=heap[grand];
              n=grand;
              grand>>=2;
          }
          else
              break;
      }
      heap[n]=key;
  }
  void  verify_max(int *heap,int n,int key)
 {
      int  grand=n>>2;
      while(grand>0)
     {
          if(heap[grand]<key)
         {
              heap[n]=heap[grand];
              n=grand;
              grand>>=2;
          }
          else
              break;
      }
      heap[n]=key;
  }
  //查找比给定索引处元素次小的元素的索引
  int  find_min(int *heap,int nsize,int i)
 {
       int  child,limit,key;
       if(!nsize)
      {
            printf("堆中已经没有元素，最小值查找失败!\n");
            return -1;
       }
       if(nsize==1)
          return 1;
//从下一层选择较小节点
       if(nsize>=(i<<1) && nsize<(i<<2))
      {
            child=i<<1;
            if(child<nsize && heap[child]>heap[child+1])
                    ++child;
            return child;
       }
//从孙节点选择较小节点
       child=i<<2;
       limit=child+3;
       limit=limit>nsize?nsize:limit;
       key=heap[child];
       i=child;
       for(++child;child<=limit;++child)
      {
             if(key>heap[child])
            {
                 i=child;
                 key=heap[child];
             }
       }
       return i;
  }
//查找比给定索引处次大的元素索引
  int  find_max(int  *heap,int  nsize,int  i)
 {
        int  child,limit,key;
 
        if(!nsize)
       {
            printf("堆中的所有元素已经被删除完毕!\n");
            return -1;
        }
        if(nsize==1)
           return 1;
//从子节点中选择较小节点
        if(nsize>=(i<<1)  &&  nsize<(i<<2))
       {
            child=i<<1;
            if(child<nsize && heap[child]<heap[child+1])
                ++child;
 //           printf("选择了元素%d \n",child);
            return child;
        }
//从孙节点中选择较小节点
        child=i<<2;
        limit=child+3;
        limit=limit>nsize?nsize:limit;
        key=heap[child];
        i=child;
        //在后代节点中找到最大节点
        for(++child;child<=limit;++child)
       {
              if(key<heap[child])
             {
                  key=heap[child];
                  i=child;
              }
        }
//        printf("选择了元素%d\n",i);
        return  i;
  }   
//从最大最小堆中删除最小元素
  int  delete_min(int *heap,int *nsize)
 {
      int  parent,child,key,k,tmp;
      int  len=*nsize,i;
      if(! len)
     {
           printf("堆已经为空，不能在删除根元素元素!\n");
           return  -1;
      }
      --(*nsize);
      heap[0]=heap[1];
      key=heap[len];
      k=(--len)>>1;
      for(i=1;i<=k;)
     {
            child=find_min(heap,len,i);
            if(key<=heap[child])
                 break;
            heap[i]=heap[child];
            if(child<=((i<<1)+1))
           {
                 i=child;
                 break;
            }
            parent=child>>1;
            if(heap[parent]<key)
           {
                 tmp=heap[parent];
                 heap[parent]=key;
                 key=tmp;
            }
            i=child;
      }
      heap[i]=key;
      printf("现在删除的元素是:%d\n",heap[0]);
      return heap[0];
  }
//删除最大元素
  int  delete_max(int  *heap,int *nsize)
 {
       int  child,parent,tmp;
       int  i=2,len,key,n;
       if(!*nsize)
      {
           printf("不存在最大节点值!\n");
           return -1; 
       }
       if(*nsize==1)
      {
            --(*nsize);
            heap[0]=heap[1];
            goto en_o;
       }
       len=(*nsize)--;
       key=heap[len];
       if(i<len && heap[i]<heap[i+1])
           ++i;
       heap[0]=heap[i];
       if(len<=3)
      {
           if(len==2)
              goto en_o;
           if(i==2)
              heap[2]=heap[3];
           goto en_o;
       }
    //   printf("key为%d \n",key);
       for(--len,n=len>>1;i<=n;)
      {
            child=find_max(heap,len,i);
       //     printf("选择的次大元素为:%d \n",heap[child]);
            if(key>=heap[child])
               break;
            heap[i]=heap[child];
            if(child<=((i<<1)+1))
           {
                 i=child;
                 break;
            }
            parent=child>>1;
            if(key<heap[parent])
           {
                tmp=key;
                key=heap[parent];
                heap[parent]=tmp;
            }
            i=child;
       }
       heap[i]=key;
    en_o:
       printf("现在删除的元素是%d \n",heap[0]);
       return heap[0];
   }   
  int  main(int argc,char *argv[])
 {
      int  i=0,tmp,k;
      int  nsize;
      int  heap[LIMIT_N+1];
      int  copy[LIMIT_N+1];
      srand(SEED_T);
      printf("数组被初始化后的结果为:\n");
      for(i=1;i<=MAX_SIZE;++i)
     {
          heap[i]=tmp=rand();
          printf(" %d  ",tmp);
      }
      printf("\n********************************************************\n");
      CreateMaxMinHeap(heap,MAX_SIZE);
      nsize=MAX_SIZE;
      printf("创建的最大最小堆为:%d,其元素如下:\n",nsize);
      for(i=1;i<=MAX_SIZE;++i)
     {
          printf("  %d  ",heap[i]);
      }
      printf("\n*************************************************************\n");

      for(i=0;i<4;++i)
     {
          tmp=rand();
          printf("现在开始插入一个节点:%d!\n",tmp);
          insert(heap,&nsize,tmp);
      }
      printf("现在所有的元素为:\n");
      for(i=1;i<=nsize;++i)
          printf("  %d  ",heap[i]);
      printf("\n*****************************************************************\n");

//将数组元素复制下来，以便对后面的以最大值删除方式的进行测试
      for(i=1;i<=nsize;++i)
          copy[i]=heap[i];

      printf("现在开始删除素所有的元素!\n");
      for(i=1,tmp=nsize;i<=tmp;++i)
          delete_min(heap,&nsize);
      if(!nsize)
          printf("成功的操作，所有的元素都被删除!\n");
      else
          printf("编码错误，仍有%d个元素未被删除掉!\n",nsize);
      printf("\n***************************************************************\n");

      printf("\n_____________________________________________________________________\n");
      printf("现在以删除最大值的方式进行删除操作!\n");
      nsize=tmp;
      for(i=1;i<=tmp;++i)
     {
           
  //         for(k=1;k<=nsize;++k)
  //             printf("  %d  ",copy[k]);
  //         putchar('\n');
           delete_max(copy,&nsize);
      }
      printf("\n______________________________________________________________________\n");
      if(!nsize)
          printf("以删除最大值的方式删除元素完毕!\n");
      else
          printf("以删除最大元素删除元素失败，仍有%d个元素未被删除\n",nsize);      
      return 0;
  }
