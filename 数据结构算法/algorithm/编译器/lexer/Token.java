/*
  *@instruction:�ʷ���Ԫ�Ĵ��ص�����
  */
  package     lexer;
  public    class    Token
 {
           public     final      int      tag;//�ôʷ���Ԫ������
           
           public    Token(int    _tag)
          {
                      this.tag=_tag;
           }
           public    String     toString()
          {
                     return     ""+(char)this.tag;
           }
  }