//
//  ZXFilterHeaderView.m
//  Masonry
//
//  Created by 谢泽鑫 on 2018/4/3.
//

#import "ZXFilterHeaderView.h"
#import "UIColor+RGB.h"
#import <Masonry/Masonry.h>

@interface ZXFilterHeaderView()

@property (nonatomic,strong) UILabel* titleLabel;

@end

@implementation ZXFilterHeaderView

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
    _titleLabel.textColor = [UIColor colorWithR:80 G:80 B:80];
    _titleLabel.text = _title;
    _titleLabel.numberOfLines = 1;
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

@end
