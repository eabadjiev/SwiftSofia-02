//
//  RepoViewController.m
//  LegacyApp
//
//  Created by Emo Abadjiev on 9/27/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

#import "RepoViewController.h"
#import "ResultViewController.h"

@interface RepoViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ResultViewController *resultViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation RepoViewController

#pragma mark View Controller
-(void) viewDidLoad {
    [super viewDidLoad];

    _resultViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                             instantiateViewControllerWithIdentifier:@"ResultViewController"];
    _resultViewController.tableView.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultViewController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.title = [NSString stringWithFormat:@"My Repos (%lu)", (unsigned long)self.items.count];
    self.editButton.enabled = self.items.count != 0;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark Table Data Source/Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = (NSDictionary*)[self.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    cell.textLabel.text = item[@"name"];
    cell.detailTextLabel.text = item[@"full_name"];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        // search table selection
        NSDictionary *item = self.resultViewController.items[indexPath.row];
        [self.items addObject:item];
        [self.tableView reloadData];
        self.title = [NSString stringWithFormat:@"My Repos (%lu)", (unsigned long)self.items.count];
        self.editButton.enabled = self.items.count != 0;
        
        [self.searchController dismissViewControllerAnimated:true completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.items removeObjectAtIndex:indexPath.row];
    self.title = [NSString stringWithFormat:@"My Repos (%lu)", (unsigned long)self.items.count];
    self.editButton.enabled = self.items.count != 0;
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    __weak ResultViewController *controller = (ResultViewController *)self.searchController.searchResultsController;
    [self executeSearchQuery:searchText handler:^(NSDictionary *json, NSError * error) {
        [controller.items removeAllObjects];
        [controller.items addObjectsFromArray:json[@"items"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [controller.tableView reloadData];
        });
    }];
}

#pragma mark Stuff

- (IBAction)didTapEdit:(UIBarButtonItem *)sender {
    NSString *newTitle = self.tableView.isEditing ? @"Edit" : @"Done";
    sender.title = newTitle;
    [self.tableView setEditing:!self.tableView.isEditing animated:true];
}

- (void)executeSearchQuery:(NSString*) query handler:(void (^)(NSDictionary *json, NSError * error)) handler {
    //    NSString *encodedQuery = [query stringByAddingPercentEncodingForFormData:NO];
    NSString *encodedQuery = query;
    NSString *requestToAPI = [NSString stringWithFormat:@"https://api.github.com/search/repositories?order=&q=%@", encodedQuery];
    NSURL *url = [NSURL URLWithString:requestToAPI];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"GET";
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSession* session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Got response %@ with error %@.\n", response, error);
        if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:0
                                  error:&jsonError];
            
            handler(json, nil);
        } else {
            handler(nil, error);
        }
    }] resume];
}

- (void)executeStatsQuery:(NSString*) fullName handler:(void (^)(NSDictionary *json, NSError * error)) handler {
    NSString *requestToAPI = [NSString stringWithFormat:@"https://api.github.com/repos/%@/stats/participation", fullName];
    NSURL *url = [NSURL URLWithString:requestToAPI];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"GET";
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSession* session = [NSURLSession sharedSession];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Got response %@ with error %@.\n", response, error);
        if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:0
                                  error:&jsonError];
            
            handler(json, nil);
        } else {
            handler(nil, error);
        }
    }] resume];
}

-(NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray arrayWithCapacity:50];
    }
    
    return _items;
}

@end
