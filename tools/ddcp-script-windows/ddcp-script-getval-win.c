/* vim: set sw=8 ts=8 si et: */
/* 
 * Windows software to communicate with the DDCP
 * Written by Guido Socher 
 *
 * Windows file IO docs: 
 * http://msdn.microsoft.com/en-us/library/aa363858%28v=VS.85%29.aspx
 * http://msdn.microsoft.com/en-us/library/aa365747%28VS.85%29.aspx
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <windows.h>

static HANDLE fd;

int main(int argc, char *argv[])
{
        char CommPath[42];
        char *device;
        COMMTIMEOUTS timeouts={0};
        DWORD numbytes_ok, temp;
        COMSTAT ComState;
        char lastError[512];
        char c;
        int state;

        if (argc != 2){
                printf("USAGE: ddcp-script-getval COMPORT\n");
                printf("Example: ddcp-script-getval COM4\n");
                exit(0);
        }
        device=argv[1];

        snprintf(CommPath,40,"\\\\.\\%s",device); // COM1 or COM2 or ...
	CommPath[40]='\0';
        fd = CreateFile(CommPath,
                GENERIC_READ | GENERIC_WRITE,
                0,
                NULL,
                OPEN_EXISTING,
                FILE_ATTRIBUTE_NORMAL|FILE_FLAG_NO_BUFFERING,
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
	ClearCommError(fd,&temp,&ComState);// error if temp is not null
        if (temp != 0) {
                //fprintf(stderr, "ClearCommError failed: com port not working\n");
                FormatMessage(
                        FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL,
                        GetLastError(),
                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                        lastError,
                        512,
                        NULL);
                fprintf(stderr,"ERROR in ClearCommError: %s\n",lastError);
                exit(1);
        }
        timeouts.ReadIntervalTimeout=50;
        timeouts.ReadTotalTimeoutConstant=50;
        timeouts.ReadTotalTimeoutMultiplier=10;
        timeouts.WriteTotalTimeoutConstant=50;
        timeouts.WriteTotalTimeoutMultiplier=10;
        if(!SetCommTimeouts(fd, &timeouts)){
                //error occureed. Inform user
                fprintf(stderr, "Setting COM port timeouts failed\n");
                exit(1);
        }
	// send empty line:
	WriteFile(fd,"\r",1,&numbytes_ok,NULL)||fprintf(stderr, "WriteFile failure\n");
        Sleep(100); // Sleep: units are in 1/1000 sec, commands are polled in the avr and it can take 100ms
	WriteFile(fd,"\r",1,&numbytes_ok,NULL)||fprintf(stderr, "WriteFile failure\n");
        Sleep(100); // Sleep: units are in 1/1000 sec, commands are polled in the avr and it can take 100ms
        state=0;
        while ( ReadFile(fd,&c,1,&numbytes_ok,NULL) != 0 ){
                //printf(":0x%x:\n",c); // debug
                if (c=='#') { // find begining of prompt
                        state=1;
                }
                if (state<1) continue;
                if (c=='>') {
                        fputc(c,stdout);
                        state=2;
                }
                if (state>1) break;
                fputc(c,stdout);
        }
        CloseHandle(fd);
        printf("\n");
        Sleep(100); // Sleep: units are in 1/1000 sec, commands are polled in the avr and it can take 100ms
        return(0);
}
