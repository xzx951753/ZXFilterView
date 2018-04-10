//
//  ZXFilterCellModel.h
//  Masonry
//
//  Created by 谢泽鑫 on 2018/3/29.
//

#import <Foundation/Foundation.h>

@interface ZXFilterViewModel : NSObject

@property (nonatomic,copy) NSString* groupName;
@property (nonatomic,strong) NSArray* buttonNames;
@property (nonatomic,strong) NSArray* buttonValues;
@property (nonatomic,assign) BOOL isCheckBox;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
