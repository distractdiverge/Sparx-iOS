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
#import "QRImagePickerController.h"
#import "OverlayView.h"
#import "QRDecoder.h"
#import "TwoDDecoderResult.h"

#import "FrontController.h"

static const NSTimeInterval kTakePictureTimeInterval = 5;

@interface FrontController(hidden)
-(void)updateQRCode:(ABRecordRef)person;
@end
@implementation FrontController(hidden)
-(void)updateQRCode:(ABRecordRef)person
{
    NSString* personName = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    UIImage* image = [QREncoder encode:[NSString stringWithFormat:@"%@",personName] size:2 correctionLevel:QRCorrectionLevelHigh];
    
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
    
    [navBar setSelectedItem:generateNavButton];
    [self tabBar:navBar didSelectItem:generateNavButton];
    
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

-(IBAction)handleScanCodeButtonPressed:(id)sender
{
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
    
    if( ![UIImagePickerController isSourceTypeAvailable:type] ) {
        UIAlertView* alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Not a supported device"
                                  message:@"You need a camera to run this app"
                                  delegate:self
                                  cancelButtonTitle:@"Darn"
                                  otherButtonTitles:nil];
        
        [alertView show];
        
    } else {
        _imagePicker = [[QRImagePickerController alloc] init];
        
        _overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
        _imagePicker.showsCameraControls = NO;
        _imagePicker.cameraOverlayView = _overlayView;
        
        [self presentModalViewController:_imagePicker animated:YES];
        
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:_imagePicker action:@selector(takePicture)];
        
        [tapRecognizer setNumberOfTapsRequired:1];
                
        [_overlayView addGestureRecognizer:tapRecognizer];
    }

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
#pragma mark -

#pragma mark UITabBarDelegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item == generateNavButton ) {
        if([[viewport subviews] count] > 0) {
            for(id child in [viewport subviews])
            {
                [child removeFromSuperview];
            }
        }
        
        [viewport addSubview:generateView];
    }
    
    else if(item == scanNavButton) {
        if([[viewport subviews] count] > 0) {
            for(id child in [viewport subviews])
            {
                [child removeFromSuperview];
            }
        }
        
        [viewport addSubview:scanView];
    }
}
#pragma mark -

#pragma mark UIImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

- (UIImage*) scaledImage:(UIImage*)baseImage {
	CGSize targetSize = CGSizeMake(320, 480);	
	CGRect scaledRect = CGRectZero;
    
	CGFloat scaledX = 480 * baseImage.size.width / baseImage.size.height;
    
	scaledRect.origin = CGPointMake(0, 0.0);
	scaledRect.size.width  = scaledX;
	scaledRect.size.height = 480;
    
	UIGraphicsBeginImageContext(targetSize);
	[baseImage drawInRect:scaledRect];
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage*) croppedImage:(UIImage*)baseImage {
	CGSize targetSize = _overlayView.cropRect.size;	
    
	UIGraphicsBeginImageContext(targetSize);
	[baseImage drawAtPoint:CGPointMake(-_overlayView.cropRect.origin.x, -_overlayView.cropRect.origin.y)];
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return result;
}

- (void) imagePickerController:(UIImagePickerController*)picker 
 didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage* scaled = [self scaledImage:image];
    
    if( nil == _decoder ) {
        _decoder = [[QRDecoder alloc] init];
        _decoder.delegate = self;
    }
    [_decoder decodeImage:scaled cropRect:_overlayView.cropRect];
    
    _overlayView.image = [self croppedImage:scaled];
}
#pragma mark -

#pragma mark NSTimer
- (void)takePicture:(NSTimer*)theTimer {
    [_imagePicker takePicture];
}
#pragma mark -

#pragma mark DecoderDelegate
- (void)decoder:(QRDecoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset {
}

- (void)decoder:(QRDecoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
}

- (void)decoder:(QRDecoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)result {

    _overlayView.points = result.points;
    
    ABAddressBookRef addressBook = ABAddressBookCreate();

    NSArray* people = (__bridge NSArray*)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)result.text);
   
    ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:0];
    
    NSString* firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    [scanOutput setText:[NSString stringWithFormat:@"FirstName: %@\nLastName: %@\n",firstName,lastName]];
    
    CFRelease(addressBook);
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)decoder:(QRDecoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
}



@end
