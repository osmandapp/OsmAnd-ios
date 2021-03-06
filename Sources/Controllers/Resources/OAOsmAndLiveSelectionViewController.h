//
//  OAOsmAndLiveSelectionViewController.h
//  OsmAnd
//
//  Created by Paul on Created by Paul on 12/18/18.
//  Copyright © 2018 OsmAnd. All rights reserved.
//

#import "OACompoundViewController.h"

#include <OsmAndCore/QtExtensions.h>
#include <QString>

typedef NS_ENUM(NSInteger, ELiveSettingsScreen)
{
    ELiveSettingsScreenUndefined = -1,
    ELiveSettingsScreenMain = 0,
    ELiveSettingsScreenFrequency
};

@interface OAOsmAndLiveSelectionViewController : OACompoundViewController<UITableViewDelegate, UITableViewDataSource>

- (id) initWithRegionName:(QString)regionName titleName:(NSString *)title;
- (id) initWithType:(ELiveSettingsScreen)type regionName:(QString)regionName titleName:(NSString *)title;

@property (nonatomic, readonly) ELiveSettingsScreen settingsScreen;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
