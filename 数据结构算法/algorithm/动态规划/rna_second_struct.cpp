/*
  *@aim:RNA二级结构
  *@date:2015-5-26
  */
  #include"CArray2D.h"
  #include<stdio.h>
  enum     RNAType
 {
             RNATypeA=0,
             RNATypeU=1,
             RNATypeC=2,
             RNATypeG=3,
             RNATypeNone=4,
             RNATypeNum
  };
  //每一种rna的对应类型A-U,C-G
  static      const  RNAType  rna_map[5]={RNATypeU,RNATypeA,RNATypeG,RNATypeC,RNATypeNone};
//@param:rna RNA序列，size长度  
//@request:size>=6
    int             rna_secondary_structure(RNAType         *rna,int       size)
   {
//rna螺旋结构的最大匹配记录
              CArray2D<int>         record(size,size);
              CArray2D<int>         *r=&record;
//rna的螺旋踪迹              
              CArray2D<int>                    rna_spiral_trace(size,size);
              CArray2D<int>                    *trace=&rna_spiral_trace;
              
              int                                         i,j,k;
              
              r->fillWith(0);
              trace->fillWith(-1);
//从长度6开始
              for(i=5;i<size;++i)
             {
                             for(j=1;j<size-i;++j)
                            {
//rna二级螺旋结构的最短 间隔是4                
                                           int               max=-1;
                                           int               index=-1;            
                                           for(k=j;k<j+i-4;++k)
                                          {
//检测是否类型匹配
                                                         int        weight=0;
                                                         int        other=-1;
                                                         if(rna_map[ rna[k]] == rna[j+i])//如果匹配
                                                        {
                                                                      weight=r->get(j,k-1)+r->get(k+1,j+i-1)+1;
                                                                      other=k;
                                                         }
                                                         else
                                                                      weight=r->get(j,j+i-1);
                                                         if(max<weight)
                                                        {
                                                                      max=weight;
                                                                      index=k;
                                                         }
                                           }
                                           r->set(j,j+i,max);
                                           trace->set(j,j+i,index);
                             }
              }
              for(i=0;i<size;++i)
             {
                            for(j=0;j<size;++j)
                                         printf("%4d",r->get(i,j));
                            printf("\n");
              }
              printf("------------------------------------\n");
              for(i=0;i<size;++i)
             {
                             for(j=0;j<size;++j)
                                         printf("%4d",trace->get(i,j));
                             printf("\n");
              }
              printf("max pair is %d\n",r->get(1,size-1));
              return    r->get(1,size-1);
    }
      int        main(int    argc,char    *argv[])
     {
              RNAType             rna[16]={
                                                             RNATypeNone,
                                                             RNATypeA,RNATypeC,RNATypeA,RNATypeU,
                                                             RNATypeG,RNATypeA,RNATypeU,RNATypeG,
                                                             RNATypeG,RNATypeC,RNATypeC,RNATypeA,
                                                             RNATypeU,RNATypeG,RNATypeU
                                                       };
              int                         size=16;
              rna_secondary_structure(rna,size);
              return      0;
      }