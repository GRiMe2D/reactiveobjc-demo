//
//  ImageRetriever.h
//  reactiveobjc-demo
//
//  Created by Shakhzod Ikromov on 10/2/17.
//  Copyright © 2017 Shakhzod Ikromov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Supressing warnings created by reactive objc
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <ReactiveObjC/ReactiveObjC.h>
#pragma clang pop

/**
 @brief A class to retrieve image from the server
 @discussion Every image is requested from http://unsplash.it/200/200?random and sent as signal values.
 Signals never completes nor sends an error. So you should dispose unused or finished subscriptions yourself.
 If error occures, it will send nil as value
 */
@interface ImageRetriever : NSObject
/**
 @brief Default constructor
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;
/**
 @brief Forces to reload image from server
 */
- (void)reloadImage;
/**
 @brief Returns a signal where UIImage sent as value. Never sends error nor completes
 @discussion Signal values can be sent on other thread rather than the main one. Take care of this
 */
- (RACSignal *)retrieveImage;
@end
