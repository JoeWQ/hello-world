/*
  *@aim:����LU�㷨������Է�����
  *@date:2015-6-9
  *@request:���Է������ϵ�����������ʽ������0
  */
#include"CArray2D.h"
#include<stdio.h>
//���������ﲻ���������������Ч��
//@param:lu���Է������ϵ������
//@request:���붼�Ƿ���,coeff->rowCount()==lu->columnCount()
//@request:coef�Խ���ϵ����Ϊ0
//@return:ϵ�������LU�ֽ�,�������д��lu�У�
//@note:�����ὫLU��������ϲ���lu�У�ͬʱ���Ǽٶ�ʹ���߶������־���Ľṹ�ǳ��˽�
//@note:���ԶԾ���Ľ���Ҳ����ȫ���Լ����
  void         lu_matrix_decomposite(CArray2D<float>    *coef,CArray2D<float>   *lu)
 {
                float           factor;
                int              i,j,k;
                int              n=coef->rowCount();
 //��һ������д��������Ͻ�Ԫ��,��������,���������ǲ��Ὣ���Ԫ��д�뵽lu������               
                lu->copyWith(coef);
                for(k=0;k<n;++k)
               {
                             factor=lu->get(k,k);
                             for(j=k+1;j<n;++j)
//�������,������         
                                          lu->set(j,k,   lu->get(j,k)/factor   );
//����Schur������
                            for(i=k+1;i<n;++i)
                           {
                                         for(j=k+1;j<n;++j)
                                        {
                                                    factor=lu->get(i,j)-lu->get(k,j)*lu->get(i,k);
                                                    lu->set(i,j, factor );
                                         }
                            }
                }
  }
 //��LU������н��룬��������Է�����
 //@param:b�����ұߵĽ��
 //@return:��a��д�뷽�����Ľ��
   void               solve_linear_equation(CArray2D<float>    *coef,float    *b,float   *a)
  {
                 float          factor;
                 int             i,k;
                 int             n=coef->rowCount();
//����ֽ�
                 CArray2D<float>           alu(n,n);
                 CArray2D<float>           *lu=&alu;
                 lu_matrix_decomposite(coef,lu);
//���������ϵ�����󷽳���
                 for(i=0;i<n;++i)
                {
                             factor=b[i];
                             for(k=0;k<i;++k)
                                          factor-=lu->get(i,k)*a[k];
                             a[i]=factor;
                 }
//���������ϵ�����󷽳���
                 for( i=n-1  ;i>=0;--i)
                {
                              factor=a[i];
                             for(k=n-1;k>i;--k)
                                        factor-=lu->get(i,k)*a[k];
                             a[i]=factor/lu->get(i,i);
                 }
   }
 //************************************************
   int          main(int    argc,char     *argv[])
  {
                 int            size=4;
//4*4ϵ������
                 float            coefficient[4][4]={
                                                               {4,5,3,1},{6,7,1,1},{1,2,8,9},{2,9,10,5}
                                                   };
                 float            b[4]={7,10,16,25};
                 float            a[4];
                 CArray2D<float>           acoef(size,size);
                 CArray2D<float>           *coef=&acoef;
                 int               i,k;
                 for(i=0;i<size;++i)
                            for(k=0;k<size;++k)
                                        coef->set(i,k,coefficient[i][k]);
                  solve_linear_equation(coef,b,a);
//��֤���
                  for(i=0;i<size;++i)
                 {
                              float      factor=0;
                              for(k=0;k<size;++k)
                                         factor+=a[k]*coefficient[i][k];
                              printf("row %d ,result is %f\n",i,factor);
                  }
                  return   0;
   }
   