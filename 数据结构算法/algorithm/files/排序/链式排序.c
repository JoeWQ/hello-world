//将已经排好序的链式大结构物理排序
  #include<stdio.h>
  #include<stdlib.h>
  #define  ARRAY_SIZE   10
  
  typedef  struct  _List
 {
     int  key;
     int  link;
  }List;

  List  list[ARRAY_SIZE]={{26,8},{5,5},{77,-1},{1,1},{61,2},
                          {11,7},{59,4},{15,9},{48,6},{19,0}};
  
  void  list_sort(List  *list,int nsize);

  int  main(int argc,char *argv[])
 {
      int  i;
      printf("排序前的列表内容为:\n");
      for(i=0;i<ARRAY_SIZE;++i)
          printf("Key:%d ,Link:%d \n",list[i].key,list[i].link);
      putchar('\n');

      printf("对已经排好序的链表进行物理排序!\n");
      list_sort(list,ARRAY_SIZE,3);
      for(i=0;i<ARRAY_SIZE;++i)
          printf("Key:%d,Link%d\n",list[i].key,list[i].link);
      putchar('\n');

      return 0;
  }
//链式排序
  void  list_sort(List  *list,int nsize,int start)
 {
      int  i,cur,next;
      int  tmp=nsize-1;
      List  elem;
      for(i=0;i<tmp;++i)
     {
          while(start<i)
            start=list[start].link;
          next=list[start].link;

          if(start!=i)
         {
              elem=list[i];
              list[i]=list[start];
              list[start]=elem;
              list[i].link=start;
          }
          start=next;
      }
  }
 