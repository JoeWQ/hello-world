/*
  *@aim:0-1��������
  *@idea:��̬�滮
  *@date:2014-11-13 10:09:53
  *@author:�ҽ���
  */
  #include"Array.h"
  #include<stdio.h>
//��Ʒ�������ͼ�ֵ
  struct     CPackage
 {
//��Ʒ������
           int     weight;
//��Ʒ�ļ�ֵ
           int     value;
  };
/*
  *@function:package01
  *@aim:�������ŵ���Ʒ����ϣ���ʹ����w���������޶���Χ�ڣ����õ�����Ʒ�ļ�ֵ֮�����
  *@param:pack��Ʒ����
  *@param:w��ǰ�������޶�������ǰ���õ�����Ʒ������֮�Ͳ��ܴ���w
  *@param:y��¼ѡ����Ʒi�벻ѡ����Ʒi���ܵõ�������ֵ
  *@param:r��¼�ڵõ������ֵ����ѡ�����Ʒ����
  */
// y->row=sizze+1,y->column=w+1
  void     package01(CPackage     *pack,int   size,int   w,Array    *y,Array    *r)
 {
           int      i,m,j;
           int      e;
//��ʼ��Ե�����ݶ�����Ϊ0
           for(i=1;i<=size;++i)
          { 
                    for(m=1;m<=w;++m)
                   {
                             if(  pack[i].weight > m )
                            {
                                      y->set(i,w, y->get(i-1,m) );
                                      r->set(i,w,r->get(i-1,m));
                             }
                             else
                            {
//��װ�ر���i�Ͳ�װ�ر���i�ǵ�������Ƚ�
                                      e= y->get(i-1,m-pack[i].weight) +pack[i].value;
                                      if(  e < y->get(i-1,m) )
                                     {
                                                y->set(i,m, y->get(i,m-1) );
                                                r->set(i,m, r->get(i,m-1) );
                                      }
                                      else
                                     {
                                                y->set(i,m,e);
                                                r->set(i,m,i);
                                      }
                            }
                    }
           }              
  }
//****************************************************************************
   int    main(int    argc,char   *argv[] )
  {
//Ϊ�˼�����������Ѷ�������������            
           struct    CPackage    pack[4]={ {0,0},{10,60}, {20,100},{30,120} };     
           int          size=3;
           int          w=50;//����
//
//           Array      weight(size+1,w+1);
           Array      value(size+1,w+1);
           Array      record(size+1,w+1);
//
          Array       *y=&value,*r=&record;
//��ʼ
          y->fillWith(0);
 //         x->fillWith(0);
          r->fillWith(0);
//
           package01(pack,size,w,y,r);
//
           int    i=0,j=0;
 //          printf("----------------------------weight---------------------");
 //          for(i=1;i<=size;++i)
 //         {
 //                     for(j=1;j<=w;++j)
     //                         printf("%4d",y->get(i,j));
  //                    printf("\n");
    //      }
           printf("----------------------------value---------------------\n");
           for(i=1;i<=size;++i)
          {
                      for(j=1;j<=w;++j)
                              printf("%4d",y->get(i,j));
                      printf("\n\n");
          }
           printf("----------------------------record---------------------\n");
           for(i=1;i<=size;++i)
          {
                      for(j=1;j<=w;++j)
                              printf("%4d",r->get(i,j));
                      printf("\n\n");
          }
          
   }
