//
//  RCTKeyboardToolbar.m
//  RCTKeyboardToolbar
//
//  Created by Kanzaki Mirai on 11/7/15.
//  Copyright © 2015 DickyT. All rights reserved.
//

#import "RCTKeyboardToolbar.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import "RCTTextField.h"
#import "RCTTextView.h"
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import "RCTTextViewExtension.h"

@implementation RCTKeyboardToolbar

#pragma mark -

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return self.bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(configure:(nonnull NSNumber *)reactNode
                  options:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry ) {
        
        UIView *view = viewRegistry[reactNode];
        if (!view) {
            RCTLogError(@"RCTKeyboardToolbar: TAG #%@ NOT FOUND", reactNode);
            return;
        }
        
        UITextField *textView;
        if ([view class] == [RCTTextView class]) {
            RCTTextView *reactNativeTextView = ((RCTTextView *)view);
            textView = [reactNativeTextView getTextView];
        }
        else {
            RCTTextField *reactNativeTextView = ((RCTTextField *)view);
            textView = reactNativeTextView;
        }
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        
//        NSInteger toolbarStyle = [RCTConvert NSInteger:options[@"barStyle"]];
        numberToolbar.barStyle = UIBarStyleDefault;//toolbarStyle;
        
        NSArray *buttons = [RCTConvert NSArray:options[@"buttons"]];
        
        NSNumber *currentUid = [RCTConvert NSNumber:options[@"uid"]];
        
        NSMutableArray *toolbarItems = [NSMutableArray array];
        for (NSString *buttonTitle in buttons) {
//            NSLog(@"Button:%@",button);
        
            UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
            button.title = buttonTitle;
            button.tag = [currentUid intValue];
            button.tintColor = [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
            [toolbarItems addObject:button];
        }
        NSLog(@"Toolbar items: %@", toolbarItems);
        numberToolbar.items = toolbarItems;
        
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
        
        callback(@[[NSNull null], [currentUid stringValue]]);
    }];
}

- (void)keyboardButtonAction:(UIBarButtonItem*)sender
{
    NSNumber *uid = [NSNumber numberWithLong:sender.tag];
    NSString *button = sender.title;
    NSLog(@"uid:%@ title:%@",uid.stringValue, button);
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardToolbarDidTouchOn"
                                                 body:@{@"uid": uid.stringValue,@"button": button}
    ];
}

@end
