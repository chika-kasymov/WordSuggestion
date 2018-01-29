//
//  ViewController.m
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 29.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *suggestedWordsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lookupTimeLabel;

@property (nonatomic, strong) NSRegularExpression *regex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error;
    self.regex = [[NSRegularExpression alloc] initWithPattern:@"\\p{L}[\\p{L}']*(?:-\\p{L}+)*"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];

    if (error) {
        NSLog(@"Invalid regex: %@", error.localizedDescription);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];

    [self setStateLoading:true];

    __weak ViewController *weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // load data

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setStateLoading:false];
        });
    });
}

#pragma mark - Methods

- (void)setStateLoading:(BOOL)loading {
    self.textView.userInteractionEnabled = !loading;
    self.textView.alpha = loading ? 0.5 : 1;
    self.spinner.hidden = !loading;

    if (loading) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSString *inputText = textView.text;
    if (!inputText) {
        return;
    }

    NSMutableString *textToLookup = @"".mutableCopy;

    NSArray<NSTextCheckingResult *> *results = [self.regex matchesInString:inputText options:NSMatchingReportProgress range:NSMakeRange(0, inputText.length)];
    int start = MAX(((int)results.count) - 4, 0);
    for (int i = start; i < results.count; i++) {
        NSTextCheckingResult *result = results[i];

        NSString *separator = i == start ? @"" : @" ";
        NSString *parsedText = [inputText substringWithRange:result.range];
        [textToLookup appendFormat:@"%@%@", separator, parsedText];
    }

    NSLog(@"Suggest words for input: %@", textToLookup);
}


@end
