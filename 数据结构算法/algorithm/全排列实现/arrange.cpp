/*
  *@aim:ȫ���еĵݹ���ǵݹ�ʵ��
  *@date:2014-11-12 10:07:43
  *@author:�ҽ���
  */
/*
  *@function:arrange_no_recursive
  *@aim:ȫ���еķǵݹ�ʵ��
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
//��⣬��һ����ѡ�����ַ���
                      i=size-1;
                      while( i>0 && p[i]<p[i-1] )
                              --i;
                      if( i == 0 )
                            break;
//���ҵ�һ����p[i-1]С���ַ�������
                     j=i-1;
                     c=p[j];
                     k=i;
                     i=size-1;
//�����ڱ�c���������С���Ǹ�����,���ڿ��Կ϶�����p[i]һ����i-1��,���������Ѿ���k=i
                     for(  ; i>j; --i)
                    {
                            if( p[i]>c && p[i]<p[k] )
                                  k=i;
                     }
//�ڶ�������������
                      p[j]=p[k];
                      p[k]=c;
//����������i��i֮���������������,
//���ڣ���֪i��i֮�����������������ģ�����ֻ�轻�����ݼ���
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
  *@aim:ȫ���еĵݹ�ʵ��
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
//��������,�ڽ���֮�����ǽ�������һ��˳��Ľ���
                               c=p[k];
                               for( j=k;j>from;--j)
                                    p[j]=p[j-1];
                               p[from]=c;
//�ݹ���ȥ
                               arrange_recursive(p,from+1,to);
//��������,��ԭԭ�����ֳ�
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
