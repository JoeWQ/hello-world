//2013��3��4��17:11:01
//ʹ�þ�����˷�����ÿ�Զ���֮������·��
//��ʹ��ͼ�ı�ʾʱ������ʹ�õ������ڽӾ���
  #include<stdio.h>
//�����������
  #define   INF_T    0x30000000
//*********************************
  int   weight[5][5]={{0,3,8,INF_T,-4},
                        {INF_T,0,INF_T,1,7},
                        {INF_T,4,0,INF_T,INF_T},
                        {2,INF_T,-5,0,INF_T},
                        {INF_T,INF_T,INF_T,6,0}
                       };
  int   lct[5][5];
//mat��Ϊһ��L(n-1)�ľ������룬��lct��ΪL(n)�ľ������룬weight��һ����������֮���Ȩֵ����
//������˷��ĺ����ǣ�ÿ��ѭ�������Ὣ���·������������չһ����
  static  void  shortest_paths(int (*mat)[5],int (*lct)[5],int (*weight)[5])
 {
       int  i,j,k,result;
       int   row=5,t;
//һ���Ǿ�����˷��Ĳ���
       for(i=0;i<row;++i)
      {
              for(j=0;j<row;++j)
             {
                    result=INF_T;
                    for(k=0;k<row;++k)
                   {
                           t=mat[i][k]+weight[k][j];
                           if(result>t)
                                 result=t;
                    }
                    lct[i][j]=result;
              }
        }
   }
//�������·�����ܵ����㷨
   void  all_pairs_shortest_paths(int (*weight)[5],int (*lct)[5])
  {
        int  mat1[5][5];
        int  mat2[5][5];
        int  i,j,k;
        int  (*p)[5],(*q)[5],(*t)[5];
        
        p=mat1,q=mat2;
        k=5;
//���ȶ�mat1������г�ʼ��
        for(i=0;i<k;++i)
            for(j=0;j<k;++j)
                   mat1[i][j]=weight[i][j];
//��ʼ�������·��
        --k;
//ע�⣬������������·��֮�������(n-1)����
        t=NULL;
        for(i=0;i<k;++i)
       {
              shortest_paths(p,q,weight);
              t=p;
              p=q;
              q=t;
        }
        k=5;
        for(i=0;i<k;++i)
             for(j=0;j<k;++j)
                 lct[i][j]=t[i][j];
  }
//��һ�־���˷��㷨 �������ļ����ٶ�Ҫ��һЩ
  static  int  lg2(int i)
 {
        int  k=0;
        while( i>>=1 )
           ++k;
        return k;
  }
  void  fast_all_pairs_shortest_paths(int (*weight)[5],int (*lct)[5])
 {
        int    i,k,row,len;
        int    mat1[5][5],mat2[5][5];
        int    *a,*b,*c;

        c=(int *)weight;
        a=(int *)mat1;
        b=(int *)mat2;

        row=5;
        len=25;
//��ʼ��ֵ
        for(i=0;i<len;++i,++a,++b,++c)
       {
             *a=*c;
             *b=*c;
        }
//���������������
        
        for(i=1;i<=row;i<<=1)
       {
              shortest_paths(mat1,mat2,weight);
              a=(int *)mat1;
              b=(int *)mat2;
              for(k=0;k<len;++k,a++,b++)
                   *a=*b;
        }
//�����յļ��������Ƶ�Ŀ�껺����
        c=(int *)lct;
        for(k=0;k<len;++k,++b,++c)
             *c=*b;
  }
//********************************************
  int  main(int  argc,char *argv[])
 {
        int  i,j,k=5;

        all_pairs_shortest_paths(weight,lct);
//��ӡ
        for(i=0;i<k;++i)
       {
              for(j=0;j<k;++j)
                      printf("%d       ",lct[i][j]);
              printf("\n");
        }

        printf("********************************************\n");
        fast_all_pairs_shortest_paths(weight,lct);
//��ӡ���ټ���ľ�������
        for(i=0;i<k;++i)
       {
              for(j=0;j<k;++j)
                      printf("%d       ",lct[i][j]);
              printf("\n");
        }        
        return 0;
  }