//2012/7/25
//�Թ��㷨
  #include<stdio.h>
  #include<stdlib.h>
  #define  MAZE_ROW      11
  #define  MAZE_COLUMN   15
  
  typedef struct _Stack
{
//��¼�µ�������
    int row;
    int col;
//��¼�µķ���
 //   int dirc;
}Stack;
  typedef struct _STACKInfo
{
    int actSize;
    int maxSize;
    int top;
    Stack *ary;
  }StackInfo;
  int maze[MAZE_ROW][MAZE_COLUMN]={ {0,1,0,0,0,1,1,0,0,0,1,1,1,1,1},
                                    {1,0,0,0,1,1,0,1,1,1,0,0,1,1,1},
                                    {0,1,1,0,0,0,0,1,1,1,1,0,0,1,1},
                                    {1,1,0,1,1,1,1,0,1,1,0,1,1,0,0},
                                    {1,1,0,1,0,0,1,0,1,0,1,1,1,1,1},
                                    {0,0,1,1,0,1,1,1,0,1,0,1,1,1,0},
                                    {0,1,1,1,1,0,0,1,1,0,1,1,1,1,1},
                                    {0,0,1,1,0,1,1,1,0,1,0,0,1,0,1},
                                    {1,1,0,0,0,1,1,0,1,1,0,0,0,0,0},
                                    {0,0,1,1,1,1,1,0,0,0,1,1,1,1,0},
                                    {0,1,0,0,1,1,1,1,1,0,1,1,1,1,0},
                                    };
  int mark[MAZE_ROW][MAZE_COLUMN];
//��¼һ��������Χ�ռ�Ŀ������
//��һ��int���зֽ�row=(offset[i]>>16) & 0xFFFF; column=offset[i] & 0xFFFF
  int offset[8];
//һ��������Χ�Ŀ��÷���
  int effect=8;

//Ϊ�˼ӿ�����ٶȣ����⽨����һЩ���ٲ��ұ�,��������Ĺ���
  Stack cenOff0[8]={{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};
  Stack cenOff1[5]={{1,0},{1,1},{0,1},{-1,1},{-1,0}};
  Stack cenOff2[3]={{1,0},{1,1},{0,1}};
  Stack cenOff3[3]={{0,1},{-1,1},{-1,0}};
  Stack cenOff4[5]={{1,0},{1,1},{0,1},{0,-1},{1,-1}};
  Stack cenOff5[5]={{0,1},{-1,1},{-1,0},{-1,-1},{0,-1}};
  Stack cenOff6[5]={{1,0},{-1,0},{-1,-1},{0,-1},{1,-1}};
  Stack cenOff7[3]={{1,0},{0,-1},{1,-1}};
//�ϸ���˵����������������õģ�Ϊ���������ۣ����Ծ��������
  Stack cenOff8[3]={{-1,0},{-1,-1},{0,-1}};

//������ջ��صĺ���
  StackInfo *CreateStack(int (*p)[MAZE_COLUMN],int row);
//�ж�ջ�Ƿ�Ϊ��
  int isStackEmpty(StackInfo *);
//��������Ԫ����ջ
  void push(StackInfo *,Stack *);
//��ջ��̽��ջ��Ԫ��
  void pop(StackInfo *,Stack *);
  int mazePath(int (*p)[MAZE_COLUMN],int row,StackInfo *);
//չʾ�Թ����Ѿ��������·��,(�Թ���������)
  void mazeTrace(StackInfo *,int,int);
//�ж���һ��Ҫ�ߵ�·��
  void judgePath(int (*p)[MAZE_COLUMN],int,Stack *);
  void easyPath(int (*p)[MAZE_COLUMN],int);
//****************************************************************************
  int main(int argc,char *argv[])
 {
    StackInfo  *info;
    int found=0;
	int i,j;
    info=CreateStack(maze,MAZE_ROW);
    for(i=0;i<MAZE_ROW;++i)
		for(j=0;j<MAZE_COLUMN;++j)
			mark[i][j]=0;
    printf("��ʼ���Թ��������\n");
    found=mazePath(maze,MAZE_ROW,info);
	printf("�������!\n");
    if(found)
   {
       printf("�����Թ���������������ʾ:\n");
       mazeTrace(info,MAZE_ROW,MAZE_COLUMN);
    }
	else
		printf("���ź������������Թ�ͼû�н�!\n");
//	easyPath(mark,MAZE_ROW);
    free(info->ary);
    free(info);
    return 0;
  }
//**************************************************
  StackInfo  *CreateStack(int (*maze)[MAZE_COLUMN],int mazeRow)
 {
     int i,j;
     int nzero=0;
     StackInfo *info;
//���Թ��еĿ��÷������Ŀ(Ԫ��Ϊ�����Ŀ)
     for(i=0;i<mazeRow;++i)
       for(j=0;j<MAZE_COLUMN;++j)
	   {
		   if(!maze[i][j])
           ++nzero;
	   }
	 printf("%d\n",nzero);
     if(!nzero)
        return NULL;
     info=(StackInfo *)malloc(sizeof(StackInfo));
     info->ary=(Stack *)malloc(sizeof(Stack)*nzero);
//��ʼ��ջ
     info->actSize=0;
     info->maxSize=nzero;
     info->top=0;
     return info;
  }
//*****************************************************************
  int isStackEmpty(StackInfo *info)
 {
    return !info->actSize;
  }
//******************************************************************
  void push(StackInfo *info,Stack *elem)
 {	   
//	  printf("@");
     if(elem && info)
    {
       if(info->actSize<info->maxSize)
      {
           info->ary[info->top].row=elem->row;
           info->ary[info->top].col=elem->col;
      //     info->ary[top].dirc=elem->dirc;
           ++info->actSize;
           ++info->top;
       }
       else
      {
           printf("ջ�������!\n");
       }
     }
  }
//*****************************************************
  void pop(StackInfo *info,Stack *elem)
 {
      int index=0;
      if(info && elem)
     {
          if(info->actSize)
         {
              index=--info->top;
              elem->row=info->ary[index].row;
              elem->col=info->ary[index].col;
//              elem->dirc=info->stack[index].dirc;
              --info->actSize;
           }
      }
  }
//**********************************************************
  void mazeTrace(StackInfo *info,int row,int column)
 {
     char *p,*tmp;
     Stack *elems;
     int i,k,multiple;
     int items;

     multiple=row*column;
     p=(char *)malloc(multiple);
//��ʼ������
     items=info->actSize;
     elems=info->ary;
//������Ŀռ��������
     for(tmp=p,i=0;i<multiple;++i,++tmp)
        *tmp=0;
//�ȳ�ʼ���Ѿ��ҵ���·��
     for(tmp=p,i=0;i<items;++i,++elems)
        tmp[elems->row*column+elems->col]='*';

     for(tmp=p,i=0,k=0;i<multiple;++tmp,++i)
    {
        if(*tmp)
       {
           printf("* ");
        }
        else
           printf("o ");
        if(++k==column)
		{
           putchar('\n');
		   k=0;
		}
     }
	 free(p);
  }
//���Թ�Ѱ�ҿ���ͨ����·��
  int mazePath(int (*maze)[MAZE_COLUMN],int row,StackInfo *info)
 {
     Stack stack;
     int found;
     int nextRow,nextCol;
     int endRow,endCol;
//��¼��ǰδ֪�ı���
     int num=0;
//�����ڴ���Ϊ0��ʧ��      
     if(maze[0][0])
	 {
		 printf("�Թ�û����ڣ�ʧ�ܣ�\n");
         return 0;
	 }
//��ʼ����������
     stack.row=0;
     stack.col=0;
     found=0;
     endRow=row-1;
     endCol=MAZE_COLUMN-1;
     push(info,&stack);
	 mark[0][0]=1;
//	 printf("&&&&&&&&&&&&&&&&&&&&&&&\n");
//***��ʼ����ѭ��
     while(!isStackEmpty(info))
    {
//		printf("*");
        pop(info,&stack);
        judgePath(maze,row,&stack);
        num=0;
        while(num<effect)
       { 
           nextRow=(offset[num]>>16) & 0xFFFF;
           nextCol=offset[num] & 0xFFFF;
           if(!maze[nextRow][nextCol] )
          {
//����ڵ�ǰ��λ���ܹ��ж���һ�������ߣ����ٴν��Ѿ�������Ԫ����ջ
		       printf("row:%d col:%d   \n",nextRow,nextCol);
               push(info,&stack);
               stack.row=nextRow;
               stack.col=nextCol;
               push(info,&stack);
//���,λ��(nextRow,nextCol)�Ѿ����߹�
               mark[nextRow][nextCol]=1;
			   break;
           }
           else if(nextRow==endRow && nextCol==endCol)
          {
               push(info,&stack);
               stack.row=endRow;
               stack.col=endCol;
               push(info,&stack);
               found=1;
               goto end;
           }
           else
               ++num;
       }
    }
end:
    if(found)
      return 1;
    return 0;
  }
//**********************************************************
//������һ����λ��,ע�⣬����������в��ܸı�stack��ָ��ռ��ֵ
   void  judgePath(int (*maze)[MAZE_COLUMN],int row,Stack *stack)
  {
      int crow,rcol;
      int num=0;
      int column=MAZE_COLUMN;
//      int tmp=0x80000000;
      int i=0,k=0;
      int rtmp,ctmp;
      Stack *cenOff=NULL;
      crow=stack->row;
      rcol=stack->col;
//�������Թ��У����е�λ�õ������������Ϊ9��
//   543
//   6*2
//   701
//һ������������Χ����Ⱥ�ͳ�Ƶ����ȼ�������ʾ
      effect=0;
      if((crow>0 && crow<row-1) && (rcol>0 && rcol<column-1))  //cenOff0����
     {
           num=8;
           cenOff=cenOff0;
      }
      else if(!rcol)  
     {
          if(crow>0 && crow<row-1)//cenOff1����
         {
               num=5;
               cenOff=cenOff1;
           }
          else if(!crow)  //cenOff2����
         {
               num=3;
               cenOff=cenOff2;
          }
          else            //����3
         {
               num=3;
               cenOff=cenOff3;
          }
      }
      else if(rcol<column-1)
     {
          if(!crow)       //����4
         {
              num=5;
              cenOff=cenOff4;
          }
          else            //����5
         {
              num=5;
              cenOff=cenOff5;
          }
      }
      else
     {
          if(crow>0  && crow<row-1)//����6
         {
              num=5;
              cenOff=cenOff6;
          }
          else if(!crow)          //����7
         {
              num=3;
              cenOff=cenOff7;
          }
          else                    //����8
         {
              num=3;
              cenOff=cenOff8;
          }
       }
       for(i=0;i<num;++i)
      {
          rtmp=cenOff[i].row+crow;
          ctmp=cenOff[i].col+rcol;
          if(!maze[rtmp][ctmp] && !mark[rtmp][ctmp])
         {
             ++effect;
             offset[k]=(rtmp<<16) | (ctmp & 0xFFFF);
             ++k;
          }
       }
  }
   void easyPath(int (*mark)[MAZE_COLUMN],int row)
   {
	   int i,j;
	   for(i=0;i<row;++i)
	   {
		   for(j=0;j<MAZE_COLUMN;++j)
		   {
			   if(!mark[i][j])
				   printf("* ");
			   else
				   printf("O ");
		   }
		   putchar('\n');
	   }
   }
			