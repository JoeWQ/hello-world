/*
  *@aim:�����ӡ����
  *@date:2015-5-27
  */
  #include"CArray2D.h"
  #include<stdio.h>
  
 //��������ӡ����
 //������С�Ĵ���
 //w:���ʳ��ȵļ���
 //@request:w[i]>0,line_length>w[i],(i>=0 && i<size)
     int             perfect_print(int           *w,int           size,int        line_length)
    {
                 int            i,j,k;

                  CArray2D<int>                 word_cost(size,size);
                  CArray2D<int>                 *p=&word_cost;
                  CArray2D<int>                 word_length(size,size);
                  CArray2D<int>                 *r=&word_length;
                  
//��������ǰ������ö��ⲽ��
                  p->fillWith(0);
                  for(i=0;i<size;++i)
                 {
                            p->set(i,i,line_length-w[i]);
                            r->set(i,i,w[i]);
                  }
                  for(i=1;i<size;++i)
                 {
                            for(j=0;j<size-i;++j)
                           {
                                          r->set(j,j+i,   r->get(j,j+i-1)+w[j+i]);
                            }
                  }
//i��ÿ��ѭ���Ŀ��                  
                  for(i=1;i<size;++i)
                 {
                               for(j=0;j<size-i;++j)
                              {
                                               int         weight=line_length<<1;
                                               for(k=j;k<j+i;++k)
                                              {
                                                            int           cost;
//�ȽϽ�k����Ͳ��ܼ������ܹ��ɵ���С����,//������Ϊһ��
//������߿��Ժϲ���һ��
                                                            if(r->get(j,k)+r->get(k+1,j+i)+i<=line_length)
                                                           {
                                                                      cost=p->get(j,k)+p->get(k+1,j+i)-1-line_length;
                                                                      if(cost>=0 )//����ϲ��ɹ�
                                                                     {
                                                                                 if(weight>cost)
                                                                                          weight=cost;
                                                                      }
                                                            }
                                                             else//���򣬼���ʹ������
                                                            {
                                                                            cost=p->get(j,k)+p->get(k+1,j+i);
                                                                            if(weight>cost)
                                                                                       weight=cost;
                                                             }
                                               }
                                               p->set(j,j+i,weight);
                               }
                  }
                  for(i=0;i<size;++i)
                 {
                                for(j=0;j<size;++j)
                                            printf("%4d",p->get(i,j));
                                printf("------------------------------------------\n");
                  }
     }
      int        main(int     argc,char        *argv[])
     {
                  int            w[ 9]={2,3,6,3,8,4,5,4,5};
                  int            size=9;
                  int            line_length=10;
                  perfect_print(w,size,line_length);
                  return        0;
      }