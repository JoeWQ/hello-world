/**ϡ�����Ŀ���ת��*/
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
  TripleInfo*  CreateTripleInfo(int **,int rows,int columns);
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
     seed=(int)clock();
     srand(seed);
     for(i=0;i<row;++i)
       for(k=0;k<column;++k)
      {
          tmp=rand();
          key=(tmp>>16)^(tmp & 0xFFFF);
          tmp=key%64;
          mat[i][k]=tmp>=48 ? tmp:0;
       }
//........................................
     tripleA=CreateTripleInfo((int **)mat,row,column);
     if(!tripleA)
    {
        printf("����ѹ������ʧ��!\n");
        return 1;
     }
     DecodeTriple(tripleA);
     tripleB=(TripleInfo *)malloc(sizeof(TripleInfo));
     tripleB->mat=(Titple *)malloc(sizeof(Triple)*tripleA->itemNumbers);
//     tribleB->totalRows=tripleA->totalRows;
//     tripleB->totalColumns=tripleA->totalColumns;
 //    tripleB->itemNumbers=tripleA->itemNumbers;
//...................................................
     FastMatrixTranspose(tripleA,tripleB);
     DecodeTriple(tripleB);
     MatrixTrandpose(tripleA,tripleB);
     DecodeTriple(tripleB);
//�ͷ��Ѿ�������ڴ�
     free(tripleA->mat);
     free(tripleA);
     free(tripleB->mat);
     free(tripleB);
    
     return 0;
 }

  TripleInfo*  CreateTripleInfo(int **mat,int rows,int columns)
 {
     int i,k;
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
     triple=(TripleInfo *)malloc(sizeof(TripleInfo));
     triple->totalRow=rows;
     triple->totalCols=columns;
     triple->itemNumbers=items;
     triple->mat=(int *)malloc(sizeof(Triple)*items);
     value=triple->mat;
     p=(int *)mat;
     for(i=0;i<tmp;++i,++p);
    {
        if(*p)
       {
           values->value=*p;
           values->row=i/columns;
           values->col=i%rows;
           ++value;
        }
     }
     return triple;
  }
//�������ת���㷨
  void FastMatrixTrandpose(TripleInfo *atrip,TripleInfo *btrip)
 {
     int rows;
     int cloumns;
     int items;
     Triple *patriple,*pbtriple,*tmp;
     int *pos;
     int *itemCount;
     int i,m;
     
     rows=atrip->totalRows;
     columns=atrip->totalCols;
     patriple=atrip->mat;  //Ϊ�˲����ķ��㣬��ָ�뵥���г�
     pbtriple=btrip->mat;  //
     btrip->totalRows=rows;
     btrip->totalCols=columns;
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
     free(pos);
     free(itemCount);
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
     for(i=0;i<rows;++i)
    {
        pos[i]=0;
        itemCount[i]=0;
     }
//����ѹ������ÿ�еķ���Ԫ����Ŀ
     for(i=0;i<items;++i)
        ++itemCount[triple[i].row];
//����ÿ�е�һ������Ԫ�ص�������
     for(i=1;i<rows;++i)
        pos[i]=pos[i-1]+itemCount[i-1];
     
//index�����е�������m����ÿ�еĵ�һ������Ԫ�ص�������
     for(i=0,index=0;i<items;  )
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
           putchar('\n');
           continue;
        }
        else
       {
         label:
           if(count)
          {
              while(k++<triple[i].col)
                 printf("0   ");
              printf("%4d",triple[i].value);
              ++i;
              --count;
              if(!count)
             {
                 while(k++<columns)
                    printf("0   ");
              }
              goto label;
           }
           putchar('\n');
        }
  }
//ʹ��һ��ķ�������ϡ������ת��
  void MatrixTranspose(TripleInfo *atrip,TripleInfo *btrip)
 {
     Triple *patriple,*pbtriple;
     int rows,columns;
     int i,k,index;
     int items,tmp;
//...........................
     rows=atrip->totalRows;
     columns=atrip->totalCols;
     items=atrip->itemNumbers;
//����
     btrip->totalRows=rows;
     btrip->totalCols=columns;
     btrip->itemNumbers=items;
     patriple=atrip->mat;
     pbtriple=btrip->mat;
     
     for(i=0,index=0;i<rows;++i)
       for(k=0;k<items;++k)
      {
          if(patriple[k].col==i)
         {
             pbtriple[i].row=patriple[k].col;
             pbtriple[i].col=patriple[k].row;
             pbtriple[i].value=patriple[k].value;
          }
       }
  }
           