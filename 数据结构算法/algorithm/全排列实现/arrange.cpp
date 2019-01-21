/*
  *@aim:全排列的递归与非递归实现
  *@date:2014-11-12 10:07:43
  *@author:狄建彬
  */
/*
  *@function:arrange_no_recursive
  *@aim:全排列的非递归实现
  *@date:2014-11-12 10:08:19
  *@request:
  */
   #include<stdio.h>
   #include<stdlib.h>
    void      arrange_no_recursive(char    *p ,int  size)
   {
            char        c;
            int           i,j,k;
////
            while( true )
           {
                      printf("%s\n",p);
//检测，下一个被选定的字符串
                      i=size-1;
                      while( i>0 && p[i]<p[i-1] )
                              --i;
                      if( i == 0 )
                            break;
//查找第一个比p[i-1]小的字符的索引
                     j=i-1;
                     c=p[j];
                     k=i;
                     i=size-1;
//查找在比c大的数中最小的那个数字,现在可以肯定的是p[i]一定比i-1大,所以现在已经令k=i
                     for(  ; i>j; --i)
                    {
                            if( p[i]>c && p[i]<p[k] )
                                  k=i;
                     }
//第二步，交换数据
                      p[j]=p[k];
                      p[k]=c;
//第三步，对i及i之后的数据升序排序,
//现在，已知i及i之后的数据是升序排序的，所以只需交换数据即可
                      i=j+1;
                      j=size-1;
                     while( i< j )
                    {
                                c=p[i];
                                p[i]=p[j];
                                p[j]=c;
                                ++i;
                                --j;
                     }
            }
    }
/*
  *@function:arrange_recursive
  *@aim:全排列的递归实现
  *@date:2014-11-12 13:21:25
  *@request:from <=to
  */
   void    arrange_recursive(char    *p,int   from,int  to )
  {
             int       k,j; 
             char    c;
             if(   from == to )
                     printf("%s\n",p);
             else
            {
                      for(k=from;k<=to;++k)
                     {
//交换数据,在交换之后我们将首先做一下顺序的矫正
                               c=p[k];
                               for( j=k;j>from;--j)
                                    p[j]=p[j-1];
                               p[from]=c;
//递归下去
                               arrange_recursive(p,from+1,to);
//交换数据,还原原来的现场
                               c=p[from];
                               for(j=from;j<k;++j)
                                     p[j]=p[j+1];
                               p[k]=c;
                      }
             }
    }
//
    int    main(int    argc,char   *argv[])
   {
           char     p[]={'1','2','3','4','5','\0'};
           char     q[]={'1','2','3','4','5','\0'};
           printf("recursive version:\n");
           arrange_recursive(p,0,4);
 //          printf("no recursive version:\n");
  //         arrange_no_recursive(q,5);
           return 0;
    }
