//2012/7/25
//迷宫算法
  #include<stdio.h>
  #include<stdlib.h>
  #define  MAZE_ROW      11
  #define  MAZE_COLUMN   15
  
  typedef struct _Stack
{
//记录下的行与列
    int row;
    int col;
//记录下的方向
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
//记录一个坐标周围空间的可用情况
//将一个int进行分解row=(offset[i]>>16) & 0xFFFF; column=offset[i] & 0xFFFF
  int offset[8];
//一个坐标周围的可用方格
  int effect=8;

//为了加快检索速度，另外建立了一些快速查找表,主力里面的规律
  Stack cenOff0[8]={{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};
  Stack cenOff1[5]={{1,0},{1,1},{0,1},{-1,1},{-1,0}};
  Stack cenOff2[3]={{1,0},{1,1},{0,1}};
  Stack cenOff3[3]={{0,1},{-1,1},{-1,0}};
  Stack cenOff4[5]={{1,0},{1,1},{0,1},{0,-1},{1,-1}};
  Stack cenOff5[5]={{0,1},{-1,1},{-1,0},{-1,-1},{0,-1}};
  Stack cenOff6[5]={{1,0},{-1,0},{-1,-1},{0,-1},{1,-1}};
  Stack cenOff7[3]={{1,0},{0,-1},{1,-1}};
//严格来说，下面的数组是无用的，为了整齐美观，所以就添加上了
  Stack cenOff8[3]={{-1,0},{-1,-1},{0,-1}};

//创建和栈相关的函数
  StackInfo *CreateStack(int (*p)[MAZE_COLUMN],int row);
//判断栈是否为空
  int isStackEmpty(StackInfo *);
//将给定的元素入栈
  void push(StackInfo *,Stack *);
//从栈中探出栈顶元素
  void pop(StackInfo *,Stack *);
  int mazePath(int (*p)[MAZE_COLUMN],int row,StackInfo *);
//展示迷宫的已经计算出的路径,(迷宫的行与列)
  void mazeTrace(StackInfo *,int,int);
//判断下一步要走的路径
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
    printf("开始对迷宫进行求解\n");
    found=mazePath(maze,MAZE_ROW,info);
	printf("计算完毕!\n");
    if(found)
   {
       printf("关于迷宫的求解情况如下所示:\n");
       mazeTrace(info,MAZE_ROW,MAZE_COLUMN);
    }
	else
		printf("很遗憾，您给出的迷宫图没有解!\n");
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
//求迷宫中的可用房间的数目(元素为零的数目)
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
//初始化栈
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
           printf("栈溢出错误!\n");
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
//初始化变量
     items=info->actSize;
     elems=info->ary;
//对申请的空间进行清零
     for(tmp=p,i=0;i<multiple;++i,++tmp)
        *tmp=0;
//先初始化已经找到的路径
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
//对迷宫寻找可以通过的路径
  int mazePath(int (*maze)[MAZE_COLUMN],int row,StackInfo *info)
 {
     Stack stack;
     int found;
     int nextRow,nextCol;
     int endRow,endCol;
//记录当前未知的变量
     int num=0;
//如果入口处不为0，失败      
     if(maze[0][0])
	 {
		 printf("迷宫没有入口，失败！\n");
         return 0;
	 }
//初始化各个变量
     stack.row=0;
     stack.col=0;
     found=0;
     endRow=row-1;
     endCol=MAZE_COLUMN-1;
     push(info,&stack);
	 mark[0][0]=1;
//	 printf("&&&&&&&&&&&&&&&&&&&&&&&\n");
//***开始进入循环
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
//如果在当前的位置能够判断下一步可以走，就再次将已经弹出的元素入栈
		       printf("row:%d col:%d   \n",nextRow,nextCol);
               push(info,&stack);
               stack.row=nextRow;
               stack.col=nextCol;
               push(info,&stack);
//标记,位置(nextRow,nextCol)已经被走过
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
//计算下一步的位置,注意，在这个函数中不能改变stack所指向空间的值
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
//在整个迷宫中，所有的位置的坐落情况共分为9种
//   543
//   6*2
//   701
//一个给定坐标周围情况先后被统计的优先级如上所示
      effect=0;
      if((crow>0 && crow<row-1) && (rcol>0 && rcol<column-1))  //cenOff0数组
     {
           num=8;
           cenOff=cenOff0;
      }
      else if(!rcol)  
     {
          if(crow>0 && crow<row-1)//cenOff1数组
         {
               num=5;
               cenOff=cenOff1;
           }
          else if(!crow)  //cenOff2数组
         {
               num=3;
               cenOff=cenOff2;
          }
          else            //数组3
         {
               num=3;
               cenOff=cenOff3;
          }
      }
      else if(rcol<column-1)
     {
          if(!crow)       //数组4
         {
              num=5;
              cenOff=cenOff4;
          }
          else            //数组5
         {
              num=5;
              cenOff=cenOff5;
          }
      }
      else
     {
          if(crow>0  && crow<row-1)//数组6
         {
              num=5;
              cenOff=cenOff6;
          }
          else if(!crow)          //数组7
         {
              num=3;
              cenOff=cenOff7;
          }
          else                    //数组8
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
			