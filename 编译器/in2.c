	void*   maomao
L1:				t1=(void*)0
				return  t1
L2:				
@end


		struct@Alex*   get_alex:	struct@Alex*	p,struct@Alex	alex,int[10]*	w
L1:				y=&alex[432]
L7:				t1=a+1
				t2=t1*8
				t3=424+t2
				y=&p[t3]
L6:				t4=b*40
				t5=a+b
				t6=t5*4
				t7=t4+t6
				t8=16+t7
				int		t9=alex[t8]
				t11=p+12
				int	  t10=  *t11
				a=t9*t10
L5:				t12=a+b
				t13=t12*40
				t14=a+2
				t15=t14*4
				t16=t13+t15
				t17=16+t16
				y=&p[t17]
L4:				*y=a+b
L3:				t18=p
				return  t18
L2:				
@end


		int   return_int
L1:				t2=p+16
				int[10][10]	  t1=  *t2
				p=@call		get_alex:	p  alex  t1  
L6:				t3=w+80
				t4= *t3
				t5=t4+4
				a=*t5
L5:				p[4]=0
L4:				t6=p+452
				t8=t6+108
				int	  t7=  *t8
				y=t7*x
L3:				t9=y+x
				t10=t9*8
				t11=424+t10
				t13=p+t11
				int	  t12=  *t13
				t14=t12*y
				return  t14
L2:				
@end
