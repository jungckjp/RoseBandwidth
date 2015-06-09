//
//  DevicesTableViewController.m
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DeviceTableViewCell.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DataDevice.h"
#import "DataOverview.h"
#import "RoseBandwidth-Swift.h"

@interface DevicesTableViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchData];
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [self fetchData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData{
    
    self.devicesIdentifier = @"DataDevice";
    DevicesTableViewController *appDelegate = (DevicesTableViewController *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    NSEntityDescription * entityDescription = [NSEntityDescription entityForName:self.devicesIdentifier inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError * error;
    self.devices = [self.managedObjectContext executeFetchRequest:request error:&error];
    self.devices = [self.devices sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            DataDevice* device1 = (DataDevice *)obj1;
            DataDevice* device2 = (DataDevice *)obj2;
        
        NSString *d1rNoComma = [device1.recievedData
                                     stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *d1sNoComma = [device1.sentData
                                 stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        NSString *d1Received = [d1rNoComma substringToIndex: [d1rNoComma length] - 3];
        NSString *d1Sent = [d1sNoComma substringToIndex: [d1sNoComma length] - 3];
        
        NSString *d2rNoComma = [device2.recievedData
                                stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *d2sNoComma = [device2.sentData
                                stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        NSString *d2Received = [d2rNoComma substringToIndex: [d2rNoComma length] - 3];
        NSString *d2Sent = [d2sNoComma substringToIndex: [d2sNoComma length] - 3];
        
        float d1Total = d1Received.floatValue + d1Sent.floatValue;
        float d2Total = d2Received.floatValue + d2Sent.floatValue;
        
        if (d1Total > d2Total) {
            return NSOrderedAscending;
        } else if (d1Total < d2Total) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    if (error != nil) {
        // ERROR
    }
    
    self.dataIdentifier = @"DataOverview";

    NSEntityDescription * entityDescription2 = [NSEntityDescription entityForName:self.dataIdentifier inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest * request2 = [[NSFetchRequest alloc] init];
    [request2 setEntity:entityDescription2];
    
    NSError * error2;
    self.dataOverview = [self.managedObjectContext executeFetchRequest:request2 error:&error2];
    
    if (error2 != nil) {
        // ERROR
    }

    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.devices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    DeviceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"deviceTableCell"];
    DataDevice *curr = ((DataDevice *)self.devices[indexPath.row]);
    DataOverview * overview = ((DataOverview *)self.dataOverview[0]);
    if ([curr.hostName isEqualToString:@"Created by Captive Portal service"]){
        cell.deviceLabel.text = @"Unnamed Device";
    } else {
        cell.deviceLabel.text = curr.hostName;
    }
    cell.addressLabel.text = curr.addressIP;
    
    NSString *receivedNoComma = [curr.recievedData
                                 stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *sentNoComma = [curr.sentData
                                 stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *receivedTotalNoComma = [overview.recievedData
                                 stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *sentTotalNoComma = [overview.sentData
                             stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSString * thisReceived = [receivedNoComma substringToIndex: [receivedNoComma length] - 3];
    NSString * thisSent = [sentNoComma substringToIndex: [sentNoComma length] - 3];
    NSString * thatReceived = [receivedTotalNoComma substringToIndex: [receivedTotalNoComma length] - 3];
    NSString * thatSent = [sentTotalNoComma substringToIndex: [sentTotalNoComma length] - 3];
    
    float used = ((thisReceived.floatValue + thisSent.floatValue) / (thatReceived.floatValue + thatSent.floatValue))*100;
    
    NSString * usedText = [NSString stringWithFormat:@"%.1f%%", used];
    
    cell.usageLabel.text = usedText;
    
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
