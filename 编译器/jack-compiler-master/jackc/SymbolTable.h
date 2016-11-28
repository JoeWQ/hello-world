#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#include "Parser.h"
#include <map>
#include <vector>

class SymbolTable
{
public:
    enum Kind
    {
        STATIC, FIELD, ARG, VAR, FUNCTION, METHOD, CONSTRUCTOR, NONE
    };
    class Info
    {
    public:
        string type;    // int, float, char, string
        Kind kind;      // kind : static, field, var, argument 
        int index;
        vector<string> args;
        Info()
        {
            type = "0";
            kind = NONE;
            index = 0;
        }
        friend bool operator==(Info info1, Info info2)
        {
            if (info1.type == info2.type && info1.kind == info2.kind && info1.args == info2.args)
                return true;
            else
                return false;
        }
    };
    static Info None;
private:
    int static_index;
    int field_index;
    int arg_index;
    int var_index;
    int errorNum;
    map<string, int> classIndex;                // ����������������
    vector<map<string, Info>> classesTable;     // ����ű�����, ��һֱ�����Ų��ᱻ����
    map<string, Info> subroutineTable;          // �������ű�
    int currentClassNumber;     // �����﷨����ʱ��, ���浱ǰ����ű���������
    string currentClass;        // �����﷨����ʱ��, ���浱ǰ������
    void initialSubroutineTable();          // ���ٺ������ű�
    SymbolTable();
    static SymbolTable * instance;      // ָ����ű�ʵ������
public:
    static SymbolTable * getInstance();     // ���ط��ű�ʵ������
    void classesTableInsert(Parser::TreeNode *t);       // ����ű�Ĳ������
    void subroutineTableInsert(Parser::TreeNode *t);    // �������ű�Ĳ������
    
    Info subroutineTableFind(string name);  // �������ű�Ĳ��Ҳ���
    Info classesTableFind(string className, string functionName);   // ����ű�Ĳ��Ҳ���
    bool classIndexFind(string className);  // �ж�className�ǲ��ǺϷ�������
    
    int getFieldNumber(string className);
    void printClassesTable();       // ���Գ���, ��ӡ����ű�
};

#endif
