//2012/12/27/14:28
//��ȡ�ַ����������������
  #include<stdio.h>
  #include<string.h>
  #include<stdlib.h>

  #define  MAX_SIZE  10
//�������λ�õ����ֱ���
//�Խ���
  #define  AA_L       0x1
//���
  #define  LL_L       0x2
//�Ϸ�
  #define  UU_L       0x3
//Ϊ�˷����ȡ��ά���飬������ĺ�
  #define  SET_ARRAY  (ma,s,i,j,c)     *(ma+i*c+j)=s
  #define  GET_ARRAY  (ma,i,j,c)        *(ma+i*c+j)
/***************************************/
 static  int  common[10][10];
 static  int  trace[10][10];

//��ȡ�����������
 void  longest_common_sequence(char  *p,char *q,char *vbuf)
{
      int  le1,le2;
      int  i,j,k;
      char  *vf;

      le1=strlen(p);
      le2=strlen(q);
      if(le1>=MAX_SIZE || le2>=MAX_SIZE)
     {
           printf("���ź����ַ��������г��Ȳ��ܴ���%d!\n",MAX_SIZE);
           return;
      }
//��ʼ�����������
      for(i=0;i<le1;++i)
           common[i][0]=0;
      for(i=0;i<le2;++i)
           common[0][i]=0;
//ע���������һ������
      --p,--q;
   
      for(i=1;i<=le1;++i)
     {
          for(j=1;j<=le2;++j)
         {
                if(p[i]==q[j])
               {
                      common[i][j]=common[i-1][j-1]+1;
                      trace[i][j]=AA_L;
                }
                else if(common[i-1][j]>=common[i][j-1])
               {
                      common[i][j]=common[i-1][j];
                      trace[i][j]=UU_L;
                }
                else
               {
                      common[i][j]=common[i][j-1];
                      trace[i][j]=LL_L;
                }
         }
      }
//������������д�뻺������
      k=le1>=le2?le1:le2;
      vf=(char *)malloc(k+1);
      vf[k]='\0';
      *vbuf='\0';
      for(i=le1,j=le2;i && j ;  )
     {
            if(p[i]==q[j])
           {
                vf[--k]=p[i];
                --i;
                --j;
            }
            else if(trace[i][j]==LL_L)
                --j;
            else
                --i;
      }
      strcpy(vbuf,vf+k);
      free(vf);
  }
//**************************************
  int  main(int argc,char *argv[])
 {
       char  vbuf[16];
       char  *p="ABCBDAB";
       char  *q="BDCABA";

       printf("��ȡ�����������....\n");
       longest_common_sequence(p,q,vbuf);
       printf("X��  %s   \nY:  %s   \nC:  %s  \n",p,q,vbuf);
       return 0;
 }