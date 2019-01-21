//**ϡ�����Ŀ���ת��
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  typedef struct _Triple
 {
     int row;
     int col;
     int value;
 }Triple;
  typedef struct _TripleInfo
 {
     int totalRows;
     int totalCols;
     int itemNumbers;
     Triple *mat;
  }TripleInfo;
//********************************************
//����һ��ѹ���ľ���
  TripleInfo  *CreateTripleInfo(int **mat,int rows,int columns);
//��ѹ���ľ�����п���ת��
  void FastMatrixTranspose(TripleInfo *,TripleInfo *);
//��ѹ���ľ������һ���ת��
  void MatrixTranspose(TripleInfo *,TripleInfo *);
//��ѹ���ľ�����н���(���)
  void DecodeTriple(TripleInfo *);
 
//**********************************************
  int main(int argc,char *argv[])
 {
     int mat[5][6];
     int row=5;
     int column=6;
     int seed;
     int i,k;
     int tmp,key;
     TripleInfo *tripleA;
     TripleInfo *tripleB;
//�Ծ����������ĳ�ʼ��,����ϡ�����
     seed=(int)time(NULL);
     srand(seed);
	   printf("seed:%u \n",seed);
     for(i=0;i<row;++i)
       for(k=0;k<column;++k)
      {
          tmp=rand();
          key=(tmp>>16)^(tmp & 0xFFFF);
          tmp=key&0x3F;
          mat[i][k]=(tmp>=48)? tmp:0;
	//	  printf("%d  ",mat[i][k]);
       }
	  printf("�������������Ϊ:\n");
	  for(i=0;i<row;++i)
	  {
		  for(k=0;k<column;++k)
			  printf("%4d",mat[i][k]);
		  putchar('\n');
	  }

//........................................
     tripleA=CreateTripleInfo((int **)mat,row,column);
	 printf("����ѹ�����!\n");
     if(!tripleA)
    {
        printf("����ѹ������ʧ��!\n");
        return 1;
     }
	 printf("��ʼ�����ɵ�ѹ���������!\n");
     DecodeTriple(tripleA);
	 printf("�������!\n");
     tripleB=(TripleInfo *)malloc(sizeof(TripleInfo));
     tripleB->mat=(Triple *)malloc(sizeof(Triple)*tripleA->itemNumbers);
//     tribleB->totalRows=tripleA->totalRows;
//     tripleB->totalColumns=tripleA->totalColumns;
 //    tripleB->itemNumbers=tripleA->itemNumbers;
//...................................................
     FastMatrixTranspose(tripleA,tripleB);
	 printf("����ת��֮���ϡ��������!\n");
     DecodeTriple(tripleB);
     MatrixTranspose(tripleA,tripleB);
	 printf("��һ�㷽���ӽ�����Ľ���!\n");
	 DecodeTriple(tripleB);
//�ͷ��Ѿ�������ڴ�
     free(tripleA->mat);
     free(tripleA);
     free(tripleB->mat);
     free(tripleB);
    
     return 0;
 }

  TripleInfo *CreateTripleInfo(int **mat,int rows,int columns)
 {
     int i;
     int tmp;
     TripleInfo *triple;
     int *p;
     Triple *values;
     int items;

     items=0;
     p=(int *)mat;
     tmp=rows*columns;
     for(i=0;i<tmp;++i,++p)
    {
       if(*p)
         ++items;
     }
	// printf("iteems:%d ",items);
     triple=(TripleInfo *)malloc(sizeof(TripleInfo));
     triple->totalRows=rows;
     triple->totalCols=columns;
     triple->itemNumbers=items;
     triple->mat=(Triple *)malloc(sizeof(Triple)*items);
     values=triple->mat;
     p=(int *)mat;
     for(i=0;i<tmp;++i,++p)
    {
        if(*p)
       {
           values->value=*p;
           values->row=i/columns;
           values->col=i%columns;
	//	   printf("row:%d ,col:%d,value:%d \n",values->row,values->col,values->value);
           ++values;
        }
     }
     return triple;
  }
//�������ת���㷨
  void FastMatrixTranspose(TripleInfo *atrip,TripleInfo *btrip)
 {
     int rows;
     int columns;
     int items;
     Triple *patriple,*pbtriple;
     int *pos;
     int *itemCount;
     int i,m;
     
     rows=atrip->totalRows;
     columns=atrip->totalCols;
     patriple=atrip->mat;  //Ϊ�˲����ķ��㣬��ָ�뵥���г�
     pbtriple=btrip->mat;  //
     btrip->totalRows=columns;
     btrip->totalCols=rows;
	 items=atrip->itemNumbers;
	 btrip->itemNumbers=items;
//....����Դѹ������ĸ��е���Ŀ
     itemCount=(int *)malloc(sizeof(int)*columns);
           pos=(int *)malloc(sizeof(int)*columns);
     for(i=0;i<columns;++i)
    {
        itemCount[i]=0;
        pos[i]=0;
     }
       
     for(i=0;i<items;++i)
        ++itemCount[patriple[i].col];
     for(i=1;i<columns;++i)
        pos[i]=itemCount[i-1]+pos[i-1];
//��ʼת��
     for(i=0;i<items;++i)
    {
       m=pos[patriple[i].col]++;
       pbtriple[m].row=patriple[i].col;
       pbtriple[m].col=patriple[i].row;
       pbtriple[m].value=patriple[i].value;
     }
  }
//��ѹ���ľ�����н���
  void DecodeTriple(TripleInfo *ptripleInfo)
 {
     Triple *triple=ptripleInfo->mat;
     int rows=ptripleInfo->totalRows;
     int columns=ptripleInfo->totalCols;
     int items=ptripleInfo->itemNumbers;
     int *pos;
     int *itemCount;
     int i,k,count,m;
     int index;
//����ѹ������������Ϣ
     pos=(int *)malloc(sizeof(int)*rows);
     itemCount=(int *)malloc(sizeof(int)*rows);
	 if(!pos || !itemCount)
	 {
		 printf("����ռ�ʧ��!\n");
		 exit(1);
	 }
     for(i=0;i<rows;++i)
    {
        pos[i]=0;
        itemCount[i]=0;
     }
//����ѹ������ÿ�еķ���Ԫ����
     for(i=0;i<items;++i)
	 {
	//	 printf("%d  ",triple[i].row);
        ++itemCount[triple[i].row];
	 }
//����ÿ�е�һ������Ԫ�ص�������

     for(i=1;i<rows;++i)
        pos[i]=pos[i-1]+itemCount[i-1];
//index�����е�������m����ÿ�еĵ�һ������Ԫ�ص�������
     for(i=0,index=0;i<items || index<rows;  )
    {
        k=0;
        count=itemCount[index];
        m=pos[index];
        if(!count)
       {
           while(k<columns)
          {
              printf("0   ");
              ++k;
           }
		   ++index;
           putchar('\n');
           continue;
        }
        else
       {
         label:
           if(count)
          {
              while(k<triple[i].col)
			  {
                 printf("0   ");
				 if(k>=triple[i].col)
					 break;
				 ++k;
			  }
              printf("%-4d",triple[i].value);
			  ++k;
              ++i;
              --count;
              if(!count)
             {
                 while(k<columns)
				 {
                    printf("0   ");
					++k;
				 }
              }
              goto label;
           }
		   ++index;
           putchar('\n');
        }
	 }
	 free(itemCount);
	 free(pos);
  }
//ʹ��һ��ķ�������ϡ������ת��
  void MatrixTranspose(TripleInfo *atrip,TripleInfo *btrip)
 {
     Triple *patriple,*pbtriple;
     int rows,columns;
     int i,k,index;
     int items;
//...........................
     rows=atrip->totalRows;
     columns=atrip->totalCols;
     items=atrip->itemNumbers;
//����
     btrip->totalRows=columns;
     btrip->totalCols=rows;
     btrip->itemNumbers=items;
     patriple=atrip->mat;
     pbtriple=btrip->mat;
     
     for(i=0,index=0;i<columns;++i)
       for(k=0;k<items;++k)
      {
          if(patriple[k].col==i)
         {
             pbtriple[index].row=patriple[k].col;
             pbtriple[index].col=patriple[k].row;
             pbtriple[index].value=patriple[k].value;
			 ++index;
          }
       }
  }
           