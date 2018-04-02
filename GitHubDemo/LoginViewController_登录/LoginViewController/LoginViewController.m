//
//  LoginViewController.m
//  GitHubDemo
//
//  Created by zrq on 2018/4/2.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginModel.h"
#import "LoginCellTableViewCell.h"
@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *infoTableView;
@property(strong,nonatomic)LoginModel *loginInfo;
///是否影藏密码
@property (assign, nonatomic) BOOL SECURE_TEXT_ENTRY;
///密码右侧的图片名称
@property (assign, nonatomic) NSString *rightImageName;
///是否记住密码
@property (assign, nonatomic) BOOL IS_REMEBER_PASSWORD;
///是否记住密码按钮
@property (strong, nonatomic) UIButton *remeberButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLoginTableView];//创建登录视图
}
#pragma mark --创建登录视图
- (void)createLoginTableView{
    self.infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.infoTableView.delegate = self;
    self.infoTableView.showsVerticalScrollIndicator = NO;
    self.infoTableView.showsHorizontalScrollIndicator = NO;
    //    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     //[self.infoTableView  setSeparatorColor:[UIColor blueColor]];
    self.infoTableView.dataSource = self;
    [self.view addSubview:self.infoTableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"LoginViewCell";
    LoginCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LoginCellTableViewCell" owner:nil options:nil].firstObject;
    }
    if (indexPath.row == 0) {
        NSLog(@"%f---%f",cell.frame.origin.x,cell.frame.origin.y);
        
        [cell setImageWithLeftImageName:@"login_ico_sx" andRightButtonIconName:@"into" andPlceHolder:@"请选择" andText:self.loginInfo.comName andIndex:indexPath.row andSecureTextEntry:NO];
    }else if (indexPath.row == 1) {
        [cell setImageWithLeftImageName:@"login_ico_yh" andRightButtonIconName:@"" andPlceHolder:@"工号" andText:self.loginInfo.loginName andIndex:indexPath.row andSecureTextEntry:NO];
    }else {
        [cell setImageWithLeftImageName:@"login_ico_mima" andRightButtonIconName:@"" andPlceHolder:@"密码" andText:self.loginInfo.password andIndex:indexPath.row andSecureTextEntry:YES];
    }
    //点击选择公司
    cell.companyBlock = ^(){
       // [self showCompanyListView];
    };
    //textField编辑
    cell.editeBlock = ^(NSInteger index, NSString *str) {
        if (index == 1) {
            self.loginInfo.loginName = str;
        }else {
            self.loginInfo.password = str;
        }
    };
    //查看密码
    cell.passwordBlock = ^(){
       // [self lookPasswordAction];
    };
    return cell;
}
//登录视图的开发
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
