//
//  WordPredictor.m
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 29.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import "WordPredictor.h"
#import "Ngram1+CoreDataClass.h"
#import "Ngram2+CoreDataClass.h"
#import "Ngram3+CoreDataClass.h"
#import "Ngram4+CoreDataClass.h"
#import "Ngram.h"
#import "FileReader.h"
#import "AppDelegate.h"

@interface WordPredictor()

@property (nonatomic) dispatch_group_t group;
@property (nonatomic, strong) NSOperationQueue *backgroundQueue;

@property (nonatomic, strong) NSRegularExpression *regex;

@end

@implementation WordPredictor

- (instancetype)init {
    self = [super init];

    if (self) {
        NSError *error;
        self.regex = [[NSRegularExpression alloc] initWithPattern:@"\\p{L}[\\p{L}']*(?:-\\p{L}+)*"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];

        if (error) {
            NSLog(@"Invalid regex: %@", error.localizedDescription);
        }
    }

    return self;
}

- (void)loadNgram1:(NSString *)ngram1Path
            ngram2:(NSString *)ngram2Path
            ngram3:(NSString *)ngram3Path
            ngram4:(NSString *)ngram4Path {
    NSFileManager *fm = [NSFileManager defaultManager];

    self.group = dispatch_group_create();

    __weak WordPredictor *weakSelf = self;

    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;

    if (![fm fileExistsAtPath:ngram1Path]) {
        NSLog(@"Can't find ngram1 at path: %@", ngram1Path);
    } else {
        dispatch_group_enter(self.group);

        FileReader *fileReader = [[FileReader alloc] initWithFilePath:ngram1Path];
        [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext *backgroundContext) {
            [fileReader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop0) {

                NSArray<NSString *> *items = [line componentsSeparatedByString:@","];
                Ngram1 *ngram = [NSEntityDescription insertNewObjectForEntityForName:@"Ngram1" inManagedObjectContext:backgroundContext];
                ngram.x = items[0];
                ngram.freq = items[1].integerValue;
            }];

            NSError *error;
            [backgroundContext save:&error];
            if (error) {
                NSLog(@"Error to save background context for Ngram1 - %@", error);
            }

            dispatch_group_leave(self.group);
        }];
    }

    if (![fm fileExistsAtPath:ngram2Path]) {
        NSLog(@"Can't find ngram2 at path: %@", ngram2Path);
    } else {
        dispatch_group_enter(self.group);

        FileReader *fileReader = [[FileReader alloc] initWithFilePath:ngram2Path];
        [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext *backgroundContext) {
            [fileReader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop0) {

                NSArray<NSString *> *items = [line componentsSeparatedByString:@","];
                Ngram2 *ngram = [NSEntityDescription insertNewObjectForEntityForName:@"Ngram2" inManagedObjectContext:backgroundContext];
                ngram.x = items[0];
                ngram.y = items[1];
                ngram.freq = items[2].integerValue;
            }];

            NSError *error;
            [backgroundContext save:&error];
            if (error) {
                NSLog(@"Error to save background context for Ngram2 - %@", error);
            }

            dispatch_group_leave(self.group);
        }];
    }

    if (![fm fileExistsAtPath:ngram3Path]) {
        NSLog(@"Can't find ngram3 at path: %@", ngram3Path);
    } else {
        dispatch_group_enter(self.group);

        FileReader *fileReader = [[FileReader alloc] initWithFilePath:ngram3Path];
        [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext *backgroundContext) {
            [fileReader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop0) {

                NSArray<NSString *> *items = [line componentsSeparatedByString:@","];
                Ngram3 *ngram = [NSEntityDescription insertNewObjectForEntityForName:@"Ngram3" inManagedObjectContext:backgroundContext];
                ngram.x = items[0];
                ngram.y = items[1];
                ngram.freq = items[2].integerValue;
            }];

            NSError *error;
            [backgroundContext save:&error];
            if (error) {
                NSLog(@"Error to save background context for Ngram3 - %@", error);
            }

            dispatch_group_leave(self.group);
        }];
    }

    if (![fm fileExistsAtPath:ngram4Path]) {
        NSLog(@"Can't find ngram4 at path: %@", ngram4Path);
    } else {
        dispatch_group_enter(self.group);

        FileReader *fileReader = [[FileReader alloc] initWithFilePath:ngram4Path];
        [appDelegate.persistentContainer performBackgroundTask:^(NSManagedObjectContext *backgroundContext) {
            [fileReader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop0) {

                NSArray<NSString *> *items = [line componentsSeparatedByString:@","];
                Ngram4 *ngram = [NSEntityDescription insertNewObjectForEntityForName:@"Ngram4" inManagedObjectContext:backgroundContext];
                ngram.x = items[0];
                ngram.y = items[1];
                ngram.freq = items[2].integerValue;
            }];

            NSError *error;
            [backgroundContext save:&error];
            if (error) {
                NSLog(@"Error to save background context for Ngram4 - %@", error);
            }

            dispatch_group_leave(self.group);
        }];
    }

    dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
        if (weakSelf.onLoadCompletion) {
            weakSelf.onLoadCompletion();
        }
    });
}

- (void)suggestWordsForInput:(NSString *)inputText completion:(void(^)(NSArray<NSString *> *))completion {
    __weak WordPredictor *weakSelf = self;

    if (self.backgroundQueue) {
        [self.backgroundQueue cancelAllOperations];
    } else {
        self.backgroundQueue = [NSOperationQueue new];
    }

    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    [self.backgroundQueue addOperationWithBlock:^{
        NSString *lastChar = [inputText substringFromIndex:inputText.length - 1];

        NSMutableArray *lastWords = [NSMutableArray new];
        BOOL isNewWord = [lastChar rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound;

        NSArray<NSTextCheckingResult *> *results = [weakSelf.regex matchesInString:inputText options:NSMatchingReportProgress range:NSMakeRange(0, inputText.length)];
        int start = MAX(((int)results.count) - 4, 0);
        for (int i = start; i < results.count; i++) {
            NSTextCheckingResult *result = results[i];

            NSString *parsedText = [inputText substringWithRange:result.range];
            [lastWords addObject:parsedText.lowercaseString];
        }

        NSString *lastWord = isNewWord ? @"" : lastWords.lastObject;
        if (!isNewWord) {
            [lastWords removeLastObject];
        }

        NSMutableDictionary<NSString *, NSNumber *> *suggestedWords = [NSMutableDictionary new];

        // 4-gram
        if (lastWords.count > 2) {
            NSString *txt = [[lastWords subarrayWithRange:NSMakeRange(lastWords.count - 3, 3)] componentsJoinedByString:@" "];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ngram4"];
            request.fetchLimit = 3;

            if (!isNewWord) {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@ AND y BEGINSWITH %@", txt, lastWord]];
            } else {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@", txt]];
            }

            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:false];
            [request setSortDescriptors:@[sortDescriptor]];

            NSError *error = nil;
            NSArray<Ngram4 *> *results = [context executeFetchRequest:request error:&error];
            if (!results) {
                NSLog(@"Error fetching Ngram4 objects: %@\n%@", [error localizedDescription], [error userInfo]);
            } else {
                int64_t freqSum = 0;
                for (Ngram4 *ngram in results) {
                    freqSum += ngram.freq;
                }

                for (Ngram4 *ngram in results) {
                    double freq = ngram.freq / (double) freqSum * 0.6;
                    NSNumber *currentFreq = suggestedWords[ngram.y];
                    if (currentFreq) {
                        suggestedWords[ngram.y] = @(currentFreq.doubleValue + freq);
                    } else {
                        suggestedWords[ngram.y] = @(freq);
                    }
                }
            }
        }

        // 3-gram
        if (lastWords.count > 1) {
            NSString *txt = [[lastWords subarrayWithRange:NSMakeRange(lastWords.count - 2, 2)] componentsJoinedByString:@" "];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ngram3"];
            request.fetchLimit = 3;

            if (!isNewWord) {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@ AND y BEGINSWITH %@", txt, lastWord]];
            } else {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@", txt]];
            }

            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:false];
            [request setSortDescriptors:@[sortDescriptor]];

            NSError *error = nil;
            NSArray<Ngram3 *> *results = [context executeFetchRequest:request error:&error];
            if (!results) {
                NSLog(@"Error fetching Ngram3 objects: %@\n%@", [error localizedDescription], [error userInfo]);
            } else {
                int64_t freqSum = 0;
                for (Ngram3 *ngram in results) {
                    freqSum += ngram.freq;
                }

                for (Ngram3 *ngram in results) {
                    double freq = ngram.freq / (double) freqSum * 0.3;
                    NSNumber *currentFreq = suggestedWords[ngram.y];
                    if (currentFreq) {
                        suggestedWords[ngram.y] = @(currentFreq.doubleValue + freq);
                    } else {
                        suggestedWords[ngram.y] = @(freq);
                    }
                }
            }
        }

        // 2-gram
        if (lastWords.count > 0) {
            NSString *txt = [[lastWords subarrayWithRange:NSMakeRange(lastWords.count - 1, 1)] componentsJoinedByString:@" "];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ngram2"];
            request.fetchLimit = 3;

            if (!isNewWord) {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@ AND y BEGINSWITH %@", txt, lastWord]];
            } else {
                [request setPredicate:[NSPredicate predicateWithFormat:@"x == %@", txt]];
            }

            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:false];
            [request setSortDescriptors:@[sortDescriptor]];

            NSError *error = nil;
            NSArray<Ngram2 *> *results = [context executeFetchRequest:request error:&error];
            if (!results) {
                NSLog(@"Error fetching Ngram2 objects: %@\n%@", [error localizedDescription], [error userInfo]);
            } else {
                int64_t freqSum = 0;
                for (Ngram2 *ngram in results) {
                    freqSum += ngram.freq;
                }

                for (Ngram2 *ngram in results) {
                    double freq = ngram.freq / (double) freqSum * 0.08;
                    NSNumber *currentFreq = suggestedWords[ngram.y];
                    if (currentFreq) {
                        suggestedWords[ngram.y] = @(currentFreq.doubleValue + freq);
                    } else {
                        suggestedWords[ngram.y] = @(freq);
                    }
                }
            }
        }

        // 1-gram
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ngram1"];
        request.fetchLimit = 3;
        [request setPredicate:[NSPredicate predicateWithFormat:@"x BEGINSWITH %@", lastWord]];

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:false];
        [request setSortDescriptors:@[sortDescriptor]];

        NSError *error = nil;
        NSArray<Ngram1 *> *ngram1Results = [context executeFetchRequest:request error:&error];
        if (!ngram1Results) {
            NSLog(@"Error fetching Ngram1 objects: %@\n%@", [error localizedDescription], [error userInfo]);
        } else {
            int64_t freqSum = 0;
            for (Ngram1 *ngram in ngram1Results) {
                freqSum += ngram.freq;
            }

            for (Ngram1 *ngram in ngram1Results) {
                double freq = ngram.freq / (double) freqSum * 0.02;
                NSNumber *currentFreq = suggestedWords[ngram.x];
                if (currentFreq) {
                    suggestedWords[ngram.x] = @(currentFreq.doubleValue + freq);
                } else {
                    suggestedWords[ngram.x] = @(freq);
                }
            }
        }

        NSArray *sortedWords = [suggestedWords keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            double v1 = [obj1 doubleValue];
            double v2 = [obj2 doubleValue];
            if (v1 < v2) {
                return NSOrderedDescending;
            } else if (v1 > v2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        sortedWords = [sortedWords subarrayWithRange:NSMakeRange(0, MIN(sortedWords.count, 3))];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(sortedWords);
            }
        });
    }];
}

- (BOOL)needLoadNgramData {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ngram1"];
    request.fetchLimit = 10;

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Ngram1 objects: %@\n%@", [error localizedDescription], [error userInfo]);
        return false;
    }

    return results.count == 0;
}

@end
