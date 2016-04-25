/*
  *@aim:最长公共上升子序列
  *@aim2:最长上升子序列
  */
  #include<stdio.h>
  #include<string>
 //最长上升子序列
  int            longest_arise_sequence(std::string      *seq)
 {
                int          *y=new       int[seq->size()+1];
                const       char     *x=seq->c_str();
                int                          i,k,size;
//假设在索引k处,以x[k]为结尾的序列获得了最长长度
                y[0]=1,k=0;
                for(i=1;i<seq->size();++i)
               {
                               size=0;
                               for(k=0;k<i;++k)
                              {
                                             if( x[k]<x[i] &&  y[k]>size)
                                                         size=y[k];
                               }
                               y[i]=size+1;
                }
                size=0;
                for(i=0;i<seq->size();++i)
               {
                              if(size<y[i])
                                       size=y[i];
                }
                delete     y;
                return    size;
  }
 //作为假设,字符串序列的长度不能大于16
    int               longest_common_arise_sequence(std::string     *seq1,std::string     *seq2)
   {
                 const        char         *x=seq1->c_str();
                 const        char         *y=seq2->c_str();
                 int            i,j,k;
                 int             dp[16][16];
                 for(i=0;i<seq1->size();++i)
                             dp[0][i]=0;
                 for(i=1;i<=seq1->size();++i)
                {
//假设上次在k处取得了最大值
                               k=0;
                               dp[i][0]=0;
                               for(j=1;j<=seq2->size();++j)
                              {
                                               dp[i][j]=0;
                                               if(x[i-1] != y[j-1])
                                                            dp[i][j]=dp[i-1][j];
                                               if( x[i-1]>y[j-1] && dp[i][j] >dp[i][k] )
                                                            k=j;
                                               if(x[i-1] == y[j-1])
                                                            dp[i][j] = dp[i][k]+1;//实际上,dp[i][k]==dp[i-1][k]
                               }
                 }
                 j=0;
                 for(i=1;i<=seq2->size();++i)
                {
                               if(j<dp[seq1->size()][i])
                                           j=dp[seq1->size()][i];
                 }
                 return       j;
    }
     int       main(int    argc,char   *argv[])
    {
                 std::string               seq1="15723498";
                 std::string               seq2="23475089";
                 
                 printf("longest_arise_sequence():%d\n",longest_arise_sequence(&seq1));
                 
                 printf("longest_common_sequence():%d\n",longest_common_arise_sequence(&seq1,&seq2));
                 
                 return         0;
     }