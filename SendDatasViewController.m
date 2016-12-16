//
//  SendDatasViewController.m
//  KargoTakip
//
//  Created by Fatih Türker on 02.08.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import "SendDatasViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "UIDevice+IdentifierAddition.h"
#import "UIDevice+serialNumber.h"
@interface SendDatasViewController ()

@end

@implementation SendDatasViewController
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateTextView];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)updateTextView {
    NSMutableString *logText = [[NSMutableString alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [logText appendString:@"Use the iOS Settings app to change the values below.\n\n"];
    [logText appendFormat:@"From: %@\n", [defaults objectForKey:@"fromEmail"]];
    [logText appendFormat:@"To: %@\n", [defaults objectForKey:@"toEmail"]];
    [logText appendFormat:@"Host: %@\n", [defaults objectForKey:@"relayHost"]];
    [logText appendFormat:@"Auth: %@\n", ([[defaults objectForKey:@"requiresAuth"] boolValue] ? @"On" : @"Off")];
    
    if ([[defaults objectForKey:@"requiresAuth"] boolValue]) {
        [logText appendFormat:@"Login: %@\n", [defaults objectForKey:@"login"]];
        [logText appendFormat:@"Password: %@\n", @"**************"];
    }
    [logText appendFormat:@"Secure: %@\n", [[defaults objectForKey:@"wantsSecure"] boolValue] ? @"Yes" : @"No"];
    self.textView.text = logText;
    
}
+ (void)initialize {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"kargotakipios@gmail.com", @"fromEmail",
                                               @"kargotakipios@gmail.com", @"toEmail",
                                               @"smtp.gmail.com", @"relayHost",
                                               @"kargotakipios@gmail.com", @"login",
                                               @"kargo123*", @"pass",
                                               [NSNumber numberWithBool:YES], @"requiresAuth",
                                               [NSNumber numberWithBool:YES], @"wantsSecure", nil];
    
    [userDefaults registerDefaults:defaultsDictionary];
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    self.textView.text  = @"Message was sent!";
    //NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    
    //self.textView.text = [NSString stringWithFormat:@"Darn! Error: %@, %@", [error code], [error localizedDescription]];
    self.textView.text = [NSString stringWithFormat:@"Error!\n%i: %@\n%@", [error code], [error localizedDescription], [error localizedRecoverySuggestion]];
    
    //NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}
-(IBAction)mandar:(id)sender {
    // Override point for customization after app launch    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = [defaults objectForKey:@"fromEmail"];
    
    testMsg.toEmail = [defaults objectForKey:@"toEmail"];
    testMsg.bccEmail = [defaults objectForKey:@"bccEmal"];
    testMsg.relayHost = [defaults objectForKey:@"relayHost"];
    
    testMsg.requiresAuth = [[defaults objectForKey:@"requiresAuth"] boolValue];
    
    if (testMsg.requiresAuth) {
        testMsg.login = [defaults objectForKey:@"login"];
        
        testMsg.pass = [defaults objectForKey:@"pass"];
        
    }
    
    testMsg.wantsSecure = [[defaults objectForKey:@"wantsSecure"] boolValue]; // smtp.gmail.com doesn't work without TLS!
    NSString *myIdentifier = [NSString stringWithFormat:@"%@",
                              [[UIDevice currentDevice] serialNumber]];

    
    testMsg.subject = myIdentifier;

    testMsg.delegate = self;
    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               @"Gelen Baslik Telefonun Seri Numarasi. Sana gelecek Databaselerin hepsinin adi kargoTakipVerileri. Sen de o seri numaranin isminde bir dosya olusturup buradaki db yi onun icine atarsan bir sikinti yasanmaz.",kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    NSString *documentsYolu = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* plistYolu = [documentsYolu stringByAppendingPathComponent:@"kargoTakipVerileri.sqlite"];
    NSLog(@"%@",plistYolu);
    //NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"vcf"];
    NSData *vcfData = [NSData dataWithContentsOfFile:plistYolu];
    
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"kargoTakipVerileri.sqlite\"",kSKPSMTPPartContentTypeKey,
                             @"attachment;\r\n\tfilename=\"kargoTakipVerileri.sqlite\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
    
    [testMsg send];

}
- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
