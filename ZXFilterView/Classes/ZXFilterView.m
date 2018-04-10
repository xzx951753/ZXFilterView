//
//  ZXFilterView.m
//  Pods-ZXFilterView_Example
//
//  Created by 谢泽鑫 on 2018/3/28.
//

#import "ZXFilterView.h"
#import <Masonry/Masonry.h>
#import "ZXFilterCell.h"
#import "ZXFilterHeaderView.h"
#import "UIImage+Color.h"
#import "UIColor+RGB.h"


@interface ZXFilterView()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIView* containerView;
@property (nonatomic,strong) NSArray* subOptions;
@property (nonatomic,weak) UIView* maskView;
@property (nonatomic,weak) UIView* toolBarView;
@property (nonatomic,weak) UIButton* resetBtn;
@property (nonatomic,weak) UIButton* finishBtn;
@property (nonatomic,assign) BOOL isCheckBox;
@property (nonatomic,strong) filterBlock block;
@property (nonatomic,strong) NSMutableDictionary* dict;
@property (nonatomic,strong) NSMutableDictionary* cellIdentifierDict;

@end

@implementation ZXFilterView

- (instancetype _Nullable)initWithSubOptions:(NSArray* _Nonnull)subOptions
                           withContainerView:(UIView* _Nonnull)containerView
                             withFilterBlock:(filterBlock _Nullable)block{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake( _containerView.frame.size.width,34);   //headerSize
    layout.estimatedItemSize = CGSizeMake(100, 0);       //cell的预估大小，cell的宽高不会小于这个数值
    layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);     //collectionView的外边距
    self.collectionViewLayout = layout;

    
    if ( self = [super initWithFrame:CGRectZero collectionViewLayout:layout] ){
        self.subOptions = subOptions;
        self.containerView = containerView;
        self.block = block;
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        
//        [self registerClass:[ZXFilterCell class] forCellWithReuseIdentifier:@"cell"];   //注册cell
        [self registerClass:[ZXFilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        
        
        //创建遮罩View
        UIView* maskView = [[UIView alloc] init];
        maskView.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:(_maskView = maskView)];
        //使用代理方法解决子view冲突，此处不需要handler
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
        tapGesture.delegate = self;
        [maskView addGestureRecognizer:tapGesture];

        //工具条View
        UIView* toolBarView = [[UIView alloc] init];
        toolBarView.backgroundColor = [UIColor grayColor];
        [maskView addSubview:(_toolBarView = toolBarView)];

        //重置按钮
        UIButton* resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:255 G:204 B:51] ] forState:UIControlStateNormal];
        [resetBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:180 G:180 B:180]] forState:UIControlStateHighlighted];
        [resetBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        resetBtn.titleLabel.textColor = [UIColor redColor];
        [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [resetBtn addTarget:self action:@selector(didClickResetBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        //提交按钮
        UIButton* finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [finishBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:255 G:153 B:0]] forState:UIControlStateNormal];
        [finishBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:180 G:180 B:180]] forState:UIControlStateHighlighted];
        [finishBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn addTarget:self action:@selector(didClickFinishBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [toolBarView addSubview:(_resetBtn = resetBtn)];
        [toolBarView addSubview:(_finishBtn = finishBtn)];
        
        //把filterView放入maskView中
        [maskView addSubview:self];
        
        

        //添加约束
        [self createAutoLayout];

    }
    return self;
}


- (void)createAutoLayout{
    
    //遮罩view添加约束
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    //工具栏约束
    [_toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(0);
        make.left.equalTo(self.maskView.mas_left).offset(self.containerView.frame.size.width);
        make.height.mas_equalTo(42);
    }];
    
    //添加filterView约束
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.equalTo(self.toolBarView.mas_left);
        make.bottom.equalTo(self.toolBarView.mas_top);
        make.right.equalTo(self.toolBarView.mas_right);
    }];
    
    
    UIView* toolBarLine = [[UIView alloc] init];
    [_toolBarView addSubview:toolBarLine];
    [toolBarLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(0);
    }];
    
    //重置按钮
    [_resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.right.equalTo(toolBarLine);
    }];
    
    //提交按钮
    [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.left.equalTo(toolBarLine);
    }];

}

- (void)show{
    self.maskView.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.maskView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.5];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0     /*动画时长*/
                              delay:0.0     /*动画延时*/
             usingSpringWithDamping:0.75    /*弹簧效果*/
              initialSpringVelocity:0.25    /*弹簧速度*/
                            options:UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [self.toolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
                                 make.left.equalTo(self.maskView.mas_left).offset(self.containerView.frame.size.width*0.16);
                             }];
                             [self.maskView layoutIfNeeded];
                         } completion:nil];
    }];
}

- (void)hide{
    [self.toolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maskView.mas_left).offset(self.containerView.frame.size.width);
    }];
    self.maskView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.maskView layoutIfNeeded];
    self.maskView.hidden = YES;
    self.dict = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.subOptions.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    ZXFilterViewModel* model = self.subOptions[section];
    return model.buttonNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    if ( _cellIdentifierDict == nil ) {
        _cellIdentifierDict = [NSMutableDictionary dictionary];
    }
    
    NSString *identifier = [_cellIdentifierDict objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    
    if(identifier == nil){
        identifier = [NSString stringWithFormat:@"selectedBtn%@", [NSString stringWithFormat:@"%@", indexPath]];
        [_cellIdentifierDict setObject:identifier forKey:[NSString  stringWithFormat:@"%@",indexPath]];
        // 注册Cell
        [collectionView registerClass:[ZXFilterCell class] forCellWithReuseIdentifier:identifier];
    }
    
    ZXFilterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ( !cell ){
        cell = [[ZXFilterCell alloc] initWithFrame:CGRectZero];
    }
    
    if ( indexPath.section == 0 && indexPath.row == 0 ){
        NSLog(@"%p",cell);
    }
    
    ZXFilterViewModel* model = self.subOptions[indexPath.section];
    [cell.button setTitle:model.buttonNames[indexPath.row] forState:UIControlStateNormal];
    cell.value = model.buttonValues[indexPath.row];
    cell.indexPath = indexPath;
    
    cell.block = ^(ZXFilterCell *filterCell) {/*选中时回调*/
        //取出filterCell.indexPath.section所对应的数据模型
        ZXFilterViewModel* model = self.subOptions[filterCell.indexPath.section];

        if ( self.dict == nil ){
            self.dict = [NSMutableDictionary dictionary];
        }

        //判断是否为复选框，如果非复选框，则置弹起其他按钮。
        if ( !model.isCheckBox ){
            for ( NSInteger count = 0 ; count < model.buttonValues.count ; count++ ){
                //创建当前选中的cell的indexPath, 并用它获取当前选中的cell
                NSIndexPath* otherIndexPath = [NSIndexPath indexPathForRow:count inSection:filterCell.indexPath.section];
                ZXFilterCell* otherCell = (ZXFilterCell*)[collectionView cellForItemAtIndexPath:otherIndexPath];
                if ( count == filterCell.indexPath.row ){
                    if ( otherCell.isSelected ){
                        //当前otherCell.isSelected状态为YES时候，说明点击前为选中状态，应该要置空dict
                        [self.dict removeObjectForKey:model.groupName];
                    }else{
                        [self.dict setObject:model.buttonValues[filterCell.indexPath.row] forKey:model.groupName];
                    }
                }else{
                    //其他的cell,设置为非选中状态
                    otherCell.selected = NO;
                }
            }
        }else{
            //复选框,先遍历所有按钮，把cell.isSelected=YES的筛选出来
            for ( NSInteger count = 0 ; count < model.buttonValues.count ; count++ ){
                //创建当前选中的cell的indexPath, 并用它获取当前选中的cell
                NSIndexPath* otherIndexPath = [NSIndexPath indexPathForRow:count inSection:filterCell.indexPath.section];
                ZXFilterCell* otherCell = (ZXFilterCell*)[collectionView cellForItemAtIndexPath:otherIndexPath];
                if ( count == filterCell.indexPath.row ){
                    //从字典中取出数组
                    NSMutableArray* mArray = [self.dict objectForKey:model.groupName];
                    if ( mArray == nil ){
                        mArray = [NSMutableArray array];
                    }
                    if ( otherCell.isSelected ){
                        //当前otherCell.isSelected状态为YES时候，说明点击前为选中状态，应该要从dict中删除该cell的value
                        //遍历数组,如果数组中存在和当前otherCell.value相同的值，则从数组中删除
                        for ( NSInteger count = 0 ; count < mArray.count ; count++ ){
                            NSString* val = mArray[count];
                            if ( [val isEqualToString:otherCell.value] ){
                                [mArray removeObjectAtIndex:count];
                            }
                        }
                    }else{
                        [mArray addObject:otherCell.value];
                    }
                    //把数组回写到dict
                    [self.dict setObject:mArray forKey:model.groupName];
                }
            }
        }
        self.block(self.dict);
    };
    return cell;
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ZXFilterHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
    ZXFilterViewModel* model = self.subOptions[indexPath.section];
    headerView.title = model.groupName;
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;

}


/*代理方法解决maskView和子view的touch冲突*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ( [touch.view isEqual:_maskView] ){
        [self hide];
    }
    return YES;
}

/*重新加载*/
- (void)reload{
    self.dict = nil;
    [self reloadData];
    self.block(self.dict);
}

/*重置按钮*/
- (void)didClickResetBtn:(UIButton*)sender{
    [self reload];
}

/*完成按钮*/
- (void)didClickFinishBtn:(UIButton*)sender{
    [self hide];
}

@end
