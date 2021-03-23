//
//  SocketManager.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/8.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>
typedef NS_ENUM(NSUInteger,WebSocketConnectType){
    WebSocketDefault = 0, //初始状态,未连接
    WebSocketConnect,      //已连接
    WebSocketDisconnect    //连接后断开
};


NS_ASSUME_NONNULL_BEGIN

@class SocketManager;
@protocol WebSocketManagerDelegate <NSObject>

- (void)WebSocketManager:(SocketManager *)webSocketManager connect:(WebSocketConnectType)connectType;
- (void)webSocketManager:(SocketManager *)webSocketManager webSocketManagerDidReceiveMessageWithString:(NSString *)string;

@end

@interface SocketManager : NSObject
@property (nonatomic, assign)   BOOL isConnect;  //是否连接
@property (nonatomic, assign)   WebSocketConnectType connectType;
@property(nonatomic,weak)  id<WebSocketManagerDelegate > delegate;
+(instancetype)shareInstance;
-(void)linkSocket:(NSString *)url;
-(void)sendMessage:(id)message; //发送消息
- (void)reConnectServer;//重新连接
- (void)RMWebSocketClose;//关闭长连接
@end

NS_ASSUME_NONNULL_END
