/*
  *@aim:�߼�������
  *@date:2015/10/7
  */
  package    inter;
  import      lexer.Word;
  import      lexer.Type;
  import      lexer.Token;
  
  public    class    And     extends    Logic
 {
              public     And(Token   tok,Expr    _left,Expr    _right)
             {
                          super(tok,_left,_right);
//                          System.out.println("And    left expr:  "+_left +"  right expr: "+_right);
              }
//��תָ��,ע������do-while����еı���,�ر��ǵ���jumping(n,0);n>0�����ı���
//���true_port!=0 && false_port!=0���򲻻��ж�����
              public    void      jumping(int    true_port,int    false_port)
             {
                            int   label=false_port!=0?false_port:new_label();
//�����һ�����ʽΪ��,ʣ�µ����Ͳ����ټ������ֱ������,�������false_portΪ0�ͱ�ʾ������ϣ��ƽ������
//����ֻ��Ҫ������һ���ж���伴��,���false_port��Ϊ0���Է�����ת
                            this.left.jumping(0,label);
                            this.right.jumping(true_port,false_port);
                            if(false_port==0)
                                      emit_label(label);
              }
  }