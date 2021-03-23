//
//  VideoCell.h
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import <UIKit/UIKit.h>
#import "WebRTCManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UICollectionViewCell
@property(nonatomic, strong) RTCMTLVideoView *renderer;
@end

NS_ASSUME_NONNULL_END
