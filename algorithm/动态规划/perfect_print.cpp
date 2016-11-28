/*
  *@aim:整齐打印问题
  *@date:2015-5-27
  */
  #include"CArray2D.h"
  #include<stdio.h>
  
 //求解整齐打印问题
 //返回最小的代价
 //w:单词长度的集合
 //@request:w[i]>0,line_length>w[i],(i>=0 && i<size)
     int             perfect_print(int           *w,int           size,int        line_length)
    {
                 int            i,j,k;

                  CArray2D<int>                 word_cost(size,size);
                  CArray2D<int>                 *p=&word_cost;
                  CArray2D<int>                 word_length(size,size);
                  CArray2D<int>                 *r=&word_length;
                  
//初试运作前所必须得额外步骤
                  p->fillWith(0);
                  for(i=0;i<size;++i)
                 {
                            p->set(i,i,line_length-w[i]);
                            r->set(i,i,w[i]);
                  }
                  for(i=1;i<size;++i)
                 {
                            for(j=0;j<size-i;++j)
                           {
                                          r->set(j,j+i,   r->get(j,j+i-1)+w[j+i]);
                            }
                  }
//i是每次循环的跨度                  
                  for(i=1;i<size;++i)
                 {
                               for(j=0;j<size-i;++j)
                              {
                                               int         weight=line_length<<1;
                                               for(k=j;k<j+i;++k)
                                              {
                                                            int           cost;
//比较将k加入和不能加入所能构成的最小代价,//加入后成为一行
//如果两边可以合并到一起
                                                            if(r->get(j,k)+r->get(k+1,j+i)+i<=line_length)
                                                           {
                                                                      cost=p->get(j,k)+p->get(k+1,j+i)-1-line_length;
                                                                      if(cost>=0 )//如果合并成功
                                                                     {
                                                                                 if(weight>cost)
                                                                                          weight=cost;
                                                                      }
                                                            }
                                                             else//否则，继续使用两段
                                                            {
                                                                            cost=p->get(j,k)+p->get(k+1,j+i);
                                                                            if(weight>cost)
                                                                                       weight=cost;
                                                             }
                                               }
                                               p->set(j,j+i,weight);
                               }
                  }
                  for(i=0;i<size;++i)
                 {
                                for(j=0;j<size;++j)
                                            printf("%4d",p->get(i,j));
                                printf("------------------------------------------\n");
                  }
     }
      int        main(int     argc,char        *argv[])
     {
                  int            w[ 9]={2,3,6,3,8,4,5,4,5};
                  int            size=9;
                  int            line_length=10;
                  perfect_print(w,size,line_length);
                  return        0;
      }