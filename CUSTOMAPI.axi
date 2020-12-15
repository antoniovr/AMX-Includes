PROGRAM_NAME='CUSTOMAPI'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/20/2020  AT: 11:29:40        *)
(***********************************************************)

#IF_NOT_DEFINED __CUSTOMAPI__
#DEFINE __CUSTOMAPI__

DEFINE_CONSTANT

    char _CRLF[] = {$0D,$0A}
    char _CR = $0D
    char _LF = $0A

    integer _LEVEL_ALL   = 1
    integer _LEVEL_VIDEO = 2
    integer _LEVEL_AUDIO = 3
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
   integer _PANTILT_STOP = 222
   
   // MD5
    long lr[64] = {7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
		   5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
		   4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
		   6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21}

    long lk[64]={3614090360, 3905402710, 606105819,  3250441966, 4118548399, 1200080426, 2821735955, 4249261313,
		 1770035416, 2336552879, 4294925233, 2304563134, 1804603682, 4254626195, 2792965006, 1236535329,
		 4129170786, 3225465664, 643717713,  3921069994, 3593408605, 38016083,   3634488961, 3889429448,
		 568446438,  3275163606, 4107603335, 1163531501, 2850285829, 4243563512, 1735328473, 2368359562,
		 4294588738, 2272392833, 1839030562, 4259657740, 2763975236, 1272893353, 4139469664, 3200236656,
		 681279174,  3936430074, 3572445317, 76029189,   3654602809, 3873151461, 530742520,  3299628645,
		 4096336452, 1126891415, 2878612391, 4237533241, 1700485571, 2399980690, 4293915773, 2240044497,
		 1873313359, 4264355552, 2734768916, 1309151649, 4149444226, 3174756917, 718787259,  3951481745}

DEFINE_VARIABLE

    volatile char cText2[256]

DEFINE_START

    define_function fnKeyboardOpen(dev dvTp,char sPrompt[],char sTitle[],char sHint[],char sHeader[])
    {
    	send_command dvTp,"'AKEYB-',sPrompt,';',sTitle,';',sHint,';',sHeader,'-;1'"
    }

    define_function fnModuleSetDebug(dev vdvDevice,integer nDebug)
    {
        send_command vdvDevice,"'DEBUG-',itoa(nDebug)"
    }

    define_function fnModuleSetIP(dev vdvDevice,char sIP[])
    {
	    send_command vdvDevice,"'PROPERTY-IP_Address,',sIP"
    }
    
    define_function fnModuleSetPort(dev vdvDevice,long nPort)
    {
	    send_command vdvDevice,"'PROPERTY-Port,',itoa(nPort)"
    }
    
    define_function fnModuleReinit(dev vdvDevice)
    {
	    send_command vdvDevice,"'REINIT'"
    }

    define_function long leftrotate(LONG lx, LONG ly)
    {
        local_var long lRotate
        lRotate=(lx << ly) BOR (lx >> (32-ly))
        return lRotate
    }

    define_function MD5(CHAR cInputstring[256], CHAR cResult[32])
    {
        local_var long lh0
        local_var long lh1
        local_var long lh2
        local_var long lh3
        
        local_var long la
        local_var long lb
        local_var long lc
        local_var long ld
        
        local_var integer nMessageLength 
        
        cText2 = cInputstring
        
        lh0 = $67452301
        lh1 = $EFCDAB89
        lh2 = $98BADCFE
        lh3 = $10325476
        
        la = lh0
        lb = lh1
        lc = lh2
        ld = lh3
        
        nMessageLength = length_string(cText2)*8	// Determinamos la lontigud del mensaje
        cText2 = "cText2,$80" // Add 1 Bit (10000000)
	
        while((length_string(cText2)%64)<>56)		// 0 Bits de relleno hasta 8 bytes de duraci�n
        {
            cText2="cText2,$00"
        }
	
	    cText2="cText2,nMessageLength%256,nMessageLength/256,$00,$00,$00,$00,$00,$00"	// add message Length in little Endian
	
        while(length_string(cText2))
        {
            local_var integer i
            local_var char cText3[64]			// 512 Bit Blocks
            local_var char cText4[16][4]		// 16 32 Bit Blocks
            local_var long lText4[16]			// 16 32 Bit Blocks
            
            local_var long lf
            local_var long lg
            local_var long ltemp
            
            cText3 = get_buffer_string(cText2,64)
            
            for(i=1;i<=16;i++)
            {
                cText4[i] = get_buffer_string(cText3,4)
                lText4[i] = (cText4[i][1])+(cText4[i][2]*256)+(cText4[i][3]*65536)+(cText4[i][4]*16777216)
            }
            
            for(i=0;i<=63;i++)
            {
                select
                {
                    active(i<=15):
                    {
                    lf=(lb BAND lc) BOR ((BNOT lb) BAND ld)
                    lg=i
                    }
                    active(i<=31):
                    {
                    lf=(ld BAND lb) BOR ((BNOT ld) BAND lc)
                    lg=(5*i+1)%16
                    }
                    active(i<=47):
                    {
                    lf=lb BXOR lc BXOR ld
                    lg=(3*i+5)%16
                    }
                    active(i<=63):
                    {
                    lf=lc BXOR (lb BOR (BNOT ld))
                    lg=(7*i)%16
                    }
                }
                
                ltemp = ld
                ld = lc
                lc = lb
                lb = lb + leftrotate((la+lf+lk[i+1]+lText4[lg+1]),lr[i+1])
                la = ltemp
            }
            
            lh0 = lh0 + la
            lh1 = lh1 + lb
            lh2 = lh2 + lc
            lh3 = lh3 + ld
        }
        
        cResult = "format('%02x',lh0%256),format('%02x',(lh0/256)%256),format('%02x',(lh0/65536)%256),format('%02x',lh0/16777216),
                   format('%02x',lh1%256),format('%02x',(lh1/256)%256),format('%02x',(lh1/65536)%256),format('%02x',lh1/16777216),
                   format('%02x',lh2%256),format('%02x',(lh2/256)%256),format('%02x',(lh2/65536)%256),format('%02x',lh2/16777216),
                   format('%02x',lh3%256),format('%02x',(lh3/256)%256),format('%02x',(lh3/65536)%256),format('%02x',lh3/16777216)"
    }

    define_function char[32] fnDeviceToString(dev dvDev)
    {
        stack_var char sDevice[32]
        sDevice = "itoa(dvDev.NUMBER),':',itoa(dvDev.PORT),':',itoa(dvDev.SYSTEM)"
	
    }

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

    define_function fnDebugIntoHex(char sDebug[])
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

(*******************************************)
(*		    	END OF PROGRAM			   *)
(*******************************************) 