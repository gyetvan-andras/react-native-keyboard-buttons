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
#import <objc/runtime.h>

@interface UIBarButtonItem (simulateVar)
-(void)setKeyString:(NSString *)myString;
-(NSString *)keyString;
@end

@implementation UIBarButtonItem (simulateVar)

static char STRING_KEY;

-(void)setKeyString: (NSString *)myString
{
    objc_setAssociatedObject(self, &STRING_KEY, myString, OBJC_ASSOCIATION_RETAIN);
}

-(NSString *)keyString
{
    return (NSString *)objc_getAssociatedObject(self, &STRING_KEY);
}

@end

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
        
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
//        NSInteger toolbarStyle = [RCTConvert NSInteger:options[@"barStyle"]];
        numberToolbar.barStyle = UIBarStyleDefault;//toolbarStyle;
        NSArray *buttons = NULL;
        @try {
            buttons = [RCTConvert NSArray:options[@"buttons"]];
        } @catch (NSException *exception) {
            RCTLogError(@"RCTKeyboardToolbar: buttons paramater must be an array of button specs!", reactNode);
            return;
        }
        
//        NSLog(@"Buttons:%@",buttons);
        NSNumber *currentUid = [RCTConvert NSNumber:options[@"uid"]];
        
        
        NSMutableArray *toolbarItems = [NSMutableArray array];
        for (NSDictionary *buttonSpec in buttons) {
            NSString *buttonTitle = buttonSpec[@"title"];
            NSString *buttonColor = buttonSpec[@"color"];
            NSString *buttonKey = buttonSpec[@"key"];
            if(!buttonKey) buttonKey = buttonTitle;
//            NSLog(@"Title:%@ color:%@ key:%@", buttonTitle, buttonColor, buttonKey);
            UIColor *tintColor = [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
            if(buttonColor) {
                tintColor = [RCTConvert UIColor:buttonColor];
            }
            if([buttonTitle compare:@"|"] == NSOrderedSame) {
                [toolbarItems addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
            } else if([buttonTitle compare:@"_"] == NSOrderedSame) {
                UIBarButtonItem* spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
                spacer.width = 10;
                [toolbarItems addObject:spacer];

            } else {
                UIBarButtonItem *button = NULL;
                if([buttonTitle compare:@"<"] == NSOrderedSame) {
                    UIImage* img = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    button = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
                } else if([buttonTitle compare:@">"] == NSOrderedSame) {
                    UIImage* img = [[UIImage imageNamed:@"forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    button = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
                } else if([buttonTitle compare:@">>"] == NSOrderedSame) {
                    UIImage* img = [[UIImage imageNamed:@"fforward"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    button = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
                } else if([buttonTitle compare:@"<<"] == NSOrderedSame) {
                    UIImage* img = [[UIImage imageNamed:@"bback"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    button = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
                } else if([buttonTitle compare:@"Done"] == NSOrderedSame) {
                    button = [[UIBarButtonItem alloc]initWithTitle:buttonTitle style:UIBarButtonItemStyleDone target:self action:@selector(keyboardButtonAction:)];
                } else {
                    button = [[UIBarButtonItem alloc]initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(keyboardButtonAction:)];
                }
                button.keyString = buttonKey;
                button.tag = [currentUid intValue];
                button.tintColor = tintColor;
                [toolbarItems addObject:button];
            }
        }
        numberToolbar.items = toolbarItems;
        
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
        
        callback(@[[NSNull null], [currentUid stringValue]]);
    }];
}

- (void)keyboardButtonAction:(UIBarButtonItem*)sender
{
    NSNumber *uid = [NSNumber numberWithLong:sender.tag];
    NSString *buttonKey = sender.keyString;
    [self.bridge.eventDispatcher sendAppEventWithName:@"TUKeyboardToolbarDidTouchOn"
                                                 body:@{@"uid": uid.stringValue,@"button": buttonKey}
    ];
}

@end
