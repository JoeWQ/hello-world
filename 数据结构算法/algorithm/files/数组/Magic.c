//**ħ����
  #include<stdio.h>
  #include<stdlib.h>
  int main(int argc,char *argv[])
 {
     int column;
     int row;
     int i,j;
     int size;
     int tmp;
     int *array,*p;
     int count;
     int vsize;
     printf("Please input the size of  magic cubic,and it must be a odd!\n");
     scanf("%d",&size);
//�������Ϊ����
     if(size<=0 || !(size&1))
    {
        printf("�������Ϊ����!\n");
        return 1;
     }
     tmp=size*size;
     vsize=size-1;
     array=(int *)malloc(tmp);
     if(!array)
    {
        printf("�ڴ�����ʧ��!\n");
        return 2;
     }
     j=(size-1)>>1;
//���������������
     for(i=0,p=array;i<tmp;++i,++p)
        *p=0;
	 *(array+j)=1;
//............................................
     for(i=0,count=2;count<=tmp;++count)
    {
        row=(i-1)>=0 ? (i-1):vsize;
        column=(j-1)>=0 ? (j-1):vsize;
        if(*(array+row*size+column))
       {
           i=(i+1)%size;
        }
        else
       {
           i=row;
           j=column;
        }
        *(array+i*size+j)=count;
      }
//�Լ���õ���ħ������д�ӡ���
	 p=array;
      for(i=0;i<size;++i)
     {
        for(j=0;j<size;++j,++p)
           printf("%4d",*p);
        putchar('\n');
      }  
     return 0;
  }