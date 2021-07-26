//
//  PepperMoveVideoSession.h
//
//  Created by Dan Brown on 6/10/21.
//  Copyright (c) 2021 Pepper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Callback block fired when a video session has been established with the camera and the video view has been added to the view
 * hierarchy; at this point we are waiting for video frames to start coming through.
 */
typedef void (^PepperMoveVideoAddedHandler)(void);

/**
 * Callback block fired when a video session has been terminated and the video view has been removed.
 */
typedef void (^PepperMoveVideoRemovedHandler)(void);

/**
 * Callback block fired when the first frame has been rendered in the video stream
 */
typedef void (^PepperMoveVideoReadyHandler)(void);

/**
 * Callback block fired when the video size changes, including when the first frame has been received.
 * @param size  The video size rect
 */
typedef void (^PepperMoveVideoSizeUpdatedHandler)(CGSize size);

/**
 * Callback block fired when a single tap on the video view occurs.
 */
typedef void (^PepperMoveVideoSingleTapHandler)(void);

/**
 * Configuration for a video session. This includes options for how to start the video (e.g. startMuted)
 * and optional callbacks for various points in the video session lifecycle (e.g. onVideoReady).
 */
@interface PepperMoveVideoSession : NSObject

/**
 * Device ID of the camera to connect to
 */
@property (nonatomic) NSString* deviceId;

/**
 * Whether the video stream should start muted
 */
@property (nonatomic) BOOL startMuted;

/**
 * Callback block fired when a video session has been established with the camera and the video view has been added to the view
 * hierarchy; at this point we are waiting for video frames to start coming through.
 */
@property (nonatomic) PepperMoveVideoAddedHandler onVideoAdded;

/**
 * Callback block fired when a video session has been terminated and the video view has been removed.
 */
@property (nonatomic) PepperMoveVideoRemovedHandler onVideoRemoved;

/**
 * Callback block fired when the first frame has been rendered in the video stream
 */
@property (nonatomic) PepperMoveVideoReadyHandler onVideoReady;

/**
 * Callback block fired when the video size changes, including when the first frame has been received.
 */
@property (nonatomic) PepperMoveVideoSizeUpdatedHandler onVideoSizeUpdated;

/**
 * Callback block fired when a single tap on the video view occurs.
 */
@property (nonatomic) PepperMoveVideoSingleTapHandler onVideoSingleTap;



// Internal
@property (nonatomic) NSString* callId;

// Internal
@property (nonatomic) NSString* callTag;

- (instancetype)init;

@end
