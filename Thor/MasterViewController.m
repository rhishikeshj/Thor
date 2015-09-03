//
//  MasterViewController.m
//  Thor
//
//  Created by Rhishikesh Joshi on 01/09/15.
//  Copyright (c) 2015 Helpshift Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "HsKeyValueStorage.h"
#import "HsKeyValueBundleStorage.h"
#import "HsTransport.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) id<HsKeyValueStorage> keyValueStorage;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    dispatch_queue_t workerQ = dispatch_queue_create("com.helpshift.thor.storage", DISPATCH_QUEUE_SERIAL);
    self.keyValueStorage = [[HsKeyValueBundleStorage alloc] initWithWorkerQueue:workerQ];
    [self.keyValueStorage initStorage];

    self.objects = [self.keyValueStorage objectForKey:@"thor.objects"];
    NSLog(@"Thor objects are : %@", self.objects);

    [self sendAppLaunch];
}

- (void) sendAppLaunch {
    HsTransport *transport = [[HsTransport alloc] init];
    NSDictionary *someData = @{@"ts" : [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:someData options:0 error:nil];
    NSLog(@"Sending body as %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/api/lib/events"];
    [transport uploadRequestTo:url
                      withData:jsonData
            andCompletionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"Upload complete !");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    [self.keyValueStorage setObject:self.objects forKey:@"thor.objects"];
    NSLog(@"Objects are : %@", [self.keyValueStorage objectForKey:@"thor.objects"]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [self.keyValueStorage setObject:self.objects forKey:@"thor.objects"];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
