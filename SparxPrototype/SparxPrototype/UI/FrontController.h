//
//  FrontController.h
//  SparxPrototype
//
//  Created by Alexander Lapinski on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface FrontController : UIViewController <ABPeoplePickerNavigationControllerDelegate>
{
    IBOutlet UIImageView* qrView;
    IBOutlet UIButton* selectContactButton;
}

-(IBAction)handleSelectContactButtonPressed:(id)sender;

@end
