/*
  *@aim:˫������
  *@date:2014-10-27 17:06:06
  *@author:�ҽ���
  */
 #include<stdio.h>
/*
  *@function:bitonic_sort
   *@aim:˫������,�Զ�����
   *@principle:˫���������0-1ԭ��������������ݱ�����˫���ģ�������������ȷ����
   *@cost:Space:O(1),Time:O(n)
   *request:none
   */
    void      bitonic_sort(int     *y,int    size)
   {
            int       i,m,j,t,r,k;
            int       *p=y;
//���⻷��ѭ��
            int         cycle;
//cycle�����űȽϵĿ��
            for(m=0; (1<<m ) <size;++m )
           {
//�۰�ĳ���
                     cycle=size>>m;
//iΪ��ַ
                     for(i=0;i<size;i+=cycle)
                    {
//tΪ�м��
                              t = i+(cycle>>1);
//jΪ�Ұ��Ŀ�ʼ����
                              j=t;
                              for(k=i ; k<t;++k,++j)
                             {
                                        if( p[k]>p[j] ) 
                                        {
                                                  r = p[k];
                                                  p[k]=p[j];
                                                  p[j]=r;
                                        }
                                        ++k;
                                        ++j;
                              }
                     }
            }
   }
  int    main(int   argc,char  *argv[])
 {
//˫������
           int     bitonic[8]={7,8,12,13,15,9,5,4};
           int      size=8;
           bitonic_sort(bitonic,size);
//
           int      i=0;
           printf("after bitonic sort:\n");
           for(   ;i<size;++i)
                 printf("%4d",bitonic[i]);
           printf("\n");
           return    0;
  }
