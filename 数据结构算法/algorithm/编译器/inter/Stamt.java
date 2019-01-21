/*
  *@aim:语句
  *@date:2015/10/7
  */
  package    inter;
  
  public    class    Stamt    extends    Node
 {
//语句的下一条目标指令标号
              public      int         after;
//语句的开始处标号
              public      int         before;
//表达式
              private     Expr         expr;
              public      Stamt()
             {
              }
//此构造函数只是一个包装者,为了包装赋值语句,如果不是一个赋值语句,会报语法错误
//表达式的要求,不要求每一行表达式都能产生副作用
              public      Stamt(Expr     _expr)
             {
                           this.expr=_expr;
                           if(!(_expr   instanceof  Assign) && !(_expr instanceof  AssignArray) && !(_expr  instanceof AssignStruct))
                                       error("syntax error:'"+_expr+"' is not an  expression.");
              }
//产生语句代码,after代表语句之后的第一条指令的地址
//before代表语句的第一条指令的地址
              public     void      gen(int    _after,int    _before)
             {
                          if(expr !=null  )
                                  expr.gen();
              }
              public     static     Stamt     Null=new    Stamt();
//用在break语句中
              public     static     Stamt     Enclosing=Stamt.Null;
  }