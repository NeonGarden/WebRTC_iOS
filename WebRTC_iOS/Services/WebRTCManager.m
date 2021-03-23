//
//  WebRTCManager.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/8.
//

#import "WebRTCManager.h"
#import "SocketManager+MessageChannel.h"

static WebRTCManager *webRTCManager;
@interface WebRTCManager ()<RTCPeerConnectionDelegate,RTCDataChannelDelegate,WebSocketManagerDelegate>
@property(nonatomic, strong)RTCVideoCapturer *videoCapturer;
@property(nonatomic, strong)NSMutableDictionary *peers;
@property(nonatomic, strong)NSMutableDictionary *dataChannels;
@property(nonatomic, strong)RTCPeerConnectionFactory *factory;
@property(nonatomic, strong)NSDictionary *mediaConstrains;
@property(nonatomic, strong)RTCAudioSession* rtcAudioSession;
@property(nonatomic, strong)id localRenderer;
@property(nonatomic, strong)NSArray<NSString *> * urlStrings;
@property(nonatomic, strong)NSString *roomId;
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *socketUrl;
@property(nonatomic, strong)NSMutableDictionary *remoteVideoTracks;
@property(nonatomic, strong)RTCVideoTrack *localVideoTrack;

@end
@implementation WebRTCManager
+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            if (webRTCManager == nil) {
                webRTCManager = [[WebRTCManager alloc]init];
            }
        });
    return webRTCManager;
}
-(instancetype)init {
    if ([super init]) {
        [self configureAudioSession];
        [SocketManager shareInstance].delegate = self;
    }
    return self;
}
-(void)initIceServers:(NSArray<NSString *> *) urlStrings Room:(NSString *)roomId userId:(NSString *)userId socketUrl:(NSString *)socketUrl{
    _urlStrings = urlStrings;
    _userId = userId;
    _roomId = roomId;
    _socketUrl = socketUrl;
    [[SocketManager shareInstance]linkSocket:socketUrl];
}

-(void)createPeer:(NSString *)peerId{
    RTCConfiguration *config = [[RTCConfiguration alloc]init];
    config.iceServers = @[[[RTCIceServer alloc]initWithURLStrings:self.urlStrings]];
    config.sdpSemantics =  RTCSdpSemanticsUnifiedPlan;
    config.continualGatheringPolicy = RTCContinualGatheringPolicyGatherContinually;
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc]initWithMandatoryConstraints:nil optionalConstraints:@{@"DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue}];
    RTCPeerConnection *peerConnection = [self.factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
    [self.peers setValue:peerConnection forKey:peerId];
    [self createMediaSenders:peerConnection peerId:peerId];
    
}

-(void)setRemoteCandidate:(RTCIceCandidate *)remoteCandidate peerId:(NSString *)peerId{
    RTCPeerConnection *peerConnection = [self.peers objectForKey:peerId];
    [peerConnection addIceCandidate:remoteCandidate];
}
-(RTCVideoTrack *)localVideoTrack {
    if (_localVideoTrack == nil) {
        RTCVideoTrack *videoTrack = [self createVideoTrack];
        _localVideoTrack = videoTrack;
    }
    return _localVideoTrack;;
}
-(void)createMediaSenders:(RTCPeerConnection *)peerConnection peerId:(NSString *)peerId{
    NSString *streamId = @"stream";
    RTCAudioTrack *audioTrack = [self createAudioTrack];
    [peerConnection addTrack:audioTrack streamIds:@[streamId]];
    [peerConnection addTrack:self.localVideoTrack streamIds:@[streamId]];
    RTCVideoTrack *remoteVideoTrack ;
    for (RTCRtpTransceiver *transceiver in peerConnection.transceivers) {
        if (transceiver.mediaType ==  RTCRtpMediaTypeVideo) {
            
            remoteVideoTrack = (RTCVideoTrack *)transceiver.receiver.track;
            [self.remoteVideoTracks setValue:remoteVideoTrack forKey:peerId];
        }
    }
    
    if (!remoteVideoTrack) {
        RTCDataChannel * dataChannel = [self createDataChannel:peerConnection];
        dataChannel.delegate = self;
       
        [self.dataChannels setValue:dataChannel forKey:peerId];
    }
}
-(RTCAudioTrack *)createAudioTrack {
    RTCMediaConstraints *audioConstrains= [[RTCMediaConstraints alloc]initWithMandatoryConstraints:nil optionalConstraints:nil];
    RTCAudioSource *audioSource = [self.factory audioSourceWithConstraints:audioConstrains];
    RTCAudioTrack * audioTrack = [self.factory audioTrackWithSource:audioSource trackId:@"audio0"];
    return audioTrack;
}
-(RTCVideoTrack *)createVideoTrack {
    RTCVideoSource  *videoSource = [self.factory videoSource];
    #if TARGET_OS_SIMULATOR
    self.videoCapturer = [[RTCFileVideoCapturer alloc]initWithDelegate:videoSource];
    #else
    self.videoCapturer = [[RTCCameraVideoCapturer alloc]initWithDelegate:videoSource];
    #endif
    RTCVideoTrack *videoTrack = [self.factory videoTrackWithSource:videoSource trackId:@"video0"];
    return videoTrack;
}
-(RTCDataChannel *)createDataChannel:(RTCPeerConnection *)peerConnection {
    RTCDataChannelConfiguration *conifg = [RTCDataChannelConfiguration new];
    RTCDataChannel * dataChannel = [peerConnection dataChannelForLabel:@"WebRTCData" configuration:conifg];
    return dataChannel;
    
}

-(void)configureAudioSession {
    [self.rtcAudioSession lockForConfiguration];
    [self.rtcAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [self.rtcAudioSession setMode:AVAudioSessionModeVideoChat error:nil];
    [self.rtcAudioSession unlockForConfiguration];
}
#pragma mark RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
   // [self.delegate webRTCManager:self peerConnection:peerConnection didAddStream:stream];
    NSLog(@"peerConnection did add stream");
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NSLog(@"peerConnection new connection state:%ld",newState);
  
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    NSLog(@"peerConnection new gathering state: %ld",newState);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    NSLog(@"peerConnection new signaling state:%ld", (long)stateChanged);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    NSLog(@"");
    __weak typeof(self) weakSelf = self;
    [self.peers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"key = %@ and obj = %@", key, obj);
        if ([obj isEqual:peerConnection]) {
            NSDictionary *candidateDic = @{@"sdpMid":candidate.sdpMid,@"candidate":candidate.sdp,@"sdpMLineIndex":@(candidate.sdpMLineIndex)};
            [[SocketManager shareInstance] sendIceCandidate:weakSelf.userId receiver:key room:self.roomId candidate:candidateDic];

        }
    }];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel {
   
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    NSLog(@"peerConnection did remove candidate(s)");
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    NSLog(@"peerConnection did remote stream");
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection {
    NSLog(@"");
}
#pragma mark RTCDataChannelDelegate
- (void)dataChannel:(nonnull RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(nonnull RTCDataBuffer *)buffer {
    if (self.delegate) {
        //[self.delegate webRTCManager:self didReceiveData:buffer.data];
    }
   
}

- (void)dataChannelDidChangeState:(nonnull RTCDataChannel *)dataChannel {
    NSLog(@"dataChannel did change state: %ld",(long)dataChannel.readyState);
}

#pragma mark offer
-(void)offerPeerId:(NSString *)peerId completion:(void(^)(RTCSessionDescription*))completion {
    RTCPeerConnection *peerConnection = [self.peers objectForKey:peerId];
    RTCMediaConstraints *constrains = [[RTCMediaConstraints alloc]initWithMandatoryConstraints:self.mediaConstrains optionalConstraints:nil];
    [peerConnection offerForConstraints:constrains completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (!error) {
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (completion && !error) {
                    completion(sdp);
                }
            }];
        }
    }];
}
#pragma mark answer
-(void)answerPeerId:(NSString *)peerId completion:(void(^)(RTCSessionDescription*))completion{
    RTCPeerConnection *peerConnection = [self.peers objectForKey:peerId];
    RTCMediaConstraints *constrains = [[RTCMediaConstraints alloc]initWithMandatoryConstraints:self.mediaConstrains optionalConstraints:nil];
    [peerConnection answerForConstraints:constrains completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (!error) {
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (completion && !error) {
                    completion(sdp);
                }
            }];
        }
    }];
}
-(void)setRemoteSdp:(RTCSessionDescription *)sdp peerId:(NSString *)peerId completion:(void (^)(NSError *_Nullable error))completion{
    RTCPeerConnection *peerConnection = [self.peers objectForKey:peerId];
    [peerConnection setRemoteDescription:sdp completionHandler:completion];
    
}
#pragma mark Media
-(void)stopCapture {
    RTCCameraVideoCapturer *capturer = (RTCCameraVideoCapturer *)self.videoCapturer;
    [capturer stopCaptureWithCompletionHandler:^{
            
    }];
}
-(void)startCaptureLocalVideoPosition:(AVCaptureDevicePosition)position{
    [self.localVideoTrack removeRenderer:self.localRenderer];
  
    RTCCameraVideoCapturer *capturer = (RTCCameraVideoCapturer *)self.videoCapturer;
    capturer.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice * camera;
    for (AVCaptureDevice * device in RTCCameraVideoCapturer.captureDevices) {
        if (device.position == position) {
            camera =  device;
        }
    }
    NSArray<AVCaptureDeviceFormat *> * formats =  [RTCCameraVideoCapturer supportedFormatsForDevice:camera];
    AVCaptureDeviceFormat * format = [[formats sortedArrayUsingComparator:^NSComparisonResult(AVCaptureDeviceFormat * obj1, AVCaptureDeviceFormat* obj2) {
        
        float width1 =  CMVideoFormatDescriptionGetDimensions(obj1.formatDescription).width;
        float width2 =  CMVideoFormatDescriptionGetDimensions(obj2.formatDescription).width;
        return width1 < width2;
    }] lastObject];
    AVFrameRateRange *fps =  [[format.videoSupportedFrameRateRanges sortedArrayUsingComparator:^NSComparisonResult(AVFrameRateRange * obj1,  AVFrameRateRange* obj2) {
        return  obj1.maxFrameRate < obj2.maxFrameRate;
    }] lastObject];
    __weak typeof(self) weakSelf = self;
    [capturer startCaptureWithDevice:camera format:format fps:fps.maxFrameRate completionHandler:^(NSError * _Nonnull e) {
        AVCaptureSession* session = capturer.captureSession;
            for (AVCaptureVideoDataOutput* output in session.outputs) {
                NSLog(@"%@", output.connections);
                    for (AVCaptureConnection * av in output.connections) {
                        //判断是否是前置摄像头状态
                        if (position == AVCaptureDevicePositionFront) {
        
                            av.videoMirrored = YES;
                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                            NSLog(@"%@镜像",av.supportsVideoMirroring?@"支持":@"不支持");
                        }else{
                            //镜像设置
        
                            av.videoMirrored = NO;
                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                            NSLog(@"%@镜像",av.supportsVideoMirroring?@"支持":@"不支持");
                        }
                    }
            }
        if (weakSelf.delegate) {
            [weakSelf.localVideoTrack addRenderer:weakSelf.localVideo];
        }
        [weakSelf.delegate webRTCManager:weakSelf AddLocalPeerId:weakSelf.userId localVideo:weakSelf.localVideo];
    }];

}
-(void)rotateCamera:(AVCaptureDevicePosition ) position{
    [self startCaptureLocalVideoPosition:position];
}
-(void)renderRemoteVideo:(id)renderer peerId:(NSString *)peerId{
    RTCVideoTrack *remoteVideoTrack = [self.remoteVideoTracks objectForKey:peerId];
    [remoteVideoTrack addRenderer:renderer];
}

-(void)createRemoteVideo:(NSString *)peerId{
    RTCMTLVideoView *renderer =  [[RTCMTLVideoView alloc]init];
    renderer.contentMode = UIViewContentModeScaleAspectFill;
    [self renderRemoteVideo:renderer peerId:peerId];
    [self.remoteVideos setObject:renderer forKey:peerId];
}

-(void)sendData:(NSData *)data peerId:(NSString *)peerId{
    RTCDataBuffer * buffer =  [[RTCDataBuffer alloc]initWithData:data isBinary:true];
    RTCDataChannel *remoteDataChannel = [self.dataChannels objectForKey:peerId];
    if (remoteDataChannel) {
        [remoteDataChannel sendData:buffer];
    }
    
}
// 静音设置
-(void)setAllAudioEnabled:(BOOL)isEnabled {
    for (RTCPeerConnection *peerConnection in [self.peers allValues]) {
        for (RTCRtpTransceiver * transceiver in peerConnection.transceivers) {
            if ([transceiver.sender.track isKindOfClass:[RTCAudioTrack class]] ) {
                RTCAudioTrack *track = (RTCAudioTrack *)transceiver.sender.track;
                track.isEnabled = isEnabled;
            }
        }
    }
    
}
-(void)setAudioEnabled:(BOOL)isEnabled peerId:(NSString *) peerId{
    RTCPeerConnection *peerConnection  = [self.peers objectForKey:peerId];
    for (RTCRtpTransceiver * transceiver in peerConnection.transceivers) {
        if ([transceiver.sender.track isKindOfClass:[RTCAudioTrack class]] ) {
            RTCAudioTrack *track = (RTCAudioTrack *)transceiver.sender.track;
            track.isEnabled = isEnabled;
        }
    }
}
//听筒模式
-(void)setAudioSession {
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
//扬声器模式
-(void)setAudioWaiFangSession {
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}
-(void)colse:(NSString *)peerId{
    RTCPeerConnection *peerConnection = [self.peers objectForKey:peerId];
    [peerConnection close];
    [self.peers removeObjectForKey:peerId];
    [self.remoteVideos removeObjectForKey:peerId];
    [self.dataChannels removeObjectForKey:peerId];
}
-(void)sendOffers{
    __weak typeof(self) weakSelf = self;
    [self.peers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqual:self.userId]) {
            [weakSelf offerPeerId:key completion:^(RTCSessionDescription * _Nonnull sdp) {
                NSDictionary *dic = @{@"type": [RTCSessionDescription stringForType:sdp.type], @"sdp": sdp.sdp};
                [[SocketManager shareInstance]sendOffer:weakSelf.userId receiver:key room:weakSelf.roomId sdp:dic];
            }];
        }
       
    }];
}

-(void)sendAnswer:( RTCSessionDescription *)sdp receiver:(NSString *)receiver{
    NSDictionary *dic = @{@"type": [RTCSessionDescription stringForType:sdp.type], @"sdp": sdp.sdp};
    [[SocketManager shareInstance]sendOffer:self.userId receiver:receiver room:self.roomId sdp:dic];
}
-(void)leaveRoom{
    [self.peers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj close];
    }];
    [self stopCapture];
    [self.dataChannels removeAllObjects];
    [self.peers removeAllObjects];
    [self.remoteVideoTracks removeAllObjects];
    [self.remoteVideos removeAllObjects];
    self.localVideo = nil;
    self.localVideoTrack = nil;
    self.videoCapturer = nil;
    self.roomId = nil;
    self.userId = nil;
    [[SocketManager shareInstance]leaveRoom];
}
#pragma mark WebSocketManagerDelegate
- (void)WebSocketManager:(SocketManager *)webSocketManager connect:(WebSocketConnectType)connectType{
    if (connectType == WebSocketConnect) {
        
        [[SocketManager shareInstance] login:self.userId];
    }
}
- (void)webSocketManager:(SocketManager *)webSocketManager webSocketManagerDidReceiveMessageWithString:(NSString *)string{
    __weak typeof(self) weakSelf = self;
    //处理socket服务端发过来的信息
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *event = msgDict[@"event"];
    NSString *sender = msgDict[@"sender"];
    //登录处理
    if ([event isEqualToString:@"_logined"]) {
        [[SocketManager shareInstance]joinRoomWithUser:self.userId room:self.roomId];
    }
    //连接者处理
  
    if ([event isEqualToString:@"_peers"]) {
        NSDictionary *data = msgDict[@"data"];
        NSArray *peers = data[@"peers"];
        [peers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf createPeer:obj];
            [weakSelf createRemoteVideo:obj];
        }];
      
        if (self.delegate) {
            [self.delegate webRTCManager:self remotePeersVideos:self.remoteVideos];
        }
       
        [self sendOffers];
    }
    //新链接者处理
    if ([event isEqualToString:@"_new_peer"]) {
        NSDictionary *data = msgDict[@"data"];
        NSString *peerId =  data[@"username"];
        [self createPeer:peerId];
        [self createRemoteVideo:peerId];
        if (self.delegate) {
            [self.delegate webRTCManager:self AddRemotePeerId:peerId remoteVideo:[self.remoteVideos objectForKey:peerId]];
        }
    }
    
    //处理offer
    if ([event isEqualToString:@"_offer"]) {
        [self.peers objectForKey:sender];
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *sdpDic = dataDic[@"sdp"];
        //拿到SDP
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:  [RTCSessionDescription typeForString:type] sdp:sdp];
        [self setRemoteSdp:remoteSdp peerId:sender completion:^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf answerPeerId:sender completion:^(RTCSessionDescription * _Nonnull sdp) {
                    [weakSelf sendAnswer:sdp receiver:sender];
                }];
            }
        }];
    }
    //处理answer
    if ([event isEqualToString:@"_answer"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *sdpDic = dataDic[@"sdp"];
        //拿到SDP
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        //根据类型和SDP 生成SDP描述对象
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:  [RTCSessionDescription typeForString:type]  sdp:sdp];
        [self setRemoteSdp:remoteSdp peerId:sender completion:^(NSError * _Nullable error) {
            
        }];
    }
    
    //处理_ice_candidate
    if ([event isEqualToString:@"_ice_candidate"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *candidateDic = dataDic[@"candidate"];
        int sdpMLineIndex = [candidateDic[@"sdpMLineIndex"]intValue];
        NSString *sdpMid = candidateDic[@"sdpMid"];
        NSString *sdp = candidateDic[@"candidate"];
        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
        [self setRemoteCandidate:candidate peerId:sender];
    }
    if ([event isEqualToString:@"_leave_peer"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        [self colse:dataDic[@"username"]];
        if (self.delegate) {
            [self.delegate webRTCManager:self RemovePeerId:dataDic[@"username"] video:[self.remoteVideos objectForKey:dataDic[@"username"]]];
        }
    }
    
}

#pragma mark getter && setter
-(NSMutableDictionary *)peers {
    if (_peers == nil) {
        _peers = [NSMutableDictionary new];
    }
    return _peers;
}
-(NSMutableDictionary *)remoteVideoTracks {
    if (_remoteVideoTracks == nil) {
        _remoteVideoTracks = [NSMutableDictionary new];
    }
    return _remoteVideoTracks;
}
-(NSMutableDictionary *)remoteVideos {
    if (_remoteVideos == nil) {
        _remoteVideos = [NSMutableDictionary new];
    }
    return _remoteVideos;
}
-(NSMutableDictionary*)dataChannels {
    if (_dataChannels == nil) {
        _dataChannels = [NSMutableDictionary new];
    }
    return _dataChannels;
}

-( RTCMTLVideoView *)localVideo {
    if (_localVideo == nil) {
        _localVideo = [[RTCMTLVideoView alloc]init];
        _localVideo.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _localVideo;
}
-(RTCAudioSession *)rtcAudioSession {
    if (_rtcAudioSession == nil) {
        _rtcAudioSession = [RTCAudioSession sharedInstance];
    }
    return _rtcAudioSession;
}
-(RTCPeerConnectionFactory *)factory {
    if (_factory == nil) {
        RTCInitializeSSL();
        _factory = [[RTCPeerConnectionFactory alloc]initWithEncoderFactory:[RTCDefaultVideoEncoderFactory new] decoderFactory:[RTCDefaultVideoDecoderFactory new]];
        _mediaConstrains = @{kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                             kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue};
    }
    return _factory;
}

@end
