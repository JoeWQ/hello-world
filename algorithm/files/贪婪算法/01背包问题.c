//2013/1/3/14:54
//01背包问题(采用动态规划方法)
  #include<stdio.h>
  typedef  struct  _Knap
 {
//重量
       int    weight;
//价值
       int    value;
  }Knap;
  static   int  s[4][56];
  static   int  select[4][56];
//这里已经假设物品已经按照其价值 升序有序
  void  knap_select(Knap  *knap,int  n,int w)
 {
       int  i,j,le,k;
    
       for(i=1;i<=n;++i)
      {
           le=knap[i].weight;
           for(j=1;j<=w;++j)
          {
//期限假设不将i加入进去
                s[i][j]=s[i-1][j];
                select[i][j]=0;
  
                if(j>=le)
               {
//注意下面的这个式子，这是解决背包问题的关键
                     k=s[i-1][j-le]+knap[i].value;
                     if(s[i][j]<k)
                    {
                           s[i][j]=k;
                           select[i][j]=1;
                     }
                }
           }
       }
       printf("背包的总价值为:%d \n",s[n][w]);
  }
//********************************************
  int  main(int  argc,char *argv[])
 {
      Knap   knap[4]={{0,0},{10,60},{20,100},{30,120}};
      knap_select(knap,4,50);
      return 0;
  }
      