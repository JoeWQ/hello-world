/*
  *@aim:在数组中查找是否有两个数的和是否为目标数
  *@date:2015-5-20
  */
 #include<stdio.h>
 //@request:y按升序排序
  int      checkSum(int      *y,int    size,int    value)
 {
          int            origin=0,final=size-1;
          int            result;
          while(origin<final)
         {
                     result=value-y[origin]-y[final];
                     if( result>0)
                              ++origin;
                     else if(result<0)
                              --final;
                     else
                    { 
                                  printf("final   result is %d+%d=%d\n",y[origin],y[final],value);
                                  return  1;
                    }
          }
          return    0;
  }
  //求数组中三个数的和是否等于目标结果值
  //@request:y按升序排序
     int              checkTriple(int    *y,int    size,int        value)
    {
                 int             origin,final;
                 int             result,it;
                 for(it=0;it<size-2;++it)
                { 
                               origin=it+1;
                               final=size-1;
                               while(origin<final)
                              {
                                            result=value-y[it]-y[origin]-y[final];
                                            if(result>0)
                                                    ++origin;
                                            else if(result<0)
                                                    --final;
                                            else
                                           {
                                                           printf("final result: %d+%d+%d=%d\n",y[it],y[origin],y[final],value);
                                                           return 1;
                                            }
                               }
                 }
                 return    0;
     }
     int        main(int      argc,char     *argv[])
    {
                 int                  y[9]={1,4,6,6,8,9,9,12,15};
                 int                  size=9;
                 int                  value=18;
                 
                 int                 x[9]={1,5,6,7,7,10,10,12,14};
                 
                 checkTriple(y,size,value);
                  value=14;
                  
                 checkSum(x,size,value);
                 return  0;
     }