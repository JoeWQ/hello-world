//ȫ���е��㷨ʵ��
//2012/10/26/18:08
  #include<stdio.h>

//�˺����Ĺ�����ʵ��n!,���д���С�����ʵ�֣��༴��(1,2,...,n)��(n,n-1,...,2,1)
  void  perm(int n)
 {
      int   len,fact,i,j,k;
      char  buf[12],data;
//Ϊ��ʹ����������ʱ�䲻���ڹ���������������Ĺ�����������
      if(n>5 || n<=0)
     {
           printf("�Ƿ�de���룬�����ֵ������>=1 & <=5 �ķ�Χ��!\n");
           return ;
      }
    
      for(i=2,fact=1;i<=n;++i)
            fact*=i;
      len=n-1;
//���ַ�������г�ʼ��
      data='1';
      for(i=0;i<n;++i)
           buf[i]=data++;
      buf[i]='\0';
      printf("%s\n",buf);

      while(fact--)
     {
           i=len;
//�ҳ���ĩ�˿�ʼ����������е�����(pi,p(i+1),p(i+2)...)
           while(i && buf[i-1]>buf[i])
                --i;
//����Ѿ������˾�ͷ���༴Ŀǰ��������(n,n-1,n-2,...,2,1������ѭ���˳�
           if(! i)
              break;
//�ҳ��ڽ������е������У���buf[i-1]��������������Ҫ�������Ԫ����������С������Ԫ��
//�±�����
           k=i;
           for(j=len;j>i;--j)
          {
                if(buf[j]>buf[i-1] && buf[j]<buf[k])
                       k=j;
           }
//��������Ԫ��
          data=buf[i-1];
          buf[i-1]=buf[k];
          buf[k]=data;
//��������������а���������
          for(k=len,j=i;j<k;++j,--k)
         {
              data=buf[k];
              buf[k]=buf[j];
              buf[j]=data;
          }
          printf("%s\n",buf);
     }
  }
//****************************************************************
  int  main(int argc,char *argv[])
 {
      int  n;
      printf("������һ������(>0 & <=5)\n");
      scanf("%d",&n);
      printf("\n");
      perm(n);
      return 0;
  }