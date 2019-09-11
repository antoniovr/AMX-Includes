PROGRAM_NAME='CUSTOMAPI'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/11/2019  AT: 09:20:14        *)
(***********************************************************)

#IF_NOT_DEFINED __CUSTOMAPI__
#DEFINE __CUSTOMAPI__

DEFINE_CONSTANT

    char _CRLF[] = {$0D,$0A}
    char _CR = $0D
    char _LF = $0A

    integer _STATE_ALL = 0
    integer _STATE_OFF = 1
    integer _STATE_ON  = 2
    integer _JUSTIFICATION_CENTER_LEFT   = 4
    integer _JUSTIFICATION_CENTER_MIDDLE = 5
    integer _JUSTIFICATION_CENTER_RIGHT  = 6

    integer _RMS_CLIENT_ONLINE    = 250

    integer _FILE_OPEN_FOR_READ   = 1
    integer _FILE_OPEN_FOR_NEW    = 2
    integer _FILE_OPEN_FOR_APPEND = 3

    integer _SOURCE_HDMI    = 1
    integer _SOURCE_DVI     = 2
    integer _SOURCE_USBC    = 3
    integer _SOURCE_HDBASET = 4

    char asSources[][32] = {
			     'HDMI',
			     'DVI',
			     'USB-C',
			     'HDBaseT'
			   }

   integer SIMULATED_FB = 256
   
   integer _ZOOM_IN   = 1
   integer _ZOOM_OUT  = 2
   integer _ZOOM_STOP = 0  

   integer _FOCUS_NEAR = 1
   integer _FOCUS_FAR = 2
   integer _FOCUS_STOP = 3
   integer _FOCUS_AUTO = 4
   integer _FOCUS_MANUAL = 5

   integer _CAM_HOME = 181
   integer _PANTILT_STOP = 0

DEFINE_VARIABLE

    define_function fnInfo(char sInfo[])
    {
	//send_string 0,"'DEBUG - ',sDebug"
	amx_log(AMX_INFO,"__file__,': ',sInfo")
    }

    define_function fnDebug(char sDebug[])
    {
	//send_string 0,"'DEBUG - ',sDebug"
	amx_log(AMX_DEBUG,"__file__,': ',sDebug")
    }

    define_function fnDebugHex(char sDebug[])
    {
	stack_var integer i
	stack_var char sDebugAux[255]
	for(i=1;i<=length_string(sDebug);i++)
	{
	    sDebugAux = "sDebugAux,itohex(sDebug[i]),' '"
	}	
	amx_log(AMX_DEBUG,"__file__,': ',sDebugAux")
	//send_string 0,"'DEBUG - ',sDebugAux"
    }

    define_function fnLog(char sData[])
    {
	stack_var slong sResult,nHandlerFile 
	nHandlerFile = -1
	nHandlerFile = file_open('log.txt',FILE_RW_APPEND)	
	if(nHandlerFile)
	{
	    fnDebug('LOG: File opened correctly')
	    sResult = file_write_line(nHandlerFile,"time,': ',sData",100)
	    if(sResult) {fnDebug('LOG: data stored correctly')}
	    else			{fnDebug('LOG: problem writting on file!')}
	    file_close(nHandlerFile)
	}
    }
	
    define_function fnBeep(dev dvTp)
    {
	send_command dvTp,'ABEEP'
    }

    define_function fnDoubleBeep(dev dvTp)
    {
	send_command dvTp,'ADBEEP'
    }
	
    define_function fnPageOpen(dev dvTp,char sPage[])
    {
	send_command dvTp,"'PAGE-',sPage"
    }

    define_function fnPopupOpen(dev dvTp,char sPopup[])
    {
	send_command dvTp,"'PPON-',sPopup"
    }

    define_function fnPopupClose(dev dvTp,char sPopup[])
    {
	send_command dvTp,"'PPOF-',sPopup"
    }

    define_function fnPopupCloseAll(dev dvTp)
    {
	send_command dvTp,"'@PPX'"
    }

    define_function fnSubPageOpen(dev dvTp,integer nAddressCode,char sSubpage[])
    {
	send_command dvTp,"'^SSH-',itoa(nAddressCode),',',sSubpage"
    }

    define_function fnSubPageClose(dev dvTp,integer nAddressCode,char sSubpage[])
    {
	send_command dvTp,"'^SHD-',itoa(nAddressCode),',',sSubpage"
    }

    define_function fnTextChange(dev dvTp,integer nTxt,char sText[])
    {
	send_command dvTp,"'^TXT-',itoa(nTxt),',0,',sText"
    }

    define_function fnTextChangeUTF(dev dvTp,integer nTxt,char sText[])
    {
	send_command dvTp,"'^UTF-',itoa(nTxt),',0,',sText"
    }

    define_function fnTextChangeRange(dev dvTp,integer nStart,integer nEnd,char sText[])
    {
	send_command dvTp,"'^TXT-',itoa(nStart),'.',itoa(nEnd),',0,',sText"
    }

    define_function fnTextJustification(dev dvTp,integer nTxt,integer nStates,integer nJustification)
    {
	send_command dvTp,"'^JST-',itoa(nTxt),',',itoa(nStates),',',itoa(nJustification)"
    }

    define_function fnButtonSetImg(dev dvTp,integer nAddress,char sImgName[])
    {
	send_command dvTp,"'^BMP-',itoa(nAddress),',0,',sImgName,',,10'"
    }

    define_function fnButtonHide(dev dvTp,integer nTxt)
    {
	send_command dvTp,"'^SHO-',itoa(nTxt),',0'"
    }

    define_function fnButtonHideRange(dev dvTp,integer nStart,integer nEnd)
    {
	send_command dvTp,"'^SHO-',itoa(nStart),'.',itoa(nEnd),',0'"
    }

    define_function fnButtonShow(dev dvTp,integer nTxt)
    {
	send_command dvTp,"'^SHO-',itoa(nTxt),',1'"
    }

    define_function fnButtonShowRange(dev dvTp,integer nStart,integer nEnd)
    {
	send_command dvTp,"'^SHO-',itoa(nStart),'.',itoa(nEnd),',1'"
    }

    define_function fnButtonEnable(dev dvTp,integer nTxt)
    {
	send_command dvTp,"'^ENA-',itoa(nTxt),',1'"
    }

    define_function fnButtonDisable(dev dvTp,integer nTxt)
    {
	send_command dvTp,"'^ENA-',itoa(nTxt),',0'"
    }

    define_function fnLevelChange(dev dvTp,integer nLvl,integer nValue)
    {
	send_level dvTp,nLvl,nValue
    }

    define_function char[8] fnSplitIntoMinutesAndSeconds(char sSeconds[], char sSeperator[])
    {
	stack_var integer nMinutes, nSeconds, nSecondsPassByReference, nSecondsforMath
	stack_var char sReturnString[8]
	
	nSecondsPassByReference = atoi(sSeconds)
	nSecondsforMath = nSecondsPassByReference
	nMinutes = nSecondsforMath / 60
	nSecondsPassByReference = nSecondsforMath % 60
	
	if(nSecondsPassByReference < 10)
	{
	    //nSeconds needs a '0' in front, looks neater
	    sReturnString = "itoa(nMinutes),sSeperator,'0',itoa(nSecondsPassByReference)"
	    
	    if(nMinutes < 10)
	    {
		//nMinutes needs a '0' in front, looks neater
		sReturnString = "'0',itoa(nMinutes),sSeperator,'0',itoa(nSecondsPassByReference)"
	    }
	}
	else
	{
	    //nSeconds does not require a '0' in front...
	    sReturnString = "itoa(nMinutes),sSeperator,itoa(nSecondsPassByReference)"
	    
	    if(nMinutes < 10)
	    {
		//nMinutes needs a '0' in front, looks neater
		sReturnString = "'0',itoa(nMinutes),sSeperator,itoa(nSecondsPassByReference)"
	    }
	}
	
	return sReturnString
    }

    define_function char[8] fnSplitIntoMinutesOnly(integer nSeconds)
    {
	stack_var integer nMinutes, nSecondsPassByReference, nSecondsforMath
	stack_var char sReturnString[8]
	
	nSecondsPassByReference = nSeconds;
	nSecondsforMath = nSecondsPassByReference;
	nMinutes = nSecondsforMath/60;
	sReturnString = "itoa(nMinutes)";
	
	return sReturnString
    }

    define_function char[100] fnGetIPErrorDescription(long nError)
    {
	stack_var char sReturn[100]
	sReturn = "'IP ERROR ',itoa(nError),': '"
	
	switch(nError)
	{
	    case 2:  {sReturn = "sReturn,'General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"}
	    case 4:  {sReturn = "sReturn,'Uknown host or DNS error (IP_CLIENT_OPEN)'"}
	    case 6:  {sReturn = "sReturn,'connection refused (IP_CLIENT_OPEN)'"}
	    case 7:  {sReturn = "sReturn,'connection timed out (IP_CLIENT_OPEN)'"}
	    case 8:  {sReturn = "sReturn,'unknown connection error (IP_CLIENT_OPEN)'"}
	    case 9:  {sReturn = "sReturn,'Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'"}
	    case 10: {sReturn = "sReturn,'Binding error (IP_SERVER_OPEN)'"}
	    case 11: {sReturn = "sReturn,'Listening error (IP_SERVER_OPEN)'"}
	    case 14: {sReturn = "sReturn,'local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"}
	    case 15: {sReturn = "sReturn,'UDP socket already listening (IP_SERVER_OPEN)'"}
	    case 16: {sReturn = "sReturn,'too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"}
	    case 17: {sReturn = "sReturn,'Local port not open, can not send string (IP_CLIENT_OPEN)'"}
	    default: {sReturn = "sReturn,'Uknown error'"}
	}
	return sReturn
    }

    define_function integer fnIsLeapYear(integer nYear)
    {
	return ( ((nYear%400)=0) or ( ((nYear%4)=0)  and ((nYear%100)<>100) ) )
    }

    define_function sinteger fnDateCompare(char sDate1[],char sDate2[])
    {
	stack_var char sF1[8],sF2[8] 
	sF1 = "'20',mid_string(sDate1,7,2),mid_string(sDate1,1,2),mid_string(sDate1,4,2)"
	sF2 = "'20',mid_string(sDate2,7,2),mid_string(sDate2,1,2),mid_string(sDate2,4,2)"
	
	if (sF1 > sF2) return 1
	if (sF1 < sF2) return (-1)   
	return 0
    }

    define_function integer fnLoByte(integer LI_WORD)
    {
	// Devuelve el LSB
	return LI_WORD%$100
    }

    define_function integer fnHiByte(integer LI_WORD)
    {
	// Devuelve el MSB
	return LI_WORD/$100
    }

    define_function char fnChecksum(char sData[])
    {
	stack_var char cSum
	stack_var integer i
	for(i=1;i<=max_length_array(sData);i++)
	{
	    cSum = cSum + sData[i]
	}
	
	return cSum
    }

#END_IF // __CUSTOMAPI__

(***********************************************************)
(*		    	ANTONIO VARGAS 			   *)
(***********************************************************)