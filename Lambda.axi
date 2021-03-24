PROGRAM_NAME='Macros'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/10/2020  AT: 20:10:31        *)
(***********************************************************)

DEFINE_DEVICE

    dvServer = 0:12:0

DEFINE_CONSTANT

    volatile integer _PORT_ALREADY_IN_USE = 14
    volatile integer _SOCKET_ALREADY_LISTENING = 15

DEFINE_VARIABLE

    volatile sinteger nHandler = -1
    volatile long nPort = 1234
    persistent char sAlexaID[300]
	persistent char sAlexaIDAux[300]

DEFINE_START

    define_function fnCommand(char sCmd[])
    {
        select
        {
            active(sCmd == 'entrada_uno'):
            {
                fnInfo('Entrada Uno')
            }
            active(sCmd == 'entrada_dos'):
            {
                fnInfo('Entrada Dos')
            }
        }
    }

    define_function fnServerClose()
    {
        ip_server_close(dvServer.PORT)
        nHandler = -1
    }

    define_function fnServerOpen()
    {
        ip_server_open(dvServer.PORT,nPort,IP_TCP)
    }

	define_function char[255] fnOKResponse()
	{
		stack_var char sResponse[255]
		sResponse = "'HTTP/1.1 200 OK',13,10,
						 'Cache-Control: private',13,10,
						 'Content-Type: texto/normal; charset=utf-8',13,10,
						 'Content-Length: 2',13,10,
						 'OK',13,10,13,10"
						 
		return sResponse
	}    

DEFINE_EVENT

    data_event[dvServer]
    {
        offline:
        {
            nHandler = -1
        }
        onerror:
        {
            if(data.number != _PORT_ALREADY_IN_USE && data.number != _SOCKET_ALREADY_LISTENING)
            {
                nHandler = -1
            }
        }
        string:
        {
			stack_var char sAux[500]
			stack_var integer nEnd
			sAux = remove_string(data.text,'HTTP/1.1',1);
			fnDebug("'Nos llega: ',sAux")
			if(find_string(sAux,'?cmd=amzn',1))
			{
				remove_string(sAux,"'GET /?cmd=amzn1.ask.device.'",1)
				nEnd = find_string(sAux,"'%20'",1)
				sAlexaID = get_buffer_string(sAux,nEnd-1)
				remove_string(sAux,'%20',1)
				fnDebug("'Alexa id: ',sAlexaID")
			}
			
			fnDebug("'Command: ',sAux")
			fnCommand(sAux)
			send_string dvServer,"fnOKResponse()"
			wait 1 fnServerClose()

        }
    }

    timeline_event[_TLID]
    {
        wait 50
        {
            if(nHandler < 0)
            {
                fnServerOpen()
            }
        }
    }

