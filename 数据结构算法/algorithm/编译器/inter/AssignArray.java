/*
  *@aim:���鸳ֵ
  *@date:2015-10-07 11:59:58
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Word;
  import    lexer.Array;
  
  public    class    AssignArray  extends   Expr
 {
 //����,����,���ʽ,��ʱ��������ƽ̹�ģ�Ҳ����������һά��
               private       Access       access;
               private       Expr          expr;
               
               public        AssignArray(Access   _access,Expr    _expr)
              {
                              super(Word.assign_array,_expr.type);
                              this.access=_access;
                              this.expr=_expr;
//���ͼ��
                              if(!this.check(access.type,_expr.type) )
                                          error("syntax error,array assign type is not match.");
               }
//���������Ƿ��Ǽ��ݵ�
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
//��������ַ����
               public    Expr      gen()
              {
//_indexһ������ѧ���ʽ,���Է��ĵ���reduce()
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