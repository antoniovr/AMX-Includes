PROGRAM_NAME='KeyValue'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/19/2019  AT: 10:55:11        *)
(***********************************************************)

/*-----------------------------------------------------------
   About:
  -----------------------------------
   Title    - KeyValue
   Desc.    - Helpers for key/value pairs.

-----------------------------------------------------------*/

#IF_NOT_DEFINED KeyValue
#DEFINE KeyValue

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//-- Key/Value settings -------------------------------------
#IF_NOT_DEFINED TOTAL_KEY_COUNT       TOTAL_KEY_COUNT     = 20                            #END_IF
#IF_NOT_DEFINED KEY_LENGTH            KEY_LENGTH          = 60                            #END_IF
#IF_NOT_DEFINED VALUE_LENGTH          VALUE_LENGTH        = 100                           #END_IF


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

//-- Key/Value pairs ----------------------------------------
#IF_NOT_DEFINED KEY_VALUE_TYPE_DEFINED
  STRUCTURE _uKeyData
  {
    CHAR  cKey[KEY_LENGTH]
    CHAR  cValue[VALUE_LENGTH]
  }

  STRUCTURE _uKeys
  {
    INTEGER   nCount
    _uKeyData uData[TOTAL_KEY_COUNT]
  }
#END_IF


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

//--------------------------------------------------------------------------------------------------------------------
// Helper routines for key/value pairs.
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Add (or update) a key/value pair.
//-----------------------------------------------------
DEFINE_FUNCTION INTEGER keyAdd (_uKeys uKeys, CHAR cKey[], CHAR cValue[])
STACK_VAR
  INTEGER nIdx
{
  nIdx = keyGetIndex (uKeys, cKey)
  IF(nIdx > 0) {
    uKeys.uData[nIdx].cValue = cValue
    RETURN(nIdx)
  }

  IF(uKeys.nCount < TOTAL_KEY_COUNT) {
    uKeys.nCount++
    uKeys.uData[uKeys.nCount].cKey   = cKey
    uKeys.uData[uKeys.nCount].cValue = LEFT_STRING(cValue, VALUE_LENGTH)
    RETURN(uKeys.nCount)
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Get a key (return index, passback value).
//-----------------------------------------------------
DEFINE_FUNCTION INTEGER keyGet (_uKeys uKeys, CHAR cKey[], CHAR cValue[])
STACK_VAR
  INTEGER nIdx
{
  nIdx = keyGetIndex (uKeys, cKey)
  IF(nIdx = 0) {
    cValue = ''
    RETURN(FALSE)
  }

  cValue = uKeys.uData[nIdx].cValue
  RETURN(nIdx)
}

//-----------------------------------------------------
// Get a key's index.
//-----------------------------------------------------
DEFINE_FUNCTION INTEGER keyGetIndex (_uKeys uKeys, CHAR cKey[])
STACK_VAR
  INTEGER nLoop
{
  FOR(nLoop=1; nLoop<=uKeys.nCount; nLoop++) {
    IF(uKeys.uData[nLoop].cKey = cKey) {
      RETURN(nLoop)
    }
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Get a key's value.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[VALUE_LENGTH] keyGetValue (_uKeys uKeys, CHAR cKey[])
STACK_VAR
  INTEGER nIdx
{
  nIdx = keyGetIndex (uKeys, cKey)
  IF(nIdx = 0) {
    RETURN('')
  }

  RETURN(uKeys.uData[nIdx].cValue)
}

//-----------------------------------------------------
// Get a key's boolean.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR keyGetBoolean (_uKeys uKeys, CHAR cKey[])
STACK_VAR
  INTEGER nIdx
{
  nIdx = keyGetIndex (uKeys, cKey)
  IF(nIdx = 0) {
    RETURN(FALSE)
  }

  RETURN(LOWER_STRING(uKeys.uData[nIdx].cValue) = 'true')
}

//-----------------------------------------------------
// Get a key's value (return value or assign a default).
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[VALUE_LENGTH] keyGetOrDefault (_uKeys uKeys, CHAR cKey[], CHAR cDefault[])
STACK_VAR
  INTEGER nIdx
{
  nIdx = keyGetIndex (uKeys, cKey)
  IF(nIdx = 0) {
    IF(keyAdd (uKeys, cKey, cDefault))
      RETURN(cDefault)
    ELSE
      RETURN('')
  }

  RETURN(uKeys.uData[nIdx].cValue)
}

//-----------------------------------------------------
// Reset all keys.
//-----------------------------------------------------
DEFINE_FUNCTION keyResetAll (_uKeys uKeys)
STACK_VAR
  INTEGER nLoop
  _uKeyData uDataBlank
{
  FOR(nLoop=1; nLoop<=uKeys.nCount; nLoop++) {
    uKeys.uData[nLoop] = uDataBlank
  }

  uKeys.nCount = 0
}

#END_IF

(***********************************************************)
(*		    	EARPRO 2019   			   *)
(***********************************************************) 