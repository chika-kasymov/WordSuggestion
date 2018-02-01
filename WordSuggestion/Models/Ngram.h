//
//  Ngram.h
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 30.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ngram1;
@class Ngram2;
@class Ngram3;
@class Ngram4;

@interface Ngram : NSObject

@property (nonatomic, copy) NSString *y;
@property (nonatomic) double freq;

- (instancetype)initWithNgram1:(Ngram1 *)ngram;
- (instancetype)initWithNgram2:(Ngram2 *)ngram;
- (instancetype)initWithNgram3:(Ngram3 *)ngram;
- (instancetype)initWithNgram4:(Ngram4 *)ngram;

@end
