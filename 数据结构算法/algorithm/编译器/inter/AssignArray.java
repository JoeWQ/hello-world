/*
  *@aim:数组赋值
  *@date:2015-10-07 11:59:58
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Word;
  import    lexer.Array;
  
  public    class    AssignArray  extends   Expr
 {
 //数组,索引,表达式,此时的数组是平坦的，也就是市中市一维的
               private       Access       access;
               private       Expr          expr;
               
               public        AssignArray(Access   _access,Expr    _expr)
              {
                              super(Word.assign_array,_expr.type);
                              this.access=_access;
                              this.expr=_expr;
//类型检查
                              if(!this.check(access.type,_expr.type) )
                                          error("syntax error,array assign type is not match.");
               }
//数据类型是否是兼容的
               private    boolean     check(Type   p1,Type  p2)
              {
                              Integer        a=Type.priority.get(p1);
                              Integer        b=Type.priority.get(p2);
                              boolean      match=false;
                              if( a!=null && b!=null)
                             {
                                           int   aValue=a.intValue();
                                           int   bValue=b.intValue();
                                           match=(aValue>0 && bValue>0 && aValue>=bValue)||(aValue==0 && bValue==0);
                              }
                              return    match;
               }
//生成三地址代码
               public    Expr      gen()
              {
//_index一定是数学表达式,可以放心调用reduce()
                              Expr    _index=access.index.reduce();
                              Expr    _expr;
                              if((expr   instanceof  Assign)||(expr instanceof AssignArray))
                                           _expr=expr.reduce();
                              else
                                           _expr=expr.gen();
                              emit(access.array+"["+_index.toString()+"] ="+_expr.toString());
                              return    this;
               }
//reduce
               public     Expr      reduce()
              {
                              Expr     _index=access.index.reduce();
                              Expr     _expr=expr.reduce();
                              emit(access.array+"[ "+_index.toString()+" ]="+_expr.toString());
                              return    _expr;
               }
               public     String     toString()
              {
                               return    access.array+"["+access.index.toString()+"] ="+expr.toString();
               }
  }