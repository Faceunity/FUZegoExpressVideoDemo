//
//  ZGVideoFrameEncoder.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/9.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoCapture

#import "ZGVideoFrameEncoder.h"
#include <VideoToolbox/VideoToolbox.h>
#include <CoreMedia/CMFormatDescriptionBridge.h>
#include <string>
#include "big_endian.h"

@interface ZGVideoFrameEncoder ()

@property (nonatomic, assign) VTCompressionSessionRef compressionSession;

@property (nonatomic, assign) dispatch_queue_t compressionQueue;

@end

@implementation ZGVideoFrameEncoder

- (instancetype)initWithResolution:(CGSize)resolution maxBitrate:(int)maxBitrate averageBitrate:(int)averageBitrate fps:(int)fps {
    self = [super init];
    if (self) {

        _compressionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        dispatch_sync(_compressionQueue, ^{
            // Create the compression session
            OSStatus status = VTCompressionSessionCreate(NULL, (int)resolution.width, (int)resolution.height, kCMVideoCodecType_H264, NULL, NULL, NULL, videoFrameFinishedEncoding, (__bridge void *)(self),  &_compressionSession);

            if (status != 0) {
                NSLog(@"[%s] VTCompressionSessionCreate failed, status: %d", __FILE_NAME__, status);
                return;
            }

            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue); // Real Time
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel); // Profile Level
            VTSessionSetProperty(_compressionSession , kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse); // Disable B frame

            // Key frame inaterval
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)(@(fps))); // GOP: 30
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)(@(1)));

            // Set fps, bitrate
//            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)(@(fps))); // 30fps
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)@[@(maxBitrate / 8), @1.0]); // 3500 * 1000
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(averageBitrate)); // 3000 * 1000

            // Tell the encoder to start encoding
            VTCompressionSessionPrepareToEncodeFrames(_compressionSession);

        });
    }
    return self;
}

- (void)dealloc {
    // Mark the completion
    VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
    // End the session
    VTCompressionSessionInvalidate(_compressionSession);
}

- (void)setMaxBitrate:(int)maxBitrate averageBitrate:(int)averageBitrate fps:(int)fps {
    NSLog(@"Set maxBitrate: %d, avgBitrate: %d, fps: %d", maxBitrate, averageBitrate, fps);
    // Key frame inaterval
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)(@(fps)));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)(@(1)));

    // Set fps, bitrate
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)(@(fps)));
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)@[@(maxBitrate / 8), @1.0]);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(averageBitrate));
}

- (void)encodeBuffer:(CMSampleBufferRef)buffer {
    dispatch_sync(_compressionQueue, ^{

        // Get the CV Image buffer
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(buffer);

        // Create properties
        VTEncodeInfoFlags infoFlagsOut;

        CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

        CMTime presentationTimestamp = CMSampleBufferGetOutputPresentationTimeStamp(buffer);
        CMTime duration = CMSampleBufferGetOutputDuration(buffer);


        // Pass it to the encoder
        OSStatus statusCode = VTCompressionSessionEncodeFrame(_compressionSession, imageBuffer, presentationTimestamp, duration, NULL, NULL, &infoFlagsOut);
        // Check for error
        if (statusCode != noErr) {
            NSLog(@"[%s] VTCompressionSessionEncodeFrame failed", __FILE_NAME__);
        }

        CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    });
}


void videoFrameFinishedEncoding(void *outputCallbackRefCon,
                                       void *sourceFrameRefCon,
                                       OSStatus status,
                                       VTEncodeInfoFlags infoFlags,
                                       CMSampleBufferRef sampleBuffer) {

    ZGVideoFrameEncoder *encoder = (__bridge ZGVideoFrameEncoder *)outputCallbackRefCon;

    // Check if there were any errors encoding
    if (status != noErr) {
        NSLog(@"Error encoding video, err=%lld", (int64_t)status);
        return;
    }

    bool keyframe = !CFDictionaryContainsKey( (CFDictionaryRef)(CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), (const void *)kCMSampleAttachmentKey_NotSync);

    std::string outputBuffer;

    H264CMSampleBufferToAvccBuffer(sampleBuffer, &outputBuffer, keyframe);

    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    NSData *outputdata = [NSData dataWithBytes:outputBuffer.c_str() length:outputBuffer.size()];

    if ([encoder.delegate respondsToSelector:@selector(encoder:encodedData:isKeyFrame:timestamp:)]) {
        [encoder.delegate encoder:encoder encodedData:outputdata isKeyFrame:keyframe ? YES : NO timestamp:timestamp];
    }
}


void H264CMSampleBufferToAvccBuffer(CMSampleBufferRef sbuf, std::string* output_buffer, bool keyframe) {
    std::string* avcc_buffer = output_buffer;

    // Perform two pass, one to figure out the total output size, and another to
    // copy the data after having performed a single output allocation. Note that
    // we'll allocate a bit more because we'll count 4 bytes instead of 3 for
    // video NALs.
    OSStatus status;
    // Get the sample buffer's block buffer and format description.
    CMBlockBufferRef bb = CMSampleBufferGetDataBuffer(sbuf);
    //DCHECK(bb);
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sbuf);
    //DCHECK(fdesc);
    size_t bb_size = CMBlockBufferGetDataLength(bb);
    size_t total_bytes = bb_size;
    size_t pset_count;
    int nal_size_field_bytes;
    status = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(fdesc, 0, nullptr, nullptr, &pset_count, &nal_size_field_bytes);
    if (status ==
        kCMFormatDescriptionBridgeError_InvalidParameter) {
        //DLOG(WARNING) << " assuming 2 parameter sets and 4 bytes NAL length header";
        pset_count = 2;
        nal_size_field_bytes = 4;
    } else if (status != noErr) {
        //CLog::RT("CMVideoFormatDescriptionGetH264ParameterSetAtIndex failed:%d\n", status);
        return ;
    }

    if (keyframe) {
        const uint8_t* pset;
        size_t pset_size;
        for (size_t pset_i = 0; pset_i < pset_count; ++pset_i) {
            status =
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(fdesc, pset_i, &pset, &pset_size, nullptr, nullptr);
            if (status != noErr) {
                //CLog::RT("CMVideoFormatDescriptionGetH264ParameterSetAtIndex failed:%d\n", status);
                return;
            }
            total_bytes += pset_size + nal_size_field_bytes;
        }
    }
    avcc_buffer->reserve(total_bytes);

    uint8_t* offset = (uint8_t*)avcc_buffer->data();

    // Copy all parameter sets before keyframes.
    if (keyframe) {
        const uint8_t* pset;
        size_t pset_size;
        char nalu_size_4[4] = {0, 0, 0, 0};
        off_t payload_size = 0;
        //ASSERT_D(nal_size_field_bytes == sizeof(nalu_size_4));
        int nal_unit_type = 0;
        for (size_t pset_i = 0; pset_i < pset_count; ++pset_i) {
            status =
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(fdesc, pset_i, &pset, &pset_size, nullptr, nullptr);
            if (status != noErr) {
                //CLog::RT("CMVideoFormatDescriptionGetH264ParameterSetAtIndex failed:%d\n", status);
                return;
            }

            payload_size = nal_size_field_bytes + pset_size;
            nal_unit_type = pset[0] & 0x1F;

            base::WriteBigEndian(nalu_size_4, (uint32_t)pset_size);
            avcc_buffer->append(nalu_size_4, sizeof(nalu_size_4));
            avcc_buffer->append(reinterpret_cast<const char*>(pset), pset_size);

            offset += payload_size;
        }
    }

    char* bb_data;
    status = CMBlockBufferGetDataPointer(bb, 0, nullptr, nullptr, &bb_data);
    if (status != noErr) {
        //CLog::RT("CMBlockBufferGetDataPointer failed:%d\n", status);
        return;
    }

    //ASSERT_D(nal_size_field_bytes == sizeof(uint32_t));

    char* nalu_data = NULL;
    int nalu_data_size = 0;
    size_t bytes_left = bb_size;
    while (bytes_left > 0) {
        nalu_data = (char*)bb_data;

        uint32_t nal_size;
        base::ReadBigEndian(bb_data, &nal_size);

        nalu_data_size = nal_size_field_bytes + nal_size;

        bytes_left -= nalu_data_size;
        bb_data += nalu_data_size;

        avcc_buffer->append(nalu_data, nalu_data_size);
    }
}



@end

#endif
