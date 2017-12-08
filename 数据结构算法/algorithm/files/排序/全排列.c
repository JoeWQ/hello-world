//全排列的算法实现
//2012/10/26/18:08
  #include<stdio.h>

//此函数的功能是实现n!,排列从最小到最大实现，亦即从(1,2,...,n)到(n,n-1,...,2,1)
  void  perm(int n)
 {
      int   len,fact,i,j,k;
      char  buf[12],data;
//为了使函数的运行时间不至于过长，将这个函数的功能做了限制
      if(n>5 || n<=0)
     {
           printf("非法de输入，输入的值必须在>=1 & <=5 的范围内!\n");
           return ;
      }
    
      for(i=2,fact=1;i<=n;++i)
            fact*=i;
      len=n-1;
//将字符数组进行初始化
      data='1';
      for(i=0;i<n;++i)
           buf[i]=data++;
      buf[i]='\0';
      printf("%s\n",buf);

      while(fact--)
     {
           i=len;
//找出从末端开始的最大降序排列的序列(pi,p(i+1),p(i+2)...)
           while(i && buf[i-1]>buf[i])
                --i;
//如果已经到达了尽头，亦即目前的排列是(n,n-1,n-2,...,2,1），则循环退出
           if(! i)
              break;
//找出在降序排列的序列中，比buf[i-1]大，且在所有满足要求的数组元素中又是最小的数组元素
//下标索引
           k=i;
           for(j=len;j>i;--j)
          {
                if(buf[j]>buf[i-1] && buf[j]<buf[k])
                       k=j;
           }
//交换数组元素
          data=buf[i-1];
          buf[i-1]=buf[k];
          buf[k]=data;
//将升序排序的序列按降序排列
          for(k=len,j=i;j<k;++j,--k)
         {
              data=buf[k];
              buf[k]=buf[j];
              buf[j]=data;
          }
          printf("%s\n",buf);
     }
  }
//****************************************************************
  int  main(int argc,char *argv[])
 {
      int  n;
      printf("请输入一个数字(>0 & <=5)\n");
      scanf("%d",&n);
      printf("\n");
      perm(n);
      return 0;
  }