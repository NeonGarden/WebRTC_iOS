//
//  SocketManager+MessageChannel.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import "SocketManager+MessageChannel.h"
#import "NSObject+JSONTool.h"
#import "Message.h"
@implementation SocketManager (MessageChannel)
-(void)login:(NSString *)username{
    if (username && username.length >0 ) {
        
        NSDictionary *data = @{@"username":username};
        NSDictionary *dic = @{@"event":@"_login",@"data":data};
        NSString *msg = [dic JSONString];
        [self sendMessage:msg];
    }
}
-(void)joinRoomWithUser:(NSString *)username room:(NSString *)roomId{
    if (username && username.length >0 && roomId && roomId.length>0) {
        NSDictionary *data = @{@"roomId":roomId, @"username":username};
        NSDictionary *dic = @{@"event":@"_join",@"data":data};
        NSString *msg = [dic JSONString];
        [self sendMessage:msg];
    }
}
-(void)leaveRoom{
    NSDictionary *dic = @{@"event":@"_leave"};
    NSString *msg = [dic JSONString];
    [self sendMessage:msg];
}
-(void)sendOffer:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId sdp:(NSDictionary *)sdp{
    NSDictionary *data = @{@"sdp":sdp};
    NSDictionary *dic = @{@"event": @"_offer",
                          @"sender": sender,
                          @"receiver": receiver,
                          @"roomId": roomId,
                          @"data": data};
    NSString *msg = [dic JSONString];
    [self sendMessage:msg];
}
-(void)sendAnswer:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId sdp:(NSDictionary *)sdp{
    NSDictionary *data = @{@"sdp":sdp};
    NSDictionary *dic = @{@"event": @"_answer",
                          @"sender": sender,
                          @"receiver": receiver,
                          @"roomId": roomId,
                          @"data": data};
    NSString *msg = [dic JSONString];
    [self sendMessage:msg];
}
-(void)sendIceCandidate:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId candidate:(NSDictionary *)candidate{
    NSDictionary *data = @{@"candidate":candidate};
    NSDictionary *dic = @{@"event": @"_ice_candidate",
                          @"sender": sender,
                          @"receiver": receiver,
                          @"roomId": roomId,
                          @"data": data};
    NSString *msg = [dic JSONString];
    [self sendMessage:msg];
}

@end
