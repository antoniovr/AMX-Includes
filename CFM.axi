PROGRAM_NAME='CFM'
(***********************************************************)
(*  FILE CREATED ON: 10/14/2019  AT: 22:07:07              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 12/21/2020  AT: 11:39:41        *)
(***********************************************************)

#include 'SwitcherInOut'

DEFINE_DEVICE

	dvAtem = 0:19:0

DEFINE_CONSTANT
   
    integer _GENERAL_CAMERA = 1
    integer _GENERAL_PRESET = 10  
	
DEFINE_VARIABLE

    volatile integer anMicStatusAux[_MAX_UNITS] //0=close 1=open 2=request

    volatile integer nMicOpened = 0
    volatile integer nMicClosed = 0
    
    volatile integer nNumberOfMics = 0

    volatile integer anListOrderOfPeopleSpeaking[10]
    volatile integer anListOrderOfPeopleSpeakingAux[10]

    volatile integer nSpeakerCam = _GENERAL_CAMERA
    volatile integer nSpeakerPreset = _GENERAL_PRESET
      
DEFINE_START

    define_function fnCallPresetAfterMicOpened()
    {
        fnInfo("'SYS: fnCallPresetAfterMicOpened ------------------> MIC OPENED: ',itoa(nMicOpened)")
        if(nNumberOfMics>=2)
        {
	    nSpeakerCam = _GENERAL_CAMERA
            fnCamPreset(_GENERAL_CAMERA,_GENERAL_PRESET)
        }
        else
        {
            nSpeakerCam = anCameras[nMicOpened]
            nSpeakerPreset = anPresets[nMicOpened]
            fnCamPreset(nSpeakerCam,nSpeakerPreset)
        }

        //wait 35
        //{
            fnShowCamera(nSpeakerCam)
        //}
    }
    
    define_function fnShowCamera(integer nCam)
    {
        stack_var integer nIn
        stack_var integer i
        fnInfo("'fnShowCamera(',itoa(nCam),')'")
        switch(nCam)
        {
            case 1: {nIn = _MTX_IN_CAM_1}
            case 2: {nIn = _MTX_IN_CAM_2}
            case 3: {nIn = _MTX_IN_CAM_3}
        }

        fnSwitch(vdvSwitcher,_LEVEL_VIDEO,nIn,i)
	}

    define_function fnAddPersonToTheSpeakingList(nMicOpened)
    {
        stack_var integer i
        fnDebug("'SYS: fnAddPersonToTheSpeakingList: nMicCLosed: ',itoa(nMicClosed)")
        for(i=1;i<=max_length_array(anListOrderOfPeopleSpeaking);i++)
        {
            if(anListOrderOfPeopleSpeaking[i] == 0) 
            {
            anListOrderOfPeopleSpeaking[i] = nMicOpened
            break;
            }
        }
    }
    
    define_function fnRemovePersonToTheSpeakingList(nMicClosed)
    {
        stack_var integer i
        fnDebug("'SYS: fnRemovePersonToTheSpeakingList: nMicCLosed: ',itoa(nMicClosed)")
        for(i=1;i<=max_length_array(anListOrderOfPeopleSpeaking);i++)
        {
            if(anListOrderOfPeopleSpeaking[i] == nMicClosed)
            {
            anListOrderOfPeopleSpeaking[i] = 0
            break;
            }
        }
        
        fnReorderSpeakingList()
    }
    
    define_function fnReorderSpeakingList()
    {
        stack_var integer i,j
        j = 1
        for(i=1;i<=max_length_array(anListOrderOfPeopleSpeakingAux);i++)
        {
            anListOrderOfPeopleSpeakingAux[i] = 0
        }
        for(i=1;i<=max_length_array(anListOrderOfPeopleSpeaking);i++)
        {
            if(anListOrderOfPeopleSpeaking[i] > 0)
            {
            anListOrderOfPeopleSpeakingAux[j] = anListOrderOfPeopleSpeaking[i]
            j++
            }
        }
        
        anListOrderOfPeopleSpeaking = anListOrderOfPeopleSpeakingAux
    }


    define_function fnCamerasFollowingMics()
    {
        if(bCamFollowingMic)
        {
            stack_var integer i
            stack_var integer j
            for(i=1;i<=max_length_array(anMicStatus[_MAX_UNITS]);i++)
            {
            if(anMicStatusAux[i] != anMicStatus[i])
            {
                anMicStatusAux[i] = anMicStatus[i]
                if(anMicStatus[i] == 1) // <------------------------------------------------------------------ MIC OPENED
                {
                    nMicOpened = i
                    fnAddPersonToTheSpeakingList(nMicOpened)
                    nNumberOfMics++
                    if (nNumberOfMics>=2)
                    {
                        fnDebug("'CFM: 2 MICS OPENED -> WE LOOK FOR THAT SECOND MIC'")
                        fnCallPresetAfterMicOpened()
                    }
                    else
                    {
                        fnDebug("'CFM: 1 MIC OPENED ->  PRESET FOR THAT MIC'")
                        fnCallPresetAfterMicOpened()
                    }
                }
                else if(anMicStatus[i] == 0) // <-------------------------------------------------------------- MIC CLOSED
                {
                nMicClosed = i
                fnRemovePersonToTheSpeakingList(nMicClosed)
                nNumberOfMics--	
                
                for(j=max_length_array(anListOrderOfPeopleSpeaking);j>=1;j--)
                {
                    if(anListOrderOfPeopleSpeaking[j])
                    {
                    nMicOpened = anListOrderOfPeopleSpeaking[j]
                    if (nNumberOfMics >= 2)
                    {
                        fnDebug("'CFM: CamerasFollowingMics-> +2 MICS OPENED -> GENERAL PRESET'")
                        fnCallPresetAfterMicOpened()		
                    }
                    else
                    {
                        fnDebug("'CFM: CamerasFollowingMics-> 1 MIC OPENED ->  PRESET FOR THAT MIC'")
                        fnCallPresetAfterMicOpened()			
                    }
                    break;
                    }
                }
                
                if (nNumberOfMics == 0)
                {
                    fnDebug("'CFM: CamerasFollowingMics-> 0 MICS OPENED -> GENERAL PRESET'")
                    fnCamPreset(_CAM_1,1)
                    fnCamPreset(_CAM_2,1)
                    fnCamPreset(_CAM_3,1)
                    nSpeakerCam = _GENERAL_CAMERA
                    nSpeakerPreset = _GENERAL_PRESET
                    nMicOpened = 0
                    nMicClosed = 0
                    wait 5
                    {
                        fnShowCamera(nSpeakerCam)
                    }
                }
                }
            }
            }				
        }
    }
	

DEFINE_EVENT

    data_event[vdvSystem]
    {
        command:
        {
            // We are not using it at this moment
        }
    }

    timeline_event[_TLID]
    {
		fnCamerasFollowingMics()
    }