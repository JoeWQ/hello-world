//随机漫步
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define COLUMN_WALK   35
  #define ROW_WALK      40
  #define MAX_WALK_STEP 20000
//*********************************
  int judge(int (*p)[COLUMN_WALK]);
  int randWalk(int (*p)[COLUMN_WALK],int,int);
  void GetMoveStep(int (*p)[COLUMN_WALK],int *,int *);
//**********************************************
  int main(int argc,char *argv[])
 {
     int walk[ROW_WALK][COLUMN_WALK];
     int i,j;
//初始点
     int ipos,jpos;
     int seed;
     int tmp;
//...............................................
     for(i=0;i<ROW_WALK;++i)
       for(j=0;j<COLUMN_WALK;++j)
           walk[i][j]=0;
     seed=time(NULL);
     srand(seed);
     tmp=rand();
     ipos=((tmp>>16)^(tmp & 0xFFFF))%ROW_WALK;
     tmp=rand();
     jpos=((tmp>>16)^(tmp & 0xFFFF))%COLUMN_WALK;
	 printf("%d %d \n",ipos,jpos);
	 printf("----------------------------------------\n");
     tmp=randWalk(walk,ipos,jpos);
     printf("随机漫步的初始原点为(%d,%d)\n",ipos,jpos);
     printf("漫步的过程中各个点的被踩踏的次数如下所示:\n");
     for(i=0;i<ROW_WALK;++i)
    {
       for(j=0;j<COLUMN_WALK;++j)
          printf("%4d",walk[i][j]);
       putchar('\n');
     }
     if(tmp)
        printf("已经在所有点漫步!\n");
     else
        printf("很遗憾还有一些点没有被走过!\n");
     return 0;
  }
//漫步:成功返回1，否则返回0；
//walk:将要漫步的二维数组，ipos,jpos 初始漫步所在点
  int randWalk(int (*walk)[COLUMN_WALK],int ipos,int jpos)
 {
     int iinc,jinc;
     int count=0;
     int tmp=0;
	 int k=0;
//**********************************
     for(count=0;count<MAX_WALK_STEP;++count)
    {
//		printf("%d",k++);
        ++walk[ipos][jpos];
        iinc=ipos;
        jinc=jpos;
        GetMoveStep(walk,&iinc,&jinc);
        ipos+=iinc;
        jpos+=jinc;
     }
     return judge(walk);
   }
//*******************************8
  void GetMoveStep(int (*walk)[COLUMN_WALK],int *piinc,int *pjinc)
 {
     int tmp;
     int itmp=*piinc;
     int jtmp=*pjinc;
     int iinc=0,jinc=0;
     int avcount=8;
     
     tmp=rand();
     if((itmp>0 &&itmp<ROW_WALK-1) &&(jtmp>0 &&jtmp<COLUMN_WALK-1))
    {
	//	printf("111");
        tmp%=8;
        switch(tmp)
       {
           case 0:iinc=-1,jinc=1;break;
           case 1:iinc=0,jinc=1;break;
           case 2:iinc=1,jinc=1;break;
           case 3:iinc=1,jinc=0;break;
           case 4:iinc=1,jinc=-1;break;
           case 5:iinc=0,jinc=-1;break;
           case 6:iinc=-1,jinc=-1;break;
           case 7:iinc=-1,jinc=0;break;
        }
        *piinc=iinc; 
        *pjinc=jinc; 
     }
     else if(!jtmp)
    {
        if(itmp && itmp!=ROW_WALK-1)
       {
	//	  printf("222");
          tmp%=5;
          switch(tmp)
         {
            case 0:iinc=-1,jinc=0;break;
            case 1:iinc=-1,jinc=1;break;
            case 2:iinc=0,jinc=1;break;
            case 3:iinc=1;jinc=1;break;
            case 4:iinc=1;jinc=0;break;
          }
          *piinc=iinc;
          *pjinc=jinc;
        }
        else if(itmp==ROW_WALK-1)
       {
		//	printf("333");
           tmp%=3;
           switch(tmp)
          {
              case 0:iinc=-1,jinc=0;break;
              case 1:iinc=-1,jinc=1;break;
              case 2:iinc=0,jinc=1;break;
           }
           *piinc=iinc;
           *pjinc=jinc;
        }
        else
       {
		//	printf("444");
           tmp%=3;
           switch(tmp)
          {
              case 0:iinc=0;jinc=1;break;
              case 1:iinc=1;jinc=1;break;
              case 2:iinc=1;jinc=0;break;
           }
           *piinc=iinc;
           *pjinc=jinc;
        }
     }
     else if(jtmp>0 && jtmp!=COLUMN_WALK-1)
    {
        if(!itmp)
       {
		//	printf("555");
           tmp%=5;
           switch(tmp)
          {
              case 0:iinc=0,jinc=-1;break;
              case 1:iinc=1,jinc=-1;break;
              case 2:iinc=1,jinc=0;break;
              case 3:iinc=1,jinc=1;break;
              case 4:iinc=0,jinc=1;break;
           }
           *piinc=iinc;
           *pjinc=jinc;
        }
        else
       {
		//	printf("666");
           tmp%=5;
           switch(tmp)
          {
              case 0:iinc=0,jinc=-1;break;
              case 1:iinc=-1,jinc=-1;break;
              case 2:iinc=-1,jinc=0;break;
              case 3:iinc=-1,jinc=1;break;
              case 4:iinc=0;jinc=1;break;
           }
           *piinc=iinc;
           *pjinc=jinc;
        }
     }
    else
   {
       if(!itmp)
      {
		//   printf("777");
          tmp%=3;
          switch(tmp)
         {
             case 0:iinc=0,jinc=-1;break;
             case 1:iinc=1,jinc=-1;break;
             case 2:iinc=1,jinc=0;break; 
          }
          *piinc=iinc;
          *pjinc=jinc;
       }
       else if(itmp!=ROW_WALK-1)
      {
	//	   printf("888");
          tmp%=5;
          switch(tmp)
         {
             case 0:iinc=-1,jinc=0;break;
             case 1:iinc=-1,jinc=-1;break;
             case 2:iinc=0,jinc=-1;break;
             case 3:iinc=1,jinc=-1;break;
             case 4:iinc=1,jinc=0;break;
          }
          *piinc=iinc;
          *pjinc=jinc;
       }
       else
      {
	//	   printf("999");
          tmp%=3;
          switch(tmp)
         {
             case 0:iinc=-1,jinc=0;break;
             case 1:iinc=-1,jinc=-1;break;
             case 2:iinc=0,jinc=-1;break; 
          }
          *piinc=iinc;
          *pjinc=jinc;
	   }
	}
  }
//判断漫步是否成功
  int judge(int (*walk)[COLUMN_WALK])
 {
     int i,j;
     int succ=1;
     
     for(i=0;i<ROW_WALK;++i)
       for(j=0;j<COLUMN_WALK;++j)
      {
          if(!walk[i][j])
         {
             succ=0;
             goto end;
          }
       }
   end:
     return succ;
  }   
