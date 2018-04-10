//
//  ZXFilterCellModel.m
//  Masonry
//
//  Created by 谢泽鑫 on 2018/3/29.
//

#import "ZXFilterViewModel.h"

@implementation ZXFilterViewModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if ( self = [super init] ){
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setNilValueForKey:(NSString *)key{};
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{};
@end
