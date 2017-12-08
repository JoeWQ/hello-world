//2013��3��19��12:42:42
//���Թ滮�ĵ������㷨ʵ��
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _Linear
 {
//��¼�洢�����������鳤��
       int         bsize;
       int         *base;
//��¼�洢�ǻ���������ĳ���
       int         nsize;
       int         *nbase;
//��¼�߹滮�� �ɳ��� �еĳ�����,ע�����ĳ��Ⱦ��� bsize
       double      *bcst;
//��¼Ŀ�꺯���� ������������ϵ��
       double      *aimc;
//��¼Ŀ�꺯���еĳ�����
       double      v;
//��¼���Թ滮�и����ǻ�������ϵ����ע�⣬�����ɳ����е�ϵ���պ��෴
//�����е���ĿΪ nsize
       double      (*ma)[10];
  } Linear;
//�����������
  static  double   E_INF=0xFFFFFFFF;
  void  print_relax_type(Linear  *p);
//������Ԫ���༴ѡȡһ���ǻ����� �� һ������������������
/*
  *���е�Ԫ�ض�������һ�������У��������������в���,�������ݻ��������Ϻͷǻ���������
  *�������������������е�
  *e:�������������(���ı�����һ���ǻ�����)
  *b:��������������(���ı�����һ��������)
 */
  static  void  pivot(Linear  *p,int  e,int  b)
 {
       int        i,j,k,m;
       double        (*ma)[10];
       double     ie,t;
       
       ma=p->ma;
//���� �ɳ��ε�ʽ�еĳ�����
	     ie=ma[b][e];
       p->bcst[e]=p->bcst[b]/ie;
//���� �����ɵ��ɳڵ�ʽ�У������ǻ�������ϵ��
       for(i=0;i<p->nsize;++i)
      {
              k=p->nbase[i];
              if(  k!=e  )
                    ma[e][k]=ma[b][k]/ie;
       }
       ma[e][b]=1/ie;
//�������ɵ� �ɳڱ��ʽ �������������
       t=p->bcst[e];/**************************/
       for(i=0;i<p->bsize;++i)
      {
             k=p->base[i];
             if(k==b)
                continue;
//���� �ɳ��ε�ʼ�յĳ�����
             p->bcst[k]-=t*ma[k][e];
//����ͷǻ������йص�����
             ie=ma[k][e];
             for(j=0;j<p->nsize;++j)
            {
                   m=p->nbase[j];
                   if( m==e )
                        continue;
                   
                   ma[k][m]-=ma[e][m]*ie;
             }
             ma[k][b]=-ma[e][b]*ie;
        }
//��һ��������Ŀ�꺯���еı��ʽ
        ie=p->aimc[e];
        p->v+=p->bcst[e]*ie;  //���³�����
   //��������ķǻ�����ǰ��ϵ��
        for(i=0;i<p->nsize;++i)
       {
              k=p->nbase[i];
              if(k==e)
                  continue;
              p->aimc[k]-=ie*ma[e][k];
        }
    //����µķǻ�����
        p->aimc[b]=-ie*ma[e][b];
//�Ի������ͷǻ��������Ͻ��и���
        for(i=0;i<p->bsize;++i)
       {
              if(p->base[i]==b)
                  break;
        }
        p->base[i]=e;
        for(i=0;i<p->nsize;++i)
       {
              if(p->nbase[i]==e)
                   break;
        }
        p->nbase[i]=b;
  }
  static  int  judge_const(Linear  *p,int *max)
 {
        int       i,k,j=0;
        double    e=-E_INF; 
        for(i=0;i<p->nsize;++i)
       {
              k=p->nbase[i];
              if(p->aimc[k]>e)
             {
                    e=p->aimc[k];
                    j=k;
              }
        }
        i=0;
        if(e>0)
       { 
             i=1;
             *max=j;
        }
        return i;
  }  
/**********************************************************/
  #include"��׼��ת��Ϊ�ɳ���.c"
/************************************************************/
//���������������õ������㷨��� ���Թ滮
//�����ɹ������ط�0�����򷵻�0
  int   simplex(Linear  *p)
 {
        int       imax,k,i;
        double    e,*limit;
		    double    (*ma)[10]=p->ma;

        limit=(double *)malloc(sizeof(double)*p->bsize);
        while(  judge_const(p,&imax) )
       {
//             ++j;
//             printf("max:%d\n",imax);
//Ѱ��һ���� �ǻ����� i ������������Ǹ��ɳڱ��ʽ
             for(i=0;i<p->bsize;++i)
            {
                   k=p->base[i];
                   e=ma[k][imax];
                   if(e>0 )
                        limit[i]=p->bcst[k]/e;
                    else
                        limit[i]=E_INF;
             }
       //Ѱ��������Ϊ�ϸ���Ǹ�����
             e=E_INF;
             k=0;
             for(i=0;i<p->bsize;++i)
            {
                   if(e>limit[i])
                  {
                        k=p->base[i];
                        e=limit[i];
                   }
             }
             if(e==E_INF) //��ʱ��������Թ滮����һ���޽��
            {
                   printf("�޽�ı��ʽ��%d�ɳڱ��ʽ�������!\n");
                   free(limit);
                   return 0;
             }
             else
                   pivot(p,imax,k);
        }
        free(limit);
        return 1;
  }
//���������ɳ������
  void  print_relax_type(Linear  *p)
 {
        int        i,j,k,t;
        double     e,(*ma)[10]=p->ma;

        for(i=0;i<p->bsize;++i)
       {
              k=p->base[i];
              printf("\n��%d��  :��ϵ��:  %lf\n",k,p->bcst[k]);
              for(j=0;j<p->nsize;++j)
             {
                     t=p->nbase[j];
                     printf("%d :%8lf   ",t,ma[k][t]); 
              }
        }
  }
  int  main(int  argc,char *argv[])
 {
        int       i,k;
/*
        double    ma[6][10]={ {0,0,0},{0,0,0},{0,0,0},
                               {1,2,3},
                               {2,2,5},
                               {4,1,2}
                         };
        int       nbase[3]={0,1,2};
        int       base[3]={3,4,5};
        double    bcst[10]={0,0,0,30,24,36};
        double    v=0;
        double    aimc[10]={3,1,2,0,0,0};
        Linear  pg,*p=&pg;

        p->bsize=3;
        p->base=base;
        p->nsize=3;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("��ʼ����......\n");
        if(simplex(p))
       {
               printf("���ֵΪ:%lf  \n",p->v);
               printf("����������ȡֵ������ʾ:\n");
               for(i=0;i<p->bsize;++i)
              {
                      k=p->base[i];
                      printf("X(%d):%lf\n",k,p->bcst[k]);
               }
        }
        else
            printf("���㷢������!\n");
*/
/*
       double    ma[6][10]={
                               {1,2,3},
                               {2,2,5},
                               {4,1,2}
                         };
        int       nbase[3]={0,1,2};
        int       base[3]={3,4,5};
        double    bcst[10]={30,24,36};
        double    v=0;
        double    aimc[10]={3,1,2,0,0,0};
        Linear  pg,*p=&pg;

        p->bsize=3;
        p->base=base;
        p->nsize=3;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("��ʼ�����׼��!\n");
        formal_to_relax_type(p);
        print_relax_type(p);
*/
        double    ma[6][10]={
                               {2,-1},
                               {1,-5},
                         };
        int       nbase[3]={0,1};
        int       base[3]={2,3};
        double    bcst[10]={2,-4};
        double    v=0;
        double    aimc[10]={2,-1};
        Linear  pg,*p=&pg;

        p->bsize=2;
        p->base=base;
        p->nsize=2;
        p->nbase=nbase;
        p->bcst=bcst;
        p->aimc=aimc;
        p->v=v;
        p->ma=ma;

        printf("��ʼ�����׼��!\n");
        if(!formal_to_relax_type(p))
       {
               printf("ת��ʧ��!\n");
               return 1;
        }
        print_relax_type(p);
        printf("\n");
        return 0;
  }