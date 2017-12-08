/*
  *@aim:函数调用
  *@date:2015-10-19
  *@author:狄建彬
  *@version:3
  *@date:2015-11-5 11:45:04
  *@aim:增加了结构体和指针
  */
  package   inter;
   import    lexer.Func;
   import    lexer.Type;
   import    lexer.Struct;
   import    lexer.Pointer;
   import    lexer.Array;
   import    lexer.Token;
   import    java.util.ArrayList;
   public    class    Call     extends     Expr
  {
//要调用的函数
                public       final        Func                        func;
//传入的实参列表
                public       final        ArrayList<Expr>    param;
//全局空参数调用,为了方便程序的编写并避免创建大量的没有内容分的列表
                public       static      final      ArrayList<Expr>      glogalNull=new    ArrayList<Expr>();
                public       Call(Func     _func,ArrayList<Expr>   _param)
               {
                                super(_func,_func.returnType);
                                this.func=_func;
                                this.param=_param;
//检测参数的合法性
                                if(_param.size() != _func.paramList.size())
                                                    error("syntax error:function "+_func+" want  param count is "+_func.paramList.size()+"   but    real   gived  is : "+_param.size());
                                int    i=0;
                                for(     ;i<_func.paramList.size();++i)
                               {
                                                 if( !this.isCompatible(_param.get(i).type,_func.paramList.get(i) ) )
                                                              error("syntax error:function '"+func+"' want type "+_func.paramList.get(i)+"  ,but  gived type '"+_param.get(i).type+"' is not compatible. ");
                                }  
                }
//检测参数是否兼容,这里我们将严格限制类型,在以后的版本中我们将逐步引入指针和结构类型，
//这里我们只是用基本的数值类型
//形参q有着更为宽广的类型
//注意指针类型和数组类型之间的微妙的等价关系
                public       boolean      isCompatible(Type    p,Type   q)
               {
                                Integer      p1=Type.priority.get(p);
                                Integer      p2=Type.priority.get(q);
                                if(p1!=null && p2!=null  )
                               {
                                            int   v1=p1.intValue();
                                            int   v2=p2.intValue();
                                            if(v1>0 && v2>0    )
                                                           return    v2>=v1;
                                            return   v1==0 && v2==0;
                                }
                                else if( p1 !=null || p2 !=null   )//基本类型和结构类型的匹配注定要失败
                                            return    false;
//为了程序的可读性,我写的比较松散
//构造类型之间的比较,分为结构类型之间,指针类型之间,数组与指针类型之间
                                if(( p instanceof   Struct )&&(q instanceof Struct) )
                                           return   p.equalWith(q);
//如果是指针与指针之间
                                if( ( p instanceof  Pointer) &&(q instanceof Pointer))
                                           return    p.equalWith(q);
//如果是指针与数组制作间,注意只有q有可能是指针q永不会为数组
                                if( (p instanceof   Array) && (q instanceof  Pointer))
                               {
                                           Array             _array1=(Array)p;
                                           Pointer          _pt1=(Pointer)q;
                                           
                                           return     _array1.type.equalWith(_pt1.type);
                                }
                                return false;
                }
//@date:2015-10-20 11:09:50
//检测函数的声明与实际的实现是否匹配,这里不检查数组
               public    boolean         isFuncDeclTypeMatch(Func   func1,Func    func2)
              {
                           boolean        match=true;
                           int                 i=0;
                           if( func1.paramList.size() != func2.paramList.size()  )
                                           error("syntax error:function "+func1.lexeme+ " defined do not match it declared :param list length is not same. ");
                           StringBuilder  build=new    StringBuilder("syntax error:function ");
                           build.append(func1.lexeme).append(" ");
                           for(    ;i<func1.paramList.size();++i)
                          {
//类型检测
                                          if(  func1.paramList.get(i) != func2.paramList.get(i) )
                                        {
                                                         build.append(" want type ").append(func1.paramList.get(i)).append(",but real type is:").append(func2.paramList.get(i)).append("\n");
                                                         match=false;
                                         }
                           }
                           if( !match  )
                                        error(build.toString());
                           return    match;
                }
//生产函数调用代码,产生三地址指令的右部,注意实参计算的顺序是从右向左的
                public       Expr       gen()
               {
                               ArrayList<Expr>      _param=new    ArrayList<Expr>(param.size());
                               int        i;
                               for(i=0;i<param.size();++i)
                                            _param.add(null);
                               i=param.size()-1;
//                               System.out.println("_param.size():"+_param.size());
                               for(    ;i>=0;--i)
                                               _param.set(i,param.get(i).reduce());
                               return    new     Call(this.func,_param);
                }
//规约函数调用
                public      Expr      reduce()
               {
                               StringBuilder     build=new    StringBuilder();
                               Expr    expr=this.gen();
                               Temp    tmp=new   Temp(func.returnType);
//压入形参列表
                               build.append(tmp).append(" = ").append(expr);
                               emit(build.toString());
                               return     tmp;
                }
                public      String    toString()
               {
                                int        i=0;
//使用call指令调用函数
                               StringBuilder     build=new    StringBuilder("@call\t\t");
                               build.append(func.lexeme);
                               if(param.size()>0)
                                           build.append(":\t");
//压入形参列表
                               for(   ;i<param.size();++i)
                                           build.append(param.get(i)).append("  ");
                               return    build.toString();
                }
   }