//2012/12/19/10:45
//全排序的非递归实现
  #include<stdio.h>
  
  void  perm(int  n)
 {
       int  sum,i,j,k;
       int  last;
       char   p[12],c;

       if(n<3 || n>7)
      {
             printf("很遗憾，考虑到效率，您输入的数字只能在(3-7)之间\n");
             return;
       }
/*
       if(n<3)
      {
            printf("非法的输入，传递进的值必须大于2\n");
            return;
       }
*/
       for(i=2,sum=1;i<=n;++i)
            sum*=i;
       for(i=0;i<n;++i)
            p[i]=(char)(i+'1');
       p[i]='\0';
       printf("%s\n",p);
       last=n-1;

       while(--sum)
      {
             i=last;
             while( i && p[i-1]>p[i])
                   --i;

             k=i;
             for(j=last;j>i;--j)
                 if(p[j]>p[i-1] && p[j]<p[k])
                        k=j;
//被选中的p[k],如果其后面还有数字，那么它至少要比其后面的那个数字大2，而比其前面的数字至少小1，
//所以交换p[k],p[i-1]之后，从i及它之后，p[i--last]依然是有序的,理解这一点很重要
             c=p[k];
             p[k]=p[i-1];
             p[i-1]=c;
//在局部重排序，得到比原来的数字大的，但同时又是最大中最小的
             for(j=last;j>i;--j,++i)
            {
                   c=p[j];
                   p[j]=p[i];
                   p[i]=c;
             }
             printf("%s\n",p);
        }
  }
  int  main(int argc,char *argv[])
 {

        int  n=0;
        printf("请输入一个数字(>2 && <8\n");
        scanf("%d",&n);
        printf("%d的排列如下所示:\n",n);
        perm(n);
        return 0;
  }
        