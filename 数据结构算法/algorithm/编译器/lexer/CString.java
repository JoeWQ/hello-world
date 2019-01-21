/*
  *@aim:字符串类型
  *@date:2015-10-27 11:16:10
  *@author:狄建彬
  */
  package    lexer;
  
  public    class    CString      extends    Token
 {
//字符串的值
             public     final      String       string;
 //字符串的类型
             public     final      Type          type;
             
             public    CString(String    _string)
            {
                          super(Tag.STRING);
//类型统一为字符串指针
                          this.type=Pointer.CharPointer;
                          this.string=_string;
             }
//
             public    String        toString()
            {
                          return     string;
             }
  }