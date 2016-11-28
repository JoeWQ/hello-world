//2012/12/28/14:04
//计算最优二叉查找树
  #include<stdio.h>
  #include<stdlib.h>
/******************************************/
  #define   INF_T    0x30000000
//定义操作二维数组的宏
  #define  GET_ARRAY(m,i,j,c)    *(m+(i)*c+(j))
  #define  SET_ARRAY(m,i,j,c,s)    *(m+(i)*c+(j))=(s)
/*********************************************************/
//参数的含义:p：权值(每种关键字的查找概率)的数组集合，q：虚拟键(不存在的数值的概率)的数组集合,为了避免浮点的不精确
//我们这里采用了整型数字

//n代表的是数组p的长度，q的长度的(n+1)
//计算最优二叉查找树
  void  optimal_bin_tree(int  *p,int *q,int n)
 {
       int    *w,*e,*root;
       int    size=n+1;
       int    i,j,k,lc;
       int    le,le2,t;
//注意我们使用一维数组代替了二维数组
       w=(int *)malloc(sizeof(int)*(size*size));
       e=(int *)malloc(sizeof(int)*(size*size));
       root=(int *)malloc(sizeof(int)*(size*size));
       
       for(i=1;i<=n;++i)
      {
            j=q[i-1];
            SET_ARRAY(w,i,i-1,size,j);
            SET_ARRAY(e,i,i-1,size,j);
       }
//注意下面的这一步,这个操作很重要
       --p;
//从从长度1开始，直到n
       for(le=1;le<=n;++le)
      {
            le2=n-le+1;
            for(i=1;i<=le2;++i)
           {
                  j=i+le-1;
                  k=GET_ARRAY(w,i,j-1,size);
                  SET_ARRAY(w,i,j,size,k+p[j]+q[j]);
                  SET_ARRAY(e,i,j,size,INF_T);
                  t=GET_ARRAY(w,i,j,size,);
                  for(k=i;k<=j;++k)
                 {
                        lc=GET_ARRAY(e,i,k-1,size)+GET_ARRAY(e,k+1,j,size)+t;
                        if(lc<GET_ARRAY(e,i,j,size))
                       {
                              SET_ARRAY(e,i,j,size,lc);
                              SET_ARRAY(root,i,j,size,k);
                        }
                  }
            }
       }
//下一步开始解码
       for(i=1;i<=n;++i)
      {
           printf("第%d行 :\n",i);
           for(j=i;j<=n;++j)
                 printf(" %d ",GET_ARRAY(root,i,j,size));
           printf(" \n");
       }
       free(w);
       free(e);
       free(root);
   }
/********************************************************/
  int  main(int argc,char *argv[])
 {
        int  p[5]={15,10,5,10,20};
        int  q[6]={5,10,5,5,5,10};

        printf("最优二叉查找树:\n");
        optimal_bin_tree(p,q,5);
        return 0;
  }
        