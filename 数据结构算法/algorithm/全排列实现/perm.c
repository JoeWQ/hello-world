/*
  *@ȫ����
  *&2016-2-19 16:52:16
  */
#include<stdio.h>

    void        perm( int     n  )
   {
//ѭ���Ĵ���
             int           _count=1;
             char        symbol[32],c;
//
             int           i,j,k,m;
             for(k=1;k<=n;++k)
            {
                        _count*=k;
                        symbol[k-1]=(char)(k+'0');
             }
             symbol[n]='\0';
            printf("%s\n",symbol);
            i=1;
            while( i<=_count  )
           {
//��һ��,���������ǰ�������ҵ�һ�������� symbol[k-1]>symbol[k]������k-1
                            for(k=n-1;k>0 && symbol[k-1]>symbol[k];--k)
                                       ;
                             j=k-1;
//������j��ʼ,���Ҵ���symbol[j]����С��Ԫ��
                             m=j+1;
                             for(k=j+1;k<n;++k)
                            {
                                            if(symbol[k]>symbol[j] && symbol[k]<symbol[m])
                                                              m=k;
                             }
//������������j,m
                             c=symbol[m];
                             symbol[m]=symbol[j];
                             symbol[j]=c;
//��j+1��ʼ��ת�ַ�����(j+1,..... n)
                             for(k=j+1,m=n-1;k<m;++k,--m)
                            {
                                            c=symbol[m];
                                            symbol[m]=symbol[k];
                                            symbol[k]=c;
                             }
                             printf("%s\n",symbol);
                             ++i;
            }
    }
//�ݹ���ʽʵ��ȫ����
    void             perm_recurve(char    *symbol,int   _from,int   _to)
   {
                  int      k;
                  char   c;
                  if(_from == _to)
                              printf("%s\n",symbol);
                  else
                 {
//���η�
                              for(k=_from;k<=_to;++k)
                             {
                                         c=symbol[_from];
                                         symbol[_from]=symbol[k];
                                         symbol[k]=c;
                                         perm_recurve(symbol,_from+1,_to);
                                         symbol[k]=symbol[_from];
                                         symbol[_from]=c;
                              }
                  }
    }
    int        main(int    argc,char   *argv[])
   {
                 char    symbol[6]={'1','2','3','4','5','\0'};
                 perm(5);
                 printf("\n-------------------------------------------\n ");
                 perm_recurve(symbol,0,4);
                 return      0;
    }