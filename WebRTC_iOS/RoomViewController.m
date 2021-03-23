//
//  RoomViewController.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import "RoomViewController.h"
#import "VideoCell.h"
#import "Config.h"

#import "WebRTCManager.h"
@interface RoomViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WebRTCManagerDelegate>
@property(nonatomic, strong)NSString* username;
@property(nonatomic, strong)NSString* roomId;
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation RoomViewController
-(instancetype)initWithUsername:(NSString *)username roomId:(NSString *)roomId{
    if ([super init]) {
        _username = username;
        _roomId = roomId;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [[WebRTCManager shareInstance]initIceServers:defaultIceServers Room:self.roomId userId:self.username socketUrl:socket_server];
    [WebRTCManager shareInstance].delegate = self;
   

    
    [[WebRTCManager shareInstance]startCaptureLocalVideoPosition:AVCaptureDevicePositionFront];
    NSDictionary *dict = @{@"peerId":self.username,@"renderer":[WebRTCManager shareInstance].localVideo};
    [self.dataSource addObject:dict];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

-(NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

-(UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame)/2 - 15, CGRectGetWidth(self.view.frame)/2 -15);
        layout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[VideoCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    NSDictionary *dict = self.dataSource[indexPath.row];
    cell.renderer = dict[@"renderer"];
    return cell;
}

-(void)webRTCManager:(WebRTCManager *)manager RemovePeerId:(nonnull NSString *)peerId video:(nonnull RTCMTLVideoView *)renderer{
    for (int i=0; i<self.dataSource.count; i++) {
        NSDictionary *dict = self.dataSource[i];
        if ([dict[@"peerId"] isEqual:peerId]) {
            [self.dataSource removeObjectAtIndex:i];
        }
    }
    [self.collectionView reloadData];
}
-(void)webRTCManager:(WebRTCManager *)manager AddLocalPeerId:(nonnull NSString *)peerId localVideo:(nonnull RTCMTLVideoView *)renderer{

}

-(void)webRTCManager:(WebRTCManager *)manager remotePeersVideos:(nonnull NSDictionary *)peerVideos{
    [peerVideos enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *dict = @{@"peerId":key,@"renderer":obj};
        [self.dataSource addObject:dict];
    }];
 
    [self.collectionView reloadData];
}
-(void)webRTCManager:(WebRTCManager *)manager AddRemotePeerId:(nonnull NSString *)peerId remoteVideo:(nonnull RTCMTLVideoView *)renderer {
    NSDictionary *dict = @{@"peerId":peerId,@"renderer":renderer};
    [self.dataSource addObject:dict];
    [self.collectionView reloadData];
}
-(void)dealloc {
    [[WebRTCManager shareInstance] leaveRoom];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
