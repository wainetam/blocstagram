//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Waine Tam on 2/15/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "MediaFullScreenAnimator.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"
#import "PostToInstagramViewController.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, CameraViewControllerDelegate, UIScrollViewDelegate, ImageLibraryViewControllerDelegate>

//@property (nonatomic, weak) UIImageView *lastTappedImageView;
//@property (nonatomic, weak) UIImageView *lastLongPressedImageView;
@property (nonatomic, assign) CGFloat decelerationRate;
@property (nonatomic, assign) BOOL didBeginDeceleration;
@property (nonatomic, assign) BOOL didBeginDragging;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustment;

//@property (nonatomic, strong) UIPopoverController *cameraPopover;

@end

@implementation ImagesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // custom initialization
//        self.images = [NSMutableArray array];
        self.decelerationRate = 10;
//        self.lastPortraitHeightToScroll = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil]; // VC will observe single key
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    // check to see if any photo capabilities are available; if so, add a camera button
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    // calls keyboardWillShow and keyboardWillHide before keyboard shows/hides
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidFinish:) name:ImageFinishedNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// QUESTION: built-in logic for handling keyboard appearance does not work on large cells like ours (per breakpoint text), so will override by not calling super
-(void)viewWillAppear:(BOOL)animated {
    
//    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
}

- (void)refreshControlDidFire: (UIRefreshControl *) sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void)infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row >= [DataSource sharedInstance].mediaItems.count - 5) {
        // the very last cell is on the screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

- (void)dealloc { // removes observer upon dealloc
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        
        if (self.tableView.decelerationRate != 0) { 
//            NSLog(@"tableview deceleration rate %f", self.tableView.decelerationRate);
            [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [self items][indexPath.row];
    
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return [UIScreen mainScreen].bounds.size.width + 150;
//    if (item.image) {
//        return 350;
//    } else {
//        return 150;
//    }
}

//- (NSArray *)items {
- (NSMutableArray *)items {
    return [DataSource sharedInstance].mediaItems;
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self infiniteScrollIfNecessary];
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"ended dragging");
    self.didBeginDragging = NO;
    [self infiniteScrollIfNecessary];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.didBeginDeceleration = YES;
//    NSLog(@"slowing down");
    
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.didBeginDeceleration = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"did scroll");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"beginning drag");
    self.didBeginDragging = YES;
    self.didBeginDeceleration = NO;
}

#pragma mark - Handling key-value notifications
// all KVO notifications are sent to this method -- here, just have one key to observe (mediaItems)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // we know mediaItems has changed. Let's see what kind of change it is
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
             if (kindOfChange == NSKeyValueChangeSetting) {
                 // someone set a brand new images array
                 [self.tableView reloadData];
             } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
                 // we have an incremental chnage: insertion, deletion, or replaced images
                 
                 // get a list of the index (or indices) that changed
                 NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
                 
                 // convert this NSIndexSet to an NSArray of NSIndexPath (which is what the table view animation methods require)
                 NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
                 [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                     NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                     [indexPathsThatChanged addObject:newIndexPath];
                 }];
                 
                 // call beginUpdates to tell the tableView that we're about to make changes
                 [self.tableView beginUpdates];
                 
                 // tell the tableView what the changes are
                 if (kindOfChange == NSKeyValueChangeInsertion) {
                     [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                 } else if (kindOfChange == NSKeyValueChangeRemoval) {
                     [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                 } else if (kindOfChange == NSKeyValueChangeReplacement) {
                     [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
                 }
                 
                 // tell the tableView that we're done telling it about changes, and to complete the animation
                 [self.tableView endUpdates];
             }
    }
}

#pragma mark - Camera, CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate

- (void) handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav {
    if (image) {
        PostToInstagramViewController *postVC = [[PostToInstagramViewController alloc] initWithImage:image];
        
        [nav pushViewController:postVC animated:YES];
    } else {
//        [nav dismissViewControllerAnimated:YES completion:nil];
        if (isPhone) {
            [nav dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.cameraPopover dismissPopoverAnimated:YES];
            self.cameraPopover = nil;
        }
    }
    
}

- (void) cameraPressed:(UIBarButtonItem *)sender {
    UIViewController *imageVC;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        
        if (isPhone) {
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            self.cameraPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
            self.cameraPopover.popoverContentSize = CGSizeMake(320, 568);
            [self.cameraPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }

    return;
}

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
//    [cameraViewController dismissViewControllerAnimated:YES completion:^{
//        if (image) {
//            NSLog(@"Got an image!");
//        } else {
//            NSLog(@"Closed without an image");
//        }
//    }];
    [self handleImage:image withNavigationController:cameraViewController.navigationController];
}

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    
//    [imageLibraryViewController dismissViewControllerAnimated:YES completion:^{
//        if (image) {
//            NSLog(@"Got an image!");
//        } else {
//            NSLog(@"Closed without an image");
//        }
//    }];

    [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self items].count;
}

- (MediaTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self; // set the cell's delegate
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [[self items] removeObjectAtIndex:indexPath.row];
        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        Media *item = [self items][indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - MediaTableViewCellDelegate
- (void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    if (isPhone) {
        fullScreenVC.transitioningDelegate = self; // TransitioningDelegate
        fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    } else {
        fullScreenVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void) cell:(MediaTableViewCell *)cell didTwoFingerTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    
    [[DataSource sharedInstance] downloadImageForMediaItem: cell.mediaItem];
}

- (void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    self.lastLongPressedImageView = imageView;
    
    [cell.mediaItem shareMediaWithViewController:self];
}

//- (void) cell:(MediaTableViewCell *)cell didClickImageView:(UIImageView *)imageView {
//    NSMutableArray *itemsToShare = [NSMutableArray array];
//    
//    if (cell.mediaItem.caption.length > 0) {
//        [itemsToShare addObject:cell.mediaItem.caption];
//    }
//    
//    if (cell.mediaItem.image) {
//        [itemsToShare addObject:cell.mediaItem.image];
//    }
//    
//    if (itemsToShare.count > 0) {
//        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
//        [self presentViewController:activityVC animated:YES completion:nil];
//    }
//}

- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell {
    [[DataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
}

- (void)cellWillStartComposingComment:(MediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

- (void)cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[DataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    int orientation = [UIDevice currentDevice].orientation;
    
    // get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    
//    NSLog(@"%@ frameValue in Screen", NSStringFromCGRect(keyboardFrameInScreenCoordinates));
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
//    NSLog(@"%@ frameValue inView", NSStringFromCGRect(keyboardFrameInViewCoordinates));
    
    // get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
//    NSLog(@"%@ commentViewframe", NSStringFromCGRect(commentViewFrameInViewCoordinates));
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets;
    UIEdgeInsets scrollIndicatorInsets;
    
    NSLog(@"%@ contentOffset", NSStringFromCGPoint(contentOffset));
    
    contentInsets = self.tableView.contentInset;
//    NSLog(@"%@ contentInsets", contentInsets);
    scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
//    NSLog(@"%@ scrollIndicatorInsets", NSStringFromCGPoint(scrollIndicatorInsets));
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
//    NSLog(@"%f keyboardY", keyboardY);
    CGFloat commentViewY = CGRectGetMaxY(commentViewFrameInViewCoordinates);
//    NSLog(@"%f commentViewY", commentViewY);
    
    CGFloat difference = commentViewY - keyboardY;
    
//    if (difference > 0) {
        NSLog(@"%f difference", difference);
        heightToScroll += difference;
//    }
    
//    if (heightToScroll > 0) {
        NSLog(@"%f heightToScroll", heightToScroll);
        if (UIDeviceOrientationIsPortrait(orientation)) {
            //            contentOffset = self.portraitContentOffset;
        } else {
//            contentOffset = self.landscapeContentOffset;
        }
        contentInsets.bottom = keyboardFrameInViewCoordinates.size.height;
        scrollIndicatorInsets.bottom = keyboardFrameInViewCoordinates.size.height;
        contentOffset.y += heightToScroll;
    
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
//    }
    
//    self.lastKeyboardAdjustment = heightToScroll;
}

- (void)keyboardWillHide:(NSNotification *)notification {    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom = 0;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = 0;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
}

#pragma mark - Popover Handling

- (void) imageDidFinish:(NSNotification *)notification {
    if (isPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.cameraPopover dismissPopoverAnimated:YES];
        self.cameraPopover = nil;
    }
}

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
