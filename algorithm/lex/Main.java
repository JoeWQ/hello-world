/*
  *@aim:main method
  *2016-1-12 10:46:25
  */
    import     java.io.IOException;
    import     java.io.File;
    import     java.io.FileInputStream;
    import     java.io.PrintStream;
    public      class      Main   
   {
                 public      static     void      main(String[]    argv)throws  IOException
                {
                              if(argv.length<1)
                            {
                                          System.out.println("Error: usage   source file,  output file.");
                                          System.exit(1);
                             }
                             for(int  i=0;i<argv.length;++i)
                            {
                                    File    file=new    File(argv[i]);
                                    if( !file.exists())
                                  {
                                          System.err.println("Error: source file "+argv[i]+"does not exist!");
                                          continue;
                                   }
//如果表示一个目录
                                  if( ! file.isFile()  )
                                 {
                                          System.err.println("Error:source file '"+argv[i]+" is not a normal file!");
                                          continue;
                                  }
                                 FileInputStream    input=new   FileInputStream(file);
                                 FileManager.initWith(input,null);
                                LuaLexer          lex=new    LuaLexer();
      //
                                Token   _tok=lex.scan();
                                while(_tok.tag != 0)
                               {
                                           if(_tok.tag == Tag.STRING)
                                                System.out.println(_tok);
                                           _tok = lex.scan();
                                }
                                FileManager.input.close();
                                FileManager.input=null;
                                FileManager.output=null;
                          }
                 }
    }