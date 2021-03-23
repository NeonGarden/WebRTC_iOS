//
//  WebRTCManager.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/8.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
NS_ASSUME_NONNULL_BEGIN
@class  WebRTCManager;
@protocol WebRTCManagerDelegate <NSObject>

-(void)webRTCManager:(WebRTCManager *)manager RemovePeerId:(NSString *)peerId  video:(RTCMTLVideoView *)renderer;
-(void)webRTCManager:(WebRTCManager *)manager AddRemotePeerId:(NSString *)peerId  remoteVideo:(RTCMTLVideoView *)renderer;
-(void)webRTCManager:(WebRTCManager *)manager remotePeersVideos:(NSDictionary *)peerVideos;

-(void)webRTCManager:(WebRTCManager *)manager AddLocalPeerId:(NSString *)peerId  localVideo:(RTCMTLVideoView *)renderer;
@end

@interface WebRTCManager : NSObject


@property(nonatomic, strong)NSMutableDictionary *remoteVideos;
@property(nonatomic, strong)RTCMTLVideoView *localVideo;
@property(nonatomic, weak) id<WebRTCManagerDelegate> delegate;
+(instancetype)shareInstance;
-(void)initIceServers:(NSArray<NSString *> *) urlString Room:(NSString *)roomId userId:(NSString *)userId socketUrl:(NSString *)socketUrl;
-(void)startCaptureLocalVideoPosition:(AVCaptureDevicePosition ) position;
-(void)rotateCamera:(AVCaptureDevicePosition ) position;
-(void)setAudioSession;
-(void)setAudioWaiFangSession;
-(void)setAllAudioEnabled:(BOOL)isEnabled;
-(void)setAudioEnabled:(BOOL)isEnabled peerId:(NSString *) peerId;
-(void)leaveRoom;
@end

NS_ASSUME_NONNULL_END
