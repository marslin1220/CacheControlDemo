//
//  TableViewController.m
//  CacheControlDemo
//
//  Created by Lin Cheng Lung on 14/09/2017.
//  Copyright © 2017 Lin Cheng Lung. All rights reserved.
//

#import <AFNetworking.h>

#import "TableViewController.h"
#import "DetailViewController.h"

@interface TableViewController ()

@property (atomic, strong) NSArray *photos;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Photos";
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestPhotos)
                  forControlEvents:UIControlEventValueChanged];
    
    [self getLatestPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLatestPhotos {
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    [manager GET:@"https://jsonplaceholder.typicode.com/photos" parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"JSON: %@", responseObject);
             NSLog(@"DiskCache: %@ of %@", @([[NSURLCache sharedURLCache] currentDiskUsage]), @([[NSURLCache sharedURLCache] diskCapacity]));
             NSLog(@"MemoryCache: %@ of %@", @([[NSURLCache sharedURLCache] currentMemoryUsage]), @([[NSURLCache sharedURLCache] memoryCapacity]));
             self.photos = responseObject;
             [self.refreshControl endRefreshing];
             [self.tableView reloadData];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"album"];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photoInfo = [self.photos objectAtIndex:indexPath.row];
    NSString *imageThumbnailURLString = [photoInfo objectForKey:@"thumbnailUrl"];
    NSString *imageTitle = [photoInfo objectForKey:@"title"];

    NSURL * imageURL = [NSURL URLWithString:imageThumbnailURLString];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage * image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    cell.textLabel.text = imageTitle;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photoInfo = [self.photos objectAtIndex:indexPath.row];

    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.imageTitle = [photoInfo objectForKey:@"title"];
    detailVC.imageURL = [photoInfo objectForKey:@"url"];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
