//2013��3��25��8:22:41/
// ��a,b�Ĵ���ʽ��ʾ���ǵ����Լ��d ,����d=a*x+b*y
  #include<stdio.h>
  #include<stdlib.h>
//ŷ������㷨  
  int   ouclid_algorithm(int  a,int  b,int *ax,int *by)
 {
         int   r,k;
         int   x,y;
         int   rc[32];
         k=0;

         while(  b )
        {
               rc[k++]=a;

               r=a%b;
               a=b;
               b=r;
         }
         *by=k;
//r��¼��a b �����Լ��
         r=a;
//�ӵ����� ���Ѿ����ɵ����ֽ��з�ת
         x=1,y=0;
         b=a;
         *ax=r;
         while( k  )
        {
               a=rc[--k];
               r=y;
               y=x-(a/b)*y;  
               x=r;
               b=a;  
         }
         k=*by;
         r=*ax;
         *ax=x;
         *by=y;
    		 return r;
  }
//
  int  main(int  argc,char *argv[])
 {

         int  i=5,k=7;
         int  x,y,d;

         d=ouclid_algorithm(i,k,&x,&y);
         printf("%d= %d*%d + %d*%d \n",d,i,x,k,y);

         i=24,k=6;
         d=ouclid_algorithm(i,k,&x,&y);
         printf("%d= %d*%d + %d*%d \n",d,i,x,k,y);

         i=0,k=56;
         d=ouclid_algorithm(i,k,&x,&y);
         printf("%d= %d*%d + %d*%d \n",d,i,x,k,y);

         i=6,k=45;
         d=ouclid_algorithm(i,k,&x,&y);
         printf("%d= %d*%d + %d*%d \n",d,i,x,k,y);

         return 0;
  }