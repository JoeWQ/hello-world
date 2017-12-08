/*
  *@aim:Knuth-Morris-Parrat �ַ���ƥ���㷨
  *@date:2014-10-24
  *@author:�ҽ���
  */
//
  #ifndef   __KMP_MATCH_H__
  #define  __KMP_MATCH_H__
  class    KMPMatcher
 {
//�ַ���ģ��
         char     *match;
//�ַ���ģ����ݺ���
         int        *back_trace;
//�������ݣ��ַ����ͻ��ݺ�������ĳ���
         int         length;
//
     public:
         KMPMatcher(char    *)  ;
         ~KMPMatcher();
//�����ַ���ƥ������ַ����������û��ƥ�䣬�򷵻�-1
         int         kmpMatch(char   *text);
     private:
//�����ַ������ݺ���
         void       backTrace();
  };
  #endif
