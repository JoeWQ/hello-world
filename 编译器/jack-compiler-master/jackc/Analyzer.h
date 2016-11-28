#ifndef _ANALYZER_H
#define _ANALYZER_H

#include "Parser.h"
#include "SymbolTable.h"
#include <vector>
#include "Error.h"

class Analyzer
{
private:
    Parser::TreeNode *tree;
    SymbolTable *symbolTable;
    string currentClassName;        // ��������ʱ��, ���浱ǰ�������
    string currentFunctionName;     // ��������ʱ��, ���浱ǰ����������
    void buildClassesTable(Parser::TreeNode *t);
    void checkStatements(Parser::TreeNode *t);
    void checkStatement(Parser::TreeNode *t);
    void checkExpression(Parser::TreeNode *t);
    void checkArguments(Parser::TreeNode *t, vector<string> parameter, string functionName);
    void checkMain();
public:
    Analyzer(Parser::TreeNode *t);
    void check();
};

#endif
