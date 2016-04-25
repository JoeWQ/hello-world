/*
 *@date:2014-09-13
 *@aim:���ٸ���Ҷ�任��ʵ��
 *@author:�ҽ���
 */
 /*
  *@func:����������ʵ�ֽ���ֵn�����mλ��ת
  *@condition:m>=1
  */
  #include"FastFFT.h"
  #include<stdlib.h>
  #include<math.h>
  #include<stdio.h>
  #define     MATH_PI       3.141592653589793
   static  int  reverse_low_bit(int   n,int  m);
   int    reverse_low_bit(int     n,int    m)
  {
//��Ϊ�����м���ʱ�����洢����ǰ������bitλ
         int     hbit,lbit;
		     int     i=0,j=m-1;
//template
		     int  t=-1;
	    	 while( i<j)
	    	{
		             lbit=n & (1<<i);
			           hbit=n & (1<<j);
//������λ,�������λ
			           n= n & (t - (1<<i)  ) | (hbit>>(j-i));
			           n= n & (t - (1<<j)  ) | (lbit<<(j-i));
			           ++i;
			           --j;
	    	 }
		   return   n;
  }
//���ٸ���Ҷ�任��׼������
 FastFFT::FastFFT(float    *factor,int   size)
{
              int    depth=0;
//��ȡ��size��Ϊ�ӽ������Ǵ���size��2��������
              while(size>>depth)
	                   ++depth;
//���������ж���Ϊ�˴���sizeΪ�����ݵ����
	            if( depth && (1 << (depth-1)) == size)
	                        --depth;
	            this->depth=depth;
	            this->size=1<<depth;
	            this->root=(Complex *)malloc(this->size*sizeof(Complex));
              this->hash_index=(int *)malloc(this->size *sizeof(int));
	            Complex   *r=root;
              int             *h=hash_index;
	            int      i;
	            for(i=0;i<this->size;++i,++r,++factor)
	           {
	                     if(i<size)
		                          r->real=*factor;
		                   else
			                      	r->real=0;
		                   r->img=0;
                       *h=reverse_low_bit(i,this->depth);
                       ++h;
	            }
 }
 FastFFT::~FastFFT()
{
             free(root);
             free(hash_index);
}
//��ɢ����Ҷ�任�Ŀ���ʵ��
 void     FastFFT::fastTransform()
{
         int    i,j,n,m;
	       int    base;//��ʼ����
	       int    d;//ÿһ���Ŀ��
//��ʱ�洢��Ԫ����λ��
         Complex      unit,temp,accu,*r=&unit,*y=&temp,*x=&accu;
	       Complex      a;
//��ʱֵ
        int          pair;
	      float        t;
//��ȴ�0��ʼ�ݽ�ֱ������������
	     for(d=1;d<=this->depth;++d)
	    {
//��Ҫ�任����Ŀ��
	               n=1<<(this->depth-d);
	           		 m=1<<d;
		           	 t=2*MATH_PI/m;
			           r->real=(float)cos(t);
			           r->img=(float)sin(t);
//��ÿһ���������Ե׶�����ֵ
			           for(i=0;i<n;++i)
		            {
					                      x->real=1;
					                      x->img=0;
//root�еĸ����ǳɶԵĴ��ڵģ�ÿһ��index��index+this->size/2����΢��Ĺ�ϵ
					                     for(j=0;j<(m>>1);++j)
				                      {
//pair��Ϊһ����base�ɶԵ�����
                                           base=this->hash_index[(i<<d)+j];
				                                   pair=this->hash_index[(i<<d)+j+(m>>1)];
//a��Ϊһ��root[base]�ĸ���
						                               a.real=root[base].real;
						                               a.img=root[base].img;
////y��Ϊһ���������ʽ,����˵��ת����
						                               y->real=x->real*root[pair].real-x->img*root[pair].img;
						                               y->img =x->real*root[pair].img +x->img*root[pair].real;
//root[base]=a+y,root[pair]=a-y
						                               root[base].real=a.real+y->real;
						                               root[base].img=a.img+y->img;
//��һ�۰벿��
						                               root[pair].real=a.real-y->real;
						                               root[pair].img=a.img-y->img;
//x=x*2*��*i/n,i��Ϊһ����λ����,y��Ϊһ��x�ĸ������뵥λ����������
                                           y->real=x->real;
                                           y->img=x->img;
						                               x->real=y->real*r->real-y->img*r->img;
						                               x->img=y->real*r->img+y->img*r->real;
					                      }
			            }
	      }
}
//��ɢ����Ҷ�任�Ŀ���ʵ��,ע����������ĺ����Ĳ�֮ͬ��
/*
  *@note11:ע���@156��@156�д��룬Ϊʲô�᲻������ĺ���������ʹ��hash_index���綨����
  *@note12:�������ԭ���ǣ��ڵ���@fastTransform֮��@root�����������е������Ѿ�����������,����
  *@note13:������ĵ������Ѿ�����Ҫ�پ�ɢ�нṹ������ض�λ
  *@note14:�ڵݹ�ʽ��ɢ����Ҷ�任������任�У��ϲ���²�ĵ��ý���ǣ��ϲ������������,�������ջ���2�λָ�����һ���ǵ���
  *@note:15:@fastTransform��,һ����@reverse��
  *@note:21:���������ǵ��㷨�У�@root�����е�����ʼ�ձ����������������
  */
 void     FastFFT::reverse()
{
           int    i,j,n,m;
	         int    base;//��ʼ����
	         int    d;//ÿһ���Ŀ��
//��ʱ�洢��Ԫ����λ��
           Complex      unit,temp,accu,*r=&unit,*y=&temp,*x=&accu;
	         Complex      a;
//��ʱֵ
           int          pair;
	         float        t;
//��ȴ�0��ʼ�ݽ�ֱ������������
	         for(d=1;d<=this->depth;++d)
	        {
//��Ҫ�任����Ŀ��
	                     n=1<<(this->depth-d);
			                 m=1<<d;
			                 t=2*MATH_PI/m;
			                 r->real=(float)cos(t);
//��һ����������ĺ����Ĳ�֮ͬ���Ĺؼ�
			                 r->img=-(float)sin(t);
//��ÿһ���������Ե׶�����ֵ
			                 for(i=0;i<n;++i)
		                  {
					                       x->real=1;
					                       x->img=0;
//root�еĸ����ǳɶԵĴ��ڵģ�ÿһ��index��index+this->size/2����΢��Ĺ�ϵ
					                      for(j=0;j<(m>>1);++j)
				                       {
//pair��Ϊһ����base�ɶԵ�����,ע���������溯��������
                                           base=(i<<d)+j;
				                                   pair=(i<<d)+j+(m>>1);
//a��Ϊһ��root[base]�ĸ���
						                              a.real=root[base].real;
						                              a.img=root[base].img;
//y��Ϊһ���������ʽ,����˵��ת����
						                              y->real=x->real*root[pair].real - x->img*root[pair].img;
						                              y->img =x->real*root[pair].img +x->img*root[pair].real;
//root[base]=a+y,root[pair]=a-y
						                              root[base].real=a.real+y->real;
						                              root[base].img=a.img+y->img;
//��һ�۰벿��
						                              root[pair].real=a.real-y->real;
						                              root[pair].img=a.img-y->img;
//����base��ֵ
//x=x*2*��*i/n,i��Ϊһ����λ����,��ʱ��y��Ϊһ����ʱ����
                                          y->real=x->real;
                                          y->img=x->img;
						                              x->real=y->real*r->real-y->img*r->img;
						                              x->img=y->real*r->img+y->img*r->real;
					                        }
			                  }
	         }
//�������������һ������
	        for(i=0;i<this->size;++i)
	                   root[i].real/=this->size;
  }
//����ʽ�ĵ�ֵ�˷�
 void    FastFFT::polyMultiply(FastFFT   *other)
{
           int    i=0;
	        Complex      *y=this->root;
	        Complex      *x=other->root;
	        Complex       unit,*t=&unit;//temp
//ע�⣬root����洢���ǵ�λ���� 1,exp(2*MATH_PI/size),exp(2*MATH_PI*2/size),
//exp(2*MATH_PI*3/size)..exp(2*MATH_PI*(size-1)/size)����Ӧ��ֵ
         for(     ;i<this->size;++i, ++x,++y )
	      {
	             t->real=y->real;
			         t->img=y->img;
			         y->real=t->real*x->real-t->img*x->img;
			         y->img =t->real*x->img +t->img*x->real;
	       }    
}
//��ȡ���ս��
 void     FastFFT::getResult(float   *r,int   size)
{
          int    i;
          Complex        *y=root;
          for(i=0;i<size;++i,++y)
                 r[i]=y->real;
 } 
