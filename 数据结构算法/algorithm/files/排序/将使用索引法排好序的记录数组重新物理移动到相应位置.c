//��ʹ���������ź���ļ�¼�����еļ�¼�����ƶ�
  #include<stdio.h>
  #include<stdlib.h>
//���ƶ��ļ�¼����
  int  list[10]={26,5,77,1,61,11,59,15,48,19};
//��¼����Ӧ������
  int  index[10]={8,5,-1,1,2,7,4,9,6,0};
//�ߴ�
  int  size=10;
//������ʵ��
  void  list_sort(int  *index,int  *list,int n,int start)
 {
       int  i,tmp;
       int  len=n-1,next;

       for(i=0;i<len;++i)
      {
           while(start<i)
              start=index[start];
           next=index[start];
           
           if(start!=i)
          {
                tmp=list[i];
                list[i]=list[start];
                list[start]=tmp;
             
                index[start]=index[i];
                index[i]=start;
           }
           start=next;
       }
  }
//*****************************************************************
  int  main(int argc,char *argv[])
 {
      int  i=0;
      list_sort(index,list,size,3);
      for(i=0;i<size;++i)
           printf("  %d  \n",list[i]);
      return 0;
  }