#ifndef FD_DLP_HC_H
#define FD_DLP_HC_H
///====================================

#include <stdio.h>
#include <winsock2.h>
#include <windows.h>
#include <time.h>
#include <math.h>
#include <dirent.h>

// # define FD_DLP_HC_API extern "C" __declspec(dllexport)
# define FD_DLP_HC_API __declspec(dllexport)

#define FD_DLP_FORMAT_LENGTH_CMD 4     //The Length of CMD_HEAD  4byte
#define FD_DLP_FORMAT_LENGTH_HEAD 4    //The Length of HEAD      4byte
#define FD_DLP_FORMAT_LENGTH_TAIL 8    //The Length of TAIL      8byte

#define FD_DLP_FORMAT_FLAG_HEAD    0xF5    //HEAD
#define FD_DLP_FORMAT_FLAG_TAIL    0x0D    //TAIL

#define FLD_DLP_FORMAT_FLAG_PARAM_QUERY 0x80 //Query Command Header

///====================================


/// @breif: SSD and DDR type
typedef  int  FD_DLP_DMD_TYPE_CODE;
enum FD_DLP_DMD_TYPE{
    FD_DLP_SAVE_TYPE_DDR = 0,
    FD_DLP_SAVE_TYPE_SSD = 1,
};

/// @brief: resolution type
typedef int FD_DLP_RESOLUTION_TYPE_CODE;
enum FD_DLP_RESOLUTION_TYPE {
    FD_DLP_RES_NULL,
    FD_DLP_RES_095_1080P,  // 0.95 1080p    1920*1080
    FD_DLP_RES_070_XGA,    // 0.7  XGA      1024*768
    FD_DLP_RES_055_XGA,    // 0.55 XGA      1024*768
    FD_DLP_RES_096_WUXGA,  // 0.96  WUXGA   1920*1200
    FD_DLP_RES_065_WXGA,   // 0.65  WXGA    1280*800
    FD_DLP_RES_065_1080P,  // 0.65  1080P   1920*1080
    FD_DLP_RES_090_WQXGA   // 0.9   WQXGA   2560*1600
};

///@brief:Device Info
typedef struct {

    unsigned long long sectors_signal;        //Number of sectors of a single disk
    unsigned int delaytime;                   //Delay parameters

    unsigned int ssd_init_info;               //[use]Hard disk initialization information
    bool ssd_init;                            //Hard disk Initialization status

    unsigned int size_signal;                 //[use]Single memory storage capacity
    unsigned int ssd_count;                   //[use]Number of storage containers
    FD_DLP_DMD_TYPE_CODE save_type;           //[use]Memory type

    unsigned int software_version_sub;        //Software version: after decimal point
    unsigned int software_version_main;       //Software version: before decimal point

    FD_DLP_RESOLUTION_TYPE_CODE resolution;   //[use]resolving power

    unsigned long long image_load_count;      //Number of loaded pictures

    unsigned long long free_all;              //Number of pictures that can be stored
    unsigned long long Address_add;           //[use]Address increment
} FD_DLP_HC_Dev_Info;

typedef struct{

    int DeviceID;                        //ID

    SOCKET rece_socket;                  //UDP socket

    SOCKADDR_IN udp_Up_ctx;              //Upper computer
    SOCKADDR_IN udp_Down_ctx;            //Lower machine

    FD_DLP_HC_Dev_Info DeviceInfo;       //Device Info

}FD_DLP_HC_Device;


///@brief: RESULT CODE
typedef int FD_DLP_HC_RESULT_CODE;
enum FD_DLP_HC_RESULT_TYPE{
    FD_DLP_HC_RESULT_SUCCESS = 0,      // SUCCESS
    FD_DLP_HC_RESULT_SERVER_CLOSED,    // udp server closed
    FD_DLP_HC_RESULT_ACTION_COMPLETED, // action completed (for single play, pause)
    FD_DLP_HC_RESULT_QUERY_COMPLETED,  // query parameter completed
};

///@brief:ERROR CODE
enum FD_DLP_HC_RESULT_ERR_TYPE {

    FD_DLP_HC_RESULT_ERR_socketCreateFail =-100,      //Socket creation failed
    FD_DLP_HC_RESULT_ERR_socketBindFail,              //Bind fail
    FD_DLP_HC_RESULT_ERR_socketreceError,             //receive error

    FD_DLP_HC_RESULT_ERR_CMDTypeError,                //Command type error

    FD_DLP_HC_RESULT_ERR_SendFail,                    //(Command or image) sending failed
    FD_DLP_HC_RESULT_ERR_CMD_Play_startpicError,      //Start position of play command is less than 1
    FD_DLP_HC_RESULT_ERR_CMD_Play_picnumError ,       //Play CMD number of pic error
    FD_DLP_HC_RESULT_ERR_CMD_Play_resolutionError ,   //Play CMD Resolution and number of storage containers do not match

    FD_DLP_HC_RESULT_ERR_CMD_Param1_picbitError,      //Param 1 CMD Gray level parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param1_delaytimeError,   //Param 1 CMD Delay parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param1_PicNumFlagError,  //Param 1 CMD Write clear picture quantity parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param1_picnumError ,     //Param 1 CMD Number of pic is not a multiple of eight

    FD_DLP_HC_RESULT_ERR_CMD_Param2_UDError,         //Param 2 CMD  The upper and lower mirror parameters error
    FD_DLP_HC_RESULT_ERR_CMD_Param2_DRError,         //Param 2 CMD  Data reverse parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param2_HXZError,        //Param 2 CMD  Row addressing parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param2_SRError,         //Param 2 CMD  Input trigger parameters error
    FD_DLP_HC_RESULT_ERR_CMD_Param2_SCError,         //Param 2 CMD  Output trigger parameter error
    FD_DLP_HC_RESULT_ERR_CMD_Param2_FFError,         //Param 2 CMD  Screen splitting trigger parameter error

    FD_DLP_HC_RESULT_ERR_DataisnotQueryCMD,          //Data is not query command feedback

    FD_DLP_HC_RESULT_ERR_SendPic_picnumError ,       //Send CMD Number of pic is not a multiple of eight
    FD_DLP_HC_RESULT_ERR_SendPicError,               //Send CMD Failed to send image
    FD_DLP_HC_RESULT_ERR_SendPicSendtypeError,       //Send CMD Error sending image category

                                                   //Category 1: Binary image folder
    FD_DLP_HC_RESULT_ERR_SendPic1_openBMPDirError,   //BMP folder open failed
    FD_DLP_HC_RESULT_ERR_SendPic1_BMPDirnumXYpicnum, //The number of BMP folder pictures is less than the number of sending targets

                                                   //Category 2: 8-bit grayscale image folder
    FD_DLP_HC_RESULT_ERR_SendPic2_openBMPDirError,   //BMP folder open failed
    FD_DLP_HC_RESULT_ERR_SendPic2_BMPDirnumXYpicnum, //The number of BMP folder pictures is less than the number of sending targets

                                                   //Category 3: bin file
    FD_DLP_HC_RESULT_ERR_SendPic3_openBinError,      //Bin file open failed

                                                   //Category: Real time picture transmission
    FD_DLP_HC_RESULT_ERR_RealtimeSP_SendtypeError,   //Real time transmission command type error

    FD_DLP_HC_RESULT_ERR_RealtimeSP_OpenBMPfail,     //Bin file open failed
    FD_DLP_HC_RESULT_ERR_RealtimeSP_readBMP30fail,   //BMP read failed before 30
    FD_DLP_HC_RESULT_ERR_RealtimeSP_picError,        //BMP image does not meet the requirements
    FD_DLP_HC_RESULT_ERR_RealtimeSP_readBMPPPYfail,  //BMP failed to read offer-30
    FD_DLP_HC_RESULT_ERR_RealtimeSP_readBMPDataError,//BMP failed to read image data


};

///@brief:CMD_TYPE
typedef int FD_DLP_CMD_TYPE_CODE;
enum FD_DLP_UDP_CMD_TYPE {
    FD_DLP_CMD_LOAD_IMAGE = 0,         // load image
    FD_DLP_CMD_INTER_PLAY_SINGLE,      // internal single play
    FD_DLP_CMD_INTER_PLAY_LOOP,        // internal loop play
    FD_DLP_CMD_EXTER_PLAY_SINGLE,      // exter single play
    FD_DLP_CMD_EXTER_PLAY_LOOP,        // exter loop play
    FD_DLP_CMD_PLAY_STOP,              // stop play
    FD_DLP_CMD_SET_PARAM_1,            // set parameter 1
    FD_DLP_CMD_PARAM_QUERY,            // query
    FD_DLP_CMD_SET_PARAM_2,            // set parameter 2
    FD_DLP_CMD_DLP_RST,                // dlp_reset
    FD_DLP_CMD_DLP_FLOAT,              // dlp_float
    FD_DLP_CMD_PLAY_PAUSE,             // pause play
    FD_DLP_CMD_PLAY_REALTIME,          // real time play
    FD_DLP_CMD_Device_RESET,           // reset Device
    FD_DLP_CMD_MAX,                    //
};

/// @brief: CMD_HEAD array
const unsigned char FD_DLP_Fix_Cmd_Flag_Array[FD_DLP_CMD_MAX] = {
    0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70,
    0x80, 0x90, 0x91, 0x92, 0x93, 0xa0, 0xB0
 };

/// @brief:DMD param array
typedef struct CMD_Paramstruct{
    long long CMD_Param1;
    long long CMD_Param2;
    long long CMD_Param3;
    long long CMD_Param4;
    long long CMD_Param5;
    long long CMD_Param6;
    long long CMD_Param7;
    long long CMD_Param8;
    long long CMD_Param9;
    long long CMD_Param10;
}FD_DLP_HC_CMD_Param,*pFD_DLP_HC_CMD_Param;

///====================================

/// @brief: Initialize the UDP ;Bind host computer IP and port,Enter the IP and port of the lower computer
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Init(int DeviceID,char* server_addr,int server_port,char* target_addr,int target_port);

/// @brief: Close UDP
FD_DLP_HC_API void FD_DLP_HC_DeInit(int DeviceID);

/// @brief: CMD withnot param
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_Fixed_Cmd_Noparam(int DeviceID, FD_DLP_CMD_TYPE_CODE type);

/// @brief: Receive UDP Info
FD_DLP_HC_API int FD_DLP_HC_Reveive(int DeviceID,unsigned char *buff);

/// @brief: CMD with param
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_CMD_Play(int DeviceID,FD_DLP_CMD_TYPE_CODE type,int Param_StartP,int Param_PlayPicnum);

/// @brief: CMD-SetParam1
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_Cmd_SetParam1(int DeviceID,int Param_Delay,int Param_Gray,int Param_Picnum,int Param_PicNumFlag);

/// @brief: CMD-SetParam2
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_Cmd_SetParam2(int DeviceID,char Param_1[3],char Param_Trigger[3],int Param_FD);


/// @brief: The analysis and query command returns to obtain the device informationa
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_AnalysisDevice(int DeviceID,unsigned char buff[32],unsigned char *DeviceInfo,int * DeviceInfolen);

/// @brief: CMD-Custom Commands
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_Custom_Cmd(int DeviceID, unsigned char* data, int len);

/// @brief: CMD-Send loaded pictures
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_Send_PICDATA(int DeviceID,int sendpic_type,char * pic_addr,int pic_num,int Param_StartPicPosition,char * PicData);

/// @brief: CMD-Send loaded pictures
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE M_FD_DLP_HC_Send_PICDATA(int DeviceID,int sendpic_type,char * pic_addr,int pic_num,int Param_StartPicPosition,unsigned char * PicData);

/// @brief:CMD-Send real time pictures
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE FD_DLP_HC_RealtimeSend_PICDATA(int DeviceID, char * pic_addr,char * picdata,int sendpic_type);

/// @brief:CMD-Send real time pictures
FD_DLP_HC_API FD_DLP_HC_RESULT_CODE M_FD_DLP_HC_RealtimeSend_PICDATA(int DeviceID, char * pic_addr,unsigned char * picdata,int sendpic_type);



///====================================

#endif // FD_DLP_HC_H
