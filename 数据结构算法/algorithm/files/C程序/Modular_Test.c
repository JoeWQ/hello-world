//2013年3月27日18:40:47
//在模运算中，余数始终与被除数保持一致

  #include<stdio.h>
 
  int  main(int  arc,char  *argv[])
 {
	 int  a=6,b=-5;
	 int  c=-6,d=5;
	 int  e=-6,f=-5;

	 printf("%d mod %d =%d \n",a,b,a%b);
	 printf("%d mod %d =%d \n",c,d,c%d);
	 printf("%d mod %d =%d \n",e,f,e%f);

	 return 0;

 }