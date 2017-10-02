//
//  ImageRetriever.m
//  reactiveobjc-demo
//
//  Created by Shakhzod Ikromov on 10/2/17.
//  Copyright © 2017 Shakhzod Ikromov. All rights reserved.
//

#import "ImageRetriever.h"

@interface ImageRetriever()
/// Here we hold our cached image
@property (nonatomic) UIImage *cachedImage;
/// Here we hold our subscribers to the signal
@property (nonatomic) NSMutableSet *subscribers;
/// Here we hold current task
@property (nonatomic) NSURLSessionTask *requestTask;
@end

@implementation ImageRetriever
- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedImage = nil;
        self.subscribers = [NSMutableSet set];
        self.requestTask = nil;
    }
    return self;
}

- (void)reloadImage {
    if (self.requestTask != nil) {
        /// Currently, we're made a request. We decide not to make another request while prevous isn't finished
        return;
    }
    
    /// Here we make an actual request
    self.requestTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://unsplash.it/200/200?random"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            /// When there's no error and we got data
            if (httpResponse.statusCode == 200 && data != nil && error == nil) {
                UIImage *image = [UIImage imageWithData:data];
                for (id<RACSubscriber> subscriber in self.subscribers) {
                    /// Sending our image to subscribers
                    /// Notice, we aren't in main thread
                    [subscriber sendNext:image];
                }
                /// And caching the image
                self.cachedImage = image;
            } else {
                /// Something got unexpected, sending nil
                for (id<RACSubscriber> subscriber in self.subscribers) {
                    /// Sending nil to subscribers
                    /// Notice, we aren't in main thread
                    [subscriber sendNext:nil];
                }
                
                /// Logging what's gone unexpected
                NSLog(@"Request failed. \n\tStatus code: %ld\n\tError: %@", (long)httpResponse.statusCode, error);
            }
        } else {
            /// Our response is nil
            for (id<RACSubscriber> subscriber in self.subscribers) {
                /// Sending nil to subscribers
                /// Notice, we aren't in main thread
                [subscriber sendNext:nil];
            }
            NSLog(@"Request failed. \n\tResponse is nil");
        }
        
        /// Clearing our current task
        self.requestTask = nil;
    }];
    
    [self.requestTask resume];
}

- (RACSignal *)retrieveImage {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        /// Here we collect our subscriber to the NSMutableSet
        [self.subscribers addObject:subscriber];
        
        
        /// Send our cached image to the subscriber. Notice we're not making an actual request
        [subscriber sendNext:self.cachedImage];
        if (self.cachedImage == nil) {
            /// Okay, there's no cache here. Force ourselves to make the actual request
            [self reloadImage];
        }
        
            /// Here we are releasing the object and removing it our set. This block will called only if requested to dispose
        return [RACDisposable disposableWithBlock:^{
            [self.subscribers removeObject:subscriber];
        }];
    }];
}
@end
