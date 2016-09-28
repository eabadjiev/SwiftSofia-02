//
//  ResultViewController.m
//  LegacyApp
//
//  Created by Emo Abadjiev on 9/27/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

#import "ResultViewController.h"

@interface ResultViewController ()
@end

@implementation ResultViewController

#pragma mark UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray arrayWithCapacity:50];
}

#pragma mark Table Data Source/Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = (NSDictionary*)[self.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    cell.textLabel.text = item[@"name"];
    cell.detailTextLabel.text = item[@"full_name"];
    UIColor *color = [UIColor yellowColor];
    cell.backgroundColor = color;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}


@end
