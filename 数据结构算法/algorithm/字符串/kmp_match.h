/*
  *@aim:Knuth-Morris-Parrat 字符串匹配算法
  *@date:2014-10-24
  *@author:狄建彬
  */
//
  #ifndef   __KMP_MATCH_H__
  #define  __KMP_MATCH_H__
  class    KMPMatcher
 {
//字符串模板
         char     *match;
//字符串模板回溯函数
         int        *back_trace;
//冗余数据，字符串和回溯函数数组的长度
         int         length;
//
     public:
         KMPMatcher(char    *)  ;
         ~KMPMatcher();
//返回字符串匹配的首字符索引，如过没有匹配，则返回-1
         int         kmpMatch(char   *text);
     private:
//计算字符串回溯函数
         void       backTrace();
  };
  #endif
