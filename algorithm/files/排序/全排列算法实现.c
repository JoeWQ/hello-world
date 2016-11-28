//全排列的算法实现
//2012/10/6/21:08
  #include<stdio.h>
  #include<stdlib.h>

  void  perm(int n)
 {
      int   i,j,k,len;
      char  buf[12],data;
      int   fact;
      len=n-1;
//找出从右向左的最大降序排列序列

      if(n>=8)
     {
           printf("很遗憾，输入的数字必须(<8 && >=1)!\n");
           return;
      }
//求出要循环的总次数n!
      for(fact=1,i=2;i<=n;++i)
           fact*=i;
//开始初始化数组
      data='1';
      for(i=0;i<n;++i)
          buf[i]=data++;
      buf[i]='\0';

	  printf("%s\n",buf);
      len=n-1;
      while(fact--)
     {
           i=len;
           while(i && buf[i]<buf[i-1])
               --i;
//如果已经到达最大端，则退出循环
           if(!i)
               return;
//查找比p[i-1]大但是在所有>i的元素中最小的元素
           k=i;
           for(j=len;j>i;--j)
          {
                if(buf[j]>buf[i-1] && buf[j]<buf[k])
                     k=j;
           }
//交换元素
           data=buf[i-1];
           buf[i-1]=buf[k];
           buf[k]=data; 

//对于已经降序排列好的，从索引i开始的序列，将其按升序排列(pi>p(i+1)>p(i+2).....)->
//(pi<p(i+1)<p(i+2)....)
           for(k=i,j=len;j>k;++k,--j)
          {
                data=buf[k];
                buf[k]=buf[j];
                buf[j]=data;
           }
//打印输出
           printf("%s \n",buf);
      }
  }
  int  main(int argc,char *argv[])
 {
      int  n;
      printf("请输入要排列的数目!\n");
      scanf("%d",&n);
      if(n<=0 || n>4)
     {
           printf("非法的输入，输入的值必须在（1-4）之间!\n");
           return 1;
      }
      perm(n);
      return 0;
  }