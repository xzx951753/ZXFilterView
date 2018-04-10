//
//  UIColor+RGB.m
//  ZXFilterView
//
//  Created by 谢泽鑫 on 2018/4/9.
//

#import "UIColor+RGB.h"

@implementation UIColor(RGB)

+ (UIColor*)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
