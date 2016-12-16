//
//  DagitimViewController.m
//  KargoTakip
//
//  Created by Fatih Türker on 05.07.2012.
//  Copyright (c) 2012 fatih__turker@hotmail.com. All rights reserved.
//

#import "DagitimViewController.h"
#import "TeslimatViewController.h"
#import "KargoTakipViewController.h"
@interface DagitimViewController ()

@end

@implementation DagitimViewController
@synthesize dagitimaDevamButton;
@synthesize breakImage;
@synthesize dagitimImage;
@synthesize kalanPaketLabel;
@synthesize teslimatUyari;
@synthesize stopOperation;
@synthesize locationManager;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(NSString*)toplamPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"toplamPaketString"];
    return recoveredString;
}
-(NSString*)indirilenPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"indirilenPaketString"];
    return recoveredString;
}
-(NSString*)kalanPaket
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"kalanPaketString"];
    return recoveredString;
}
-(NSString*)OpID
{
    NSString* recoveredString = [[NSUserDefaults standardUserDefaults] objectForKey:@"OperationIDString"];
    return recoveredString;
}
-(IBAction)dagitimaDevam{
    NSString *stopIt=@"25";
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];
    TeslimatViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"teslimatAra"];
    [self.navigationController pushViewController:detail animated:YES];
    breakImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23948_640" ofType:@"png"]];
    dagitimImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23965_640" ofType:@"png"]];
    
    [self.dagitimaDevamButton setTitle: @"Dağıtımda" forState: UIControlStateNormal];
    
    NSDateFormatter *formatter;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
    NSString *molaBitisString;
    molaBitisString = [formatter stringFromDate:[NSDate date]];
    
    //DataBase Operation Update
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"UPDATE Break SET bitis_time=\"%@\" WHERE op_id=\"%i\"",molaBitisString, [[self OpID ] integerValue]];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            // NSLog(@"Islem Tamam");
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB); 
    }
}
-(IBAction)mola{
    breakImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23965_640" ofType:@"png"]];
    dagitimImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23948_640" ofType:@"png"]];
    [self.dagitimaDevamButton setTitle: @"Dağıtıma Devam Et" forState: UIControlStateNormal];
    NSDateFormatter *formatter;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
    NSString *molaBaslangicString;
    molaBaslangicString = [formatter stringFromDate:[NSDate date]];
    
    NSString *stopIt=@"5";
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];
    //DataBase Operation
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Break(baslangic_time, op_id) VALUES (\"%@\",\"%@\")",molaBaslangicString, [self OpID]];
        
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
    
    //break location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    //[locationManager startMonitoringSignificantLocationChanges];
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSString *longitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%1.4f",locationManager.location.coordinate.latitude];
    
    //DataBase Operation Update
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"UPDATE Break SET long=\"%@\" WHERE op_id=\"%i\"",longitude, [[self OpID ] integerValue]];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            // NSLog(@"Islem Tamam");
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB); 
    }
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"UPDATE Break SET lat=\"%@\" WHERE op_id=\"%i\"",latitude, [[self OpID ] integerValue]];
        
        const char *query_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            // NSLog(@"Islem Tamam");
            
        } else {
            // NSLog(@"Islem Gerceklestirilemiyor");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB); 
    }
    
    [locationManager stopUpdatingLocation];
   
}

-(IBAction)teslimataDon{
    NSString *stopIt=@"5";
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopTimer"];
    TeslimatViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"teslimatAra"];
    [self.navigationController pushViewController:detail animated:YES];
  
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        [[NSUserDefaults standardUserDefaults] setObject:kalanPaketLabel.text forKey:@"artikPaket"];
        
        NSDateFormatter *formatter;
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
        NSString *bitisdateString;
        bitisdateString = [formatter stringFromDate:[NSDate date]];
        
        //DataBase Operation Update
        const char *dbpath = [databasePath UTF8String];
        sqlite3_stmt    *statement;
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat: @"UPDATE Operation SET bitis_time=\"%@\" WHERE op_id=\"%i\"",bitisdateString, [[self OpID ] integerValue]];
            
            const char *query_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                // NSLog(@"Islem Tamam");
                
            } else {
                // NSLog(@"Islem Gerceklestirilemiyor");
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(contactDB);
        }
        NSString *stopIt2=@"5";
        [[NSUserDefaults standardUserDefaults] setObject:stopIt2 forKey:@"stopTimer"];
        KargoTakipViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"kargoTakip"];
        detail.redGreenImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23948_640" ofType:@"png"]];
        NSString *startIt=@"10";
        [[NSUserDefaults standardUserDefaults] setObject:startIt forKey:@"gpsStart"];
        NSString *stopIt=@"5";
        [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopOperation2String"];
        stopOperation=@"10";
        [[NSUserDefaults standardUserDefaults] setObject:stopOperation forKey:@"stopOperationString"];
        [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"flagString"];
        [self.navigationController pushViewController:detail animated:YES];
    }

}

-(IBAction)operasyonuBitir{
    if([kalanPaketLabel.text integerValue]>0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Teslim Edilecek Paket Adedi Daha Bitmedi!!" message:@"Operasyonu Bitirme İşlemine Devam Etmek İstiyor Musunuz?" delegate:self cancelButtonTitle:@"Hayır" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Evet"];
        [alert show];
    }else{
    NSDateFormatter *formatter;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"artikPaket"];

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy_HH:mm:ss"];
    NSString *bitisdateString;
    bitisdateString = [formatter stringFromDate:[NSDate date]];
        
        //DataBase Operation Update
        const char *dbpath = [databasePath UTF8String];
        sqlite3_stmt    *statement;
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat: @"UPDATE Operation SET bitis_time=\"%@\" WHERE op_id=\"%i\"",bitisdateString, [[self OpID ] integerValue]];
            
            const char *query_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                // NSLog(@"Islem Tamam");
                
            } else {
                // NSLog(@"Islem Gerceklestirilemiyor");
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(contactDB); 
        }
        NSString *stopIt2=@"5";
        [[NSUserDefaults standardUserDefaults] setObject:stopIt2 forKey:@"stopTimer"];
    KargoTakipViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"kargoTakip"];
    detail.redGreenImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"park-23948_640" ofType:@"png"]];
        NSString *startIt=@"10";
        [[NSUserDefaults standardUserDefaults] setObject:startIt forKey:@"gpsStart"];
    NSString *stopIt=@"5";
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"stopOperation2String"];
    stopOperation=@"10";
    [[NSUserDefaults standardUserDefaults] setObject:stopOperation forKey:@"stopOperationString"];
    [[NSUserDefaults standardUserDefaults] setObject:stopIt forKey:@"flagString"];
    [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)viewDidLoad
{
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

    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.title =@"Dağıtım"; 
    self.navigationItem.hidesBackButton = YES;
    kalanPaketLabel.text = [self kalanPaket];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setKalanPaketLabel:nil];
    [self setTeslimatUyari:nil];
    [self setDagitimImage:nil];
    [self setBreakImage:nil];
    [self setDagitimaDevamButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
