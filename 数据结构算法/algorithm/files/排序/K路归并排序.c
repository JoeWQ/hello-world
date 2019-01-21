//2012/10/23/22:49
//K路归并排序,所有的参与排序的数组，其数组长度存储在数组(p)的首元素中，亦即p[0]
/*
  注意这里面，多路归并和单路归并在思路上有着很大的区别
*/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  K_MERGE  32
  #define  MAX_SIZE  1024

  typedef  struct  _Node
 {
//记录待排序的数组首地址
      int   *p;
//记录正在排序的数组的元素的下标索引
      int   index;
//唯了能加快程序的运行，data的实际表示为p[index]
      int   data;
 }Node;
//最多支持32路归并排序
  Node  nodes[K_MERGE];
//所有待归并数组的最终归处
  int   heap[MAX_SIZE];
     
//单路堆排序的实现
  void  adjust(int *,int,int);
  void  heapSort(int *);
//K路归并排序的实现
  void  K_merge(int **,int ,Node *,int *);
  static void  K_adjust(Node *,int,int);
  void  K_mergeSort(Node *,int);
/*******************************************************/
//升序排列
  void  heapSort(int *heap)
 {
      int  child,tmp;
      int  n=heap[0];

      for(child=n>>1;child;--child)
           adjust(heap,n,child);
      for(child=n;child>1;--child)
     {
           tmp=heap[child];
           heap[child]=heap[1];
           heap[1]=tmp;

           adjust(heap,child-1,1);
      }
  }
//调整堆结构,使剩余的所有元素仍然构成一个最大堆结构
  void  adjust(int *heap,int n,int parent)
 {
      int child,tmp;
      
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
//现在实现K路归并排序
  void  K_merge(int  **head,int nsize,Node  *nodes,int  *heap)
 {
       int  i,n;
       Node  *np=nodes;
//第一步，将所有的待排序的数组首元素复制到专用数据结构中
       for(++np,i=0;i<nsize;++i,++np)
      {
            np->p=head[i];
            np->index=1;
            np->data=*(head[i]+1);
            printf(" %d ",np->data);
       }
       printf("\n");
//第第二步，开始合并所有的元素
//只要结构数组的长度大于0，循环就一直下去
       n=nsize;
//      K_mergeSort(nodes,n);
      for(i=nsize>>1;i;--i)
          K_adjust(nodes,i,n);
/*
      for(np=nodes+1,i=1;i<=nsize;++i,++np)
           printf("%d  ",np->data);
      printf("\n");
*/
      np=nodes+1;
      i=1;
      while(n)
     {
           heap[i++]=np->data;
//如果出现某一个数组排序已经到达尽头，那么就把保持这个数组相关信息的结构内容清除掉
           ++np->index;
           if(np->index>*np->p)
          {
               np->p=nodes[n].p;
               np->index=nodes[n].index;
               np->data=nodes[n].data;
               --n;
               K_adjust(nodes,1,n);
           }
           else
          {
               np->data=*(np->p+np->index);
               K_adjust(nodes,1,n);
           }
      }
      heap[0]=i-1;
  }
//*对K路归并排序所用的数据结构进行调整
 //*这个过程是堆排序的一个变种
 
  void  K_mergeSort(Node *nodes,int n)
 {
      int   child;
      Node  tmp;

      for(child=n>>1;child;--child)
           K_adjust(nodes,child,n);
/*
      for(child=n;child>1;--child)
     {
           tmp=nodes[child];
           nodes[child]=nodes[1];
           nodes[1]=tmp;

           tmp.p=nodes[child].p;
           tmp.index=nodes[child].index;
           tmp.data=nodes[child].data;

           nodes[child].p=nodes[1].p;
           nodes[child].index=nodes[1].index;
           nodes[child].data=nodes[1].data;

           nodes[child].p=tmp.p;
           nodes[child].index=tmp.index;
           nodes[child].data=tmp.data;


           K_adjust(nodes,1,child-1);
      }
*/
  }
//调整数据结构,按最小堆进行排序
  void  K_adjust(Node *nodes,int parent,int n)
 {
      int  child;
      Node  tmp;
      
      tmp.p=nodes[parent].p;
      tmp.index=nodes[parent].index;
      tmp.data=nodes[parent].data;
      for(child=parent<<1;child<=n;child<<=1)
     {
            if(child<n && nodes[child].data>nodes[child+1].data)
                  ++child;
            if(tmp.data>nodes[child].data)
           {
                 nodes[parent].p=nodes[child].p;
                 nodes[parent].index=nodes[child].index;
                 nodes[parent].data=nodes[child].data;
                 parent=child;
            }
            else
                 break;
      }
      nodes[parent]=tmp;
/*
      nodes[child].p=tmp.p;
      nodes[child].index=tmp.index;
      nodes[child].data=tmp.data;
*/
   }
/**********************************************************/
   int  main(int argc,char *argv[])
  {
       int  mat[5][9];
       int  i,k,flag;
       int  *p[5];
       int  seed=0x1237;

       srand(seed);
//数组初始化
       for(i=0;i<5;++i)
         for(k=1;k<=8;++k)
             mat[i][k]=rand();
//长度存储
      for(i=0;i<5;++i)
          mat[i][0]=8;
 //打印
      for(i=0;i<5;++i)
     {
           printf("长度:%d \n",mat[i][0]);
           for(k=1;k<=8;++k)
                printf(" %d ",mat[i][k]);
           printf("\n");
      }
      printf("开始排序.....\n");
      for(i=0;i<5;++i)
          heapSort(mat[i]);

      printf("对单个数组排序后，数组中各个元素的位置如下所示:\n");
      for(i=0;i<5;++i)
     {
           printf("长度:%d \n",mat[i][0]);
           for(k=1;k<=8;++k)
                printf(" %d ",mat[i][k]);
           printf("\n");
      }

      printf("\n*************************************************\n");
      printf("开始进行归并....\n");
      for(i=0;i<5;++i)
         p[i]=&mat[i][0];
      K_merge(p,5,nodes,heap);
      printf("归并排序后，数组的内容如下:\n");
      k=heap[0];
      flag=0;
      for(i=1;i<=k;++i)
     {
          printf(" %d ",heap[i]);
          if(flag & 0x8)
         {
              flag=0;
              putchar('\n');
          }
          ++flag;
      }
	  printf("\n");
      return 0;
  }
      