/*
  *@aim:插值查找
  &2016-2-20 18:34:37
  */
 #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//默认y为升序排序
   int               interprolate_search(const   int    *y,const  int   size,const  int   _key)
 {
//中间索引值
               int           _index;
               int           _start;
               int           _final;
//统计比较的次数
               int           _times=0;
               _start=0,_final=size-1;
               while( _start<_final   )
              {
//求出中间索引插值
                             _index=_start+(_key-y[_start])*(_final-_start)/(y[_final]-y[_start]);
                             ++_times;
                             if( _key>y[_index]  )
                                         _start=_index+1;
                             else if( _key<y[_index] )
                                         _final=_index-1;
                             else
                            {
                                         printf("compare times:%d\n",_times);
                                         return   _index;
                             }
               }
               return  -1;
   }
   int        main(int    argc,char   *argv[])
  {
               int            y[1024];
               const      int        size=1024;
               int            _key,k,i;
               
               srand((int)time(NULL));
               for(k=0;k<size;++k)
                           y[k]=rand();
               for(i=0;i<size;++i)
              {
                           _key=i;
                           for(k=i+1;k<size;++k)
                          {
                                          if(y[_key]>y[k])
                                                      _key=k;
                           }
                           int   temp=y[_key];
                           y[_key]=y[i];
                           y[i]=temp;
               }
//实验证明,对于随机数据,插值查找的速度要远快于折半查找 
               _key=y[rand()%size];
               printf("_key is %d,final  index is %d\n",_key,interprolate_search(y,size,_key));
               return      0;
   }