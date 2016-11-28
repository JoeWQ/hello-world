/*
  *@aim:KMPģʽƥ���㷨��ʵ��
  *@date:2014-10-24 11:05:50
  *@author:�ҽ���
  */

   #include<stdlib.h>
   #include<stdio.h>
   #include"kmp_match.h"
//
   KMPMatcher::KMPMatcher(char    *match)
  {
           int         length=0;
           char      *p=match;
//���㳤��
           while( *p )
          {
                 ++length;
                  ++p;
           }
           this->length=length;
//�ַ�������
           p=(char   *)malloc(sizeof(char)*length+4);
           this->match=p;
           while( *match )
          {
                  *p=*match;
                  ++p;
                  ++match;
           }
//����ռ�洢���ݺ�����ֵ
          this->back_trace=(int *)malloc(sizeof(int)*length);
//������ݺ���
  //        printf("before bacTrace\n");
          this->backTrace();
   //       printf("-------after backTrace----------\n");
   }
   KMPMatcher::~KMPMatcher()
  {
            free(this->match);
            free(this->back_trace);
   }
//������ݺ���
/*
  *@request:this->length>1
  */
   void    KMPMatcher::backTrace( )
  {
            int      q=-1;
            int      i=1;
//ע�⣬�ڼ���Ĺ�������Ҫ�õ��ַ��������׺��ǰ׺����йش˵ȸ����μ�<�㷨����>��31��
            this->back_trace[0]=q;
            while( this->match[i] )
           {
                     while( q>=0 && this->match[q+1]!=this->match[i] )
                                 q=this->back_trace[q];
//���q+1�ַ��͵�ǰ�ַ��ɹ�ƥ�䣬�ͽ�����qд��back_trace[i]��
                     if( this->match[q+1] == this->match[i]  )
                    {
//һ�½�������һ�����жϣ����У���this->match[q+2] == this->match[i+1]
                                q=q+1;
//�����һ���ַ���Ȼ���ǵ�ǰ�ַ������յ㣬������һ���Ŀ��ܵĻ���
                                if(  this->match[i+1])
                               {
                                          if(  this->match[q+1] == this->match[i+1] )
                                                      q=this->back_trace[q];
                                }
                     }
                     this->back_trace[i]=q;
                     ++i;
           }
  }
//�ַ����Ŀ��ٱȽ�
/*
  *@request:match��text���������ַ�������ͬ
   */
   int     KMPMatcher::kmpMatch(char   *text)
  {
           int      q=-1;
           int       i;
//�ַ����Ŀ��ٱȽ�
          for(i=0;text[i];  )
         {
//
                     if( text[i] ==this->match[q+1] )
                    {
                             ++q;
                             ++i;
                     }
                     else if( q < 0 )
                            ++i;
                     else
                            q=this->back_trace[q];
//������ﾡͷ
                     if( ! this->match[q+1] )
                            return   i-q-1;
          }
          return    -1;
  }
