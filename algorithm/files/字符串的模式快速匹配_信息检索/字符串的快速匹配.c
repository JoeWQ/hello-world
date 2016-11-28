//2013��3��30��19:54:21
//Knuth-Morris-Parrat �ַ�����ģʽ����ƥ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
//����������ַ����� ����ƥ�亯��
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
//�ַ����Ŀ���ƥ��
//���ƥ��ɹ����򷵻�str��ʼƥ������������򷵻�-1
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
//�ַ����Ŀ��ٱȽ�,����p�Ƿ�Ϊq��ǰ׺
  int   begin_with(char  *p,char  *q)
 {

        for(  ; *p && *q && *p==*q ;++p,++q)

        return   ! *p;
  }
//����
  int  main(int  argc,char  *argv[])
 {
        int     *next,i,len;
        char    *p="acabaabaabcacaabc";
        char    *pat="abaabcac";
        
        len=strlen(pat);
        next=(int *)malloc(sizeof(int)*len);
        printf("�����ַ�����ʧ�亯��!\n");
        failure(pat,next);
/*
        for(i=0;i<len;++i)
              printf("%d--->%d  \n",i,next[i]);
*/
        i=string_match(p,pat,next);
        if(i!=-1)
             printf("ƥ��ɹ�������Ϊ:%d  \n",i);
        else
             printf("ƥ��ʧ��!\n");
        return 0;
  }
            
        