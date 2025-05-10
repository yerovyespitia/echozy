#include "VirtualAudioDriver.h"
#include <pthread.h>
#include <mach/mach.h>

// Constantes
#define kVirtualAudioDriver_Manufacturer "Echozy"
#define kVirtualAudioDriver_Name "Echozy Virtual Audio"
#define kVirtualAudioDriver_UID "com.echozy.virtualaudio"

// Variables globales
static pthread_mutex_t gDriverMutex = PTHREAD_MUTEX_INITIALIZER;
static VirtualAudioDriver gDriver = {0};

// Implementación de las funciones principales
OSStatus VirtualAudioDriver_Initialize(VirtualAudioDriver* driver) {
    if (!driver) return kAudioHardwareBadObjectError;
    
    pthread_mutex_lock(&gDriverMutex);
    
    // Inicializar el diccionario de volúmenes por aplicación
    driver->appVolumes = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks,
        &kCFTypeDictionaryValueCallBacks
    );
    
    driver->masterVolume = 1.0f;
    driver->isRunning = false;
    
    pthread_mutex_unlock(&gDriverMutex);
    return noErr;
}

OSStatus VirtualAudioDriver_Start(VirtualAudioDriver* driver) {
    if (!driver) return kAudioHardwareBadObjectError;
    
    pthread_mutex_lock(&gDriverMutex);
    
    // Configurar el dispositivo virtual
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyProcessIsMaster,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };
    
    UInt32 isMaster = 1;
    OSStatus status = AudioObjectSetPropertyData(
        kAudioObjectSystemObject,
        &propertyAddress,
        0,
        NULL,
        sizeof(isMaster),
        &isMaster
    );
    
    if (status == noErr) {
        driver->isRunning = true;
    }
    
    pthread_mutex_unlock(&gDriverMutex);
    return status;
}

OSStatus VirtualAudioDriver_Stop(VirtualAudioDriver* driver) {
    if (!driver) return kAudioHardwareBadObjectError;
    
    pthread_mutex_lock(&gDriverMutex);
    driver->isRunning = false;
    pthread_mutex_unlock(&gDriverMutex);
    
    return noErr;
}

OSStatus VirtualAudioDriver_SetAppVolume(VirtualAudioDriver* driver, pid_t pid, Float32 volume) {
    if (!driver) return kAudioHardwareBadObjectError;
    
    pthread_mutex_lock(&gDriverMutex);
    
    CFNumberRef pidNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &pid);
    CFNumberRef volumeNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat32Type, &volume);
    
    if (pidNumber && volumeNumber) {
        CFDictionarySetValue(driver->appVolumes, pidNumber, volumeNumber);
    }
    
    if (pidNumber) CFRelease(pidNumber);
    if (volumeNumber) CFRelease(volumeNumber);
    
    pthread_mutex_unlock(&gDriverMutex);
    return noErr;
}

OSStatus VirtualAudioDriver_GetAppVolume(VirtualAudioDriver* driver, pid_t pid, Float32* volume) {
    if (!driver || !volume) return kAudioHardwareBadObjectError;
    
    pthread_mutex_lock(&gDriverMutex);
    
    CFNumberRef pidNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &pid);
    CFNumberRef volumeNumber = NULL;
    
    if (pidNumber) {
        volumeNumber = (CFNumberRef)CFDictionaryGetValue(driver->appVolumes, pidNumber);
        if (volumeNumber) {
            CFNumberGetValue(volumeNumber, kCFNumberFloat32Type, volume);
        } else {
            *volume = 1.0f; // Volumen por defecto
        }
    }
    
    if (pidNumber) CFRelease(pidNumber);
    
    pthread_mutex_unlock(&gDriverMutex);
    return noErr;
}

OSStatus VirtualAudioDriver_DeviceIOProc(
    AudioServerPlugInDriverRef driver,
    AudioObjectID deviceID,
    const AudioTimeStamp* now,
    const AudioBufferList* inputData,
    const AudioTimeStamp* inputTime,
    AudioBufferList* outputData,
    const AudioTimeStamp* outputTime,
    void* clientData
) {
    VirtualAudioDriver* virtualDriver = (VirtualAudioDriver*)clientData;
    if (!virtualDriver || !virtualDriver->isRunning) return kAudioHardwareBadObjectError;
    
    // Obtener el PID del proceso actual
    pid_t pid = mach_task_self();
    
    // Obtener el volumen para esta aplicación
    Float32 appVolume;
    VirtualAudioDriver_GetAppVolume(virtualDriver, pid, &appVolume);
    
    // Aplicar el volumen al buffer de salida
    for (UInt32 i = 0; i < outputData->mNumberBuffers; i++) {
        Float32* buffer = (Float32*)outputData->mBuffers[i].mData;
        UInt32 frames = outputData->mBuffers[i].mDataByteSize / sizeof(Float32);
        
        for (UInt32 frame = 0; frame < frames; frame++) {
            buffer[frame] *= appVolume * virtualDriver->masterVolume;
        }
    }
    
    return noErr;
} 