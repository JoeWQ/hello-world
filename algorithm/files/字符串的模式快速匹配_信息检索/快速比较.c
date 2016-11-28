//字符串的快速比较
  #include<stdio.h>
  #include<string.h>
  #include<stdlib.h>
  #include<time.h>
//************************************************
//匹配字符串的失配函数
  int  failure[256];
//存储输入字符串
  char input[256];
  char pat[256];
  
  void fail(char *p,int ,int *);
//Knuth,Morris,Pratt 算法
  int  pmkmatch(char *,char *);

  int main(int argc,char *argv[])
 {
     int index=0;
     printf("请输入一个字符串(<256)!\n");
     gets(input);
     printf("请输入要匹配的字符串(<256)!\n");
     gets(pat);
     
     index=pmkmatch(input,pat);
     if(index<0)
    {
         printf("很遗憾,您输入的匹配字符串不能匹配您输入的字符!\n");
     }
     else
         printf("匹配成功，匹配的开始索引为%d !\n",index);
     return 0;
  }
//**********************************************************************
//检测字符串匹配的情况，若成功返回非0值，否则返回负数
//input :被匹配的字符串，pat：匹配字符串
  int pmkmatch(char *input,char *pat)
 {
     int i,k;
     int alen;
     int blen;
     int ret;
     
     alen=strlen(input);
     blen=strlen(pat);
     if(blen>alen || !blen)
        return -1;
//计算匹配字符串的失配函数
     fail(pat,blen,failure);
     i=0,k=0;
//	 printf("&&&&&&\n");
     while(i<alen  && k<blen)
    {
         if(input[i]==pat[k])
        {
             ++i;
             ++k;
         }
         else if(!k)
             ++i;
         else
             k=failure[k];
     }
     ret=(k==blen)? (i-blen) : -1;
     return ret;
  }
//计算失配函数
  void  fail(char *pat,int len,int *failure)
 {
      int i,k;
      i=1,k=0;
      failure[0]=0;
//	  printf("*********************\n");
      while(i<len)
     {
          if(pat[i]==pat[k])
         {
              ++i;
              ++k;
              if(pat[i]!=pat[k])
             {
                  failure[i]=k;
              }
              else
                  failure[i]=failure[k];
          }
	    	  else if(!k)
		     {
		      	  ++i;
		      	  if(pat[i]!=pat[k])
			       {
				          failure[i]=0;
			        }
		      	  else
				          failure[i]=1;
		      }
          else
              k=failure[k];
      }
      for(i=0;i<len;++i)
     {
         printf("%4c",pat[i]);
      }
      putchar('\n');
      for(i=0;i<len;++i)
     {
          printf("%4d",failure[i]);
      }
	  putchar('\n');
  }