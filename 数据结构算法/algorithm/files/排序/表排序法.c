//ʹ�ñ������,ע������ı��ȷ��Ҫ��ѭһ��ͨ�õĹ���
//ʹ��һ�����򷽷�,�ڽ�����¼��ͬʱҲ��������е�Ԫ��
  #include<stdio.h>
  #include<stdlib.h>
//������ѧ����:ÿ�����ж������ɸ������ཻ��ѭ�����

  int  key[8]={35,14,12,42,26,50,31,18};
  
  int  table[8]={2,1,5,4,6,0,3,7};
  
  int  size=8;

  void  table_sort(int  *table,int *list,int n)
 {
       int  i,k;
       int  tmp,len=n-1;
       int  current,next;
       int  **tp,*p;
//���ȶ�����ļ�¼����һ��"��ʽ����",��������
       tp=(int **)malloc(sizeof(int *)*n);
       
       for(p=list,i=0;i<n;++i,++p)
      {
           tp[i]=p;
           table[i]=i;
       }
       for(i=0;i<len;++i)
      {
           tmp=*tp[i];
           current=i;
           for(k=i+1;k<n;++k)
          {
              if(tmp<*tp[k])
             {
                   current=k;
                   tmp=*tp[k];
              }
           }
           if(current!=i)
          {
               tmp=table[i];
               table[i]=table[current];
               table[current]=tmp;

               p=tp[i];
               tp[i]=tp[current];
               tp[current]=p;
           }
       }
       printf("�������Ľ��:\n");
       for(i=0;i<n;++i)
           printf("  %d  ",table[i]);
       putchar('\n');

       for(i=0;i<len;++i)
      {
           if(table[i]!=i)
          {
               tmp=list[i];
               current=i;
               do
              {
                   next=table[current];
                   list[current]=list[next];
                   table[current]=current;
                   current=next;
               }while(table[current]!=i);
							list[current]=tmp;
              table[current]=current;
          }
       }
  }
  int  main(int argc,char *argv[])
 {
      int  i=0;
      table_sort(table,key,size);
      for(i=0;i<size;++i)
         printf("  %d  ",key[i]);
      putchar('\n');
      return 0;
  } 