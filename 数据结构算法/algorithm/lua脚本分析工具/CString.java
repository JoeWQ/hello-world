/*
  *@2016-2-2 11:35:41
  *@×Ö·û´®ÀàÐÍ
  */
  public     class    CString     extends    Token
 {
             public      final      String     string;
             
             public     CString(String   _string)
            {
                          super(Tag.STRING);
                          this.string=_string;
            }
             public     String     toString()
            {
                          return     "\""+string+"\"";
             }
  }