//2012/12/19/10:45
//ȫ����ķǵݹ�ʵ��
  #include<stdio.h>
  
  void  perm(int  n)
 {
       int  sum,i,j,k;
       int  last;
       char   p[12],c;

       if(n<3 || n>7)
      {
             printf("���ź������ǵ�Ч�ʣ������������ֻ����(3-7)֮��\n");
             return;
       }
/*
       if(n<3)
      {
            printf("�Ƿ������룬���ݽ���ֵ�������2\n");
            return;
       }
*/
       for(i=2,sum=1;i<=n;++i)
            sum*=i;
       for(i=0;i<n;++i)
            p[i]=(char)(i+'1');
       p[i]='\0';
       printf("%s\n",p);
       last=n-1;

       while(--sum)
      {
             i=last;
             while( i && p[i-1]>p[i])
                   --i;

             k=i;
             for(j=last;j>i;--j)
                 if(p[j]>p[i-1] && p[j]<p[k])
                        k=j;
//��ѡ�е�p[k],�������滹�����֣���ô������Ҫ���������Ǹ����ִ�2��������ǰ�����������С1��
//���Խ���p[k],p[i-1]֮�󣬴�i����֮��p[i--last]��Ȼ�������,�����һ�����Ҫ
             c=p[k];
             p[k]=p[i-1];
             p[i-1]=c;
//�ھֲ������򣬵õ���ԭ�������ִ�ģ���ͬʱ�����������С��
             for(j=last;j>i;--j,++i)
            {
                   c=p[j];
                   p[j]=p[i];
                   p[i]=c;
             }
             printf("%s\n",p);
        }
  }
  int  main(int argc,char *argv[])
 {

        int  n=0;
        printf("������һ������(>2 && <8\n");
        scanf("%d",&n);
        printf("%d������������ʾ:\n",n);
        perm(n);
        return 0;
  }
        