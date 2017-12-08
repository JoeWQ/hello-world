/*
  *@date:2014-10-25 11:09:14
  *@aim:kmp�㷨����
  */
  #include<stdio.h>
  #include<string.h>
  #include<stdlib.h>
  #include<sys/time.h>
  #include<time.h>
  #include"kmp_match.h"
  
/*
  *@aim:�ַ����Ƚϵ������㷨
  *@request:match��text���������ַ�������ͬ
  */
  int    prim_match(char    *match,char   *text)
 {
         int    i,j;
         for(i=0,j=0;  text[i] && text[i+j];  )
        {
                    if( match[j] == text[i+j] )
                            ++j;
                    else
                   {
                            j=0;
                            ++i;
                    }
                    if(  !match[j] )
                          return    i;
         }
         return  -1;
  }
/*
  *@note:ʹ�ô���������ַ������Ա�����ʹ��KMP�㷨����ͨ���㷨Ҫ��11%���ң�һ����ԣ�ֻ����ģʽ�ĳ��ȱȽϳ�
  *@note:�����ַ����Ĺ����ԱȽ�ǿ��ʱ��ʹ��KMP�Ľ���Ż��ǱȽ�������,�ڷǳ����˵�����£�������������10������
  */
  int    main(int   argc,char  *argv[] )
 {
  //        char       *text="abbchhorijviojovfhiovjfievohuhdjxiaohuaxiongjioljkotmnkijfgv";
  //        char       *temp="xiaohuaxiong";
          
          struct   timeval    prev,next;
//ѭ���ȽϵĴ���
          int              count=10000;
          int              i,size,index;
          char           *text=(char *)malloc(sizeof(char)*40960);
          char           *temp=(char *)malloc(sizeof(char)*256);
          char           model[64];
  //        printf("-----------------------------000----------------------------------\n");
//�����ַ���ģ��
          char    *t="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaatewvbsgbntyewswbsdaweaVRNYHevsrbhnukmutryrtuifg";
          char    *q="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaba";
          int       len=strlen(t);
          for(i=0;i<=62;++i)
         {
                    if(i<26 )
                          model[i]=(char)('a'+i);
                    else if( i< 52 )
                          model[i]=(char)('A'+i-26);
                    else
                          model[i]=(char)('0'+i-52);
         }
         model[62]='\0';
         printf("%s\n",model);
//����̳��ַ���
/*
          srand((int)time(NULL));
          size=40960;
          for(i=0;i<size-1;++i)
                 text[i]=model[ rand()%62];
          text[size-1]='\0';
//
          size=256;
          for(i=0;i<size-1;++i)
                 temp[i]=model[rand()%62];
          temp[size-1]='\0';
          printf("%s\n%s",temp,text);
*/
//ʹ���ض����ַ������бȽ�
          size=40960;
          for(i=0;i+len<size-1;i+=len)
         {
                   int  j=0;
                   while(j<len )
                  {
                          text[i+j]=t[j++];
                   }
          }
          text[size-1]='\0';
          printf("-----------------------------11----------------------------------\n");
//
          size=256;
          len=strlen(q);
          for(i=0;i+len<size-1 ;i+=len)
         {
                  int  j=0;
                  while( j< len )
                 {
                        temp[i+j]=q[j];
                        ++j;
                  }
         }
          temp[size-1]='\0';
          printf("-----------------------------temp:%s----------------------------------\n",temp);
//*********************************************************
//
          KMPMatcher    kmp(q);
          KMPMatcher    *p=&kmp;
          printf("-----------------------------33----------------------------------\n");
//��ʼ����
//*******************************************************************************************
          gettimeofday(&prev,NULL);
          for( i=0; i< count;++i)
         {
 //                  char       *text="abbchhorijviojovfhiovjfievohuhdjxiaohuaxiongjioljkotmnkijfgv";
   //                char       *temp="xiaohuaxiong";
 //                  printf("---------------\n");
                   index=prim_match(q,text);
 //                  printf("index is %d \n",index);
         }
          gettimeofday(&next,NULL);
          printf("prim method cost time %d.%d \n",next.tv_sec-prev.tv_sec,next.tv_usec-prev.tv_usec);
 //         printf("-----------------------------33----------------------------------\n");
//****************************************************************************************************************************
          gettimeofday(&prev,NULL);
          for( i=0 ;i <count;++i)
                  index=p->kmpMatch( text );
          gettimeofday(&next,NULL);
          printf("kmp method cost time %d.%d \n",next.tv_sec-prev.tv_sec,next.tv_usec-prev.tv_usec);
//
         free(temp);
         free(text);
         return  0;
  }
