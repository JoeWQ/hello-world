//��һ�����������������iС������Ԫ��,���������鲻һ���������
//2012/10/16/18:36
  #include<stdio.h>
  #include<stdlib.h>

 int  find_i_min(int *,int,int);
 static int partion(int *,int,int);
 int  find_max(int *,int);
 int  find_min(int *,int);

  int  find_i_min(int *buf,int n,int  ti)
 {
       int  i,k,j;
       int  key;
//�����������������Ӧ���������⴦��
       if(! ti)
           return find_min(buf,n);
       if(ti>=n-1)
           return find_max(buf,n);
       if(ti<0)
      {
            printf("����Ƿ�!\n");
            return -1;
       }
//��ʼ����Ԫ�ػ��֣����Ļ��ַ���������������
       i=0;
       k=n-1;
       j=0;
       while(i<k)
      {
//ѡ����λ������ʹ����Ԫ�صĻ��ָ�����
            j=(i+k)>>1;
            if(buf[i]>buf[j] && buf[i]<buf[k])
           {
                 key=buf[i];
                 buf[i]=buf[k];
                 buf[k]=key;
            }
            else if(buf[j]>buf[i] && buf[j]<buf[k])
           {
                 key=buf[j];
                 buf[j]=buf[k];
                 buf[k]=key;
            }

            j=partion(buf,i,k);
            printf("j:%d \n",j);
            if(j==ti)
           {
                i=j;
                break;
            }
            if(j>ti)
               k=j-1;
            else
               i=j+1;
            printf("i:%d,k:%d,ti:%d \n",i,k,ti);
  //          _sleep(2000);
       }
       return buf[i];
  }
//��������з����������ı�׼Ϊ���ΪС��buf[q],�ұ�Ϊ����buf[q]�м�Ϊbuf[q]
   static int  partion(int *buf,int p,int q)
  {
       int  i,k;
       int  tmp,key;
       i=p,k=q;
       key=buf[q];

       while(i<k)
      {
           while(i<k && buf[i]<=key)
                ++i;
           while(k>i && buf[k]>=key)
                --k;
           if(i<k)
          { 
               tmp=buf[i];
               buf[i]=buf[k];
               buf[k]=tmp;
               ++i;
               --k;
           }
       }
       tmp=buf[i];
       buf[i]=key;
       buf[q]=tmp;
/*      
       for(i=p;i<=q;++i)
           printf("%d  ",buf[i]);
       printf("\n");
*/
       return k;
  }
           
//ͬʱ���������Сֵ
  int  find_max(int *buf,int n)
 {
      int i,max;
      for(max=buf[0],i=1;i<n;++i)
     {
           if(max<buf[i])
                max=buf[i];
      }
      return max;
  }

  int  find_min(int *buf,int n)
 {
      int i,min;
      for(min=buf[0],i=1;i<n;++i)
     {
           if(min>buf[i])
               min=buf[i];
      }
      return min;
  }
//***************************************************
  int main(int argc,char *argv[])
  {
	  int buf[8]={4,7,3,1,5,6,2,8};
	  int vbuf[8];
	  int j=0;
	  int k=0;
	  int n=0;
	  int i=0;
      for(i=7;i>=0;--i)
	  {
	       printf("��%d����СԪ��Ϊ%d\n",i,find_i_min(buf,8,i));
/*
 		   if(i==5)
		   {
			   for(k=0;k<8;++k)
				   printf("%d  ",buf[k]);
			   printf("\n");
		   }
*/
	  }
//	  printf("��%d����СԪ��Ϊ%d\n",i,find_i_min(buf,8,i));
		 printf("i:%d\n",i);
	  return 0;
  }