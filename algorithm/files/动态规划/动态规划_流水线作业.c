//2012/12/24/14:21
//流水线模拟
  #include<stdio.h>
/********************************/
  static  int  line1[16]={7,9,3,4,8,4};
  static  int  line2[16]={8,5,6,4,5,7};
  static  int  la1[16]={2,3,1,3,4};
  static  int  la2[16]={2,1,2,2,1};
  static  int  e1=2,e2=4;
  static  int  x1=3,x2=2;
  static  int  f1[16];
  static  int  f2[16];
  static  int  stack[24];
  static  int  t1[16],t2[16];

/*******计算最为快速的流水线*************/
  void  fast_line(int  *l1,int  *l2,int  *a1,int *a2,int n)
 {
        int  i,j;
        int  cost,vcost;
//初始化流水线
        f1[0]=e1+l1[0];
        f2[0]=e2+l2[0];
        t1[0]=1;
        t2[0]=2;
        for(i=1;i<n;++i)
       {
             cost=f1[i-1]+l1[i];
             vcost=f2[i-1]+a2[i-1]+l1[i];
             if(cost<=vcost)
            {
                  f1[i]=cost;
                  t1[i]=1;
             }
             else
            {
                  f1[i]=vcost;
                  t1[i]=2;
             }
//计算第二个流水线
            cost=f2[i-1]+l2[i];
            vcost=f1[i-1]+a1[i-1]+l2[i];
            if(cost<=vcost)
           {
                 f2[i]=cost;
                 t2[i]=2;
            }
            else
           {
                f2[i]=vcost;
                t2[i]=1;
            }
        }
        f1[n-1]+=x1;
        f2[n-1]+=x2;
        j=1;
        if(f1[n-1]>f2[n-1])
             ++j;
//下面产生输出
//        printf("line:%d ,station:%d \n",j,n-1);
        for(i=n-1; i>=0 ;--i)
       {
             printf("line:%d , station:%d \n",j,i);
             j=j==1?t1[i]:t2[i];
        }
  }
//*****************************
  int  main(int argc,char *argv[])
 {
       fast_line(line1,line2,la1,la2,6);
       return 0;
  }
 