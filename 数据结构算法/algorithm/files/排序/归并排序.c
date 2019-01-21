//�鲢��������
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  #define  SEED_T    0x1000
  #define  ARY_SIZE  15
  void  merge(int *,int,int,int);

  void  merge_sort(int *,int);

  int  main(int argc,char *argv[])
 {
     int  ary[ARY_SIZE];
     int  sort[ARY_SIZE];
     int  i=0,k=0;
     printf("�����������������!\n");
     srand(SEED_T);
     for(i=0;i<ARY_SIZE;++i)
         ary[i]=rand();
     printf("����Ĵ�СΪ%d����������:\n",ARY_SIZE);
     for(i=0;i<ARY_SIZE;++i)
    {
         printf("%d  ",ary[i]);
     }
     putchar('\n');

     printf("��ʼ�������������!\n");
     merge_sort(ary,sort,ARY_SIZE);
     printf("������������������:\n");

     for(i=0;i<ARY_SIZE;++i)
    {
         printf("%d  ",ary[i]);
         ++k;
         if(k==4)
        {
            putchar('\n');
            k=0;
         }
     }
     putchar('\n');

     return 0;
  }
//�鲢����ĺ�������]
  void  merge_sort(int *list,int *sort,int n)
 {
     int  k,len;
     int  tmp,tlen;
     int  flag=1;

     for(len=2;len<n;len<<=1)
    {
          for(tmp=0,tlen=n-len,k=0;;++k,tmp+=len)
         {
              if(tmp<=tlen)
                  merge(list,sort,tmp,tmp+len,tmp+(len>>1));
              else if(tmp<n)
                  merge(list,sort,tmp,n,tmp+(len>>1));
              else
                  break;
          }
     }
     merge(list,sort,0,n,len>>1);
  }
//�Ծֲ���������
//����middle������Ҫ�鲢���еķֽ��,��middle�����ڵڶ������е���ʼ��
//��������
  void  merge(int *list,int *sort,int start,int end,int middle)
 {
       int  bound=middle;
       int  k=start;
       int  i=start;
       while(start<bound && middle<end)
      {
           if(list[start]>=list[middle])
                sort[k++]=list[start++];
           else
                sort[k++]=list[middle++];
       }
       if(start>=bound)
      {
            while(middle<end)
                sort[k++]=list[middle++];
       }
       else
      {
            while(start<bound)
                sort[k++]=list[start++];
       }
       for(;i<end;++i)
          list[i]=sort[i];
   }