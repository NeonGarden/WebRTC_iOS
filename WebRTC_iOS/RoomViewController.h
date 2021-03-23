//
//  RoomViewController.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomViewController : UIViewController
-(instancetype)initWithUsername:(NSString *)username roomId:(NSString *)roomId;
@end

NS_ASSUME_NONNULL_END
