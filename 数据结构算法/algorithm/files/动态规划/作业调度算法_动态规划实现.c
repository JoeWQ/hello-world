//2012/12/30/11:03
//��ҵ�����㷨,���������ҵЧ���ȡ����ҵ��������
  #include<stdio.h>
  #include<stdlib.h>
  #define  INF_T   0x30000000
//�꺯��
  #define  MIN(a,b)    (a)<(b)?(a):(b)
/**********************************/
  typedef  struct  _Job
 {
//��ҵҪ���ĵ�ʱ��
       int    time;
//����ҵҪ�����߽�ֹʱ��
       int    deadline;
//�ڽ�ֹʱ������ҵ��ɺ�����õ�Ч��
       int    benefit;
  }Job;
//**************************************
  static  int  bf[8][16];
  static  int  tg[8][16];
  static  int  p[16];
/*************************************/
//�ڵ����������֮�䣬�����Ѿ���������ǰ�(deadline,time,benefit)����������
  void  job_schedule(Job  *job,int n,int  dw)
 {
       int  i,j,le,min;
       int  vp,k;
//��ʼ������
       for(i=0;i<=n;++i)
           bf[i][0]=0;
       for(i=0;i<=dw;++i)
           bf[0][i]=0;
//���ö�̬�滮���
       for(i=1;i<=n;++i)
      {
             le=job[i].deadline;
             k=job[i-1].deadline;
             for(j=1;j<=le;++j)
            {
//���i���ܼ��뱻���ȵĶ���
                  bf[i][j]=bf[i-1][MIN(j,k)];
                  tg[i][j]=0;
//                  p[i]=0;
//�����i����ҵ�����ȣ�
//��ô���ʹ��������ʱ���ý����������ܹ���֤i֮ǰ����ҵ�ܹ��ڸ���ԣ��ʱ���ڱ�����,ע������ĵȺ�
                 if(j>=job[i].time)
                {
                       min=((j-job[i].time)<k)?(j-job[i].time):k;
                       vp=bf[i-1][min]+job[i].benefit;
                       if(bf[i][j]<vp)
                      {
                            bf[i][j]=vp;
                            tg[i][j]=1;
//                            p[i]=1;
                       }
                  }
/*
for i = 1->n  
for j = 1->d[i]  
    //������i   
    s[i][j] = s[i-1][min(j, d[i-1])]  
    select[i][j] = false  
    //����i   
    if j>t[i]  
        if s[i][j] < s[i-1][min(j-t[i], d[i-1])]+p[i]  
            s[i][j] = s[i-1][min(j-t[i], d[i-1])]+p[i]  
            select[i][j] = true  
*/
             }
        }

//������������еı�ѡ�е���ҵ

        printf(" 1  2  3  4  5  6  7  8  9  10 11 12 13 14\n");
        for(j=1;j<=dw ;++j)
       {
             printf("��%d:\n",j);
             for(i=1;i<=n;++i)
            {
                   if(tg[i][j])
                      printf(" 1 ");
                   else
                      printf(" 0 ");
             }
             printf("\n");
        }

//
        printf("Ч��ֵ:\n");
        for(i=1;i<=n;++i)
       {
             printf("\n��%d��:            \n     ",i); 
             for(j=1;j<=dw;++j)
                  printf(" %d  ",bf[i][j]);
        }
        printf("\n*******************\n");
/*        for(i=1;i<16;++i)
           if(p[i])
              printf("  %d  ",i);
*/
//��tg������н���,�Գ�ȡ����ѡ�е���ҵ
//������濪ʼ����
        printf("\n");
        for(i=n,j=dw;i && j;--i)
       {
//ע������Ĵ��룬������ı��������෴�Ĺ�ϵ
//���i��ѡ��
              if(tg[i][j])
             {
                   printf(" %d  ",i);
                   j=MIN(job[i-1].deadline,j-job[i].time);
              }
              else
                  j=MIN(j,job[i-1].deadline);
       }
        printf("\n��ߵĵ���Ч��Ϊ:%d \n",bf[n][dw]);
  }
//
  int  main(int argc,char *argv[])
 {
//
       Job   job[7]={{0,0,0},{2,4,7},{2,4,6},{1,6,4},{5,7,12},{4,10,10},{1,14,3}};
       int   size=6;
       
       printf("���Ч��ֵ������:\n");
       job_schedule(job,size,14);
       printf("\n*****************************\n");
       return 0;
  }
       
      