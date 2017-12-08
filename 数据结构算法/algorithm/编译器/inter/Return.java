/*
  *@aim:return语句
  *@date:2015-10-20 11:22:34
  *@author:狄建彬
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  import      lexer.Func;
  import      lexer.Struct;
  import      lexer.Pointer;
  import      lexer.Array;
//注意return语句的表达式可以为空Void.Null,并且return语句不会参与表达式的运算
   public     class      Return      extends    Stamt
  {
                  private          Func           func;
                  private          Expr           expr;
//传入外围函数
                  public       Return(Expr    _expr)
                 {
 //                               super(Word._return,null);
//先检测外围函数
                                if(Func.Enclosing ==Func.Null )
                                              error("syntax error:return express do not enclose.");
                                this.func=Func.Enclosing;
                                this.expr=_expr;
//在检测返回的类型是否一致或者兼容
                                boolean     gen_error=false;
                                if(func.returnType!=Type.Void)
                               {
//如果返回类型不兼容,当前我们暂时不让函数返回指针/结构体,数组在后续的版本中我们将实现这些功能
//@date:2015-11-5 14:59:27
//@version:实现可以返回各种类型的数据
                                             Integer       a=Type.priority.get(func.returnType);
                                             Integer       b=Type.priority.get(_expr.type);
                                             if( a!=null && b!=null)
                                            {
                                                               int        v1=a.intValue();
                                                               int        v2=b.intValue();
                                                               if(  v1>0 && v2>0  )
                                                                            gen_error=v1<v2;
                                                               else 
                                                                            gen_error=v1>0 || v2>0;
                                             }
                                             else
                                           {
                                                             gen_error=true;
                                                              if( (func.returnType instanceof Struct) && (_expr.type instanceof Struct))
                                                                           gen_error=!func.returnType.equalWith(_expr.type);
                                                              if(func.returnType instanceof    Pointer)
                                                             {
                                                                            Pointer   _p1=(Pointer)func.returnType;
                                                                            if(_expr.type instanceof  Pointer)
                                                                                          gen_error=!_p1.type.equalWith(((Pointer)_expr.type).type);
                                                                            else if(_expr.type instanceof Array)
                                                                                          gen_error=!_p1.type.equalWith(((Array)_expr.type).type);
                                                              }
                                             }
                                }
                                else 
                                            gen_error=_expr.type!=Type.Void;
                               if(    gen_error    )
                                                 error("syntax error: function type "+func.returnType+" is not compatible with return type "+_expr.type);
//为函数做上标志，表示有返回语句出现
                               func.hasReturnStamt=true;
                  }
//生成代码
                  public     void        gen(int   _after,int   _before)
                 {
                                  if(  expr.type!=Type.Void )
                                 { 
                                                   Expr      p=expr.gen();
                                                   Temp    t=new    Temp(p.type);
                                                   emit(t+"="+p);
                                                   emit("return  "+t);
                                  }
                                  else
                                                  emit("return");
                  }
//注意一般下面的函数不会被调用,因为return语句不会参与表达式计算
                  public     String       toString()
                 {
                                if( expr.type != Type.Void  )
                                               return     "return  "+expr;
                                return   "return";
                  }
   }