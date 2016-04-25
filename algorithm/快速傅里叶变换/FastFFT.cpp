/*
 *@date:2014-09-13
 *@aim:快速傅里叶变换的实现
 *@author:狄建彬
 */
 /*
  *@func:辅助函数，实现将数值n的最低m位翻转
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
//作为两个中见临时变量存储交换前的两个bit位
         int     hbit,lbit;
		     int     i=0,j=m-1;
//template
		     int  t=-1;
	    	 while( i<j)
	    	{
		             lbit=n & (1<<i);
			           hbit=n & (1<<j);
//清除相关位,再置相关位
			           n= n & (t - (1<<i)  ) | (hbit>>(j-i));
			           n= n & (t - (1<<j)  ) | (lbit<<(j-i));
			           ++i;
			           --j;
	    	 }
		   return   n;
  }
//快速傅里叶变换的准备工作
 FastFFT::FastFFT(float    *factor,int   size)
{
              int    depth=0;
//求取与size最为接近，但是大于size的2的整次幂
              while(size>>depth)
	                   ++depth;
//下面的这个判断是为了处理当size为整次幂的情况
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
//离散傅里叶变换的快速实现
 void     FastFFT::fastTransform()
{
         int    i,j,n,m;
	       int    base;//起始索引
	       int    d;//每一步的跨度
//临时存储单元，单位根
         Complex      unit,temp,accu,*r=&unit,*y=&temp,*x=&accu;
	       Complex      a;
//临时值
        int          pair;
	      float        t;
//跨度从0开始递进直到它的最大深度
	     for(d=1;d<=this->depth;++d)
	    {
//需要变换的数目对
	               n=1<<(this->depth-d);
	           		 m=1<<d;
		           	 t=2*MATH_PI/m;
			           r->real=(float)cos(t);
			           r->img=(float)sin(t);
//对每一组数进行自底而上求值
			           for(i=0;i<n;++i)
		            {
					                      x->real=1;
					                      x->img=0;
//root中的复数是成对的存在的，每一个index和index+this->size/2有着微妙的关系
					                     for(j=0;j<(m>>1);++j)
				                      {
//pair作为一个与base成对的索引
                                           base=this->hash_index[(i<<d)+j];
				                                   pair=this->hash_index[(i<<d)+j+(m>>1)];
//a作为一个root[base]的副本
						                               a.real=root[base].real;
						                               a.img=root[base].img;
////y作为一个公共表达式,或者说旋转因子
						                               y->real=x->real*root[pair].real-x->img*root[pair].img;
						                               y->img =x->real*root[pair].img +x->img*root[pair].real;
//root[base]=a+y,root[pair]=a-y
						                               root[base].real=a.real+y->real;
						                               root[base].img=a.img+y->img;
//另一折半部分
						                               root[pair].real=a.real-y->real;
						                               root[pair].img=a.img-y->img;
//x=x*2*π*i/n,i作为一个单位复根,y作为一个x的副本参与单位复根的运算
                                           y->real=x->real;
                                           y->img=x->img;
						                               x->real=y->real*r->real-y->img*r->img;
						                               x->img=y->real*r->img+y->img*r->real;
					                      }
			            }
	      }
}
//离散傅里叶变换的快速实现,注意它和上面的函数的不同之处
/*
  *@note11:注意第@156，@156行代码，为什么会不想上面的函数那样，使用hash_index来界定索引
  *@note12:最根本的原因是，在调用@fastTransform之后，@root复数域数组中的数据已经重新排序了,所以
  *@note13:在下面的调用中已经不需要再经散列结构数组的重定位
  *@note14:在递归式离散傅里叶变换和其逆变换中，上层对下层的调用结果是，上层的数据重排序,所以最终会有2次恢复次序，一次是调用
  *@note:15:@fastTransform中,一次是@reverse中
  *@note:21:但是在我们的算法中，@root数组中的数据始终保持着它的物理次序，
  */
 void     FastFFT::reverse()
{
           int    i,j,n,m;
	         int    base;//起始索引
	         int    d;//每一步的跨度
//临时存储单元，单位根
           Complex      unit,temp,accu,*r=&unit,*y=&temp,*x=&accu;
	         Complex      a;
//临时值
           int          pair;
	         float        t;
//跨度从0开始递进直到它的最大深度
	         for(d=1;d<=this->depth;++d)
	        {
//需要变换的数目对
	                     n=1<<(this->depth-d);
			                 m=1<<d;
			                 t=2*MATH_PI/m;
			                 r->real=(float)cos(t);
//这一点是与上面的函数的不同之处的关键
			                 r->img=-(float)sin(t);
//对每一组数进行自底而上求值
			                 for(i=0;i<n;++i)
		                  {
					                       x->real=1;
					                       x->img=0;
//root中的复数是成对的存在的，每一个index和index+this->size/2有着微妙的关系
					                      for(j=0;j<(m>>1);++j)
				                       {
//pair作为一个与base成对的索引,注意它和上面函数的区别
                                           base=(i<<d)+j;
				                                   pair=(i<<d)+j+(m>>1);
//a作为一个root[base]的副本
						                              a.real=root[base].real;
						                              a.img=root[base].img;
//y作为一个公共表达式,或者说旋转因子
						                              y->real=x->real*root[pair].real - x->img*root[pair].img;
						                              y->img =x->real*root[pair].img +x->img*root[pair].real;
//root[base]=a+y,root[pair]=a-y
						                              root[base].real=a.real+y->real;
						                              root[base].img=a.img+y->img;
//另一折半部分
						                              root[pair].real=a.real-y->real;
						                              root[pair].img=a.img-y->img;
//更新base的值
//x=x*2*π*i/n,i作为一个单位复根,此时，y作为一个临时变量
                                          y->real=x->real;
                                          y->img=x->img;
						                              x->real=y->real*r->real-y->img*r->img;
						                              x->img=y->real*r->img+y->img*r->real;
					                        }
			                  }
	         }
//最后在整体上做一次整除
	        for(i=0;i<this->size;++i)
	                   root[i].real/=this->size;
  }
//多项式的点值乘法
 void    FastFFT::polyMultiply(FastFFT   *other)
{
           int    i=0;
	        Complex      *y=this->root;
	        Complex      *x=other->root;
	        Complex       unit,*t=&unit;//temp
//注意，root里面存储的是单位复根 1,exp(2*MATH_PI/size),exp(2*MATH_PI*2/size),
//exp(2*MATH_PI*3/size)..exp(2*MATH_PI*(size-1)/size)所对应的值
         for(     ;i<this->size;++i, ++x,++y )
	      {
	             t->real=y->real;
			         t->img=y->img;
			         y->real=t->real*x->real-t->img*x->img;
			         y->img =t->real*x->img +t->img*x->real;
	       }    
}
//获取最终结果
 void     FastFFT::getResult(float   *r,int   size)
{
          int    i;
          Complex        *y=root;
          for(i=0;i<size;++i,++y)
                 r[i]=y->real;
 } 
