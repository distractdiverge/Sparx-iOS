//
//  FrontController.h
//  SparxPrototype
//
//  Created by Alexander Lapinski on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DecoderDelegate.h"
@class QRImagePickerController;
@class OverlayView;

static const int kGenerateViewTag = 1;
static const int kScanViewTag = 2;

@interface FrontController : UIViewController <ABPeoplePickerNavigationControllerDelegate, 
    UITabBarDelegate, 
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    DecoderDelegate,
    ABPersonViewControllerDelegate>
{
    IBOutlet UITabBar* navBar;
    IBOutlet UITabBarItem* generateNavButton;
    IBOutlet UITabBarItem* scanNavButton;
    IBOutlet UIView* viewport;
   
    IBOutlet UIView* generateView;
    IBOutlet UIImageView* qrView;
    IBOutlet UIButton* selectContactButton;
    
    IBOutlet UIView* scanView;
    IBOutlet UILabel* scanOutput;
    IBOutlet UIButton* scanCodeButton;
    
    @private
    UIImagePickerController*  _imagePicker;
    OverlayView*              _overlayView;
    NSTimer*                  _timer;
    QRDecoder*                _decoder;

}

-(IBAction)handleSelectContactButtonPressed:(id)sender;
-(IBAction)handleScanCodeButtonPressed:(id)sender;

@end
