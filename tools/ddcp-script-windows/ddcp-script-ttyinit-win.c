/* vim: set sw=8 ts=8 si et: */
/* Windows software to initialize the com port
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <windows.h>

static HANDLE fd;

int open_tty(char *comport){
        char CommPath[42];
        char lastError[512];
        DCB Dcb;
        BOOL ok;

        snprintf(CommPath,40,"\\\\.\\%s",comport); // COM1 or COM2 or ...
	CommPath[40]='\0';
        fd = CreateFile(CommPath,
                      GENERIC_READ | GENERIC_WRITE,
                      0,
                      NULL,
                      OPEN_EXISTING,
                      0,
                      NULL);

        if (fd == INVALID_HANDLE_VALUE) {
                //fprintf(stderr, "CreateFile failed: CommPath (%.8x)\n", (unsigned int)GetLastError());
                FormatMessage(
                        FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL,
                        GetLastError(),
                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                        lastError,
                        512,
                        NULL);
                fprintf(stderr,"ERROR open com-port: %s\n",lastError);
                exit(1);
        }

        memset(&Dcb, 0x0, sizeof(DCB));
        Dcb.DCBlength = sizeof (DCB);
        ok = GetCommState(fd, &Dcb);
        if (!ok){
                fprintf(stderr, "File %s Line %d Function GetCommState failed (%.8x)\n",
                       __FILE__, __LINE__,(unsigned int) GetLastError());
                exit(1);
        }
 
 	// some reasonable defaults even if we do not use Tx/Rx:
 	Dcb.Parity=NOPARITY;
 	Dcb.BaudRate=9600;
 	Dcb.ByteSize=8;
 	Dcb.StopBits=ONESTOPBIT;

        Dcb.fDtrControl = DTR_CONTROL_ENABLE;
        Dcb.fRtsControl = RTS_CONTROL_ENABLE;
        ok = SetCommState(fd, &Dcb);
        if (!ok){
                fprintf(stderr, "File %s Line %d Function SetCommState failed (%.8x)\n",
                       __FILE__, __LINE__,(unsigned int) GetLastError());
                exit(1);
        }
        return(0);
}

int main(int argc, char *argv[])
{
        char *device;

        if (argc != 2){
                printf("USAGE: ddcp-script-ttyinit COMPORT\n");
                printf("Example: ddcp-script-ttyinit COM4\n");
                exit(0);
        }
        device=argv[1];

        open_tty(device);
        Sleep(100); // sleep: units are in 1/1000 sec
        CloseHandle(fd);
        return(0);
}
