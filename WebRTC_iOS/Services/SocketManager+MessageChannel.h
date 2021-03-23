//
//  SocketManager+MessageChannel.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import "SocketManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SocketManager (MessageChannel)
-(void)login:(NSString *)username;
-(void)joinRoomWithUser:(NSString *)username room:(NSString *)roomId;
-(void)leaveRoom;
-(void)sendOffer:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId sdp:(NSDictionary *)sdp;
-(void)sendAnswer:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId sdp:(NSDictionary *)sdp;
-(void)sendIceCandidate:(NSString *)sender receiver:(NSString *)receiver room:(NSString *) roomId candidate:(NSDictionary *)candidate;

@end

NS_ASSUME_NONNULL_END
