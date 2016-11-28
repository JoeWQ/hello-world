//2013��3��13��15:04:22
//���Nά���Է�����(����n�����̣��Һ���n��δ֪�����ķ�����,�༴ϵ������Ϊ�������N�׷���)
  #include<stdio.h>
  #include<stdlib.h>

//N�׷����LUP�ֽ�
//maΪ�������rowΪʵ������ľ���ά����piΪ �û������һβ����pi[i]=j��ʾ �û������i��j��Ϊ1
//����������ܹ������ LPU �ֽ⣬����1�����򷵻�0
  static  int  lup_decomposition(double (*ma)[10],double *value,int row,int *pi)
 {
        int      i,j,k,t;
        double   p,e;

//�ȶ����ݽ��б�Ҫ�ĳ�ʼ��
        for(i=0;i<row;++i)
             pi[i]=i;
//�ֽ��������,�����ֱ��д��ԭ�����������ma�У����ҽ������ϲ�ĵ��ú�������
        t=0;
        for(k=0;k<row;++k)
       {
              p=0;
              for(i=k;i<row;++i)
             {
                    e=ma[i][k];
                    e=e>0?e:-e;
                    if(e>p)
                   {
                         p=e;
                         t=i;
                    }
              }
              if(p==0)
             {
                    printf("�Ƿ��Ĳ������������Ϊ�������!\n");
                    return 0;
              }
//����������������½�������,ע������Ĵ���֮��������Լ����ǰ����Ĳ�ͬ��˼��
              if(k!=t)
             {
                    i=pi[t];
                    pi[t]=pi[k];
                    pi[k]=i;

//                    e=value[k];
//                    value[k]=value[t];
//                    value[t]=e;
                    for(i=0;i<row;++i)
                   {
                           e=ma[k][i];
                           ma[k][i]=ma[t][i];
                           ma[t][i]=e;
                    }
              }
//���¾����е�����
              p=ma[k][k];
              for(i=k+1;i<row;++i)
             {
                    ma[i][k]/=p;
                    for(j=k+1;j<row;++j)
                          ma[i][j]-=ma[i][k]*ma[k][j];
              }
        }
        return 1;
  }
//������Է�����
//�����ĺ���
/*
  ma:�������(�������ϵ������)
  row:�������ʵ�ʵ������ģ(�������δ֪������)
  value:������ĵ�ʽ�ұߵ�rowάֵ����
  resolved:��Ž��������
*/
//���������нⷵ��1�����򷵻�0
  int   resolve_linear_quatation(double  (*ma)[10],double *value,double *resolved,int row)
 { 
        int      i,j,k;
        int      *pi;
        double   p,e;

        pi=(int *)malloc(sizeof(int)*row);
        if(! lup_decomposition(ma,value,row,pi))
       {
            free(pi);
            return 0;
        }
//���� ���Է��صľ���ma���н��룬��������Է�����
        printf("**************************************\n");
        for(i=0;i<row;++i)
       {
              j=pi[i];
              if(j!=-1)
             {
                    k=i;
                    while(j!=i)
                   {
                        e=value[k];
                        value[k]=value[j];
                        value[j]=e;

                        pi[k]=-1;
                        k=j;
                        j=pi[k];
                    }
                    pi[k]=-1;
              }
        }
/*
        for(i=0;i<row;++i)
             printf("%d--->%d \n",i,pi[i]);
        for(i=0;i<row;++i)
             printf("%d--->%lf\n",i,value[i]);
*/
//����������Ǿ���
        for(i=0;i<row;++i)
       {
              p=value[i];
              for(j=0;j<i;++j)
                  p-=ma[i][j]*resolved[j];
              resolved[i]=p;
        }
//����������Ǿ���
        for(i=row-1;i>=0;--i)
       {
              p=resolved[i];
              for(j=row-1;j>i;--j)
                   p-=ma[i][j]*resolved[j];
              resolved[i]=p/ma[i][i];
        }
        free(pi);
        return 1;
  }
//��������
  int  main(int  argc,char *argv[])
 {

        double  ma[10][10]={ {1,5,4},
                          {2,0,3},
                          {5,8,2}
                         };
        double  value[10]={12,9,5};
/*

        double  ma[10][10]={  {2,1 ,1},
                              {3,2,4},
                              {5,1,4}
                            };
        double  value[10]={13,23,31};
*/
        int  row=3;
        int  i,j=0;
        double  resolved[10],e;
        

        if(! resolve_linear_quatation(ma,value,resolved,row))
       {
                printf("������Է�����ʧ��!\n");
                return 1;
        }
        printf("���Է�����Ľ�������ʾ:\n");
        for(i=0;i<row;++i)
            printf("x(%d): %lf \n",i,resolved[i]);
        printf("------------------------------------  \n");

        e=resolved[0]+5*resolved[1]+4*resolved[2];
        printf("%lf  \n",e);
        e=resolved[0]*2+3*resolved[2];
        printf(" %lf  \n",e);
        e=resolved[0]*5+8*resolved[1]+2*resolved[2];
        printf(" %lf  \n",e);
/*
        e=2*resolved[0]+resolved[1]+resolved[2];
        printf("%lf  \n",e);
        e=3*resolved[0]+2*resolved[1]+4*resolved[2];
        printf(" %lf  \n",e);
        e=5*resolved[0]+resolved[1]+4*resolved[2];
        printf(" %lf  \n",e);
*/
        return 0;
  }