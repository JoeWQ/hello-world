	int			number
	int			count,	saiker
	float			sum
	char			sank
	int			dsal
	struct@Alex*   get_alex:	struct@Alex*	p,struct@Alex	alex,int[10]*	w
L1:				t1=b*40
				t2=a+b
				t3=t2*4
				t4=t1+t3
				t5=16+t4
				int		t6=alex[t5]
				t8=p+12
				int	  t7=  *t8
				a=t6*t7
L3:				t9=p
				return  t9
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


		void*   maomao
L1:				t1=(void*)0
				return  t1
L2:				
@end


		int   get_cross_number:	int	a,int	rc,bool	ww,int	p
				it=9
				x=8
				y=65
L1:				it=2+number
L21:				x=7
L20:				y=it+x
L19:				x=0
				it=0
				y=0
L18:				x=2
				y=58
				w[3512] =9+y
L17:				iffalse	y>16	 jmp L23
L22:				x=17-it
				jmp  L16
L23:				x=y*it
L16:				t1=y-x
				t2=x+it
				if	t1<t2	 jmp L26
				iffalse	y>9	 jmp L15
				t3=7+y
				iffalse	t3<x	 jmp L15
L26:L24:				t4=i*40
				t5=j*4
				t6=t4+t5
				t7=800+t6
				w[t7] =i+j
L34:				t8=y-8
				y=t8+x
L33:				it=y*x
L32:				j=j+1
L31:				t9=y-x
				t10=x+it
				if	t9<t10	 jmp L24
				iffalse	y>9	 jmp L35
				t11=7+y
				t12=x*100
				t13=t12/it
				if	t11<t13	 jmp L24
L35:L30:				y=y+1
L29:				iffalse	y==0	 jmp L28
L36:				x=x+1
L37:				jmp   L15
L28:				i=i+1
L27:				iffalse	x==y	 jmp L25
L38:				y=1
L25:				t14=y-x
				t15=x+it
				if	t14<t15	 jmp L24
				iffalse	y>9	 jmp L39
				t16=7+y
				if	t16<x	 jmp L24
L39:L15:				if	y>7	 jmp L42
				iffalse	9<x	 jmp L40
				t18=x+y
				iffalse	it>t18	 jmp L40
L42:				t17= true
				jmp   L41
L40:				t17=false
L41:				b=t17
L14:				t20=y-x
				t21=x+it
				if	t20<t21	 jmp L45
				iffalse	y>9	 jmp L43
				t22=7+y
				iffalse	t22<x	 jmp L43
L45:				t19= true
				jmp   L44
L43:				t19=false
L44:				c=t19
L13:				iffalse	x==0	 jmp L47
L48:				jmp    L46
L47:				x=x+1
L46:				t23=y-x
				t24=x+it
				if	t23<t24	 jmp L13
				iffalse	y>9	 jmp L49
				t25=7+y
				if	t25<x	 jmp L13
L49:L12:				t26=y-x
				t27=x+it
				if	t26<t27	 jmp L52
				iffalse	y>9	 jmp L11
				t28=7+y
				iffalse	t28<x	 jmp L11
L52:L50:				x=x+1
L51:				t29=y-x
				t30=x+it
				if	t29<t30	 jmp L50
				iffalse	y>9	 jmp L53
				t31=7+y
				if	t31<x	 jmp L50
L53:L11:				sum=0
L10:				t32=j*y
				t33=t32/x
				t34=i+t33
				t35=y*5
				t36=x-t35
				t37=t36/9
				it=t34+t37
L9:				t38=108.0+y
				sum=(int)t38
L8:				t39=sum
				t40=t39+x
				it=t40+y
L7:				it=115
L6:				if	7>8	 jmp L54
				t41= true
				jmp   L55
L54:				t41=false
L55:				e=t41
L5:				it=-7
L4:				it=7
L3:				t42=108+y
				return  t42
L2:				
@end
	int			yycc
	int			uucy


		int   number:	int	b
L1:				x[343] =(char)7
L3:				t1=x[1352]
				t2=uucy*yycc
				t3=t1+t2
				return  t3
L2:				
@end


		void   display_result
L1:				t1=x*y
				t2=t1+7
				t3=8/y
				x=t2+t3
L4:				t4=x*x
				t5=y%7
				t6=t4+t5
				y=t6+9
L3:				t7 = @call		number:	y  
				t8=x*y
				t9=t8+7
				t10=8/y
				t11=t9+t10
				t12=y/t11
				t13=x*y
				t14=t13+7
				t15=8/y
				t16=t14+t15
				x=@call		get_cross_number:	t16  t12  true  t7  
L2:				
@end
