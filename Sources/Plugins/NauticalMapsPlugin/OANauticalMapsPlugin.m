//
//  OANauticalMapsPlugin.m
//  OsmAnd Maps
//
//  Created by nnngrach on 08.07.2021.
//  Copyright © 2021 OsmAnd. All rights reserved.
//

#import "OANauticalMapsPlugin.h"
#import "OAApplicationMode.h"
#import "OAIAPHelper.h"

#define PLUGIN_ID kInAppId_Addon_Nautical

@implementation OANauticalMapsPlugin

- (NSString *) getId
{
    return PLUGIN_ID;
}

- (NSArray<OAApplicationMode *> *) getAddedAppModes
{
    return @[OAApplicationMode.BOAT];
}

@end

