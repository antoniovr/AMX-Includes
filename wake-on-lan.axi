program_name='wake-on-lan'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/15/2021  AT: 08:00:23        *)
(***********************************************************)

#if_not_defined __WAKE_ON_LAN__
#define __WAKE_ON_LAN__

/*
 * --------------------
 * Wake On Lan devices
 * --------------------
 */

DEFINE_DEVICE

    #warn 'Wake-on-lan: Define the IP socket in the main program or leave it this way (0:15:0)'
    #if_not_defined dvIpSocketWakeOnLan
	dvIpSocketWakeOnLan = 0:15:0
    #end_if

/*
 * --------------------
 * Wake On Lan constants
 * --------------------
 */

DEFINE_CONSTANT

    integer WAKE_ON_LAN_MAGIC_PACKET_BYTE_SIZE  = 102

    integer WAKE_ON_LAN_UDP_LISTENING_PORT      = 9 // udp port 7 also works for WOL

    char WAKE_ON_LAN_MAGIC_PACKET_HEADER[]      = {$FF,$FF,$FF,$FF,$FF,$FF}

    char WAKE_ON_LAN_BROADCAST_ADDRESS[]        = '255.255.255.255'


/*
 * --------------------
 * Wake On Lan variables
 * --------------------
 */

DEFINE_VARIABLE

    integer waitTimeSendWakeOnLanPacketAfterOpeningUdpSocket = 0


/*
 * --------------------
 * Wake On Lan functions
 * --------------------
 */


/*
 * --------------------
 * Function: wakeOnLan
 *
 * Parameters:  char macAddress[] - mac address (in raw hex form, not ASCII)
 * 
 * Description: Builds and sends a Wake-On-Lan magic packet. Uses 255.255.255.255 as
 *              the broadcast address.
 * --------------------
 */
define_function fnWakeOnLan(char macAddress[])
{
    local_var char wakeOnLanMagicPacket[102]   // need to be a local_var to go inside wait statement
    stack_var integer i
    
    wakeOnLanMagicPacket = "WAKE_ON_LAN_MAGIC_PACKET_HEADER"
    
    for (i = 1; i <= 16; i++)
    {
	wakeOnLanMagicPacket = "wakeOnLanMagicPacket,macAddress"
    }
    
    ip_client_open (dvIpSocketWakeOnLan.port, WAKE_ON_LAN_BROADCAST_ADDRESS, WAKE_ON_LAN_UDP_LISTENING_PORT, IP_UDP)
    send_string dvIpSocketWakeOnLan,wakeOnLanMagicPacket
    ip_client_close (dvIpSocketWakeOnLan.port)
}

/*
 * --------------------
 * Function: wakeOnLanSpecifyBroadcastAddress
 *
 * Parameters:  char macAddress[] - mac address (in raw hex form, not ASCII)
 *              char broadcastAddress[] - broadcast IP address
 * 
 * Description: Builds and sends a Wake-On-Lan magic packet.
 * --------------------
 */
define_function wakeOnLanSpecifyBroadcastAddress (char macAddress[], char broadcastAddress[])
{
    local_var char wakeOnLanMagicPacket[102]   // need to be a local_var to go inside wait statement
    stack_var integer i
    
    wakeOnLanMagicPacket = "WAKE_ON_LAN_MAGIC_PACKET_HEADER"
    
    for (i = 1; i <= 16; i++)
    {
	wakeOnLanMagicPacket = "wakeOnLanMagicPacket,macAddress"
    }
    
    ip_client_open (dvIpSocketWakeOnLan.port, broadcastAddress, WAKE_ON_LAN_UDP_LISTENING_PORT, IP_UDP)
    send_string dvIpSocketWakeOnLan,wakeOnLanMagicPacket
    ip_client_close (dvIpSocketWakeOnLan.port)
}

#end_if


(********************************************)
(*             END OF PROGRAM               *)
(********************************************) 