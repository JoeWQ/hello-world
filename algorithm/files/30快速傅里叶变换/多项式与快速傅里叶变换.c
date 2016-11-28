//2013��3��24��20:05:55
//����ʽ����ٸ���Ҷ�任
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #define   M_PI    3.1415926
//���帴�� �ṹ
  typedef  struct  _Complex
 {
        float    real;
        float    img;
  }Complex;

//λ��ת(����͵�nλ����֮����иߵ�λ��ת��
  static  int  rev(int  c,int n)
 {
         int  i,k;
         int  r,t;
         int  w,s;

         for(i=0,k=n-1;i<k;++i,--k)
        {
               r=c & (1<<k); //��ȡ��λ�ı���ֵ
               t=c & (1<<i);//��ȡ��λ�ı���ֵ
 
               s=0xFFFFFFFF ^ (1<<k);   //�Ը�λ�����������
               w=0xFFFFFFFF ^ (1<<i);   //�Ե�λ�����������
 
               c&=s;
               c&=w;
//��r �� t��������Чλ���б���ֵ����
               r>>=(k-i);
               t<<=(k-i);
//����͸����λ���б���λ ����
               c|=r;
               c|=t;
         }
         return c;
  }
//���� ����ֵ
  static  int  log2(int  n)
 {
        int  k=0;
        while( n>>=1 )
            ++k;
        return k;
  }
//��������ֵ ������������ɢ�з�ʽ ���Ƶ�Ŀ��������
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
//���ٸ���Ҷ�任/ע�� n �����2�������ݣ�����ʹ p�ĳ��� ����Ϊ 2�������ݣ�
  void   fft(Complex  *p,int  n)
 {
         int       i,j,k,m;
         int       s,w;
         int       index1,index2;
         float     real,img;
         float     ureal,uimg;
         float     u,t;
         Complex    *unit;

//����ȡ��λ������ֵ
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
//�����ǿ��ٸ���Ҷ�任�Ĺ���
         for(i=2;i<=n;i<<=1)
        {
                w=i>>1;
                for(k=0;k<n;k+=i)
               {
                      for(j=0;j<w;++j)
                     {
                            index1=k+j;
                            index2=index1+w;ok 
                   //��ȡ��ת�������ڵ��±�         
                            s=n*j/i;
                   //�����Ǹ����ĳ˷�
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
//���ٸ���Ҷ�任����任
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
                    //��ȡ��ָ����������
                            s=n*j/i;
                            u=unit[s].real;
                            t=unit[s].img;
                    //���и����ĳ˷�����
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
//ע����һ���ز����٣�����������fft�Ĺؼ�
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
//ִ�е�ֵ�Եĳ˷�����
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
//ִ���渵��Ҷ�任
           rev_copy(poly,dst_poly,n);
           rev_fft(dst_poly,n);
           for(i=0;i<n;++i)
               printf("  %d----> real:%f img: %f  \n",i,dst_poly[i].real,dst_poly[i].img);       
/*
           printf("λ��ת��....\n");
           rev_copy(src,dst,n);
           printf("���п��ٸ���Ҷ�任\n");
           fft(dst,n);
           printf("\n��������ٸ���Ҷ�任\n");
           rev_copy(dst,src,n);  //ע����һ���ز�����
           rev_fft(src,n);
           printf("��ʼ�������....\n");
           for(i=0;i<n;++i)
          {
                  printf("%d  real:%f  ,img:%f  \n",i,src[i].real,src[i].img);
           }
*/
           return 0;
  }