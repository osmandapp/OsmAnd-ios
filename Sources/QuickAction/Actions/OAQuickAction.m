//
//  OAQuickAction.m
//  OsmAnd
//
//  Created by Paul on 8/6/19.
//  Copyright © 2019 OsmAnd. All rights reserved.
//

#import "OAQuickAction.h"
#import "OAQuickActionType.h"
#import "OAQuickActionRegistry.h"
#import "OrderedDictionary.h"
#import "OADefaultFavorite.h"

static NSInteger SEQ = 0;

@implementation OAQuickAction

- (instancetype) init
{
    return [self initWithActionType:OAQuickActionRegistry.TYPE_ADD_ITEMS];
}

-(instancetype) initWithActionType:(OAQuickActionType *)type
{
    self = [super init];
    if (self) {
        _identifier = [[NSDate date] timeIntervalSince1970] * 1000 + (SEQ++);
        _actionType = type;
    }
    return self;
}

- (instancetype) initWithAction:(OAQuickAction *)action
{
    self = [super init];
    if (self) {
        _identifier = action.identifier;
        _name = action.getRawName;
        _actionType = action.actionType;
        _params = action.getParams;
    }
    return self;
}

-(NSString *) getIconResName
{
    return _actionType ? _actionType.iconName : nil;
}

- (NSString *)getSecondaryIconName
{
    return _actionType ? _actionType.secondaryIconName : nil;
}

- (BOOL)hasSecondaryIcon
{
    return self.getSecondaryIconName != nil;
}

-(long) getId
{
    return _identifier;
}

-(NSInteger) getType
{
    return _actionType ? _actionType.identifier : 0;
}

-(BOOL) isActionEditable
{
    return _actionType != nil && _actionType.actionEditable;
}

-(NSString *) getRawName
{
    return _name;
}

-(NSString *) getDefaultName
{
    return _actionType ? _actionType.name : @"";
}

- (NSString *) getName
{
    if (_name.length == 0)
        return [self getDefaultName];
    else
        return _name;
}

- (BOOL) hasCustomName
{
    return ![[self getName] isEqualToString:[self getDefaultName]];
}

-(NSDictionary *) getParams
{
    if (!_params)
        _params = [NSDictionary new];

    return _params;
}

-(void) setName:(NSString *) name
{
    _name = name;
}

-(void) setParams:(NSDictionary<NSString *, NSString *> *) params
{
    _params = params;
}

+(NSInteger) prepareDefaultColorNumberFromValue:(NSInteger)value
{
    NSInteger defaultColor = value;
    NSArray *colors = [OADefaultFavorite builtinColors];
    if (defaultColor < 0 || defaultColor >= colors.count)
        defaultColor = 0;
    return defaultColor;
}

-(BOOL) isActionWithSlash
{
    return NO;
}

- (BOOL)isActionEnabled
{
    return YES;
}

-(NSString *) getActionText
{
    return nil;
}

-(NSString *) getActionStateName
{
    return [self getName];
}

//public void setAutoGeneratedTitle(EditText title){
//}

- (void)execute
{
}

- (void)drawUI
{
}

-(OrderedDictionary *)getUIModel
{
    return [[OrderedDictionary alloc] init];
}

- (BOOL)fillParams:(NSDictionary *)model
{
    return YES;
}

-(BOOL) hasInstanceInList:(NSArray<OAQuickAction *> *) active
{
    for (OAQuickAction *action in active)
    {
        if (action.getType == self.getType)
            return YES;
    }

    return NO;
}

- (NSString *)getTitle:(NSArray *)filters
{
    return nil;
}

- (NSString *)getListKey
{
    return nil;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
        return YES;
    if (!object)
        return NO;
    
    if ([object isKindOfClass:self.class])
    {
        OAQuickAction *action = (OAQuickAction *) object;
        if (self.getType != action.getType)
            return NO;
        if (_identifier != action.identifier)
            return NO;
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    NSInteger result = self.getType;
    result = 31 * result + (NSInteger) (_identifier ^ (_identifier >> 32));
    result = 31 * result + (_name != nil ? [_name hash] : 0);
    return result;
}

+ (OAQuickActionType *) TYPE
{
    return nil;
}

@end
