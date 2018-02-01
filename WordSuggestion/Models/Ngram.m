//
//  Ngram.m
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 30.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import "Ngram.h"
#import "Ngram1+CoreDataClass.h"
#import "Ngram2+CoreDataClass.h"
#import "Ngram3+CoreDataClass.h"
#import "Ngram4+CoreDataClass.h"

@implementation Ngram

- (instancetype)initWithNgram1:(Ngram1 *)ngram {
    self = [super init];

    if (self) {
        self.y = ngram.x;
        self.freq = ngram.freq;
    }

    return self;
}

- (instancetype)initWithNgram2:(Ngram2 *)ngram {
    self = [super init];

    if (self) {
        self.y = ngram.y;
        self.freq = ngram.freq;
    }

    return self;
}

- (instancetype)initWithNgram3:(Ngram3 *)ngram {
    self = [super init];

    if (self) {
        self.y = ngram.y;
        self.freq = ngram.freq;
    }

    return self;
}

- (instancetype)initWithNgram4:(Ngram4 *)ngram {
    self = [super init];

    if (self) {
        self.y = ngram.y;
        self.freq = ngram.freq;
    }

    return self;
}

@end
