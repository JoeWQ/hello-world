/*
  *@aim:ST��,��������е�����һ�������ڵ���Сֵ
  *@date:2015-7-8 14:40:04
  */
  #include"st_table.h"
  #include<stdio.h>
  #include<time.h>
  #include<stdlib.h>
  #define     min(a,b)  a<b?a:b
  #define     QUERY_RFESULT(a,b,table)        printf("between %d   ,  %d ,result is %d\n",a,b,table->query(a,b))
  /*
    *@note:�볣��ķ������,ST�������ѵ�ʱ�����,�ڴ�ռ���������,�����ģ��ȡ���������ڵ����(��С)ֵ
    *@note:ʱ��ST����ֵ�ÿ��ǵ�
    *@note:ע�⣬����ʼ�����Ǵ�1��ʼ
    *@param:����ĳߴ���������Ͻ�Ķ���
    */
    STTable::STTable(int      *content,int    size,int   power_serial)
   {
 //ע��һ������ռ������,����size�Ĵ�С��2^31֮��
 //m_storage->(i,k):��ʾ��i��ʼ������2^k��������С����(k=0,1,2,3,4,...)
                  m_storage=new    CArray2D<int>(size,power_serial);
                  m_log=new          int[size];
//������ȡһϵ���������Ķ���
                  m_log[0]=m_log[1]=0;
                  int                         i,k;
                  for(i=2;i<size;++i)
                 {
                                 m_log[i]=m_log[i-1];
                                 if( 1<<(m_log[i]+1) == i )
                                           ++m_log[i];
                  }
//��(i,i^k)֮�ڵ���Сֵ
                  for(i=size-1;i>=0;--i)
                 {
                              m_storage->set(i,0,content[i]);
                              for(k=1;k<power_serial && i+(1<<k)<size;++k)
                             {
//ע���������������Ȼǰ�벿�ǳ�����,i+2^(k-1)�ƺ�����ͬ��,���Ƕ���Ҫע�⵽�������̺��ĵ������ǲ�ͬ��
//i+(1<<k-1),k-1;i,k-1ǰ���е�1<<k-1������ǳ���,�������ֵ�k-1������ǿ��
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
//��ѯ            
                 QUERY_RFESULT(0,size-1,table);
                 QUERY_RFESULT(0,size>>1,table);
                 QUERY_RFESULT(0,size>>2,table);
                 QUERY_RFESULT(size>>2,size>>1,table);
                 QUERY_RFESULT(size>>1,size-1,table);
                 QUERY_RFESULT(size>>7,size>>6,table);
      }