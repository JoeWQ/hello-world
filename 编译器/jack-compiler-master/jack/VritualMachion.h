#ifndef _VIRTUAL_MACHION_H
#define _VIRTUAL_MACHION_H

#include <vector>
#include <string>
#include <unordered_map>

using namespace std;

extern vector<string> filenames;

void executeArithmetic(string command);                         // ִ������ָ��
void executePush(string segment, int index);                    // ִ��pushָ��
void executePop(string segment, int index);                     // ִ��popָ��
void executeLabel(string label);                                // ִ��labelָ��
void executeGoto(string label);                                 // ִ��gotoָ��
void executeIf(string label);                                   // ִ��if-gotoָ��
void executeCall(string functionName, int numArgs);             // ִ��callָ��
void executeReturn();                                           // ִ��returnָ��
void executeFunction(string functionName, int numLocals);       // ִ��functionָ��
void executeEnd();                                              // �������

void init();                                                    // cpuͨ��֮���ʼ��ip
void instructionFetch();                                        // cpuȡָ��
void execute();                                                 // cpuִ��ָ��

void setKeyboardValue(short val);
void loadProgram();                                             // �������ָ��洢����
void run();                                                     // CPUͨ�翪ʼ����

#endif
