//**计数排序算法的实现
//2012/10/24/18:53

  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  #define  RANGE      16
  #define  N_SIZE     16
  #define  BUF_SIZE   128

  int  tmp[BUF_SIZE];
  int  out[N_SIZE];
  int  in[N_SIZE];
/*注意，计数排序不是基于比较的排序算法，他的运行时间的界为O(n).
 *但是它的适用范围比较窄，一般用在关键字范围比较窄，且元素的数目比较少得情况,
 *在元素数目比较多的情况下，由于基数排序需要的空间比较大，且不是进行原地排序，
 *所以对高速缓存的利用并不好，所以尽管它有运行时间的数量级比较小的优点，但并不
 *适合所有的情况。
 *这个时候就应该考虑适用堆排序，或者适用归并排序了。
 */
  void  CountSort(int *p,int n,int *out,int *tmp)
 {
      int  i,k,m;
      int  *ip=tmp;

//对数组进行初始化
      for(i=0;i<n;++i,++ip)
           *ip=0;
//开始计数
      for(i=0;i<n;++i)
     {
          k=p[i];
          ++tmp[k];
      }
//计算小于i的元素的数目
      for(k=0,i=1;i<n;++i,++k)
          tmp[i]+=tmp[k];
      for(i=0;i<n;++i)
     {
           k=p[i];
           m=tmp[k];
           out[m-1]=k;
           --tmp[k];
      }
  }
//*********************************************************
  int  main(int argc,char *argv[])
 {
      int  i,seed;
      seed=time(NULL);
      srand(seed);
       
      for(i=0;i<N_SIZE;++i)
           in[i]=rand()%RANGE;
//输出未排序的数组元素
      for(i=0;i<N_SIZE;++i)
          printf(" %d ",in[i]);

      printf("\n开始进行计数排序\n");
      CountSort(in,N_SIZE,out,tmp);
      printf("排序后，数组中的元素如下所示:\n");
      for(i=0;i<N_SIZE;++i)
          printf(" %d ",out[i]);
      printf("\n");
      return 0;
  }