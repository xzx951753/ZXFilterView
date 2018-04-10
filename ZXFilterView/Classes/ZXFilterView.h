//
//  ZXFilterView.h
//  Pods-ZXFilterView_Example
//
//  Created by 谢泽鑫 on 2018/3/28.
//

#import <UIKit/UIKit.h>
#import "ZXFilterViewModel.h"

typedef void(^filterBlock) (NSDictionary* dict);

@interface ZXFilterView : UICollectionView

- (instancetype _Nullable)initWithSubOptions:(NSArray* _Nonnull)subOptions
                           withContainerView:(UIView* _Nonnull)containerView
                             withFilterBlock:(filterBlock _Nullable)block;
- (void)show;
- (void)hide;
@end
