//
//  ZXFilterCell.h
//  Masonry
//
//  Created by 谢泽鑫 on 2018/3/29.
//

#import <UIKit/UIKit.h>

@class ZXFilterCell;

typedef void(^cellBlock) (ZXFilterCell* filterCell);

@interface ZXFilterCell : UICollectionViewCell
@property (nonatomic,weak) UIButton* button;
@property (nonatomic,copy) NSString* value;
@property (nonatomic,strong) cellBlock block;
@property (nonatomic,strong) NSIndexPath* indexPath;
@property (nonatomic,assign) BOOL isCheckBox;
@property (nonatomic,copy) NSString* groupName;

@end
