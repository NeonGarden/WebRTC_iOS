//
//  VideoCell.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import "VideoCell.h"

@implementation VideoCell
-(instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.clipsToBounds = YES;
    }
    return self;
}
-(void)setRenderer:( RTCMTLVideoView *)renderer{
    renderer.frame = self.contentView.frame;
    _renderer = renderer;
    [self.contentView addSubview:_renderer];
    
}
@end
