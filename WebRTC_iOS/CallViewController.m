//
//  CallViewController.m
//  WebRTC_iOS
//
//  Created by Apple on 2021/3/16.
//

#import "CallViewController.h"
#import "RoomViewController.h"
@interface CallViewController ()
@property(nonatomic, strong)UILabel *nameLa;
@property(nonatomic, strong)UITextField *nameTF;
@property(nonatomic, strong)UILabel *roomLa;
@property(nonatomic, strong)UITextField *roomTF;
@property(nonatomic, strong)UIButton *enterBtn;
@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.nameLa];
    [self.view addSubview:self.nameTF];
    [self.view addSubview:self.roomLa];
    [self.view addSubview:self.roomTF];
    [self.view addSubview:self.enterBtn];
    // Do any additional setup after loading the view.
}

-(UILabel *)nameLa {
    if (_nameLa == nil) {
        _nameLa = [[UILabel alloc]initWithFrame:CGRectMake(20, 120, 60, 40)];
        _nameLa.text = @"用户名";
        _nameLa.textColor = [UIColor blackColor];
    }
    return _nameLa;
}
-(UITextField *)nameTF {
    if (_nameTF == nil) {
        _nameTF = [[UITextField alloc]init];
        _nameTF.frame = CGRectMake(100, 120, 200, 40);
        _nameTF.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _nameTF;
}

-(UILabel *)roomLa {
    if (_roomLa == nil) {
        _roomLa = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, 60, 40)];
        _roomLa.text = @"房间号";
        _roomLa.textColor = [UIColor blackColor];
    }
    return _roomLa;
}
-(UITextField *)roomTF {
    if (_roomTF == nil) {
        _roomTF = [[UITextField alloc]init];
        _roomTF.frame = CGRectMake(100, 200, 200, 40);
        _roomTF.borderStyle = UITextBorderStyleRoundedRect;
    }
    return _roomTF;
}
-(UIButton *)enterBtn {
    if (_enterBtn == nil) {
        _enterBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 45 , 300, 90, 40)];
        [_enterBtn setTitle:@"进入房间" forState:UIControlStateNormal];
        [_enterBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_enterBtn addTarget:self action:@selector(enterClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterBtn;;
}
-(void)enterClick {
    if (self.nameTF.text.length >0 && self.roomTF.text.length >0) {
        RoomViewController *vc = [[RoomViewController alloc]initWithUsername:self.nameTF.text roomId:self.roomTF.text];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
