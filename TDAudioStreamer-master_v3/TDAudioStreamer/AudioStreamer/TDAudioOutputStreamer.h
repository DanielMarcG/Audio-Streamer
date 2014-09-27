//
//  TDAudioOutputStreamer.h
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/14/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TDAudioOutputStreamer.h"
#import "TDAudioStream.h"


// return max value for given values
#define max(a, b) (((a) > (b)) ? (a) : (b))
// return min value for given values
#define min(a, b) (((a) < (b)) ? (a) : (b))

#define kOutputBus 0
#define kInputBus 1

// our default sample rate
#define SAMPLE_RATE 44100.00

//@class AVURLAsset;

@interface TDAudioOutputStreamer : NSObject
{
// Audio unit
AudioComponentInstance audioUnit;

// Audio buffers
AudioBuffer audioBuffer;

// gain
float gain;
    
    
//BOOL DataFlag;
    
}


@property (readonly) AudioBuffer audioBuffer;
@property (readonly) AudioComponentInstance audioUnit;
@property (nonatomic) float gain;
@property (strong, nonatomic) TDAudioStream *audioStream;
@property (strong, nonatomic) NSThread *streamThread;
@property (assign, atomic) BOOL isStreaming;

@property (strong, nonatomic) TDAudioOutputStreamer *AudioOutputStreamer;

// NSStream methods
- (instancetype)initWithOutputStream:(NSOutputStream *)stream;
- (void)start;
- (void)stop;

// audio unit methods
- (void)initializeAudio;
- (void)processBuffer: (AudioBufferList*) audioBufferList;
- (void)sendDataChunk;
- (void)startAudioUnit;
- (void)stopAudioUnit;
- (void)setGain:(float)gainValue;
- (float)getGain;
- (void)hasError:(int)statusCode:(char*)file:(int)line;

@end
