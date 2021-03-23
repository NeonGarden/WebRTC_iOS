//
//  ViewController.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/8.
//

#import "ViewController.h"
#import "WebRTCManager.h"
#import "SocketManager.h"
#import "CallVideoViewController.h"

@interface ViewController ()<WebSocketManagerDelegate,WebRTCManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *offerBtn;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SocketManager shareInstance].delegate = self;
    [WebRTCManager shareInstance].delegate = self;
    // Do any additional setup after loading the view.
}
- (IBAction)gotoCall:(id)sender {
    [self.navigationController pushViewController:[CallVideoViewController new] animated:YES];
}
- (IBAction)offerClick:(id)sender {
   
//    [[WebRTCManager shareInstance]offer:^(RTCSessionDescription * _Nonnull sdp) {
//
//        NSDictionary *dic = @{@"event":@"_offer",@"data":@{@"sdp":@{@"type": [RTCSessionDescription stringForType:RTCSdpTypeOffer], @"sdp": sdp.sdp}}};
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        [[SocketManager shareInstance]sendMessage:jsonString];
////         [[SocketManager shareInstance]sendMessage:sdp.sdp];
//    }];
}

- (IBAction)answerBtn:(id)sender {
//    [[WebRTCManager shareInstance]answer:^(RTCSessionDescription * _Nonnull sdp) {
//        NSDictionary *dic = @{@"event":@"_answer",@"data":@{@"sdp":@{@"type": [RTCSessionDescription stringForType:RTCSdpTypeAnswer], @"sdp": sdp.sdp}}};
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        [[SocketManager shareInstance]sendMessage:jsonString];
//    }];
}
- (void)webSocketManagerDidReceiveMessageWithString:(NSString *)string {
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *event = msgDict[@"event"];
    if ([event  isEqual:@"_ice_candidate"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *candidateDic = dataDic[@"candidate"];
        int sdpMLineIndex = [candidateDic[@"sdpMLineIndex"]intValue];
        NSString *sdpMid = candidateDic[@"sdpMid"];
        NSString *sdp = candidateDic[@"candidate"];
        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
       // [[WebRTCManager shareInstance]setRemoteCandidate:candidate];
    }
    if ([event isEqual: @"_offer"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *sdpDic = dataDic[@"sdp"];
        //拿到SDP
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        //根据类型和SDP 生成SDP描述对象
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:  [RTCSessionDescription typeForString:type] sdp:sdp];
//        [[WebRTCManager shareInstance]setRemoteSdp:remoteSdp completion:^(NSError * _Nullable error) {
//            NSLog(@"%@",error.description);
//        }];
    }
    if ([event  isEqual:@"_answer"]) {
        NSDictionary *dataDic = msgDict[@"data"];
        NSDictionary *sdpDic = dataDic[@"sdp"];
        //拿到SDP
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        //根据类型和SDP 生成SDP描述对象
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:  [RTCSessionDescription typeForString:type]  sdp:sdp];
//        [[WebRTCManager shareInstance]setRemoteSdp:remoteSdp completion:^(NSError * _Nullable error) {
//
//        }];
    }
}
-(void)webRTCManager:(WebRTCManager *)manager didChangeConnectionState:(RTCIceConnectionState) state{
    
}
-(void)webRTCManager:(WebRTCManager *)manager didDiscoverLocalCandidate:(RTCIceCandidate *) candidate{
    
//    NSString *candidateString =  [candidate JSONString];
//    NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:candidateData options:NSJSONReadingMutableContainers error:nil];
//
    
    NSDictionary *candidateDic = @{@"sdpMid":candidate.sdpMid,@"candidate":candidate.sdp,@"sdpMLineIndex":@(candidate.sdpMLineIndex)};
    NSDictionary *dic = @{@"event":@"_ice_candidate",@"data":@{ @"candidate":candidateDic}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[SocketManager shareInstance]sendMessage:jsonString];
}
-(void)webRTCManager:(WebRTCManager *)manager didReceiveData:(NSData *) data{
    
}
@end
