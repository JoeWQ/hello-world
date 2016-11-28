/*
  *@aim:操作符类型
  *@date:2015/10/6
  */
  package     inter;
  import       lexer.Token;
  import       lexer.Type;
  
  public     class    Op   extends    Expr
 {
//所产生的表达式的结果的最终类型
              public     Op(Token   token,Type   type)
             {
                            super(token,type);
              }
//生成三地址代码,规约成单一的临时变量
              public     Expr       reduce()
             {
                           Expr     x=this.gen();
                           if( !(x instanceof   Constant) )
                          {
                                   Temp    t=new    Temp(type);
                                   emit(t+"="+x);
                                   return    t;
                           }
                           return   x;
              }
  }