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
@property (nonatomic,strong) NSMutableDictionary* cellOptionsCacheDict;
@property (nonatomic,strong) NSMutableDictionary* cellIdentifiersCacheDict;
@property (nonatomic,strong) NSMutableArray* cellCacheArray;
@property (nonatomic,strong) NSMutableArray* cellTempArray;
@end

@implementation ZXFilterView

- (instancetype _Nullable)initWithSubOptions:(NSArray* _Nonnull)subOptions
                           withContainerView:(UIView* _Nonnull)containerView
                             withFilterBlock:(filterBlock _Nullable)block{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake( _containerView.frame.size.width,34);   //headerSize
    layout.estimatedItemSize = CGSizeMake(100, 0);       //cell的预估大小，cell的宽高不会小于这个数值
    layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);     //collectionView的外边距

    
    if ( self = [super initWithFrame:CGRectZero collectionViewLayout:layout] ){
        self.subOptions = subOptions;
        self.containerView = containerView;
        self.block = block;
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
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
        make.height.mas_equalTo(45);
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
        [UIView animateWithDuration:0.75     /*动画时长*/
                              delay:0.0     /*动画延时*/
             usingSpringWithDamping:0.75    /*弹簧效果*/
              initialSpringVelocity:0    /*弹簧速度*/
                            options:UIViewAnimationOptionLayoutSubviews
                         animations:^{
                             [self.toolBarView mas_updateConstraints:^(MASConstraintMaker *make) {
                                 make.left.equalTo(self.maskView.mas_left).offset(60);
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
    [self.cellOptionsCacheDict removeAllObjects];
    [self.cellIdentifiersCacheDict removeAllObjects];
    [self reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.subOptions.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    ZXFilterViewModel* model = self.subOptions[section];
    return model.buttonNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    /**
        该段代码用于解决使用registerClass注册cell后，因重用机制，
        导致cell每次重用时isSelected状态会被清空，特此为每个cell在地址池申请注册，
        通过不同的identifier把cell的内存地址固定住
        start
     **/
    if ( _cellIdentifiersCacheDict == nil ) {
        _cellIdentifiersCacheDict = [NSMutableDictionary dictionary];
    }

    NSString *identifier = [_cellIdentifiersCacheDict objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    
    if(identifier == nil){
        identifier = [NSString stringWithFormat:@"selectedBtn%@", [NSString stringWithFormat:@"%@", indexPath]];
        [_cellIdentifiersCacheDict setObject:identifier forKey:[NSString  stringWithFormat:@"%@",indexPath]];
        // 注册Cell
        [collectionView registerClass:[ZXFilterCell class] forCellWithReuseIdentifier:identifier];
    }
    /************************ end ***************************/
    
    ZXFilterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ZXFilterViewModel* model = self.subOptions[indexPath.section];
    [cell.button setTitle:model.buttonNames[indexPath.row] forState:UIControlStateNormal];
    cell.value = model.buttonValues[indexPath.row];
    cell.indexPath = indexPath;
    

    
    /*
     version : 0.1.3
     解决某个组因cell过多，划出屏幕时，消失的cell会被释放掉，所以将所有cell存入数组。
     使用嵌套数组，cellArray存放了model.buttonValues.count个数组, groupArray和每个section的cell顺序一一对应
     Start:
     */
    if ( _cellCacheArray == nil ){
        _cellCacheArray = [NSMutableArray array];
    }
    
    if ( _cellTempArray == nil ){
        _cellTempArray = [NSMutableArray array];
    }
    
    //遍历_cellCacheArray,查找当前cell是否在_cellCacheArray中存在
    NSInteger find = 0;     //find = 重复存在的次数
    for ( NSArray* group in _cellCacheArray ){
        for ( ZXFilterCell* item in group ){
            if ( [cell isEqual:item] ){
                find += 1;
            }
        }
    }

    if ( find == 0 ){
        [_cellTempArray addObject:cell];
        if ( indexPath.row == model.buttonValues.count - 1 ){
            [_cellCacheArray addObject:_cellTempArray];
            _cellTempArray = nil;
        }
    }
    /*********** :End *************/


    
    /************ :End ***********/
    
    
    /*
        点击子按钮时，触发该block
     Start:
     */
    cell.block = ^(ZXFilterCell *filterCell) {
        //锁定重置按键
        self.resetBtn.enabled = NO;
        //选中按钮由didSelectItem方法处理
        [self didSelectItem:filterCell];
        //接触重置锁定按钮
        self.resetBtn.enabled = YES;
    };
    /************ :End ************/

    return cell;
}


- (void)didSelectItem:(ZXFilterCell*)cell{
    
    //判断cell缓存数组是否越界，防止崩溃
    if ( cell.indexPath.section > _cellCacheArray.count ){
        return ;
    }
    
    //cell选项缓存
    if ( self.cellOptionsCacheDict == nil ){
        self.cellOptionsCacheDict = [NSMutableDictionary dictionary];
    }

    //组模型
    ZXFilterViewModel* model = (ZXFilterViewModel*)self.subOptions[cell.indexPath.section];
    
    //保存按钮旧状态
    BOOL tempSelectStatus = cell.isSelected;
    
    if ( model.isCheckBox ){ //复选
        //从字典中取出数组
        NSMutableArray* mArray = [self.cellOptionsCacheDict objectForKey:model.groupName];
        if ( mArray == nil ){
            mArray = [NSMutableArray array];
        }
        
        if ( tempSelectStatus ){  //当前isSelected状态为YES时候，说明点击前为选中状态，应该要从dict中删除该cell的value
            cell.selected = NO;
        //遍历数组,如果数组中存在和当前otherCell.value相同的值，则从数组中删除
            for ( NSInteger count = 0 ; count < mArray.count ; count++ ){
                NSString* val = mArray[count];
                if ( [val isEqualToString:cell.value] ){
                    [mArray removeObjectAtIndex:count];
                }
            }
        }else{
            cell.selected = YES;
            [mArray addObject:cell.value];
        }
        [self.cellOptionsCacheDict setObject:mArray forKey:model.groupName];
    }else{ //单选
        for ( ZXFilterCell* item in _cellCacheArray[cell.indexPath.section] ){
            item.selected = NO;
        }
        
        if ( tempSelectStatus ){
            cell.selected = NO;
            [self.cellOptionsCacheDict removeObjectForKey:model.groupName];
        }else{
            cell.selected = YES;
            [self.cellOptionsCacheDict setObject:model.buttonValues[cell.indexPath.row] forKey:model.groupName];
        }
    }
    self.block(self.cellOptionsCacheDict);
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
    [self.cellOptionsCacheDict removeAllObjects];
    [self.cellIdentifiersCacheDict removeAllObjects];
    [self reloadData];
    self.block(self.cellOptionsCacheDict);
}

/*重置按钮*/
- (void)didClickResetBtn:(UIButton*)sender{
    [self reload];
}

/*完成按钮*/
- (void)didClickFinishBtn:(UIButton*)sender{
    [self hide];
}


- (void)reloadData{
    //发送通知,告诉cell，即将重置所有按钮
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZXFilterViewReset" object:nil];
    [super reloadData];
}

@end
