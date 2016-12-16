//
//  TeslimatViewController.m
//  KargoTakip
//
//  Created by Fatih Türker on 05.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import "TeslimatViewController.h"
#import "DagitimViewController.h"
#import "KargoTakipViewController.h"
@interface TeslimatViewController ()

@end

@implementation TeslimatViewController
@synthesize indirilenPaket;
@synthesize indirilenPaketUyari,locationManager,myTimer;
static int flag;
static int kalanPaket=-1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(NSString*)toplamPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"toplamPaketString"];
    return recoveredString;
}
-(NSString*)kalanPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"kalanPaketString"];
    return recoveredString;
}
-(IBAction) teslimAlindi{
    if([[self kalanPaket] integerValue]==-1){
     
            kalanPaket = [[self toplamPaket] integerValue];
            NSString *kalanPaketStr = [NSString stringWithFormat:@"%i",kalanPaket];
            [[NSUserDefaults standardUserDefaults] setObject:kalanPaketStr forKey:@"kalanPaketString"];
           
    }
    NSCharacterSet *nonNumberSet = [NSCharacterSet symbolCharacterSet];
    NSCharacterSet *nonNumberSet2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *nonNumberSet3 = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *nonNumberSet4 = [NSCharacterSet punctuationCharacterSet];
    NSCharacterSet *nonNumberSet5 = [NSCharacterSet decimalDigitCharacterSet];
    if([indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
    NSString *stopIt=@"6";
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DBLocation) userInfo:nil repeats:YES];
    
    //DataBase Operation
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    NSString *LocID = [[NSString alloc] init];
    NSString *indirilenPak = [NSString stringWithFormat:@"%i",[indirilenPaket.text integerValue]];
    NSString *kalanPak = [NSString stringWithFormat:@"%i",kalanPaket];
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT MAX(loc_id) FROM Location ORDER BY loc_id"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char* mevName3 = (const char *) sqlite3_column_text(statement, 0);
                if(mevName3==nil){
                    LocID = @" ";
                }else {
                    LocID = [NSString stringWithUTF8String: mevName3];
                }
            } 
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Delivery(loc_id, quant_received, kalan_paket, status) VALUES (\"%i\",\"%@\",\"%@\",\"%@\")",[LocID integerValue], indirilenPak, kalanPak,@"1"];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
             NSLog(@"%@",insertSQL);
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB); 
    }
    DagitimViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"dagitim"];
    [self.navigationController pushViewController:detail animated:YES];
    }
}
-(void) DBLocation{
    //DataBase Location (Add Time Interval)
    NSString *OpID=[[NSString alloc] init];;
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    //NSLog(@"OK");
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"SELECT op_id FROM Operation WHERE baslangic_time=\"%@\"",[self baslangicDateString]];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char* mevName = (const char *) sqlite3_column_text(statement, 0);
                if(mevName==nil){
                    OpID = @" ";
                }else {
                    OpID = [NSString stringWithUTF8String: mevName];
                }
                [[NSUserDefaults standardUserDefaults] setObject:OpID forKey:@"OperationIDString"];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *longitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.latitude];
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Location(op_id, long, lat) VALUES (\"%i\",\"%@\",\"%@\")",[OpID integerValue],longitude, latitude];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@",insertSQL);
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    if([[self stopTimer] integerValue]==5){
        [myTimer invalidate];
        myTimer = nil;
    }
    if([[self stopOperation2] integerValue]!=10){
        if([[self stopOperation] integerValue]==10){
            
            [myTimer invalidate];
            myTimer = nil;
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if([[self stopOperation2] integerValue]!=10){
        if([[self stopOperation] integerValue]==10){
            [locationManager stopUpdatingLocation];
        }
    }
}
-(NSString*)stopOperation2
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopOperation2String"];
    return recoveredString;
}
-(NSString*)baslangicDateString
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"bDateString"];
    return recoveredString;
}
-(NSString*)stopTimer
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopTimer"];
    return recoveredString;
}
-(NSString*)stopOperation
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopOperationString"];
    return recoveredString;
}
-(IBAction) teslimEdildi{
    [indirilenPaket resignFirstResponder];
    NSCharacterSet *nonNumberSet = [NSCharacterSet symbolCharacterSet];
    NSCharacterSet *nonNumberSet2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *nonNumberSet3 = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *nonNumberSet4 = [NSCharacterSet punctuationCharacterSet];
    NSCharacterSet *nonNumberSet5 = [NSCharacterSet decimalDigitCharacterSet];
    if([[self kalanPaket] integerValue]==-1){
        if([[self toplamPaket] integerValue] >= [indirilenPaket.text integerValue]){
            if(indirilenPaket>=0){
                if([indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
            kalanPaket = [[self toplamPaket] integerValue] - [indirilenPaket.text integerValue];
            NSString *kalanPaketStr = [NSString stringWithFormat:@"%i",kalanPaket];
            [[NSUserDefaults standardUserDefaults] setObject:kalanPaketStr forKey:@"kalanPaketString"];
            flag = 0;
                }
            }}else{
            indirilenPaketUyari.text = @"İndirilen Paket Adedi Toplam Paket Adedinden Fazla!!";
            flag = 1;
        }
    }else {
        if(kalanPaket >= [indirilenPaket.text integerValue]){
            if(indirilenPaket>=0){ if([indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
            kalanPaket = kalanPaket - [indirilenPaket.text integerValue];
            NSString *kalanPaketStr = [NSString stringWithFormat:@"%i",kalanPaket];
            [[NSUserDefaults standardUserDefaults] setObject:kalanPaketStr forKey:@"kalanPaketString"];
            flag = 0;
            }
            }
        }else{
            indirilenPaketUyari.text = @"İndirilen Paket Adedi Kalan Paket Adedinden Fazla!!";
            flag = 1;
        }
    }

    
    if([indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound &&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet2].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet3].location == NSNotFound && [indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet4].location == NSNotFound&&[indirilenPaket.text rangeOfCharacterFromSet:nonNumberSet5].location != NSNotFound){
        if(flag ==0){
        //DataBase Operation
        NSString *stopIt=@"6";
        [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DBLocation) userInfo:nil repeats:YES];
        const char *dbpath = [databasePath UTF8String];
        sqlite3_stmt    *statement;
        NSString *LocID = [[NSString alloc] init];
        NSString *kalanPak = [NSString stringWithFormat:@"%i",kalanPaket];
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat: @"SELECT MAX(loc_id) FROM Location ORDER BY loc_id"];
            
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    const char* mevName3 = (const char *) sqlite3_column_text(statement, 0);
                    if(mevName3==nil){
                        LocID = @" ";
                    }else {
                        LocID = [NSString stringWithUTF8String: mevName3];
                    }
                } 
                sqlite3_finalize(statement);
            }
            sqlite3_close(contactDB);
        }
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Delivery(loc_id, kalan_paket, quant_received, status) VALUES (\"%i\",\"%@\",\"%@\",\"%@\")",[LocID integerValue], kalanPak, @"0", @"0"];
           // NSLog(@"%@",insertSQL);
            const char *query_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                 NSLog(@"%@",insertSQL);
                
            } else {
                // NSLog(@"Islem Gerceklestirilemiyor");
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(contactDB); 
        }
    DagitimViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"dagitim"];
    [self.navigationController pushViewController:detail animated:YES];
    }else{
    
        NSString *kalanPaketStr = [NSString stringWithFormat:@"Kalan Paket: %i",kalanPaket];
         NSString *toplamPaketStr = [NSString stringWithFormat:@"Toplam Paket: %@",[self toplamPaket]];
        if([[self kalanPaket] integerValue]==-1){
            indirilenPaketUyari.text=toplamPaketStr;
        }else{
            indirilenPaketUyari.text=kalanPaketStr;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen İndirilecek Paket Adedini Doğru Giriniz!!" message:@"İndirilecek Paket Adedi Kalan veya Toplam Paket Adedinden Fazla Olabilir." delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];

    }}else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lütfen İndirilecek Paket Adedini Doğru Giriniz!!" message:@"Toplam Paket Adedini Girerken Sayı Haricinde Karakterler Kullanılmış Olabilir." delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton=YES;
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"kargoTakipVerileri.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS Operation(op_id integer PRIMARY KEY AUTOINCREMENT, baslangic_time text, bitis_time text, toplam_paket text)";
            
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            const char *sql_stmt2 = "CREATE TABLE IF NOT EXISTS Location(loc_id integer PRIMARY KEY AUTOINCREMENT, op_id integer, long text, lat text,FOREIGN KEY(op_id) REFERENCES Operation(op_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt2, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            const char *sql_stmt3 = "CREATE TABLE IF NOT EXISTS Delivery(del_id integer PRIMARY KEY AUTOINCREMENT, loc_id integer, kalan_paket text, quant_received text, status integer, FOREIGN KEY(loc_id) REFERENCES Location(loc_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt3, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            const char *sql_stmt4 = "CREATE TABLE IF NOT EXISTS Break(break_id integer PRIMARY KEY AUTOINCREMENT, op_id integer, baslangic_time text, bitis_time text,long text, lat text, FOREIGN KEY(op_id) REFERENCES Operation(op_id))";
            
            if (sqlite3_exec(contactDB, sql_stmt4, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                //status.text = @"Failed to create table";
            }
            
            sqlite3_close(contactDB);
            
        } else {
            // status.text = @"Failed to open/create database";
        }
        
    }
    if([[self stopTimer] integerValue]!=25){
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.title =@"Teslimat";
    }
    if([[self stopTimer] integerValue]==25){
        NSString *stopIt=@"6";
        [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];
        self.title =@"Dağıtım";
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(DBLocation) userInfo:nil repeats:YES];
        DagitimViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"dagitim"];
        [self.navigationController pushViewController:detail animated:YES];
        
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setIndirilenPaket:nil];
    [self setIndirilenPaketUyari:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
