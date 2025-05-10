#ifndef VirtualAudioDriver_h
#define VirtualAudioDriver_h

#include <CoreAudio/AudioServerPlugIn.h>
#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// Estructura para mantener el estado del driver
typedef struct VirtualAudioDriver {
    AudioServerPlugInDriverRef driverRef;
    AudioObjectID deviceID;
    Boolean isRunning;
    Float32 masterVolume;
    CFMutableDictionaryRef appVolumes;
} VirtualAudioDriver;

// Funciones principales del driver
OSStatus VirtualAudioDriver_Initialize(VirtualAudioDriver* driver);
OSStatus VirtualAudioDriver_Start(VirtualAudioDriver* driver);
OSStatus VirtualAudioDriver_Stop(VirtualAudioDriver* driver);
OSStatus VirtualAudioDriver_SetAppVolume(VirtualAudioDriver* driver, pid_t pid, Float32 volume);
OSStatus VirtualAudioDriver_GetAppVolume(VirtualAudioDriver* driver, pid_t pid, Float32* volume);

// Callbacks del AudioServerPlugIn
OSStatus VirtualAudioDriver_DeviceIOProc(
    AudioServerPlugInDriverRef driver,
    AudioObjectID deviceID,
    const AudioTimeStamp* now,
    const AudioBufferList* inputData,
    const AudioTimeStamp* inputTime,
    AudioBufferList* outputData,
    const AudioTimeStamp* outputTime,
    void* clientData
);

#ifdef __cplusplus
}
#endif

#endif /* VirtualAudioDriver_h */ 