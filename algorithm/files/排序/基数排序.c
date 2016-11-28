//基数排序
  #include<stdio.h>
  #include<stdlib.h>
  #define  ARRAY_SIZE   9
  #define  SEED_T       0x1000
  #define  RADIX_SIZE   3
  #define  MAX_DIGIT    10

  typedef  struct  _Radix
 {
     int      key[RADIX_SIZE];
     struct   _Radix   *next;
  }Radix;

  Radix  **radix_sort(Radix  *,int);
  Radix   radix[ARRAY_SIZE];

  int  main(int  argc,char  *argv[])
 {
      int  i,k;
      Radix   **pr;
      printf("将随机数种子初始化!\n");
      srand(SEED_T);
      printf("使用随机数给基数结构初始化!\n");
      for(i=0;i<ARRAY_SIZE;++i)
     {
          radix[i].next=NULL;
          for(k=0;k<RADIX_SIZE;++k)
              radix[i].key[k]=rand()%MAX_DIGIT;
      }
      printf("结构的内容如下:\n");
      for(i=0;i<ARRAY_SIZE;++i)
     {
         printf("%d%d%d\n",radix[i].key[0],radix[i].key[1],radix[i].key[2]);
//              putchar('\n');
      }
      printf("\n排序后的内容如下所示:\n");
      pr=radix_sort(radix,ARRAY_SIZE);
     for(i=0;i<ARRAY_SIZE;++i)
    {
         printf("%d%d%d \n",pr[i]->key[0],pr[i]->key[1],pr[i]->key[2]);
     }
     free(pr);
     return  0;
  }
//基数排序算法
  Radix  **radix_sort(Radix  *radix,int nsize)
 {
      int i,k,j;
      Radix  **front,**rear,**tmp,*pr;
      front=(Radix **)malloc(sizeof(Radix *)*MAX_DIGIT);
      rear=(Radix **)malloc(sizeof(Radix *)*MAX_DIGIT);
      tmp=(Radix **)malloc(sizeof(Radix *)*nsize);
    
      for(i=0;i<nsize;++i,++radix)
         tmp[i]=radix;
      for(i=RADIX_SIZE-1;i>=0;--i)
     {
          for(k=0;k<MAX_DIGIT;++k)
		     {
              front[k]=NULL;
			        rear[k]=NULL;
		      }
          for(j=0;j<nsize;++j)
         {
              k=tmp[j]->key[i];
              if(front[k])
                 rear[k]->next=tmp[j];
              else
                 front[k]=tmp[j];
              rear[k]=tmp[j];
              rear[k]->next=NULL;
          }
          for(j=0,k=0;k<MAX_DIGIT;++k) 
         {
              pr=front[k];
              while(pr)
             {
                 tmp[j++]=pr;
                 pr=pr->next;
              }
          }         
      }
      free(front);
      free(rear);
      return tmp;
  }