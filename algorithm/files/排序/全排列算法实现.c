//ȫ���е��㷨ʵ��
//2012/10/6/21:08
  #include<stdio.h>
  #include<stdlib.h>

  void  perm(int n)
 {
      int   i,j,k,len;
      char  buf[12],data;
      int   fact;
      len=n-1;
//�ҳ�����������������������

      if(n>=8)
     {
           printf("���ź�����������ֱ���(<8 && >=1)!\n");
           return;
      }
//���Ҫѭ�����ܴ���n!
      for(fact=1,i=2;i<=n;++i)
           fact*=i;
//��ʼ��ʼ������
      data='1';
      for(i=0;i<n;++i)
          buf[i]=data++;
      buf[i]='\0';

	  printf("%s\n",buf);
      len=n-1;
      while(fact--)
     {
           i=len;
           while(i && buf[i]<buf[i-1])
               --i;
//����Ѿ��������ˣ����˳�ѭ��
           if(!i)
               return;
//���ұ�p[i-1]����������>i��Ԫ������С��Ԫ��
           k=i;
           for(j=len;j>i;--j)
          {
                if(buf[j]>buf[i-1] && buf[j]<buf[k])
                     k=j;
           }
//����Ԫ��
           data=buf[i-1];
           buf[i-1]=buf[k];
           buf[k]=data; 

//�����Ѿ��������кõģ�������i��ʼ�����У����䰴��������(pi>p(i+1)>p(i+2).....)->
//(pi<p(i+1)<p(i+2)....)
           for(k=i,j=len;j>k;++k,--j)
          {
                data=buf[k];
                buf[k]=buf[j];
                buf[j]=data;
           }
//��ӡ���
           printf("%s \n",buf);
      }
  }
  int  main(int argc,char *argv[])
 {
      int  n;
      printf("������Ҫ���е���Ŀ!\n");
      scanf("%d",&n);
      if(n<=0 || n>4)
     {
           printf("�Ƿ������룬�����ֵ�����ڣ�1-4��֮��!\n");
           return 1;
      }
      perm(n);
      return 0;
  }