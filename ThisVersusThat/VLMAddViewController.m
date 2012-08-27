//
//  VLMAddViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "VLMAddViewController.h"
#import "VLMConstants.h"
#import "UIBarButtonItem+Fat.h"
#import "UIPlaceholderTextView.h"
#import "AppDelegate.h"
#import "Parse/Parse.h"
//#import "Parse/PFFile.h"
//#import "Parse/PFObject.h"
#import "UIImage+ResizeAdditions.h"

@interface VLMAddViewController ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UITextView *questionfield;
@property (strong, nonatomic) UIImageView *leftimage;
@property (strong, nonatomic) UIImageView *rightimage;
@property (strong, nonatomic) UITextField *leftcaption;
@property (strong, nonatomic) UITextField *rightcaption;
@property (strong, nonatomic) UILabel *charsremaining;
@property (nonatomic) BOOL questionOK;
@property (nonatomic) BOOL leftimageexists;
@property (nonatomic) BOOL rightimageexists;
@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat originalOffsetX;
@property (nonatomic) CGRect originalRect;


// anypic's code specifies 'assign' which ARC conversion rewrites as unsafe_unretained
// however unsafe_unretained will release references to these PFFiles before we're done uploading them
// so: i'm instead marking them as merely nonatomic and letting xcode decide what's best
@property (nonatomic) PFFile *photoFileLeft;
@property (nonatomic) PFFile *thumbnailFileLeft;
@property (nonatomic) PFFile *photoFileRight;
@property (nonatomic) PFFile *thumbnailFileRight;

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier fileUploadBackgroundTaskIdL;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier pollPostBackgroundTaskId;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier fileUploadBackgroundTaskIdR;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier photoPostBackgroundTaskIdR;

@end

@implementation VLMAddViewController

@synthesize containerView;
@synthesize originalOffsetX;
@synthesize originalRect;
@synthesize velocity;
@synthesize leftimage;
@synthesize rightimage;
@synthesize leftcaption;
@synthesize rightcaption;
@synthesize charsremaining;
@synthesize leftimageexists;
@synthesize rightimageexists;
@synthesize questionOK;
@synthesize questionfield;
@synthesize photoFileLeft;
@synthesize thumbnailFileLeft;
@synthesize photoFileRight;
@synthesize thumbnailFileRight;
@synthesize fileUploadBackgroundTaskIdL;
@synthesize pollPostBackgroundTaskId;
@synthesize fileUploadBackgroundTaskIdR;
@synthesize photoPostBackgroundTaskIdR;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leftimageexists = NO;
    self.rightimageexists = NO;
    self.questionOK = NO;
    
    self.fileUploadBackgroundTaskIdL = UIBackgroundTaskInvalid;
    self.fileUploadBackgroundTaskIdR = UIBackgroundTaskInvalid;
    self.pollPostBackgroundTaskId = UIBackgroundTaskInvalid;
    
    [self setuptoolbar];
    [self setuptaprecognizer];
    [self setupquestion];
    [self setupimages];
    
}

#pragma mark - UI Setup

- (void)setuptoolbar {
    [self setTitle:@"Add"];
	
    [self.view setBackgroundColor:FEED_TABLEVIEW_BGCOLOR];
    UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelbutton];
    
    UIBarButtonItem *donebutton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    [donebutton setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:donebutton];

    CGRect f = CGRectMake(0, 0, 150, HEADER_HEIGHT);
    UIView *titleView = [[UIView alloc] initWithFrame:f];
    UIButton *fb = [[UIButton alloc] initWithFrame:f];    

    [fb.titleLabel setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:15.0f]];
    [fb setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
    [fb setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [fb setShowsTouchWhenHighlighted:NO];
    [fb setTitle:self.title forState:UIControlStateNormal];
    [titleView addSubview:fb];
    [fb addTarget:self action:@selector(handleGenericTap:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect ff = fb.titleLabel.frame;
    ff.origin.y += HEADER_TITLE_VERTICAL_OFFSET;
    [fb.titleLabel setFrame:ff];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT*0.5, 150, HEADER_HEIGHT/2)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [label setFont:[UIFont fontWithName:HEADER_TITLE_FONT size:10.0f]];
    [label setNumberOfLines:0];
    [label setText:@""];
    [label setTextAlignment:UITextAlignmentCenter];
    
    [titleView addSubview:label];
    [self.navigationItem setTitleView:titleView];
    self.charsremaining = label;
}

- (void)setuptaprecognizer {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGenericTap:)];
    [tgr setDelegate:self];
    [self.view addGestureRecognizer:tgr];

    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [pgr setDelegate:self];
    [self.view addGestureRecognizer:pgr];
}

- (void)setupquestion{
    UIView *questionholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 14*6)];
    UIPlaceHolderTextView *question = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10, 14*6-10)];
    [question setKeyboardType:UIKeyboardTypeAlphabet];
    [question setBackgroundColor:[UIColor whiteColor]];
    [question setPlaceholder:@"Which couch should I buy?"];
    [question setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [question setReturnKeyType: UIReturnKeyDone];
    [question setDelegate:self];
    [questionholder addSubview:question];
    [questionholder setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:questionholder];
    self.questionfield = question;
}

- (void)setupimages{
    self.originalOffsetX = 0.0f;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 6*14, 640.0f, 294.0f)];
    self.velocity = 0;
    
    // left tile
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(15, 14-5, 286, 286)];
    left.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [self.containerView addSubview:left];
    
    // left image (placeholder)
    self.leftimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_placeholder.png"]];
    [leftimage setFrame:CGRectMake(5, 5, 276, 276)];
    [left addSubview:leftimage];
    
    // transparent black layer
    UIView *leftShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
    [leftShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [left addSubview:leftShade];
    
    // left caption
    UITextField *captionLeft = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 276, 14*4)];
    [captionLeft setKeyboardType:UIKeyboardTypeAlphabet];
    [captionLeft setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [captionLeft setTextAlignment:UITextAlignmentCenter];
    [captionLeft setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [captionLeft setPlaceholder:@"Untitled"];
    [captionLeft setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [captionLeft setReturnKeyType: UIReturnKeyDone];
    [captionLeft setDelegate:self];
    self.leftcaption = captionLeft;
    [left addSubview:captionLeft];

    // left camera button
    UIButton *leftcam = [[UIButton alloc] initWithFrame:CGRectMake(15, 276-55-5, 55, 55)];;
    [leftcam setShowsTouchWhenHighlighted:YES];
    [leftcam setImage:[UIImage imageNamed:@"leica.png"] forState:UIControlStateNormal];
    [leftcam addTarget:self action:@selector(handleCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    [left addSubview:leftcam];

    // right tile
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(15 + 286+5, 14-5, 286, 286)];
    right.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    [self.containerView addSubview:right];
    
    // right image
    self.rightimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_placeholder.png"]];
    [rightimage setFrame:CGRectMake(5, 5, 276, 276)];
    [right addSubview:rightimage];
    
    // transparent black layer
    UIView *rightShade = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 276, 276)];
    [rightShade setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [right addSubview:rightShade];

    // right caption
    UITextField *captionRight = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 276, 14*4)];
    [captionRight setKeyboardType:UIKeyboardTypeAlphabet];
    [captionRight setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [captionRight setTextAlignment:UITextAlignmentCenter];
    [captionRight setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [captionRight setPlaceholder:@"Untitled"];
    [captionRight setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [captionRight setReturnKeyType: UIReturnKeyDone];
    [captionRight setDelegate:self];
    self.rightcaption = captionRight;
    [right addSubview:captionRight];
    
    // right camera button
    UIButton *rightcam = [[UIButton alloc] initWithFrame:CGRectMake(15, 276-55-5, 55, 55)];;
    [rightcam setShowsTouchWhenHighlighted:YES];
    [rightcam setImage:[UIImage imageNamed:@"leica.png"] forState:UIControlStateNormal];
    [rightcam addTarget:self action:@selector(handleCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    [right addSubview:rightcam];
    
    // add to view
    [self.view addSubview:self.containerView];
    self.originalRect = self.containerView.frame;
}

#pragma mark - TextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    int newlen = [[textView text] length] - range.length + text.length;
    if ( newlen > 140 ) {
        [charsremaining setText:@"0 characters remaining"];
        return NO;
    }
    if([text isEqualToString:@"\n"]) {
        [charsremaining setText:@""];
        [self.view endEditing:YES];
        return NO;
    }
    if ( newlen == 0 ){
         self.questionOK = NO;
    } else{
         self.questionOK = YES;
    }
    NSString *s = [NSString stringWithFormat:@"%d characters remaining", (int)(140-newlen)];
    [charsremaining setText:s];
    [self shouldEnableDone];
    return YES;
}

#pragma mark - TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ( [[textField text] length] - range.length + string.length > 75 ) return NO;
    if([string isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

#pragma mark - GestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ){
        if ( [touch.view isKindOfClass:[UITextField class]] ) {
            NSLog(@"textfield!");
            [charsremaining setText:@""];
            return NO;
        }
        if ( [touch.view isKindOfClass:[UITextView class]] ) {
            NSLog(@"textview");
            UITextView *tv = (UITextView *)touch.view;
            int len = tv.text.length;
            NSLog(@"%d", len);
            [charsremaining setText:[NSString stringWithFormat:@"%d characters remaining", 140-len]];
            return NO;
        }
    }
    if ( [touch.view isKindOfClass:[UIButton class]] ) {
        NSLog(@"button!");
        return NO;
    } 
    return YES; 
}

- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

#pragma mark - Camera & ImagePicker

// copied from AnyPic
- (BOOL)shouldStartCameraController {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    cameraUI.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    cameraUI.navigationItem.hidesBackButton = YES;

    [self presentModalViewController:cameraUI animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    return YES;
}

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    return presentedPhotoCaptureController;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO 
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;

    [cameraUI.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];

    [cameraUI setDelegate:self];
    if ( cameraUI )
        [self presentViewController:cameraUI animated:NO completion:nil];
    /*
    [self presentViewController:cameraUI animated:NO completion:^(void){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }];
     */
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:NO];
    
    NSLog(@"picker did finish");
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];

    if ( self.originalOffsetX == 0 ) {
        self.leftimageexists = YES;
        [self.leftimage setImage:image];
        [self shouldUploadImage:image isLeft:YES];
    } else {
        self.rightimageexists = YES;
        [self.rightimage setImage:image];
        [self shouldUploadImage:image isLeft:NO];
    }
    [self shouldEnableDone];
}

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController 
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] && 
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }   
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}

#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage isLeft:(BOOL)left{    

    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:0.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    if ( left ){
        self.photoFileLeft = [PFFile fileWithData:imageData];
        self.thumbnailFileLeft = [PFFile fileWithData:thumbnailImageData];
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.fileUploadBackgroundTaskIdL = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdL];
        }];
            
        NSLog(@"Requested background expiration task with id %d for Anypic photo upload", self.fileUploadBackgroundTaskIdL);
        [self.photoFileLeft saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                NSLog(@"Photo uploaded successfully");
                
                [self.thumbnailFileLeft saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"here");
                    if (succeeded) {
                        NSLog(@"Thumbnail uploaded successfully");
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdL];
                }];
                

            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdL];
            }
        }];
    }
    else {
        self.photoFileRight = [PFFile fileWithData:imageData];
        self.thumbnailFileRight = [PFFile fileWithData:thumbnailImageData];
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.fileUploadBackgroundTaskIdR = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdR];
        }];
        
        NSLog(@"Requested background expiration task with id %d for Anypic photo upload", self.fileUploadBackgroundTaskIdR);
        [self.photoFileRight saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                NSLog(@"Photo uploaded successfully");
                
                [self.thumbnailFileRight saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"here");
                    if (succeeded) {
                        NSLog(@"Thumbnail uploaded successfully");
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdR];
                }];
                
                
            } else {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskIdR];
            }
        }];

    }
    return YES;
}

#pragma mark - cancel and done

- (void)cancel:(id)sender{

    [self dismissModalViewControllerAnimated:YES];

}

- (void)done:(id)sender{

    // trap for empty photos (left and right thumbnails and photos)
    // should never happen (since done button is disabled until these exist)
    if (!self.photoFileLeft || !self.photoFileRight || !self.thumbnailFileLeft || !self.thumbnailFileRight) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your poll" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // string cleaning
    NSString *trimmedQuestion = [self.questionfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedCaptionLeft = [self.leftcaption.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedCaptionRight = [self.rightcaption.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!trimmedQuestion) trimmedQuestion = @"";
    if (!trimmedCaptionLeft) trimmedCaptionLeft = @"";
    if (!trimmedCaptionRight) trimmedCaptionRight = @"";
    
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];

    PFObject *aPhotoLeft = [PFObject objectWithClassName:@"Photo"];
    [aPhotoLeft setObject:self.thumbnailFileLeft forKey:@"Thumbnail"];
    [aPhotoLeft setObject:self.photoFileLeft forKey:@"Original"];
    [aPhotoLeft setObject:trimmedCaptionLeft forKey:@"Caption"];
    aPhotoLeft.ACL = photoACL;
    
    PFObject *aPhotoRight = [PFObject objectWithClassName:@"Photo"];
    [aPhotoRight setObject:self.thumbnailFileRight forKey:@"Thumbnail"];
    [aPhotoRight setObject:self.photoFileRight forKey:@"Original"];
    [aPhotoRight setObject:trimmedCaptionRight forKey:@"Caption"];
    aPhotoRight.ACL = photoACL;
    
    // create a photo object
    PFObject *poll = [PFObject objectWithClassName:POLL_CLASS_KEY];
    [poll setObject:[PFUser currentUser] forKey:POLL_USER_KEY];
    [poll setObject:trimmedQuestion forKey:POLL_QUESTION_KEY];
    [poll setObject:aPhotoLeft forKey:@"PhotoLeft"];
    [poll setObject:aPhotoRight forKey:@"PhotoRight"];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *pollACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [pollACL setPublicReadAccess:YES];
    poll.ACL = pollACL;

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.pollPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.pollPostBackgroundTaskId];
    }];

    AppDelegate *ad =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showHUDPosting];
    
    [poll saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            
            NSLog(@"Poll uploaded");
            [ad hideHUDPosting];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cc.vellum.thisversusthat.notification.userdidpublishpoll" object:nil];
            
        } else {
            NSLog(@"Poll failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your poll" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            [ad hideHUDPosting];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.pollPostBackgroundTaskId];
    }];
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - event handlers

- (void)handleGenericTap:(id)sender{
    [self.view endEditing:YES];
    [charsremaining setText:@""];

}

- (void) handleCameraButton:(id)sender{
        
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose photo", nil];
        [actionSheet showInView:self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

-(void) handlePan:(id)sender{
    
    // cast sender to uipangesturerecognizer
    UIPanGestureRecognizer *pgr = ( UIPanGestureRecognizer *)sender;

    BOOL registerDeltas = NO;
    
    // look at the pan gesture's internal state
    switch (pgr.state) {
            
        case UIGestureRecognizerStateBegan:
            [pgr setTranslation:CGPointZero inView:self.view];
            //[self killAnimations];
            registerDeltas = YES;
            break;
            
        case UIGestureRecognizerStateEnded:
            [self resetAnimated:YES];
            break;
            
        case UIGestureRecognizerStateChanged:
            registerDeltas = YES;
            break;
            
        case UIGestureRecognizerStateCancelled:
        default:
            break;
    }

    if ( registerDeltas ){
        CGPoint delta = [pgr translationInView:self.view];
        [pgr setTranslation:CGPointZero inView:self.view];
        
        CGPoint vel = [pgr velocityInView:self.view];
        [self translateByX:delta.x withVelocity:vel.x];
        //NSLog( @"dx:%f", delta.x );

    }
}

-(void) translateByX: (CGFloat) offsetval withVelocity:(CGFloat)velocityval{
    CGFloat val = offsetval;
    self.velocity = velocityval;
    if (( self.containerView.frame.origin.x >= 0 && val > 0 ) ||
        ( self.containerView.frame.origin.x < -290 && val < 0 ))
    {
        val /= 4.0;
    }
    
    [UIView animateWithDuration:0
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.containerView.frame, val, 0);
                     }
                     completion:nil
     ];
    
    NSLog(@"%f", val);
}

-(void) resetAnimated:(BOOL)anim{
    CGFloat val = self.containerView.frame.origin.x;
    CGFloat delta = self.containerView.frame.origin.x - self.originalOffsetX;
    CGFloat duration = 0.5;
    UIViewAnimationCurve curve = UIViewAnimationOptionCurveEaseOut;
    if ( val >= 0 ) {
        
        self.originalOffsetX = 0;
        
    } else if ( val <= -290 ) {
        
        self.originalOffsetX = -290;
        
    } else if (fabsf(self.velocity) > 10 ){
        duration = 290/fabsf(self.velocity);
        if ( duration < 0.3 ) duration = 0.3;
        if ( duration > 1 ) duration = 1;
        if ( self.velocity < 0 ){
            self.originalOffsetX = -290;
        }else {
            self.originalOffsetX = 0;            
        }
    } else {
        if  (fabsf(delta) < 290/2) {
            // do nothing, return to last known page
        } else {
            if ( delta < 0 ) {
                self.originalOffsetX = -290;
            }
            else if ( delta > 0 ) {
                self.originalOffsetX = 0;
            }
        }
    }
    [UIView animateWithDuration:duration
                          delay:0 
                        options:curve|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.containerView.frame = CGRectOffset(self.originalRect, self.originalOffsetX, 0.0f);
                     }
                     completion:nil
     ];
}

-(void)killAnimations{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    
    // kill animations
    [UIView setAnimationsEnabled:NO];
    [self.containerView.layer removeAllAnimations];
    
    // restore the previous animation state
    [UIView setAnimationsEnabled:animationsEnabled];
    
}

#pragma mark - Check if done

- (BOOL)shouldEnableDoneButton {
    if ( self.questionOK && self.leftimageexists && self.rightimageexists ) return YES;
    return NO;
}

- (void)shouldEnableDone{
    if ( [self shouldEnableDoneButton] ){
        if (!self.navigationItem.rightBarButtonItem.enabled)
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        if (self.navigationItem.rightBarButtonItem.enabled)
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

#pragma mark -
#pragma mark Boilerplate

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
