//使用表格排序,注意这里的表格确定要遵循一种通用的规则
//使用一种排序方法,在交换记录的同时也交换表格中的元素
  #include<stdio.h>
  #include<stdlib.h>
//依据数学定理:每个排列都由若干个互不相交的循环组成

  int  key[8]={35,14,12,42,26,50,31,18};
  
  int  table[8]={2,1,5,4,6,0,3,7};
  
  int  size=8;

  void  table_sort(int  *table,int *list,int n)
 {
       int  i,k;
       int  tmp,len=n-1;
       int  current,next;
       int  **tp,*p;
//首先对输入的记录进行一种"形式排序",升序排序
       tp=(int **)malloc(sizeof(int *)*n);
       
       for(p=list,i=0;i<n;++i,++p)
      {
           tp[i]=p;
           table[i]=i;
       }
       for(i=0;i<len;++i)
      {
           tmp=*tp[i];
           current=i;
           for(k=i+1;k<n;++k)
          {
              if(tmp<*tp[k])
             {
                   current=k;
                   tmp=*tp[k];
              }
           }
           if(current!=i)
          {
               tmp=table[i];
               table[i]=table[current];
               table[current]=tmp;

               p=tp[i];
               tp[i]=tp[current];
               tp[current]=p;
           }
       }
       printf("表格输出的结果:\n");
       for(i=0;i<n;++i)
           printf("  %d  ",table[i]);
       putchar('\n');

       for(i=0;i<len;++i)
      {
           if(table[i]!=i)
          {
               tmp=list[i];
               current=i;
               do
              {
                   next=table[current];
                   list[current]=list[next];
                   table[current]=current;
                   current=next;
               }while(table[current]!=i);
							list[current]=tmp;
              table[current]=current;
          }
       }
  }
  int  main(int argc,char *argv[])
 {
      int  i=0;
      table_sort(table,key,size);
      for(i=0;i<size;++i)
         printf("  %d  ",key[i]);
      putchar('\n');
      return 0;
  } 