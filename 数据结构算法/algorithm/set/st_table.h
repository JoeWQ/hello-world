/*
  *@aim:ST��
  *@date:2015-7-8
  */
  #ifndef    __ST_TABLE_H__
  #define   __ST_TABLE_H__
  #include"CArray2D.h"
    class        STTable
   {
 private:
              CArray2D<int>          *m_storage;
//��������,������ȡһϵ�����������Ķ���
              int                                *m_log;
 //
 private:
              STTable(STTable  &);
 public:
              STTable(int         *content,int    size,int   power_serial);
              ~STTable();
//��ѯ�����ڵ���Сֵ,
//@request:from>to,��from>0,from<size,to>1 && to<=size
              int        query(int   from,int   to);
    };
  
  #endif