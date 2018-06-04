//
//  ZXFilterCell.m
//  Masonry
//
//  Created by 谢泽鑫 on 2018/3/29.
//

#import "ZXFilterCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"
#import "UIImage+Color.h"

#define MaxWidth 180.0
#define MinWidth 30.0

@interface ZXFilterCell()
@property (nonatomic,assign) BOOL isReloading;
@end

@implementation ZXFilterCell


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if ( self ){
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 0.5;
        UIButton* buttom = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttom addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [buttom.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:(_button = buttom)];
        [self createAutoLayout];
        [self judgeStatus];
        
        //安装重置按钮通知,收到通知后，清空cell状态
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetNotificationHander)
                                                     name:@"ZXFilterViewReset"
                                                   object:nil];
        
        //安装点击事件通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boundNotificationHander:)
                                                     name:@"ZXFilterViewBound"
                                                   object:nil];
    }
    return self;
}


- (void)resetNotificationHander{
    //设置重置状态标识
    _isReloading = YES;
}

//收到点击事件的通知
- (void)boundNotificationHander:(NSNotification*)notic{
    /*选中cell后，所有按钮都会收到同通知，对比notic.objcect，如果是通知自己则处理block, 不是通知自己的则弹起按钮*/
    ZXFilterCell* noticCell = (ZXFilterCell*)notic.object;
    if ( noticCell.indexPath.section == self.indexPath.section ){
        if ( [self isEqual:noticCell] ){
            self.selected = self.isSelected ? NO : YES;
            if ( self.block ){
                self.block(self);
            }
        }else{
            if ( !self.isCheckBox ){
                self.selected = NO;
            }
        }
    }
}

- (void)createAutoLayout{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.button.mas_bottom).offset(0);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_offset(-10);
        make.bottom.mas_equalTo(0);
    }];
    
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    size.width = [self calculateContentWidth];
    cellFrame.size = size;
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
}

//计算title所需要的宽度
- (CGFloat)calculateContentWidth{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:_button.titleLabel.font forKey:NSFontAttributeName];
    CGSize size = [_button.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0)                                             options:NSStringDrawingUsesLineFragmentOrigin
    attributes:dic context:nil].size;
    CGFloat width = size.width;
    if ( width > MaxWidth ){     //判断title字符长度是否超过MaxWidth
        width = MaxWidth + 24;      //如果超过了MaxWidth，按钮长度=MaxWidth+24
    }else if ( width < MinWidth ){      //判断title字符长度小于MinWidth
        width = MinWidth + 24;            //如果小于MinWidth，按钮长度=MinWidth+24
    }else{
        width += 24;            //其他情况，直接给字符宽度+24
    }
    return width;
}

- (void)didClickBtn:(UIButton*)sender{
    //向所有cell发送通知,把当前点击的cell作为对象发出
    NSNotification * notice = [NSNotification notificationWithName:@"ZXFilterViewBound" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notice];
}


- (void)judgeStatus{
    if ( self.isSelected ){
        self.backgroundColor = [UIColor colorWithR:255 G:239 B:213];
        self.layer.borderColor = [UIColor colorWithR:255 G:153 B:0].CGColor;
        [_button setTitleColor:[UIColor colorWithR:255 G:153 B:0] forState:UIControlStateNormal];
    }else{
        self.backgroundColor = [UIColor colorWithR:242 G:242 B:242];
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [_button setTitleColor:[UIColor colorWithR:170 G:170 B:170] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self judgeStatus];
}

/*重写prepareForReuse方法，防止cell在重用时，isSelected状态被清空*/
- (void)prepareForReuse{
    if ( self.isReloading ){
        _isReloading = NO;
        [super prepareForReuse];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
