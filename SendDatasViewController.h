//
//  SendDatasViewController.h
//  KargoTakip
//
//  Created by Fatih Türker on 02.08.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <MessageUI/MessageUI.h>
#import <CFNetwork/CFNetwork.h>
#import "SKPSMTPMessage.h"
@interface SendDatasViewController : UIViewController<SKPSMTPMessageDelegate>{
    NSString        *databasePath;
    sqlite3 *contactDB;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;

-(IBAction)mandar:(id)sender;
- (void)updateTextView;
@end
