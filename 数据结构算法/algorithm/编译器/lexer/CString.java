/*
  *@aim:�ַ�������
  *@date:2015-10-27 11:16:10
  *@author:�ҽ���
  */
  package    lexer;
  
  public    class    CString      extends    Token
 {
//�ַ�����ֵ
             public     final      String       string;
 //�ַ���������
             public     final      Type          type;
             
             public    CString(String    _string)
            {
                          super(Tag.STRING);
//����ͳһΪ�ַ���ָ��
                          this.type=Pointer.CharPointer;
                          this.string=_string;
             }
//
             public    String        toString()
            {
                          return     string;
             }
  }