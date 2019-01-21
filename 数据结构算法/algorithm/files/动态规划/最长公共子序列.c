//2012/12/27/14:28
//求取字符串的最长公共子序列
  #include<stdio.h>
  #include<string.h>
  #include<stdlib.h>

  #define  MAX_SIZE  10
//定义相对位置的数字表现
//对角线
  #define  AA_L       0x1
//左边
  #define  LL_L       0x2
//上方
  #define  UU_L       0x3
//为了方便存取二维数组，而定义的宏
  #define  SET_ARRAY  (ma,s,i,j,c)     *(ma+i*c+j)=s
  #define  GET_ARRAY  (ma,i,j,c)        *(ma+i*c+j)
/***************************************/
 static  int  common[10][10];
 static  int  trace[10][10];

//求取最长公共子序列
 void  longest_common_sequence(char  *p,char *q,char *vbuf)
{
      int  le1,le2;
      int  i,j,k;
      char  *vf;

      le1=strlen(p);
      le2=strlen(q);
      if(le1>=MAX_SIZE || le2>=MAX_SIZE)
     {
           printf("很遗憾，字符串的序列长度不能大于%d!\n",MAX_SIZE);
           return;
      }
//初始化，清零操作
      for(i=0;i<le1;++i)
           common[i][0]=0;
      for(i=0;i<le2;++i)
           common[0][i]=0;
//注意下面的这一步操作
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
//将公共子序列写入缓冲区中
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

       printf("求取最长公共子序列....\n");
       longest_common_sequence(p,q,vbuf);
       printf("X：  %s   \nY:  %s   \nC:  %s  \n",p,q,vbuf);
       return 0;
 }