//快速排序的递归实现
  #include<stdio.h>


//升序排列
  void  quick_sort(int *sort,int start,int limit)
 {
      int i,k,tmp;
	  int j=start;
      if(start<limit)
     {
//选取中间的元素作为参考值
           tmp=sort[limit-1];
           for(i=start;start<limit;++start)
          {
               if(sort[start]<tmp)
              {
//避免不必要的数组元素移动
                  if(start!=i)
                 {
                       k=sort[i];
                       sort[i]=sort[start];
                       sort[start]=k;
                  }
                  ++i;
               }
           }
//以tmp元素为分界，数组的左右分开,左边都小于tmp右边大于tmp
		   sort[limit-1]=sort[i];
		   sort[i]=tmp;

           quick_sort(sort,j,i-1);
           quick_sort(sort,i+1,limit);
      }
  }

  int main(int argc,char *argv[])
 {
      int sort[7]={2,1,5,7,8,3,4};
	  int k=0;
      int i;
      for(i=0;i<7;++i)
         printf("%d ",sort[i]);
      printf("\n排序后\n");

      quick_sort(sort,0,7);
      for(i=0;i<7;++i)
         printf("%d ",sort[i]);
      printf("\n");
      return 0;
  }

               