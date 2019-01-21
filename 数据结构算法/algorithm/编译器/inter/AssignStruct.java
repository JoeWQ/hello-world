/*
  *@aim:�ṹ�帳ֵ���,ע�����ǻ�Ը�ֵ�Ĺ��̽�����ȵ��﷨����,�ѱ�֤���ɵĴ��������
  *@date:2015-11-4 10:41:23
  *@author:�ҽ���
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  import      lexer.Type;
  import      java.util.HashMap;
  public      class     AssignStruct     extends     Expr
 {
//��ʶ��
              private      Expr                   access_struct;
              private      Expr                   expr;
              
              public       AssignStruct(Expr   _access,Expr    _expr)
             {
                           super(Word.assign,_expr.type);
                           this.access_struct=_access;
                           this.expr=_expr;
//���ʽ���
                           if( !(_access   instanceof  AccessStruct) && !(_access  instanceof  AccessStructByPointer)  )
                                        error("assign  object must be  AccessStruct or AccessStructByPointer,but gived is "+_access);
//���ͼ��
                           if( !this.check(_access.type,_expr.type))
                                       error("syntax error:no compatible  type to assign,want type '"+_access.type+"',but gived is '"+_expr.type+"' ");
              }
//���ͼ��
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
//�������ͱ�����ͬ����
                          if( !match   )
                                     match=p1.equalWith(p2);
                          return   match;
             }
//��������ַ����
              public    Expr     gen()
             {
//����ұ���һ����ֵ���,��Ҫ���⴦��
                           Expr    x=null;
                           if( (expr  instanceof   Assign) || (expr instanceof  AssignArray) || (expr instanceof  AssignStruct) )  
                                       x=expr.reduce();
                           else
                                       x=expr.gen();
//�Խṹ����ʽ����������
                           emit(access_struct.gen()+"="+x.toString());
                           return   x;
              }
//����ֵ�����ԼΪ��һ�ı���,����������ھ��и����õı��ʽ�лᱻʹ��
//ע��reduce��gen�����Ĳ�֮ͬ��,�����Ϊ���ʽ��һ����,��������ͻᱻ����
              public     Expr      reduce()
             {
//�������ı��ʽ��ͬ,��ֵ���ʽ�Ǿ��и����õ�,�����Ϊһ�����ʽ��һ����,��ֵ�Ľ��Ҳ���Բ�������
                          Expr      x=expr.reduce();
                          emit(access_struct.reduce()+"="+x);
                          return   x;
              }
//�Ա�ʶ�����м�
 
//���س�������п���,ע����Ϊ��ֵ������и�����,��������������ʵ����һЩ����
              public     Expr      recduceConstant()
             {
                          return   this;
              }
              public    String    toString()
             {
                           return     access_struct+" = "+expr.toString();
              }
  }