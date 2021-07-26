//
//  ViewController.m
//  PepperMoveSDK-Demo
//
//  Created by Dan Brown on 06/22/2021.
//  Copyright (c) 2021 Dan Brown. All rights reserved.
//

#import "ViewController.h"
#import <PepperMoveSDK/PepperMove.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

static PepperMove* move;
static NSString* deviceId;
static UIButton* takePhotoButton;
static UIButton* startRecordButton;
static UIButton* stopRecordButton;
static UIButton* getSdCardInfoButton;
static UIButton* formatSdCardButton;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    
    // move = [[PepperMove alloc] initWithURL:@"wss://dev.move.pepperos.io/ws"]; // Dev
    move = [[PepperMove alloc] initWithURL:@"wss://stage.move.pepperos.io/ws"]; // Staging
    // move = [[PepperMove alloc] initWithURL:@"wss://prod.move.pepperos.io/ws"]; // Production
    
    [PepperMove setLogAdapter:0 handler:^(NSString* logMsg) {
        NSLog(@"%@", logMsg);
    }];

    UIView *liveViewBackground = [[UIView alloc] initWithFrame:self.view.bounds];
    liveViewBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    liveViewBackground.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:liveViewBackground];

    // Authenticate by with email & password to get a cognito token, which we then use to authenticate with Move
    NSString* email = @"danbrown@pepper.me";
    
    // NSString* vendorAPIURL = @"https://dev.api.pepperos.io/authentication/byEmail"; // Dev
    NSString* vendorAPIURL = @"https://staging.api.pepperos.io/authentication/byEmail"; // Staging
    // NSString* vendorAPIURL = @"https://api.pepperos.io/authentication/byEmail"; // Production
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    // 64bit encode pepper:username and password to make the basic auth header
    NSLog(@"Pepper account");
    NSString *authStr = [NSString stringWithFormat:@"pepper:%@:%@", email, @"Password12345!"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSLog(@"PepperMove: The auth header is %@", authValue);
    [request setAllHTTPHeaderFields:@{@"authorization":authValue,@"content-type":@"application/json"}];
    [request setURL:[NSURL URLWithString:vendorAPIURL]];
    
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];
    
    if([responseCode statusCode] != 200) {
        NSLog(@"Error getting %@, HTTP status code %li", vendorAPIURL, (long)[responseCode statusCode]);
    }

    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *pepperUser = jsonData[@"pepperUser"];
    
    NSLog(@"Logged in with account ID: %@",pepperUser[@"account_id"]);
    NSDictionary *cognitoProfile = jsonData[@"cognitoProfile"];
    NSString* cognitoToken = cognitoProfile[@"Token"];
    
    // ID of a camera paired to the above account
    deviceId = @"7fe8ca49-5d5c-41ba-8564-0af3c5ae0159";
    
    // Now authenticate with Move
    [move setCredentials:email token:cognitoToken];
    
    // Spin up a live stream
    PepperMoveVideoSession* session = [[PepperMoveVideoSession alloc] init];
    
    session.deviceId = deviceId;
    
    session.onVideoSizeUpdated = ^(CGSize size) {
        NSLog(@"ViewController - onVideoSizeUpdated: %dx%d", (int)size.width, (int)size.height);
    };
    session.onVideoAdded = ^{
        NSLog(@"ViewController - onVideoAdded");
    };
    session.onVideoRemoved = ^{
        NSLog(@"ViewController - onVideoRemoved");
        [weakSelf setAudioOutputSpeaker:NO];
    };
    session.onVideoReady = ^{
        NSLog(@"ViewController - onVideoReady");
        [weakSelf setAudioOutputSpeaker:YES];
    };
    
    session.onVideoSingleTap = ^{
        NSLog(@"ViewController - onVideoReady");
    };
    
    [move startVideo:session view:liveViewBackground];
    
    // [move setInputEnabled:NO];
    // [move setMute:session mute:NO];
    // [move setTwoWayTalk:session enable:YES];
    float parentW = self.view.frame.size.width;
    float parentH = self.view.frame.size.height;
    float buttonW = 100.0;
    float buttonH = 40.0;
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, parentH - 160.0, parentW, 160)];
    [self.view addSubview:buttonContainer];
    
    takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoButton setTitle:@"Take photo" forState:UIControlStateNormal];
    takePhotoButton.backgroundColor = [UIColor systemBlueColor];
    
    takePhotoButton.frame = CGRectMake(10, 10, buttonW, buttonH);
    [buttonContainer addSubview:takePhotoButton];
    
    startRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startRecordButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    [startRecordButton setTitle:@"Start record" forState:UIControlStateNormal];
    startRecordButton.backgroundColor = [UIColor systemBlueColor];
    
    startRecordButton.frame = CGRectMake(1 * (buttonW + 10 + 10), 10, buttonW, buttonH);
    [buttonContainer addSubview:startRecordButton];
    
    stopRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopRecordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [stopRecordButton setTitle:@"Stop record" forState:UIControlStateNormal];
    stopRecordButton.backgroundColor = [UIColor systemBlueColor];
    
    stopRecordButton.frame = CGRectMake(2 * (buttonW + 10) + 10, 10, buttonW, buttonH);
    [buttonContainer addSubview:stopRecordButton];
    
    getSdCardInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getSdCardInfoButton addTarget:self action:@selector(getSdCardInfo) forControlEvents:UIControlEventTouchUpInside];
    [getSdCardInfoButton setTitle:@"Get SD info" forState:UIControlStateNormal];
    getSdCardInfoButton.backgroundColor = [UIColor systemBlueColor];
    
    getSdCardInfoButton.frame = CGRectMake(0 * (buttonW + 10) + 10, 60, buttonW, buttonH);
    [buttonContainer addSubview:getSdCardInfoButton];
    
    formatSdCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [formatSdCardButton addTarget:self action:@selector(formatSdCard) forControlEvents:UIControlEventTouchUpInside];
    [formatSdCardButton setTitle:@"Format SD" forState:UIControlStateNormal];
    formatSdCardButton.backgroundColor = [UIColor systemBlueColor];
    
    formatSdCardButton.frame = CGRectMake(1 * (buttonW + 10) + 10, 60, buttonW, buttonH);
    [buttonContainer addSubview:formatSdCardButton];
}

- (void)setAudioOutputSpeaker:(BOOL)enabled {
    AVAudioSession *session =   [AVAudioSession sharedInstance];
    NSError *error;
    NSLog(@"Adjusting Speaker");
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (enabled) { // Enable speaker
        NSLog(@"Turning on Speaker Phone YES");
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }
    else { // Disable speaker
        NSLog(@"Turning off Speaker Phone NO");
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
    [session setActive:YES error:&error];
}

- (void)takePhoto {
    NSLog(@"Take photo tapped");
    [move takeSnapshot:deviceId completionHandler:^(NSObject* output, NSError* error) {
        NSLog(@"Take photo, success = %@", error == nil ? @"true" : @"false");
    }];
}

- (void)startRecording {
    
    NSLog(@"Start recording tapped");
    [move startRecording:deviceId completionHandler:^(NSObject* output, NSError* error) {
        NSLog(@"Start recording, success = %@", error == nil ? @"true" : @"false");
    }];
}

- (void)stopRecording {
    NSLog(@"Stop recording tapped");
    [move stopRecording:deviceId completionHandler:^(NSObject* output, NSError* error) {
        NSLog(@"Stop recording, success = %@", error == nil ? @"true" : @"false");
    }];
}

- (void)getSdCardInfo {
    NSLog(@"Get SD card info tapped");
    [move getSdCardInfo:deviceId completionHandler:^(NSObject* output, NSError* error) {
        NSLog(@"Get SD card info, success = %@", error == nil ? @"true" : @"false");
    }];
}

- (void)formatSdCard {
    NSLog(@"Format SD card tapped");
    [move formatSdCard:deviceId completionHandler:^(NSObject* output, NSError* error) {
        NSLog(@"Format SD card, success = %@", error == nil ? @"true" : @"false");
    }];
}

@end
