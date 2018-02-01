//
//  ViewController.m
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 29.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import "ViewController.h"
#import "WordPredictor.h"

@interface ViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *suggestedWordsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lookupTimeLabel;

@property (nonatomic, strong) WordPredictor *wordPredictor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.wordPredictor = [WordPredictor new];

    self.spinner.hidden = true;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];

    [self loadNgramDataIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.suggestedWordsLabel.preferredMaxLayoutWidth = self.suggestedWordsLabel.frame.size.width;
}

#pragma mark - Methods

- (void)loadNgramDataIfNeeded {
    if (!self.wordPredictor.needLoadNgramData) {
        return;
    }

    [self setStateLoading:true];

    __weak ViewController *weakSelf = self;

    self.wordPredictor.onLoadCompletion = ^{
        NSLog(@"Finished parsing ngrams data.");

        [weakSelf setStateLoading:false];
    };

    NSString *ngram1Path = [[NSBundle mainBundle] pathForResource:@"ngram1" ofType:@"csv"];
    NSString *ngram2Path = [[NSBundle mainBundle] pathForResource:@"ngram2" ofType:@"csv"];
    NSString *ngram3Path = [[NSBundle mainBundle] pathForResource:@"ngram3" ofType:@"csv"];
    NSString *ngram4Path = [[NSBundle mainBundle] pathForResource:@"ngram4" ofType:@"csv"];

    [self.wordPredictor loadNgram1:ngram1Path
                            ngram2:ngram2Path
                            ngram3:ngram3Path
                            ngram4:ngram4Path];
}

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
    if (!inputText || inputText.length == 0) {
        return;
    }

    __weak ViewController *weakSelf = self;

    NSDate *methodStart = [NSDate date];
    [self.wordPredictor suggestWordsForInput:inputText completion:^(NSArray<NSString *> *wordSuggestions) {
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];

        weakSelf.suggestedWordsLabel.text = [wordSuggestions componentsJoinedByString:@"\n"];
        weakSelf.lookupTimeLabel.text = [NSString stringWithFormat:@"%.5f seconds", executionTime];
    }];
}

@end
