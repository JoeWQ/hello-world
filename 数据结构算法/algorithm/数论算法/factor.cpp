/*
  *@aim:�������������ֽ�
  *@date:2015-6-16
  */
  #include<stdio.h>
  #include<math.h>
  //�κ�һ������1�����������Էֽ�Ϊn= p1^e1 * p2^e2 * p3*e3 ......pn^en
  //����piΪ����,eiΪ����
  //final_size���طֽ��������ָ��
  void            factor_decompose(int      integer,int    *factor,int    *e,int   *final_size)
 {
                 int           d;
                 int           now;
                 int           size=0;;
                 int           wa;
                 
                 int            k=(int)sqrt(integer)+1;
                 for(d=2;d<k;++d)
                {
                             if(  integer%d == 0  )
                            {
                                           factor[size]=d;
                                           e[size]=0;
                                           while(  integer%d ==0 )
                                          {
                                                        ++e[size];
                                                        integer/=d;
                                           }
                                           ++size;
                                           if(integer == 1)
                                                 break;
                             }
                 }
                 if(integer != 1)
                {
                              factor[size]=integer;
                              e[size]=1;
                              ++size;
                 }
                 *final_size=size;
  } 
 //
    int        main(int    argc,char   *argv[])
   {
                int                     factor[64];
                int                     e[64];
                int                     size=64;
                int                     final_size;
                
                int                    i;
                factor_decompose(64,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(81,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(95,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");
                
                factor_decompose(105,factor,e,&final_size);
                for(i=0;i<final_size;++i)
                    printf("%d ^ %d     ",factor[i],e[i]);
                printf("\n");                
                return      0;
    }