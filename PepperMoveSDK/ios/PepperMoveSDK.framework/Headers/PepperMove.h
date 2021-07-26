//
//  PepperMove.h
//
//  Created by Dan Brown on 6/10/21.
//  Copyright (c) 2021 Pepper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PepperMoveVideoSession.h"

/**
 * PepperMove Client for realtime video streaming from wifi cameras.
 */
@interface PepperMove : NSObject {
}

@property (nonatomic) BOOL inputEnabled;

/**
 * Initialize a new Pepper Move client pointing to the given server
 *
 * @param url   Pepper Move server to connect to
 * @return An instance of the PepperMove class
 */
- (instancetype)initWithURL:(NSString*)url;

/**
 * Set the credentials for authenticating with PepperMove
 *
 * @param email  The user's email address
 * @param token  The authentication token
 */
- (void)setCredentials:(NSString*)email token:(NSString*)token;

/**
 * Request live video for a camera and place it within the view provided
 * @param session   A class containing information required to start a video session with a camera (deviceId) and optional callback blocks
 * @param view   The view in which the camera video will be added as a subview
 * @par Example:
 * @code{.m}
 *  PepperMoveVideoSession* session = [[PepperMoveVideoSession alloc] init];
 *  session.deviceId = @"823ed274-1477-4c7a-aab0-627694e47406";
 *  session.onVideoReady = ^{
 *      // Clean up and hide any loading UI now that the video stream is available
 *  };
 *
 *  [pepperMove startVideo:session view:view]
 * @endcode
 */
- (void)startVideo:(PepperMoveVideoSession*)session view:(UIView*)view;

/**
 * Terminate a live video session
 * @param session   A class containing information required to start a video session with a camera (deviceId) and optional callback blocks
 */
- (void)stopVideo:(PepperMoveVideoSession*)session;

/**
 * Enable or disable the audio in the camera's video stream
 * @param session   A class containing information required to start a video session with a camera (deviceId) and optional callback blocks
 * @param mute   Whether the video stream should be muted
 */
- (void)setMute:(PepperMoveVideoSession*)session mute:(BOOL)mute;

/**
 * Enables or disables two-way audio; if enabled, and microphone permission has been granted in the app, audio will be captured by the mic and sent to the camera's speaker.
 * @param session   A class containing information required to start a video session with a camera (deviceId) and optional callback blocks
 * @param enable   Whether the two-way talk should be enabled
 * @return Whether two-way audio was successfully toggled
 */
- (BOOL)setTwoWayTalk:(PepperMoveVideoSession*)session enable:(BOOL)enable;

/**
 * Enables or disables pinch-to-zoom and panning on the video view, for any active and future video sessions.
 * You may wish to disable this if it conflicts with your own UI, or if you wish to handle zooming/panning yourself.
 *
 * @param enabled  Whether user input is enabled
 */
- (void)setInputEnabled:(BOOL)enabled;

/**
 * Takes a snapshot of the live video stream.
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)takeSnapshot:(NSString*)deviceId completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Starts recording a video clip from the live video stream.
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)startRecording:(NSString*)deviceId completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Stops recording a video clip from the live video stream.
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)stopRecording:(NSString*)deviceId completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Retrieves details of files currently stored on the SD card, if there is one in the camera.
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)getSdCardInfo:(NSString*)deviceId completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Initiates formatting of the SD card, if there is one in the camera.
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)formatSdCard:(NSString*)deviceId completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Deletes the specified file from the SD card
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)deleteSdCardFile:(NSString*)deviceId filename:(NSString*)filename completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Initiates an upload to the cloud of the specified file from the SD card
 *
 * @param deviceId  Device ID of the camera
 * @param completionHandler Handler block called when the command completes, with the command output (if applicable) or an error if it fails
 */
- (void)uploadSdCardFile:(NSString*)deviceId filename:(NSString*)filename completionHandler:(void (^)(NSObject* output, NSError* error))completionHandler;

/**
 * Disconnect from the PepperMove server
 */
- (void)disconnect;

/**
 * Sets a custom handler for log messages. If none is set logs are directed to NSLog.
 *
 * @param level  The minimum log level for which logs should be redirected (0 = Verbose, 1 = Debug, 2 = Info, 3 = Warn, 4 = Error)
 * @param handler The handler run for each log message
 */
+ (void)setLogAdapter:(int)level handler:(void(^)(NSString* logMsg))handler;

@end
