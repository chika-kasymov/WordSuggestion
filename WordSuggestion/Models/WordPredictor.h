//
//  WordPredictor.h
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 29.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordPredictor : NSObject

@property (nonatomic, copy) void(^onLoadCompletion)(void);

- (void)loadNgram1:(NSString *)ngram1Path
            ngram2:(NSString *)ngram2Path
            ngram3:(NSString *)ngram3Path
            ngram4:(NSString *)ngram4Path;
- (void)suggestWordsForInput:(NSString *)inputText completion:(void(^)(NSArray<NSString *> *))completion;
- (BOOL)needLoadNgramData;

@end
