/*
  *@aim:���Է������ϵ�������LUP�ֽ�
  *@date:2015-6-9
  */
  #include"CArray2D.h"
  #include<stdio.h>
  #include<math.h>
  #include<assert.h>
  //�����LUP�ֽ�
  //@request:coef->rowCount()>=2,coef->rowCount()==lup->rowCount()
  //@request:����ľ������Ϊ����
  //@return:true��������Ƿ��������false����������������
  //@param:xchgΪ��������,Ҳ�����û�����P��һά��ʾ
    bool           lup_matrix_decomposite(CArray2D<float>   *coef,CArray2D<float>    *lup,int   *xchg)
   {
                 float            factor,e;
                 int               i,j,k;
                 int               n=coef->rowCount();
                 
//���û������ʼ��Ϊ��λ����
                 for(i=0;i<n;++i)
                                   xchg[i]=i;
                  lup->copyWith(coef);
                 for(k=0;k<n;++k)
                {
//�������ϵ��
                                   factor=0.0f;
                                   j=-1;
                                   for(i=k;i<n;++i)
                                  {
//ʹ��ϵ���ľ���ֵ
                                                  e=abs(lup->get(i,k));
                                                  if( e>factor)
                                                 {
                                                                factor=e;
                                                                j=i;
                                                  }
                                   }
//���û���ҵ�����0��ϵ������ֵ��ֱ������,��ʱ˵���������С��n
                                   if(j==-1 )
                                                 return    false;
//��������,����п���
                                   if(j  != k)
                                  {
                                               for(i=0;i<n;++i  )
                                              {
                                                           e=lup->get(k,i);
                                                           lup->set(k,i,   lup->get(j,i));
                                                           lup->set(j,i,e);
                                               }
//�����û�����
                                               i=xchg[j];
                                               xchg[j]=xchg[k];
                                               xchg[k]=i;
                                   }
//���ಿ��������LU�ֽ���һ����
//factorһ��Ҫ���¼���,��Ϊ����ʹ�õ��Ǿ����Ԫ�صľ���ֵ
                                    factor=lup->get(k,k);
                                   for(i=k+1;i<n;++i)
                                                  lup->set(i,k,    lup->get(i,k)/factor);
//����ϵ������
                                   for(i=k+1;i<n;++i)
                                  {
                                                 for(j=k+1;j<n;++j)
                                                {
                                                               factor=lup->get(i,j)-lup->get(k,j)*lup->get(i,k);
                                                               lup->set(i,j,factor);
                                                 }
                                   }
                 }
                 return  true;
    }
//�Է��ص�LUP�������,��������Է�����
//������LU�ֽ�Ľ������,lup�ֽ�Ľ��뵱Ȼ��Ҫ��Ը���һЩ
//@return:true������ϵ�����������ʽ������0,��ô���ط��̵Ľ�,���򷵻�false
//@note:�������޸�ϵ������,����ʹ����һ��Ҫע����һ��
    bool               solve_linear_equation(CArray2D<float>    *coef,float        *b,float     *a)
   {
                 int                i,j,k;
                 float                factor;
                 const    int                n=coef->rowCount();
//
                 CArray2D<float>         alup(n,n);
                 CArray2D<float>         *lup=&alup;
//��������
                 int               *xchg=new     int[n];
//�������ֽ�ʧ��
                 if(  ! lup_matrix_decomposite(coef,lup,xchg))
                {
                              delete      xchg;
                              return     false;
                  }
//����������
                 for(i=0;i<n;++i)
                {
                               if(xchg[i] != i)
                              {
                                             factor=b[i];
                                             j=i;
                                             k=xchg[j];
                                             do
                                             {
                                                            b[j]=b[k];
                                                            xchg[j]=j;
                                                            j=k;
                                                            k=xchg[k];
                                              }while(k !=i);
                                              xchg[j]=j;
                                              b[j]=factor;
                               }
                 } 
//ɾ���û�����
                 delete       xchg;
                 xchg=NULL;
//��������Ǿ���
                 for(i=0;i<n;++i)
                {
                               factor=b[i];
                               for(j=0;j<i;++j)
                                         factor-=lup->get(i,j)*a[j];
                               a[i]=factor;
                 }
//��������Ǿ���
                 for(i=n-1;i>=0;--i)
                {
                                factor=a[i];
                                for(j=n-1;j>i;--j)
                                          factor-=lup->get(i,j)*a[j];
                                a[i]=factor/lup->get(i,i);
                 }
                 return    true;
    }
//
    int        main(int    argc,char    *argv[])
   {
                 int            size=4;
//4*4ϵ������
                 float            coefficient[4][4]={
                                                               {4,5,3,1},{6,7,1,1},{1,2,8,9},{2,9,10,5}
                                                   };
                 float            b[4]={7,10,16,25};
                 float            a[4];
                 
                 CArray2D<float>            acoef(size,size);
                 CArray2D<float>            *coef=&acoef;
                 
                 int              i,j;
                 float           factor;
                 
                 for(i=0;i<size;++i)
                           for(j=0;j<size;++j)
                                          coef->set(i,j,coefficient[i][j]);
                 assert(   solve_linear_equation(coef,b,a) );
                 
                 for(i=0;i<size;++i)
                {
                              factor=0;
                              for(j=0;j<size;++j)
                                          factor+=coefficient[i][j]*a[j];
                              printf("row %d is %f\n",i,factor);
                 }
                 return  0;
    }