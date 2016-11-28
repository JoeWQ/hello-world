//2013��3��14��11:59:03
//�� ���������������
  #include<stdio.h>
  #include<stdlib.h>
//���þ����LUP�ֽ⣬����������������
  static  int  lup_decomposition(double (*ma)[10],int *pi,int row)
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
//��XΪ�������A�������,��A*X=I(n);��XΪn��nά�������ɵģ����Կ��Խ�n��n�׷�����Ľ�
//ʹ�þ����LUP�ֽ⣬������O(n*n)�Ľ���ʱ���ڽӴ���N������
  int  reverse_matrix(double (*ma)[10],double (*rever)[10],int  row)
 {
        int       *pi,*tag;
        int       i,j,k,t;
        double    *value;
        double    *resolve;
        double    p;
        
        pi=(int *)malloc(sizeof(int)*row);
        tag=(int *)malloc(sizeof(int)*row);
        value=(double *)malloc(sizeof(double)*row);
        resolve=(double *)malloc(sizeof(double)*row);

        if(!  lup_decomposition(ma,pi,row))
       {
               free(pi);
               free(tag);
               free(value);
               free(resolve);
               return  0;
        }
        for(k=0;k<row;++k)
       {
//������ʽ�ұߵ�ֵ Ϊһ����λ����(��K��Ԫ��Ϊ1)
              for(i=0;i<row;++i)
                    value[i]=0;
              value[k]=1;
//�����ݽ���һЩ��Ҫ�ĳ�ʼ��
              for(i=0;i<row;++i)
                    tag[i]=0;
//������λ������Ԫ��1��λ��
              for(i=0;i<row;++i)
             {
                    j=pi[i];
//�����i������Ԫ�ػ�û�б����ʹ�
                    if(! tag[j])
                   {
                         t=i;
                         while(j!=i)
                        {
                               p=value[t];
                               value[t]=value[j];
                               value[j]=p;
//ע������ı��˳�����Ĳ���˳��ǳ���Ҫ
                               tag[t]=1;
                               t=j;
                               j=pi[t];
                          }
                          tag[t]=1;
                     }
               }
//ʹ�������Ǿ������
              for(j=0;j<row;++j)
             {
                   p=value[j];
                   for(i=0;i<j;++i)
                       p-=ma[j][i]*resolve[i];
                   resolve[j]=p;
              }
//ʹ�������Ǿ������
              for(j=row-1;j>=0;--j)
             {
                   p=resolve[j];
                   for(i=row-1;i>j;--i)
                       p-=ma[j][i]*resolve[i];
                   resolve[j]=p/ma[j][j];
              }
//���Ƶ�Ŀ�����ĵ�k����
              for(i=0;i<row;++i)
                   rever[i][k]=resolve[i];
       }
       free(pi);
       free(tag);
       free(value);
       free(resolve);
       return 1;
  }
  int  main(int argc,char *argv[])
 {
       double  ma[10][10]={   {2,1,1},
                              {3,2,4},
                              {5,1,4}
                           };
       double  tmp[10][10];
       double  resolve[10][10],p;
       int     i,j,k,row=3;
       for(i=0;i<row;++i)
           for(j=0;j<row;++j)
                tmp[i][j]=ma[i][j];
 
       printf("��ʼ��������....\n");
       reverse_matrix(ma,resolve,row);
       printf("\n��֤���Ľ��...\n");

       for(i=0;i<row;++i)
      {
            for(j=0;j<row;++j)
                  printf(" %8lf ",resolve[i][j]);
            printf("\n");
       }
       printf("\n*************************************************\n");
       for(i=0;i<row;++i)
      {
            for(j=0;j<row;++j)
           {
                  p=0;
                  for(k=0;k<row;++k)
                        p+=tmp[i][k]*resolve[k][j];
                  printf(" %8lf ",p);
            }
            printf("\n");
       }
       return 0;
  }