//��������ĵݹ�ʵ��
  #include<stdio.h>


//��������
  void  quick_sort(int *sort,int start,int limit)
 {
      int i,k,tmp;
	  int j=start;
      if(start<limit)
     {
//ѡȡ�м��Ԫ����Ϊ�ο�ֵ
           tmp=sort[limit-1];
           for(i=start;start<limit;++start)
          {
               if(sort[start]<tmp)
              {
//���ⲻ��Ҫ������Ԫ���ƶ�
                  if(start!=i)
                 {
                       k=sort[i];
                       sort[i]=sort[start];
                       sort[start]=k;
                  }
                  ++i;
               }
           }
//��tmpԪ��Ϊ�ֽ磬��������ҷֿ�,��߶�С��tmp�ұߴ���tmp
		   sort[limit-1]=sort[i];
		   sort[i]=tmp;

           quick_sort(sort,j,i-1);
           quick_sort(sort,i+1,limit);
      }
  }

  int main(int argc,char *argv[])
 {
      int sort[7]={2,1,5,7,8,3,4};
	  int k=0;
      int i;
      for(i=0;i<7;++i)
         printf("%d ",sort[i]);
      printf("\n�����\n");

      quick_sort(sort,0,7);
      for(i=0;i<7;++i)
         printf("%d ",sort[i]);
      printf("\n");
      return 0;
  }

               