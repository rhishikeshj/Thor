//
//  DetailViewController.h
//  Thor
//
//  Created by Rhishikesh Joshi on 01/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

