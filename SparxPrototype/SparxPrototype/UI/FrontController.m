//
//  FrontController.m
//  SparxPrototype
//
//  Created by Alexander Lapinski on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QREncoder/QREncoder.h>
#import <AddressBookUI/AddressBookUI.h>

#import "FrontController.h"

@interface FrontController(hidden)
-(void)updateQRCode:(ABRecordRef)person;
@end
@implementation FrontController(hidden)
-(void)updateQRCode:(ABRecordRef)person
{
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    UIImage* image = [QREncoder encode: [NSString stringWithFormat:@"%@-%@",firstName,lastName]];
    
    [qrView setImage:image];
    [qrView layer].magnificationFilter = kCAFilterNearest;
}
@end

static int const kPadding = 5;

@implementation FrontController

#pragma mark - 
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark -
#pragma mark UI Action Handlers
-(IBAction)handleSelectContactButtonPressed:(id)sender
{
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    [picker setPeoplePickerDelegate:self];
    
    [self presentModalViewController:picker animated:YES];
}

#pragma mark -
#pragma mark ABPeoplePickerDelegate
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self updateQRCode:person];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}
@end
