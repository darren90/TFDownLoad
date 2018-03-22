//
//  TFViewController.m
//  TFDownLoad
//
//  Created by 1005052145@qq.com on 03/18/2018.
//  Copyright (c) 2018 1005052145@qq.com. All rights reserved.
//

#import "TFViewController.h"
#import "TFDownloadManager.h"

@interface TFViewController ()

@end

@implementation TFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	 
}

- (IBAction)downloadAction:(id)sender {
    [TFDownloadManager manager];
}

- (IBAction)pauseAction:(id)sender {
    
}

- (IBAction)continueAction:(id)sender {
    
}



@end
