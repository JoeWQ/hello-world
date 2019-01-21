/*
  *@aim:ST表,求给定序列的任意一个区间内的最小值
  *@date:2015-7-8 14:40:04
  */
  #include"st_table.h"
  #include<stdio.h>
  #include<time.h>
  #include<stdlib.h>
  #define     min(a,b)  a<b?a:b
  #define     QUERY_RFESULT(a,b,table)        printf("between %d   ,  %d ,result is %d\n",a,b,table->query(a,b))
  /*
    *@note:与常规的方法相比,ST表所花费的时间更少,内存空间的需求更少,当大规模求取任意区间内的最大(最小)值
    *@note:时，ST表是值得考虑的
    *@note:注意，其起始索引是从1开始
    *@param:数组的尺寸的整数幂上界的对数
    */
    STTable::STTable(int      *content,int    size,int   power_serial)
   {
 //注意一下输足空间的申请,假设size的大小在2^31之内
 //m_storage->(i,k):表示从i开始，连续2^k个数中最小的数(k=0,1,2,3,4,...)
                  m_storage=new    CArray2D<int>(size,power_serial);
                  m_log=new          int[size];
//批量求取一系列连续数的对数
                  m_log[0]=m_log[1]=0;
                  int                         i,k;
                  for(i=2;i<size;++i)
                 {
                                 m_log[i]=m_log[i-1];
                                 if( 1<<(m_log[i]+1) == i )
                                           ++m_log[i];
                  }
//求(i,i^k)之内的最小值
                  for(i=size-1;i>=0;--i)
                 {
                              m_storage->set(i,0,content[i]);
                              for(k=1;k<power_serial && i+(1<<k)<size;++k)
                             {
//注意下面两句代码虽然前半部非常类似,i+2^(k-1)似乎是相同的,但是读者要注意到两者所蕴含的的意义是不同的
//i+(1<<k-1),k-1;i,k-1前者中的1<<k-1代表的是长度,而后这种的k-1代表的是跨度
                                            int         a=m_storage->get(i,k-1);
                                            int         b=m_storage->get(i+(1<<k-1),k-1);
                                            
                                            m_storage->set(i,k,min(a,b));
                              }
                  }
    }
      STTable::~STTable()
    {
                delete       m_storage;
                delete       m_log;
                m_storage=NULL;
                m_log=NULL;
     }
       int           STTable::query(int   from,int  to)
      {
                 int             log=m_log[to-from+1];
                 
                 int             a=m_storage->get(from,log);
                 int             b=m_storage->get(to-(1<<log)+1,log);
                 return      min(a,b);
       }
//
       int          main(int    argc,char    *argv[])
     {
                 int         y[255];
                 int         size=255;
                 
                 int         i=0;
                 srand((int)time(NULL));
                 for(   ;i<size;++i)
                            y[i]=rand()%797;
                 for(i=0;i<size;++i)
                {
                            printf("%d   ",y[i]);
                            if(  !(i & 0x08) )
                                    putchar('\n');
                 }
                 STTable      atable(y,size,8);
                 STTable      *table=&atable;
//查询            
                 QUERY_RFESULT(0,size-1,table);
                 QUERY_RFESULT(0,size>>1,table);
                 QUERY_RFESULT(0,size>>2,table);
                 QUERY_RFESULT(size>>2,size>>1,table);
                 QUERY_RFESULT(size>>1,size-1,table);
                 QUERY_RFESULT(size>>7,size>>6,table);
      }