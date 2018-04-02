//
//  LoginCellTableViewCell.m
//  GitHubDemo
//
//  Created by zrq on 2018/4/2.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import "LoginCellTableViewCell.h"
#import "CommonTool.h"
@interface LoginCellTableViewCell()<UITextFieldDelegate>
@property (assign, nonatomic) NSInteger index;
@end
@implementation LoginCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.infoTextField.delegate = self;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //self.backgroundColor = [UIColor clearColor];
    self.preservesSuperviewLayoutMargins = NO;//维持父控件的布局边距
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;

}
//设置cell 的风格
- (void)setImageWithLeftImageName:(NSString *)leftIconName andRightButtonIconName:(NSString *)rightIconName andPlceHolder:(NSString *)placeholder andText:(NSString *)text andIndex:(NSInteger)index andSecureTextEntry:(BOOL)secureTextEntry{
    //左侧icon
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 45, 50)];
    UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, (50-36/2)/2, 31/2, 36/2)];
    iconView.image = [UIImage imageNamed:leftIconName];
    [leftView addSubview:iconView];
    self.infoTextField.leftViewMode = UITextFieldViewModeAlways;
    self.infoTextField.leftView = leftView;
    self.infoTextField.placeholder = placeholder;
    self.infoTextField.text = text;
    self.infoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.infoTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.infoTextField.textColor = [UIColor blackColor];
    self.index = index;
    
    if (index == 2) {
        self.infoTextField.secureTextEntry = secureTextEntry;
    }
    
    if (![CommonTool isBlank:rightIconName]) {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 30, 50);
        [rightButton addTarget:self action:@selector(rightButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:[UIImage imageNamed:rightIconName] forState:UIControlStateNormal];
        [rightView addSubview:rightButton];
        self.infoTextField.rightViewMode = UITextFieldViewModeAlways;
        self.infoTextField.rightView = rightView;
    }
}
- (void)rightButtonClickAction:(UIButton *)sender {
    if (self.index == 0) {
        if (self.companyBlock) {
            self.companyBlock();
        }
    }else {
        if (self.passwordBlock) {
            self.passwordBlock();
        }
    }
}

//textField的代理方法
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField.placeholder isEqualToString:@"请选择"]) {
        if (self.companyBlock) {
            self.companyBlock();
        }
        return NO;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.editeBlock) {
        self.editeBlock(self.index, textField.text);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

