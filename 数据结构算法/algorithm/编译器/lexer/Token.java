/*
  *@instruction:词法单元的词素的类型
  */
  package     lexer;
  public    class    Token
 {
           public     final      int      tag;//该词法单元的类型
           
           public    Token(int    _tag)
          {
                      this.tag=_tag;
           }
           public    String     toString()
          {
                     return     ""+(char)this.tag;
           }
  }