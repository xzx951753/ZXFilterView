//
//  ZXViewController.m
//  ZXFilterView
//
//  Created by xzx951753 on 03/28/2018.
//  Copyright (c) 2018 xzx951753. All rights reserved.
//

#import "ZXViewController.h"
#import <Masonry/Masonry.h>
#import <ZXFilterView/ZXFilterView.h>

@interface ZXViewController ()

@property (nonatomic,strong) NSArray* dataArray;

@property (nonatomic,weak) ZXFilterView* filterView;

@end

@implementation ZXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
        生成筛选数据
        根据ZXFilterCellModel字段，生成必要的：groupName<字符串：组名> ,
                                    buttonNames<数组：NSString类型的按钮名>
                                   buttonValues<数组：NSString类型的按钮值>
                                  isCheckBox:<布尔值：是否为复选框>
     Start:
     */
    NSMutableArray* mArray = [NSMutableArray array];        //mArray用于存储ZXFilterCellModel
    for ( NSInteger groupCount = 0 ; groupCount < 5 ; groupCount++ ){
        NSMutableDictionary* mDict = [NSMutableDictionary dictionary];
        NSMutableArray* buttonNames = [NSMutableArray array];
        NSMutableArray* buttonVals = [NSMutableArray array];
        
        //设置组名
        [mDict setObject:[NSString stringWithFormat:@"group%ld",groupCount] forKey:@"groupName"];

        for ( NSInteger buttonCount = 0 ; buttonCount < 15 ; buttonCount++ ){   //外循环3次，创建groupCound个group，每组group14个按钮
            [buttonNames addObject:[NSString stringWithFormat:@"Button%ld",buttonCount]];
            [buttonVals addObject:[NSString stringWithFormat:@"%ld",buttonCount]];
        }
        
        [mDict setObject:buttonNames forKey:@"buttonNames"];
        [mDict setObject:buttonVals forKey:@"buttonValues"];
        
        if ( groupCount == 1 ) {
            [mDict setObject:[NSNumber numberWithBool:YES] forKey:@"isCheckBox"];   //设置group1为复选框
        }
        
        ZXFilterViewModel* model = [[ZXFilterViewModel alloc] initWithDict:mDict];  //字典转模型
        [mArray addObject:model];
    }
    _dataArray = mArray;
    /***********  :End *************/
    
    
    /*
        创建筛选按钮
     Start:
     */
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"筛选" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didClickFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(20);
    }];
    /************* :End ***************/
    
    
    /*
        创建筛选器，containerView是筛选菜单的父view，你希望把筛选菜单放到哪？
        可以放到self.view 、 self.navigationController.view 、 self.tabBarController.view …………
        最好找一个能覆盖全屏的view
        withFilterBlock: 选中按钮触发该block， 并且把选中数据通过dict显示出来.
     Start:
     */
    ZXFilterView* filterView = [[ZXFilterView alloc] initWithSubOptions:self.dataArray
                                                      withContainerView:self.tabBarController.view withFilterBlock:^(NSDictionary *dict) {
                                                          NSLog(@"%@",dict);
                                                      }];
    _filterView = filterView;
    /************* :End ***************/
}


- (void)didClickFilterBtn:(id)sender{
    //弹出ZXFilterView
    [_filterView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
