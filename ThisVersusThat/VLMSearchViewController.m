//
//  VLMSearchViewController.m
//  ThisVersusThat
//
//  Created by David Lu on 4/13/13.
//
//

#import "VLMSearchViewController.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "VLMConstants.h"
#import "VLMResultCell.h"
#import "VLMMessageCell.h"


typedef enum {
    kQueryBeingStill,
    kQueryWaiting,
    kQueryFound,
    kQueryTimedOut,
    kQueryDownloadErrror
} VLMQueryResponseState;


@interface VLMSearchViewController ()
@property (nonatomic, strong) UITableView *tv;
@property (nonatomic, strong) UITextField *tf;
@property VLMQueryResponseState responseState;
@property (nonatomic, strong) NSArray *productresults;
@end


@implementation VLMSearchViewController


@synthesize tv;
@synthesize tf;
@synthesize responseState;
@synthesize productresults;
@synthesize mydelegate;


- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = @"Search";
        
        UIView *tfbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [tfbg setUserInteractionEnabled:NO];
        [tfbg setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:tfbg];
        
        UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 320-10, 60)];
        [textfield setBackgroundColor:[UIColor whiteColor]];
        [textfield setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textfield setPlaceholder:@"type a product name"];
        [textfield setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
        [textfield setReturnKeyType: UIReturnKeySearch];
        [textfield setDelegate:self];
        self.tf = textfield;
        [self.tf becomeFirstResponder];
        [self.view addSubview:self.tf];

        CGRect rect = self.view.bounds;
        UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 61, 320, rect.size.height - 61)];
        tableview.backgroundColor = [UIColor clearColor];
        tableview.separatorColor = [UIColor clearColor];
        [self.view addSubview:tableview];
        self.tv = tableview;
        [self.tv setDelegate:self];
        [self.tv setDataSource:self];
        
        [self registerForKeyboardNotifications];

        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 1)];
        [sep setUserInteractionEnabled:NO];
        [sep setBackgroundColor:[UIColor colorWithWhite:0.75f alpha:1.0f]];
        [self.view addSubview:sep];
        
        self.responseState = kQueryBeingStill;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
     UIBarButtonItem *cancelbutton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
     [self.navigationItem setLeftBarButtonItem:cancelbutton];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ( [[textField text] length] - range.length + string.length > 75 ) return NO;
    if([string isEqualToString:@"\n"]) {
        [self querySvpplyFor:[textField text]];
        return NO;
    }
    return YES;
}


#pragma mark - ()

- (void)cancel:(id)sender{
    //[self dismissModalViewControllerAnimated:NO];
    [self.mydelegate searchViewControllerFinished:self];
}

- (void)search{
    
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.tv setFrame:CGRectMake(0, 61, 320, self.view.bounds.size.height - 61 - kbSize.height)];
    [self.tv reloadData];
}


#pragma mark - JSON

- (void)querySvpplyFor:(NSString *)query{
    self.responseState = kQueryWaiting;
    
    NSString *SEARCHTERM = [NSString stringWithFormat:@"%@", query];
    NSLog(@"query svpply for: %@", SEARCHTERM );
    
    SEARCHTERM = [SEARCHTERM stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlString = [NSString stringWithFormat:SERVER_STRING, SEARCHTERM];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             [self receivedData:data];
         } else if ([data length] == 0 && error == nil){
             [self emptyReply];
         } else if (error != nil && error.code == NSURLErrorTimedOut){
             [self timedOut];
         } else if (error != nil){
             [self downloadError:error];
         }
         [self performSelectorOnMainThread:@selector(updatetable) withObject:nil waitUntilDone:NO];
         
     }];
    
    [self.tv reloadData];
}

- (void)receivedData:(NSData *)data {
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Here is what we got %@", jsonString);
    
    NSDictionary *got = [jsonString objectFromJSONString];
    NSDictionary *gotresponse = [got valueForKey:@"response"];
    NSArray *gotproducts = [gotresponse valueForKey:@"products"];
    self.productresults = [gotproducts copy];
    self.responseState = kQueryFound;
}

- (void)updatetable{
    NSLog(@"updatetable");
    [self.tv reloadData];
}

- (void)emptyReply{
    NSLog(@"emptyreply");
    self.responseState = kQueryDownloadErrror;
}

- (void)timedOut{
    NSLog(@"timedout");
    self.responseState = kQueryTimedOut;
}

- (void)downloadError:(NSError *)error{
    NSLog(@"downloaderror");
    self.responseState = kQueryDownloadErrror;
}


#pragma mark - DEMO - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"numrowsinsection");
    if ( self.responseState == kQueryFound){
        int ret = [self.productresults count];
        if ( ret > 25 ) ret = 25;
        return ret;
    } else if ( self.responseState == kQueryBeingStill) {
        return 0;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellforrow");
    static NSString *ResultCellIdentifier = @"ResultCell";
    static NSString *MessageCellIdentifier = @"MessageCell";
    
    if (self.responseState != kQueryFound){
        VLMMessageCell *cell = (VLMMessageCell*)[tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
        if (cell == nil) {
            cell = [[VLMMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier];
        }
        NSString *messaging = @"no results";
        switch (self.responseState) {
            case kQueryWaiting:
                messaging = @"loading...";
                [cell showSpinner];
                break;
            case kQueryTimedOut:
                messaging = @"timed out";
                [cell hideSpinner];
                break;
            case kQueryDownloadErrror:
                messaging = @"download error";
                [cell hideSpinner];
                break;
                
            default:
                break;
        }
        
        [cell setItemText:messaging];
        
        //cell.textLabel.text = messaging;
        return cell;
    }else{
        int ind = indexPath.row;
        VLMResultCell *cell = (VLMResultCell*)[tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
        if (cell == nil) {
            cell = [[VLMResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResultCellIdentifier];
        }
        if (self.productresults == nil){
            NSLog(@"products is nil");
        } else {
            NSDictionary *product = (NSDictionary *) [self.productresults objectAtIndex:ind];
            NSString *image = [product valueForKey:@"image"];
            NSString *pagetitle = [product valueForKey:@"page_title"];
            //NSString *pageurl = [product valueForKey:@"page_url"];
            
            //NSLog(@"%@", pagetitle);
            //cell.textLabel.text = pagetitle;
            [cell setItemPhoto:image];
            [cell setItemText:pagetitle];
        }
        return cell;
        
    }
    //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.f];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ( self.responseState == kQueryFound){
        int count = [self.productresults count];
        if ( count > 0 ){
            NSLog(@"row selected: %d", indexPath.row);
            NSDictionary *product = (NSDictionary *) [self.productresults objectAtIndex:indexPath.row];
            NSString *image = [product valueForKey:@"image"];
            NSString *pagetitle = [product valueForKey:@"page_title"];

            [self.mydelegate didSelectItemWithTitle:pagetitle andImageURL:image];
            [self.mydelegate searchViewControllerFinished:self];
            
            ///
            
            
            
            //VLMResultCell *cell = [self tableView:self cellForRowAtIndexPath:indexPath];
            //NSString *pageurl = [product valueForKey:@"page_url"];
            
            //NSLog(@"%@", pagetitle);
            //[self cancel:nil];
            
        }
    }
    
}


@end
