//2013年3月24日20:05:55
//多项式与快速傅里叶变换
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #define   M_PI    3.1415926
//定义复数 结构
  typedef  struct  _Complex
 {
        float    real;
        float    img;
  }Complex;

//位反转(在最低的n位比特之间进行高地位反转）
  static  int  rev(int  c,int n)
 {
         int  i,k;
         int  r,t;
         int  w,s;

         for(i=0,k=n-1;i<k;++i,--k)
        {
               r=c & (1<<k); //获取高位的比特值
               t=c & (1<<i);//获取低位的比特值
 
               s=0xFFFFFFFF ^ (1<<k);   //对高位进行清零操作
               w=0xFFFFFFFF ^ (1<<i);   //对低位进行清零操作
 
               c&=s;
               c&=w;
//对r 和 t的两个有效位进行比特值交换
               r>>=(k-i);
               t<<=(k-i);
//对最低个最高位进行比特位 交换
               c|=r;
               c|=t;
         }
         return c;
  }
//计算 对数值
  static  int  log2(int  n)
 {
        int  k=0;
        while( n>>=1 )
            ++k;
        return k;
  }
//将给定的值 按给定的索引散列方式 复制到目标数组中
  static  Complex   *rev_copy(Complex  *src,Complex  *dst,int n)
 {
         int  i=0,k=0;
         int  ln=log2(n);
         if(! dst)
               dst=(Complex  *)malloc(sizeof(Complex)*n);
         if((1<<ln)<n)
               ++ln;
         for(i=0;i<n;++i,++src)
        {
                k=rev(i,ln);
                dst[k].real=src->real;
                dst[k].img=src->img;
         }
         return dst;
  }
//快速傅里叶变换/注意 n 最好是2的整次幂，或者使 p的长度 补足为 2的整次幂，
  void   fft(Complex  *p,int  n)
 {
         int       i,j,k,m;
         int       s,w;
         int       index1,index2;
         float     real,img;
         float     ureal,uimg;
         float     u,t;
         Complex    *unit;

//先求取单位复根的值
         m=(n>>1)+1;
         unit=(Complex *)malloc(sizeof(Complex)*m);
         unit->real=1;
         unit->img=0;

         u=(float)(2*M_PI/n);
         for(i=1;i<m;++i)
        {
               img=u*i;
               unit[i].real=(float)cos(img);
               unit[i].img=(float)sin(img);
         }
//下面是快速傅里叶变换的过程
         for(i=2;i<=n;i<<=1)
        {
                w=i>>1;
                for(k=0;k<n;k+=i)
               {
                      for(j=0;j<w;++j)
                     {
                            index1=k+j;
                            index2=index1+w;ok 
                   //求取旋转因子所在的下标         
                            s=n*j/i;
                   //下面是复数的乘法
                            u=unit[s].real;
                            t=unit[s].img;
                            real=u*p[index2].real-t*p[index2].img;
                            img=t*p[index2].real+u*p[index2].img;

                            ureal=p[index1].real;
                            uimg=p[index1].img;

                            p[index1].real=ureal+real;
                            p[index1].img=uimg+img;
 
                            p[index2].real=ureal-real;
                            p[index2].img=uimg-img;
                      }
                 }
         }
        free(unit);  
  }
//快速傅里叶变换的逆变换
  void   rev_fft(Complex  *rf,int  n)
 {
         int     i,j,k;
         int     s,w;
         int     index1,index2;
         float   u,t;
         float   real,img;
         float   ureal,uimg;
         Complex   *unit; 
         
         w=(n>>1)+1;
         unit=(Complex  *)malloc(sizeof(Complex)*w);
         unit->real=1;
         unit->img=0;
 
         t=(float)(-2*M_PI/n);
         for(i=1;i<w;++i)
        {
                u=t*i;
                unit[i].real=(float)cos(u);
                unit[i].img=(float)sin(u);
         }
         for(i=2;i<=n;i<<=1)
        {
                w=i>>1;
                for(k=0;k<n;k+=i)
               {
                      for(j=0;j<w;++j)
                     {
                            index1=k+j;
                            index2=index1+w;
                    //获取复指数根的索引
                            s=n*j/i;
                            u=unit[s].real;
                            t=unit[s].img;
                    //进行复数的乘法运算
                            real=rf[index2].real*u-rf[index2].img*t;
                            img=rf[index2].img*u+rf[index2].real*t;

                            ureal=rf[index1].real;
                            uimg=rf[index1].img;
                          
                            rf[index1].real=ureal+real;
                            rf[index1].img=uimg+img;
                            
                            rf[index2].real=ureal-real;
                            rf[index2].img=uimg-img;
                       }
                  }
           }
//注意下一步必不可少，它是区别于fft的关键
           for(i=0;i<n;++i)
          {
                  rf[i].real/=n;
                  rf[i].img/=n;
           }
           free(unit);
  }
  int  main(int  argc,char  *argv[])
 {
           int   n=16,i,j,k;
           float    real,img;
           Complex   src[16]={ {8,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0} };
           Complex   dst[16];
   
           Complex   src2[16];
           Complex   dst2[16];

           Complex   poly[16];
           Complex   dst_poly[16];

           for(i=0;i<n;++i)
                 src2[i]=src[i];
 
           rev_copy(src,dst,n);
           fft(dst,n);

           rev_copy(src2,dst2,n);
           fft(dst2,n);
//执行点值对的乘法运算
           k=n>>1;
           for(i=0;i<n;++i)
          {
                 real=dst[i].real*dst2[i].real - dst[i].img*dst2[i].img;
                 img=dst[i].real * dst2[i].img + dst2[i].real*dst[i].img;
                 poly[i].real=real;
                 poly[i].img=img;
           }
/*
           for(  ;i<n;++i)
          {
                 poly[i].real=0;
                 poly[i].img=0;
           }
*/
//执行逆傅里叶变换
           rev_copy(poly,dst_poly,n);
           rev_fft(dst_poly,n);
           for(i=0;i<n;++i)
               printf("  %d----> real:%f img: %f  \n",i,dst_poly[i].real,dst_poly[i].img);       
/*
           printf("位置转换....\n");
           rev_copy(src,dst,n);
           printf("进行快速傅里叶变换\n");
           fft(dst,n);
           printf("\n进行逆快速傅里叶变换\n");
           rev_copy(dst,src,n);  //注意这一步必不可少
           rev_fft(src,n);
           printf("开始产生输出....\n");
           for(i=0;i<n;++i)
          {
                  printf("%d  real:%f  ,img:%f  \n",i,src[i].real,src[i].img);
           }
*/
           return 0;
  }