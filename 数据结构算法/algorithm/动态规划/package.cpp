/*
  *@aim:��������
  */
  #include"CArray2D.h"
  #include<stdio.h>
   struct        CPackage
  {
               int           weight;
               int           value;
   };
 //pack[0]Ϊ���ⱳ��  
    void            package_schedule(CPackage       *pack,int    size,int   w)
   {
              CArray2D<int>           weight(size,w+1),*e;
              CArray2D<int>           trace(size,w+1),*r;
              int                                 i,j;
              
              e=&weight;
              r=&trace;
              e->fillWith(0);
              r->fillWith(0);
              for(i=1;i<size;++i)
             {
                            for(j=1;j<=w;++j)
                           {
                                        if(pack[i].weight<=j)
                                       {
//�Ƚϣ�����i�벻����i���ܹ��ɵ����Ȩֵ
                                                      int         weight=pack[i].value+e->get(i-1,j-pack[i].weight);
                                                      if(weight>e->get(i-1,j))
                                                     {
                                                                 e->set(i,j,weight);
                                                                 r->set(i,j,i);
                                                       }
                                                      else
                                                     {
                                                                 e->set(i,j, e->get(i-1,j));
//���û��ѡ�е�ǰ�ı�������ʹ�û����е����ֵ
                                                                 r->set(i,j,    r->get(i-1,j));
                                                      }
                                        }
                            }
               }
               for(i=0;i<size;++i)
              {
                            for(j=1;j<=w;++j)
                                       printf("%4d   ",e->get(i,j));
                            printf("\n");
               }
               printf("-----------------------------------------------------\n");
               for(i=0;i<size;++i)
              {
                            for(j=1;j<=w;++j)
                                       printf("%4d    ",r->get(i,j));
                            printf("\n");
               }
               printf("max  weight   is %d\n",e->get(size-1,w));
    }
    int        main(int    argc,char    *argv[])
   {
               CPackage           pack[4]={{0,0},{11,150},{10,12},{10,10}};
               int                      size=4;
               
               package_schedule(pack,size,20);
               return       0;
    }
    