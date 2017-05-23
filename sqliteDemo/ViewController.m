//
//  ViewController.m
//  数据库
//
//  Created by roc on 2017/1/11.
//  Copyright © 2017年 roc. All rights reserved.
//

#import "ViewController.h"
#import "PModel.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface ViewController ()

@property(nonatomic,assign)sqlite3 *sqlite3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"====%@",docDir);
    
    
    [self creatDatabase:nil creatSuccessed:^{
        
        NSLog(@"创表成功");
        
        [self insertData:nil insertSuccessed:^{
            
            NSLog(@"插入数据成功");
            
        } insertFailed:^{
            NSLog(@"插入数据失败");
            
        }];
        
    } creatFailed:^{
        
        NSLog(@"失败");
    }];
    
    
    
}

-(void)creatDatabase:(PModel *)model creatSuccessed:(void(^)())sucessed creatFailed:(void(^)())failed{
    
    //获取pmodel中变量的名字
    NSMutableArray *nameArray = [NSMutableArray array];
    
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList([PModel class], &propertyCount);
    
    for (int i = 0; i<propertyCount; i++) {
        objc_property_t propety = propertys[i];
        const char *propertyName = property_getName(propety);
        
        [nameArray addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    free(propertys);
    
    //    NSLog(@"xxx%@",nameArray);
    
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"person.db"];
    NSInteger result = sqlite3_open(fileName.UTF8String, &_sqlite3);
    if (result == SQLITE_OK) {
        //        NSLog(@"打开数据库成功");
        char *errmsg = NULL;
        sqlite3_exec(_sqlite3, [NSString stringWithFormat:@"create table if not exists t_person(ID integer primary key autoincrement,%@ text ,%@ integer)",nameArray[1],nameArray[2]].UTF8String, NULL, NULL, &errmsg);
        if (!errmsg) {
            //            NSLog(@"创表成功");
            
            sucessed();
        } else {
            //            NSLog(@"创表失败:%s",errmsg);
            failed();
        }
        
    }else{
        //        NSLog(@"打开数据库失败");
        failed();
    }
    
}

-(void)insertData:(PModel *)model insertSuccessed:(void(^)())success insertFailed:(void(^)())failed{
    
    NSString *nameStr = @"roc";
    NSInteger age = 18;
    NSString *sql = [NSString stringWithFormat:@"insert into t_person(name,age) VALUES('%@','%ld')",nameStr,age];
    char *errmsg = NULL;
    sqlite3_exec(_sqlite3, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        
        failed();
    }else{
        
        success();
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
