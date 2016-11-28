//2013年3月30日19:54:21
//Knuth-Morris-Parrat 字符串的模式快速匹配
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
//计算给定的字符串的 部分匹配函数
  static  void  failure(char  *str,int  *next)
 {
        int  len,i,j;

        len=strlen(str);
        next[0]=-1;
		    j=-1;
        i=0;
        while( i<len )
       {
			       if(j==-1 || str[j]==str[i])
            {
                  ++i,++j;
                  if(str[i]!=str[j])
                       next[i]=j;
                  else
                       next[i]=next[j];
             }
			       else
				          j=next[j];
        }
  }
//字符串的快速匹配
//如果匹配成功，则返回str开始匹配的索引，否则返回-1
  int  string_match(char  *str,char  *pat,int  *next)
 {
        int   i,k;
        int   slen=strlen(str);
        int   plen=strlen(pat);

        i=0,k=0;
        while( i<slen && k<plen )
       {
               if(k==-1 || str[i]==pat[k])
              {
                     ++i;
                     ++k;
               }
               else
                     k=next[k];
        }
        return  (k==plen)? (i-plen):-1;
  }
//字符串的快速比较,测试p是否为q的前缀
  int   begin_with(char  *p,char  *q)
 {

        for(  ; *p && *q && *p==*q ;++p,++q)

        return   ! *p;
  }
//测试
  int  main(int  argc,char  *argv[])
 {
        int     *next,i,len;
        char    *p="acabaabaabcacaabc";
        char    *pat="abaabcac";
        
        len=strlen(pat);
        next=(int *)malloc(sizeof(int)*len);
        printf("计算字符串的失配函数!\n");
        failure(pat,next);
/*
        for(i=0;i<len;++i)
              printf("%d--->%d  \n",i,next[i]);
*/
        i=string_match(p,pat,next);
        if(i!=-1)
             printf("匹配成功，索引为:%d  \n",i);
        else
             printf("匹配失败!\n");
        return 0;
  }
            
        