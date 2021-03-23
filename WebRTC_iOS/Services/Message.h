//
//  Message.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject
@property(nonatomic, copy)NSString *event;
@property(nonatomic, copy)NSString *sender;
@property(nonatomic, copy)NSString *roomId;
@property(nonatomic, copy)NSString *receiver;
@property(nonatomic, strong) id data;
@end

NS_ASSUME_NONNULL_END
