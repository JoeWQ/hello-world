/*
  *@aim:0-1背包问题
  *@idea:动态规划
  *@date:2014-11-13 10:09:53
  *@author:狄建彬
  */
  #include"Array.h"
  #include<stdio.h>
//物品的重量和价值
  struct     CPackage
 {
//物品的重量
           int     weight;
//物品的价值
           int     value;
  };
/*
  *@function:package01
  *@aim:求解出最优的物品的组合，以使得在w的重量的限定范围内，所得到的物品的价值之和最大
  *@param:pack物品数组
  *@param:w当前的重量限定，即当前所得到的物品的重量之和不能大于w
  *@param:y记录选择物品i与不选择物品i所能得到的最大价值
  *@param:r记录在得到的最大值中所选择的物品序列
  */
// y->row=sizze+1,y->column=w+1
  void     package01(CPackage     *pack,int   size,int   w,Array    *y,Array    *r)
 {
           int      i,m,j;
           int      e;
//初始边缘的数据都设置为0
           for(i=1;i<=size;++i)
          { 
                    for(m=1;m<=w;++m)
                   {
                             if(  pack[i].weight > m )
                            {
                                      y->set(i,w, y->get(i-1,m) );
                                      r->set(i,w,r->get(i-1,m));
                             }
                             else
                            {
//用装载背包i和不装载背包i是的情况作比较
                                      e= y->get(i-1,m-pack[i].weight) +pack[i].value;
                                      if(  e < y->get(i-1,m) )
                                     {
                                                y->set(i,m, y->get(i,m-1) );
                                                r->set(i,m, r->get(i,m-1) );
                                      }
                                      else
                                     {
                                                y->set(i,m,e);
                                                r->set(i,m,i);
                                      }
                            }
                    }
           }              
  }
//****************************************************************************
   int    main(int    argc,char   *argv[] )
  {
//为了简化起见，现在已对任务做了排序            
           struct    CPackage    pack[4]={ {0,0},{10,60}, {20,100},{30,120} };     
           int          size=3;
           int          w=50;//上限
//
//           Array      weight(size+1,w+1);
           Array      value(size+1,w+1);
           Array      record(size+1,w+1);
//
          Array       *y=&value,*r=&record;
//初始
          y->fillWith(0);
 //         x->fillWith(0);
          r->fillWith(0);
//
           package01(pack,size,w,y,r);
//
           int    i=0,j=0;
 //          printf("----------------------------weight---------------------");
 //          for(i=1;i<=size;++i)
 //         {
 //                     for(j=1;j<=w;++j)
     //                         printf("%4d",y->get(i,j));
  //                    printf("\n");
    //      }
           printf("----------------------------value---------------------\n");
           for(i=1;i<=size;++i)
          {
                      for(j=1;j<=w;++j)
                              printf("%4d",y->get(i,j));
                      printf("\n\n");
          }
           printf("----------------------------record---------------------\n");
           for(i=1;i<=size;++i)
          {
                      for(j=1;j<=w;++j)
                              printf("%4d",r->get(i,j));
                      printf("\n\n");
          }
          
   }
