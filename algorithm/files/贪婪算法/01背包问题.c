//2013/1/3/14:54
//01��������(���ö�̬�滮����)
  #include<stdio.h>
  typedef  struct  _Knap
 {
//����
       int    weight;
//��ֵ
       int    value;
  }Knap;
  static   int  s[4][56];
  static   int  select[4][56];
//�����Ѿ�������Ʒ�Ѿ��������ֵ ��������
  void  knap_select(Knap  *knap,int  n,int w)
 {
       int  i,j,le,k;
    
       for(i=1;i<=n;++i)
      {
           le=knap[i].weight;
           for(j=1;j<=w;++j)
          {
//���޼��費��i�����ȥ
                s[i][j]=s[i-1][j];
                select[i][j]=0;
  
                if(j>=le)
               {
//ע����������ʽ�ӣ����ǽ����������Ĺؼ�
                     k=s[i-1][j-le]+knap[i].value;
                     if(s[i][j]<k)
                    {
                           s[i][j]=k;
                           select[i][j]=1;
                     }
                }
           }
       }
       printf("�������ܼ�ֵΪ:%d \n",s[n][w]);
  }
//********************************************
  int  main(int  argc,char *argv[])
 {
      Knap   knap[4]={{0,0},{10,60},{20,100},{30,120}};
      knap_select(knap,4,50);
      return 0;
  }
      