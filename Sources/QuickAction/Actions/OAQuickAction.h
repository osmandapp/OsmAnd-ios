//
//  OAQuickAction.h
//  OsmAnd
//
//  Created by Paul on 8/6/19.
//  Copyright © 2019 OsmAnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"
#import "Localization.h"

#define kSectionNoName @"no_name"

@class OrderedDictionary;
@class OAQuickActionType;

//typedef NS_ENUM(NSInteger, EOAQuickActionType)
//{
//    EOAQuickActionTypeStub = 0,
//    EOAQuickActionTypeNew,
//    EOAQuickActionTypeMarker,
//    EOAQuickActionTypeFavorite,
//    EOAQuickActionTypeShowFavorite,
//    EOAQuickActionTypeTogglePOI,
//    EOAQuickActionTypeGPX,
//    EOAQuickActionTypeParking,
//    EOAQuickActionTypeTakeAudioNote,
//    EOAQuickActionTypeTakeVideoNote,
//    EOAQuickActionTypeTakePhoto,
//    EOAQuickActionTypeNavVoice,
//    EOAQuickActionTypeAddNote,
//    EOAQuickActionTypeAddPOI,
//    EOAQuickActionTypeMapStyle,
//    EOAQuickActionTypeMapOverlay,
//    EOAQuickActionTypeMapUnderlay,
//    EOAQuickActionTypeMapSource,
//    EOAQuickActionTypeAddDestination,
//    EOAQuickActionTypeReplaceDestination,
//    EOAQuickActionTypeAddFirstIntermediate,
//    EOAQuickActionTypeAutoZoomMap,
//    EOAQuickActionTypeToggleOsmNotes,
//    EOAQuickActionTypeToggleLocalEditsLayer,
//    EOAQuickActionTypeToggleNavigation,
//    EOAQuickActionTypeResumePauseNavigation,
//    EOAQuickActionTypeToggleDayNight,
//    EOAQuickActionTypeToggleGPX,
//    EOAQuickActionTypeToggleContourLines,
//    EOAQuickActionTypeToggleTerrain
//};

@interface OAQuickAction : NSObject

@property (nonatomic, readonly) OAQuickActionType *actionType;
@property (nonatomic) long identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic) NSDictionary<NSString *, NSString *> *params;

- (instancetype) initWithActionType:(OAQuickActionType *)type;
- (instancetype) initWithAction:(OAQuickAction *)action;

-(NSString *) getIconResName;
-(NSString *) getSecondaryIconName;
-(BOOL) hasSecondaryIcon;

-(long) getId;
-(NSInteger) getType;
-(BOOL) isActionEditable;
-(BOOL) isActionEnabled;
-(NSString *) getRawName;
-(NSString *) getDefaultName;
-(NSString *) getName;
-(BOOL) hasCustomName;

-(NSDictionary *) getParams;
-(void) setName:(NSString *) name;
-(void) setParams:(NSDictionary<NSString *, NSString *> *) params;
-(BOOL) isActionWithSlash;
-(NSString *) getActionText;
-(NSString *) getActionStateName;

//public void setAutoGeneratedTitle(EditText title){
//}

-(void) execute;
-(void) drawUI;
-(OrderedDictionary *)getUIModel;
-(BOOL) fillParams:(NSDictionary *)model;

-(BOOL) hasInstanceInList:(NSArray<OAQuickAction *> *)active;
-(NSString *)getTitle:(NSArray *)filters;
-(NSString *) getListKey;

+ (OAQuickActionType *) TYPE;
+(NSInteger) prepareDefaultColorNumberFromValue:(NSInteger)value;

@end
