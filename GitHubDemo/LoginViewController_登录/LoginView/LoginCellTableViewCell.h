//
//  LoginCellTableViewCell.h
//  GitHubDemo
//
//  Created by zrq on 2018/4/2.
//  Copyright © 2018年 zrq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginCellTableViewCell : UITableViewCell
///输入密码的block
typedef void(^ShowPasswordBlock)(void);
///输入文本框的block
typedef void(^TextFieldEndEditeBlock)(NSInteger index, NSString *str);
///定义展示view的block
typedef void(^ShowCompanyListViewBlock)(void);
///文本输入框
@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@property (copy, nonatomic) ShowCompanyListViewBlock companyBlock;
@property (copy, nonatomic) TextFieldEndEditeBlock editeBlock;
@property (copy, nonatomic) ShowPasswordBlock passwordBlock;
///设置cell 的风格   leftIconName:左侧的图标  rightIconName：右侧的图标  placeholder：提示要输入的内容
- (void)setImageWithLeftImageName:(NSString *)leftIconName andRightButtonIconName:(NSString *)rightIconName andPlceHolder:(NSString *)placeholder andText:(NSString *)text andIndex:(NSInteger)index andSecureTextEntry:(BOOL)secureTextEntry;
@end
