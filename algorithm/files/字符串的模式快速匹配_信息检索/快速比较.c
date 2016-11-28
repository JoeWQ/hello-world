//�ַ����Ŀ��ٱȽ�
  #include<stdio.h>
  #include<string.h>
  #include<stdlib.h>
  #include<time.h>
//************************************************
//ƥ���ַ�����ʧ�亯��
  int  failure[256];
//�洢�����ַ���
  char input[256];
  char pat[256];
  
  void fail(char *p,int ,int *);
//Knuth,Morris,Pratt �㷨
  int  pmkmatch(char *,char *);

  int main(int argc,char *argv[])
 {
     int index=0;
     printf("������һ���ַ���(<256)!\n");
     gets(input);
     printf("������Ҫƥ����ַ���(<256)!\n");
     gets(pat);
     
     index=pmkmatch(input,pat);
     if(index<0)
    {
         printf("���ź�,�������ƥ���ַ�������ƥ����������ַ�!\n");
     }
     else
         printf("ƥ��ɹ���ƥ��Ŀ�ʼ����Ϊ%d !\n",index);
     return 0;
  }
//**********************************************************************
//����ַ���ƥ�����������ɹ����ط�0ֵ�����򷵻ظ���
//input :��ƥ����ַ�����pat��ƥ���ַ���
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
//����ƥ���ַ�����ʧ�亯��
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
//����ʧ�亯��
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