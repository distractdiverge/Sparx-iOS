//
//  FrontController.m
//  SparxPrototype
//
//  Created by Alexander Lapinski on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "


#import "FrontController.h"

@implementation FrontController

#pragma mark - 
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
	UIImage* image = [QREncoder encode:@"http://www.google.com/"];
    
	UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat qrSize = self.view.bounds.size.width - kPadding * 2;
	imageView.frame = CGRectMake(kPadding, (self.view.bounds.size.height - qrSize) / 2,
                                 qrSize, qrSize);
	[imageView layer].magnificationFilter = kCAFilterNearest;
    
	[self.view addSubview:imageView];
    [imageView release];

}
@end
