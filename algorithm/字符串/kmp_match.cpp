/*
  *@aim:KMP模式匹配算法的实现
  *@date:2014-10-24 11:05:50
  *@author:狄建彬
  */

   #include<stdlib.h>
   #include<stdio.h>
   #include"kmp_match.h"
//
   KMPMatcher::KMPMatcher(char    *match)
  {
           int         length=0;
           char      *p=match;
//计算长度
           while( *p )
          {
                 ++length;
                  ++p;
           }
           this->length=length;
//字符串复制
           p=(char   *)malloc(sizeof(char)*length+4);
           this->match=p;
           while( *match )
          {
                  *p=*match;
                  ++p;
                  ++match;
           }
//申请空间存储回溯函数的值
          this->back_trace=(int *)malloc(sizeof(int)*length);
//计算回溯函数
  //        printf("before bacTrace\n");
          this->backTrace();
   //       printf("-------after backTrace----------\n");
   }
   KMPMatcher::~KMPMatcher()
  {
            free(this->match);
            free(this->back_trace);
   }
//计算回溯函数
/*
  *@request:this->length>1
  */
   void    KMPMatcher::backTrace( )
  {
            int      q=-1;
            int      i=1;
//注意，在计算的过程中需要用到字符串的真后缀的前缀概念，有关此等概念，请参见<算法导论>第31章
            this->back_trace[0]=q;
            while( this->match[i] )
           {
                     while( q>=0 && this->match[q+1]!=this->match[i] )
                                 q=this->back_trace[q];
//如果q+1字符和当前字符成功匹配，就将索引q写入back_trace[i]中
                     if( this->match[q+1] == this->match[i]  )
                    {
//一下将会做进一步的判断，其中，当this->match[q+2] == this->match[i+1]
                                q=q+1;
//如果下一个字符仍然不是当前字符串的终点，将做进一步的可能的回溯
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
//字符串的快速比较
/*
  *@request:match与text所包含的字符不能相同
   */
   int     KMPMatcher::kmpMatch(char   *text)
  {
           int      q=-1;
           int       i;
//字符串的快速比较
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
//如果到达尽头
                     if( ! this->match[q+1] )
                            return   i-q-1;
          }
          return    -1;
  }
