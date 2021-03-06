//
//  OAMapSource.h
//  OsmAnd
//
//  Created by Alexey Pelykh on 4/24/14.
//  Copyright (c) 2014 OsmAnd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OAMapSource : NSObject <NSCopying>

- (instancetype) initWithResource:(NSString *)resourceId;

- (instancetype) initWithResource:(NSString *)resourceId
                       andVariant:(NSString *)variant;

- (instancetype) initWithResource:(NSString *)resourceId
                       andVariant:(NSString *)variant
                             name:(NSString *)name;

- (instancetype) initWithResource:(NSString *)resourceId
                       andVariant:(NSString *)variant
                             name:(NSString *)name
                             type:(NSString *)type;

+ (OAMapSource *) fromDictionary:(NSDictionary<NSString *, NSString *> *) dictionary;
// "OnlineTileSources" or "MapStyle" resource
@property (nonatomic, readonly) NSString *resourceId;
// For "OnlineTileSources": name of source
// For "MapStyle": name of preset or nil
@property (nonatomic, readonly) NSString *variant;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;

- (NSDictionary<NSString *, NSString *> *) toDictionary;

+ (OAMapSource *) getOsmAndOnlineTilesMapSource;

@end
