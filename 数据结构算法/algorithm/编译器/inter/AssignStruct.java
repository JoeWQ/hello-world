/*
  *@aim:结构体赋值语句,注意我们会对赋值的过程进行深度的语法分析,已保证生成的代码的质量
  *@date:2015-11-4 10:41:23
  *@author:狄建彬
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  import      lexer.Type;
  import      java.util.HashMap;
  public      class     AssignStruct     extends     Expr
 {
//标识符
              private      Expr                   access_struct;
              private      Expr                   expr;
              
              public       AssignStruct(Expr   _access,Expr    _expr)
             {
                           super(Word.assign,_expr.type);
                           this.access_struct=_access;
                           this.expr=_expr;
//表达式检查
                           if( !(_access   instanceof  AccessStruct) && !(_access  instanceof  AccessStructByPointer)  )
                                        error("assign  object must be  AccessStruct or AccessStructByPointer,but gived is "+_access);
//类型检查
                           if( !this.check(_access.type,_expr.type))
                                       error("syntax error:no compatible  type to assign,want type '"+_access.type+"',but gived is '"+_expr.type+"' ");
              }
//类型检查
             private        boolean     check(Type   p1,Type  p2)
            {
                          Integer       ap=Type.priority.get(p1);
                          Integer       bp=Type.priority.get(p2);
                          boolean     match=false;
                          if(ap!=null && bp!=null)
                         {
                                      int    aValue=ap.intValue();
                                      int    bValue=bp.intValue();
                                      match=(aValue>0 && bValue>0 && aValue>=bValue)||( aValue==0 && bValue==0);
                          }
//否则类型必须是同构的
                          if( !match   )
                                     match=p1.equalWith(p2);
                          return   match;
             }
//生成三地址代码
              public    Expr     gen()
             {
//如果右边是一个赋值语句,需要特殊处理
                           Expr    x=null;
                           if( (expr  instanceof   Assign) || (expr instanceof  AssignArray) || (expr instanceof  AssignStruct) )  
                                       x=expr.reduce();
                           else
                                       x=expr.gen();
//对结构体访问进行语义分析
                           emit(access_struct.gen()+"="+x.toString());
                           return   x;
              }
//将赋值运算规约为单一的变量,这个函数在在具有副作用的表达式中会被使用
//注意reduce和gen函数的不同之处,如果作为表达式的一部分,这个函数就会被调用
              public     Expr      reduce()
             {
//与其他的表达式不同,赋值表达式是具有副作用的,如果作为一个表达式的一部分,赋值的结果也可以参与运算
                          Expr      x=expr.reduce();
                          emit(access_struct.reduce()+"="+x);
                          return   x;
              }
//对标识符进行简化
 
//返回常量如果有可能,注意因为赋值运算具有副作用,所以其和其他类的实现有一些区别
              public     Expr      recduceConstant()
             {
                          return   this;
              }
              public    String    toString()
             {
                           return     access_struct+" = "+expr.toString();
              }
  }