/*
  *@aim:ST表
  *@date:2015-7-8
  */
  #ifndef    __ST_TABLE_H__
  #define   __ST_TABLE_H__
  #include"CArray2D.h"
    class        STTable
   {
 private:
              CArray2D<int>          *m_storage;
//对数数组,批量求取一系列连续的数的对数
              int                                *m_log;
 //
 private:
              STTable(STTable  &);
 public:
              STTable(int         *content,int    size,int   power_serial);
              ~STTable();
//查询区间内的最小值,
//@request:from>to,切from>0,from<size,to>1 && to<=size
              int        query(int   from,int   to);
    };
  
  #endif