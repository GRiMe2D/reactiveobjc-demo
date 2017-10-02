//
//  BasicSignalViewController.m
//  reactiveobjc-demo
//
//  Created by Shakhzod Ikromov on 10/2/17.
//  Copyright © 2017 Shakhzod Ikromov. All rights reserved.
//

#import "BasicSignalViewController.h"
#import "ImageRetriever.h"

@interface BasicSignalViewController ()
@property (nonatomic) ImageRetriever *imageRetriever;

@property (weak, nonatomic) IBOutlet UIImageView *imageWithMiddleHandler;
@property (strong, nonatomic) RACDisposable *imageWithMiddleHandlerDisposable;

@property (weak, nonatomic) IBOutlet UIImageView *imageWithoutMiddleHandler;
@property (strong, nonatomic) RACDisposable *imageWithoutMiddleHandlerDisposable;

@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;
@end

@implementation BasicSignalViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageRetriever = [[ImageRetriever alloc] init];
    self.animationImageView.image = [UIImage animatedImageNamed:@"middleHandlerAnimation" duration:2];
}

- (IBAction)onTapReloadButton:(id)sender {
    [self.imageRetriever reloadImage];
}

- (IBAction)onImageWithMiddleHandlerConnectChanged:(UISwitch *)sender {
    if (sender.isOn) {
        /// Subscribing values on main thread and replacing every nil to placeholder image
        self.imageWithMiddleHandlerDisposable = [[[[self.imageRetriever retrieveImage] deliverOnMainThread] bind:^RACSignalBindBlock _Nonnull{
            return ^(id _Nullable value, BOOL *stop) {
                if (value == nil) {
                    return [RACSignal return:[UIImage imageNamed:@"placeholderImage"]];
                } else {
                    return [RACSignal return:value];
                }
            };
        }] subscribeNext:^(UIImage * _Nullable image) {
            self.imageWithMiddleHandler.image = image;
        }];
    } else {
        [self.imageWithMiddleHandlerDisposable dispose];
    }
}

- (IBAction)onImageWithoutMiddlehandlerConnectChanged:(UISwitch *)sender {
    if (sender.isOn) {
        /// Just subscribing to values and delivering them on main thread.
        self.imageWithoutMiddleHandlerDisposable = [[[self.imageRetriever retrieveImage] deliverOnMainThread] subscribeNext:^(UIImage * _Nullable image) {
            self.imageWithoutMiddleHandler.image = image;
        }];
    } else {
        [self.imageWithoutMiddleHandlerDisposable dispose];
    }
}
@end
