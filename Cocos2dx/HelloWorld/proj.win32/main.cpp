#include "main.h"
#include "AppDelegate.h"
#include "cocos2d.h"

USING_NS_CC;

int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);
	AllocConsole();
	 HWND    hwndConsole = GetConsoleWindow();
	if (hwndConsole != NULL)
	{
		ShowWindow(hwndConsole, SW_SHOW);
		BringWindowToTop(hwndConsole);
		freopen("CONOUT$", "wt", stdout);
		freopen("CONOUT$", "wt", stderr);

		HMENU hmenu = GetSystemMenu(hwndConsole, FALSE);
		if (hmenu != NULL) DeleteMenu(hmenu, SC_CLOSE, MF_BYCOMMAND);
	}
    // create the application instance
    AppDelegate app;
    int  ret= Application::getInstance()->run();

	FreeConsole();
}
