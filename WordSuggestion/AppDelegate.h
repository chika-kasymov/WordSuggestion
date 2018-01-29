//
//  AppDelegate.h
//  WordSuggestion
//
//  Created by Shyngys Kassymov on 29.01.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

