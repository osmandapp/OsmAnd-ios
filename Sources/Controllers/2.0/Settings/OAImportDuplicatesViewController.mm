//
//  OAImportDuplicatesViewControllers.m
//  OsmAnd Maps
//
//  Created by nnngrach on 15.10.2020.
//  Copyright © 2020 OsmAnd. All rights reserved.
//

#import "OAImportDuplicatesViewController.h"
#import "OAImportCompleteViewController.h"
#import "Localization.h"
#import "OAColors.h"
#import "OAResourcesUIHelper.h"
#import "OASettingsImporter.h"
#import "OAApplicationMode.h"
#import "OAQuickActionRegistry.h"
#import "OAQuickActionType.h"
#import "OAQuickAction.h"
#import "OAMapSource.h"
#import "OASQLiteTileSource.h"
#import "OAPOIUIFilter.h"
#import "OAAvoidRoadInfo.h"
#import "OAProfileDataObject.h"
#import "OAMenuSimpleCell.h"
#import "OAMenuSimpleCellNoIcon.h"
#import "OATitleTwoIconsRoundCell.h"
#import "OAActivityViewWithTitleCell.h"

#define kMenuSimpleCell @"OAMenuSimpleCell"
#define kMenuSimpleCellNoIcon @"OAMenuSimpleCellNoIcon"
#define kTitleTwoIconsRoundCell @"OATitleTwoIconsRoundCell"
#define kCellTypeWithActivity @"OAActivityViewWithTitleCell"
#define RENDERERS_DIR @"rendering/"
#define ROUTING_PROFILES_DIR @"routing/"


@interface HeaderType : NSObject
@property (nonatomic) NSString *label;
@end

@implementation HeaderType
- (instancetype) initWithLabel:(NSString *)label
{
    self = [super init];
    if (self)
    {
        _label = label;
    }
    return self;
}
@end



@interface OAImportDuplicatesViewController () <UITableViewDelegate, UITableViewDataSource, OASettingsImportExportDelegate>

@end

@implementation OAImportDuplicatesViewController
{
    OsmAndAppInstance _app;
    NSArray<id> *_duplicatesList;
    NSArray<OASettingsItem *> * _settingsItems;
    NSString *_file;
    OASettingsHelper *_settingsHelper;
    
    NSString *_title;
    NSString *_description;

    NSMutableArray<NSMutableArray<NSDictionary *> *> *_data;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithDuplicatesList:(NSArray<id> *)duplicatesList settingsItems:(NSArray<OASettingsItem *> *)settingsItems file:(NSString *)file
{
    self = [super init];
    if (self)
    {
        _duplicatesList = duplicatesList;
        _settingsItems = settingsItems;
        _file = file;
        [self commonInit];
    }
    return self;
}

//onCreate
- (void) commonInit
{
    _app = [OsmAndApp instance];
    _settingsHelper = [OASettingsHelper sharedInstance];
    
    //[self generateFakeData]; //TODO: delete this
    
    OAImportAsyncTask *importTask = _settingsHelper.importTask;
    if (!importTask)
        _settingsItems = [importTask getSelectedItems];
    if (!_duplicatesList)
        _duplicatesList = [importTask getDuplicates];
    if (!_file)
        _file = [importTask getFile];
    
    importTask.delegate = self;
}

//onActivityCreated
- (void) viewDidLoad
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.additionalNavBarButton.hidden = YES;
    [self setupBottomViewMultyLabelButtons];
    [super viewDidLoad];
    
    if (_duplicatesList)
        [self prepareData: [self prepareDuplicates:_duplicatesList]];
    if ([_settingsHelper.importTask getImportType] == EOAImportTypeImport)
        [self setupImportingUI];
    else
        _title = OALocalizedString(@"import_duplicates_title");
    _title = OALocalizedString(@"import_duplicates_title");
}

- (void) setupImportingUI
{
    _title = OALocalizedString(@"shared_string_importing");
    _description = [NSString stringWithFormat:OALocalizedString(@"importing_from"), _file];
    
    [self turnOnLoadingIndicator];
    self.bottomBarView.hidden = YES;
    self.view.backgroundColor = self.tableView.backgroundColor;
    [self.tableView reloadData];
    
}

- (void) turnOnLoadingIndicator
{
    _data = @[ @[ @{
        @"cellType": kCellTypeWithActivity,
        @"label": OALocalizedString(@"shared_string_importing"),
    }]];
}

- (void) generateFakeData
{
    //TODO: for now here is generating fake data, just for demo
    NSMutableArray *fakeDataArray = [NSMutableArray new];

    OAApplicationModeBean *appMode = [[OAApplicationModeBean alloc] init];
    appMode.userProfileName = @"Test Profile Name";
    appMode.routingProfile = @"Test value";
    appMode.iconName = @"ic_custom_transport_tram";
    appMode.iconColor = color_primary_purple;
    [fakeDataArray addObject: appMode];
    
    NSArray<OAQuickActionType *> *allQuickActions = [[OAQuickActionRegistry sharedInstance] produceTypeActionsListWithHeaders];
    OAQuickAction *action = [[OAQuickAction alloc] initWithActionType:allQuickActions[3]];
    [fakeDataArray addObject: action];
    
    OAPOIUIFilter *filter = [[OAPOIUIFilter alloc] initWithName:OALocalizedString(@"poi_filter_custom_filter") filterId:CUSTOM_FILTER_ID acceptedTypes:[NSMapTable strongToStrongObjectsMapTable]];
    filter.isStandardFilter = YES;
    [fakeDataArray addObject: filter];

    OASQLiteTileSource *tileSource = [[OASQLiteTileSource alloc] init];
    [fakeDataArray addObject: tileSource];
    
    NSString *renderTestSting = @"rendering/Desert.xml";
    [fakeDataArray addObject: renderTestSting];
    NSString *routingTestSting = @"routing/Moon.xml";
    [fakeDataArray addObject: routingTestSting];
    
    OAAvoidRoadInfo *avoidRoad = [[OAAvoidRoadInfo alloc] init];
    avoidRoad.name = @"Avoid Fake Road";
    [fakeDataArray addObject: avoidRoad];
    
    _duplicatesList = [NSArray arrayWithArray:fakeDataArray];
}



- (NSArray<NSArray <id>*> *) prepareDuplicates:(NSArray *)duplicatesList
{
    NSMutableArray<NSMutableArray <id>*> *duplicates = [NSMutableArray new];
    
    NSMutableArray<OAApplicationModeBean *> *profiles = [NSMutableArray new];
    NSMutableArray<OAQuickAction *> *actions = [NSMutableArray new];
    NSMutableArray<OAPOIUIFilter *> *filters = [NSMutableArray new];
    NSMutableArray<OASQLiteTileSource *> *tileSources = [NSMutableArray new]; //ITileSource ???
    NSMutableArray<NSString *> *renderFilesList = [NSMutableArray new];
    NSMutableArray<NSString *> *routingFilesList = [NSMutableArray new];
    NSMutableArray<OAAvoidRoadInfo *> *avoidRoads = [NSMutableArray new];
    
    for (id object in duplicatesList)
    {
        if ([object isKindOfClass:OAApplicationModeBean.class])
            [profiles addObject: (OAApplicationModeBean *)object];
        else if ([object isKindOfClass:OAQuickAction.class])
            [actions addObject: (OAQuickAction *)object];
        if ([object isKindOfClass:OAPOIUIFilter.class])
            [filters addObject: (OAPOIUIFilter *)object];
        else if ([object isKindOfClass:OASQLiteTileSource.class])
            [tileSources addObject: (OASQLiteTileSource *)object];
        else if ([object isKindOfClass:NSString.class])
        {
            NSString *file = (NSString *)object;
            if ([file containsString:RENDERERS_DIR])
                [renderFilesList addObject: file];
            if ([file containsString:ROUTING_PROFILES_DIR])
                [routingFilesList addObject: file];
        }
        else if ([object isKindOfClass:OAAvoidRoadInfo.class])
            [avoidRoads addObject: (OAAvoidRoadInfo *)object];
    }
    if (profiles.count > 0)
    {
        NSMutableArray *profilesSection = [NSMutableArray new];
        [profilesSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"shared_string_profiles")]];
        [profilesSection addObjectsFromArray:profiles];
        [duplicates addObject:profilesSection];
        
    }
    if (actions.count > 0)
    {
        NSMutableArray *actionsSection = [NSMutableArray new];
        [actionsSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"shared_string_quick_actions")]];
        [actionsSection addObjectsFromArray:actions];
        [duplicates addObject:actionsSection];
    }
    if (filters.count > 0)
    {
        NSMutableArray *filtersSection = [NSMutableArray new];
        [filtersSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"shared_string_poi_types")]];
        [filtersSection addObjectsFromArray:filters];
        [duplicates addObject:filtersSection];
    }
    if (tileSources.count > 0)
    {
        NSMutableArray *tileSourcesSection = [NSMutableArray new];
        [tileSourcesSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"quick_action_map_source_title")]];
        [tileSourcesSection addObjectsFromArray:tileSources];
        [duplicates addObject:tileSourcesSection];
    }
    if (routingFilesList.count > 0)
    {
        NSMutableArray *routingSection = [NSMutableArray new];
        [routingSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"shared_string_routing")]];
        [routingSection addObjectsFromArray:routingFilesList];
        [duplicates addObject:routingSection];
    }
    if (renderFilesList.count > 0)
    {
        NSMutableArray *renderSection = [NSMutableArray new];
        [renderSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"shared_string_rendering_style")]];
        [renderSection addObjectsFromArray:renderFilesList];
        [duplicates addObject:renderSection];
    }
    if (avoidRoads.count > 0)
    {
        NSMutableArray *avoidRoadsSection = [NSMutableArray new];
        [avoidRoadsSection addObject:[[HeaderType alloc] initWithLabel:OALocalizedString(@"avoid_road")]];
        [avoidRoadsSection addObjectsFromArray:avoidRoads];
        [duplicates addObject:avoidRoadsSection];
    }
    return duplicates;
}


// from DuplicatesSettingsAdapter.java : onBindViewHolder()
- (void) prepareData:(NSArray<NSArray <id>*> *)duplicates
{
    _data = [NSMutableArray new];
    for (NSArray *section in duplicates)
    {
        NSMutableArray *sectionData = [NSMutableArray new];
        for (id currentItem in section)
        {
            NSMutableDictionary *item = [NSMutableDictionary new];
            if ([currentItem isKindOfClass:HeaderType.class])
            {
                HeaderType *header = (HeaderType *)currentItem;
                item[@"label"] = header.label;
                item[@"description"] = [NSString stringWithFormat:OALocalizedString(@"listed_exist"), [header.label lowerCase]];
                item[@"cellType"] = kMenuSimpleCellNoIcon;
            }
            else if ([currentItem isKindOfClass:OAApplicationModeBean.class])
            {
                OAApplicationModeBean *modeBean = (OAApplicationModeBean *)currentItem;
                NSString *profileName = modeBean.userProfileName;
                if (!profileName || profileName.length == 0)
                {
                    OAApplicationMode* appMode = [OAApplicationMode valueOfStringKey:modeBean.stringKey def:nil];
                    profileName = appMode.name;
                }
                item[@"label"] = profileName;
                NSString *routingProfile = @"";
                NSString *routingProfileValue = modeBean.routingProfile;
                if (routingProfileValue && routingProfileValue.length > 0)
                {
                    try
                    {
                        routingProfile = [OARoutingProfileDataObject getLocalizedName: [OARoutingProfileDataObject getValueOf: [routingProfileValue upperCase]]];
                        routingProfile = [routingProfile capitalizedString];

                    } catch (NSException *e)
                    {
                        routingProfile = [routingProfileValue capitalizedString];
                        NSLog(@"Error trying to get routing resource for %@ \n %@ %@", routingProfileValue, e.name, e.reason);
                    }
                }
                if (!routingProfile || routingProfile.length == 0)
                    item[@"description"] = @"";
                else
                    item[@"description"] = [NSString stringWithFormat:OALocalizedString(@"ltr_or_rtl_combine_via_colon"), OALocalizedString(@"nav_type_hint"), routingProfile];
                
                item[@"icon"] = [UIImage imageNamed:modeBean.iconName];
                item[@"iconColor"] = UIColorFromRGB(modeBean.iconColor);
                item[@"cellType"] = kMenuSimpleCell;
            }
            else if ([currentItem isKindOfClass:OAQuickAction.class])
            {
                OAQuickAction *action = (OAQuickAction *)currentItem;
                item[@"label"] = [action getName];
                item[@"icon"] = [UIImage imageNamed:[action getIconResName]];
                item[@"description"] = @"";
                item[@"cellType"] = kTitleTwoIconsRoundCell;
            }
            else if ([currentItem isKindOfClass:OAPOIUIFilter.class])
            {
                OAPOIUIFilter *filter = (OAPOIUIFilter *)currentItem;
                item[@"label"] = [filter getName];
                NSString *iconRes = [filter getIconId];
                item[@"icon"] = [UIImage imageNamed: (![iconRes isEqualToString:@"0"] ? iconRes : @"ic_custom_user")]; // check this
                //item[@"icon"] = [UIImage imageNamed: @"ic_action_wheelchair_forward"]; // to remove
                item[@"description"] = @"";
                item[@"cellType"] = kTitleTwoIconsRoundCell;
            }
            else if ([currentItem isKindOfClass:OASQLiteTileSource.class]) //ITileSource ???
            {
                //item[@"label"] = ((OASQLiteTileSource *)currentItem).name; // ?? find how to extract name
                item[@"label"] = @"Faked name"; // ???
                item[@"icon"] = [UIImage imageNamed:@"ic_custom_map"];
                item[@"description"] = @"";
                item[@"cellType"] = kTitleTwoIconsRoundCell;
            }
            else if ([currentItem isKindOfClass:NSString.class])
            {
                NSString *file = (NSString *)currentItem;
                item[@"label"] = [[file lastPathComponent] stringByDeletingPathExtension];
                if ([file containsString:RENDERERS_DIR])
                    item[@"icon"] = [UIImage imageNamed:@"ic_custom_map_style"];
                else if ([file containsString:ROUTING_PROFILES_DIR])
                    item[@"icon"] = [UIImage imageNamed:@"ic_action_route_distance"];
                item[@"description"] = @"";
                item[@"cellType"] = kTitleTwoIconsRoundCell;
            }
            else if ([currentItem isKindOfClass:OAAvoidRoadInfo.class])
            {
                item[@"label"] = ((OAAvoidRoadInfo *)currentItem).name;
                item[@"icon"] = [UIImage imageNamed:@"ic_action_alert"];
                item[@"description"] = @"";
                item[@"cellType"] = kTitleTwoIconsRoundCell;
            }
            NSDictionary *newDict = [NSDictionary dictionaryWithDictionary:item];
            [sectionData addObject:newDict];
        }
        [_data addObject:sectionData];
    }
}

- (void) applyLocalization
{
    [self.backButton setTitle:OALocalizedString(@"shared_string_back") forState:UIControlStateNormal];
}

- (NSString *) getTableHeaderTitle
{
    return OALocalizedString(@"import_duplicates_title");
}

- (void) setupBottomViewMultyLabelButtons
{
    self.primaryBottomButton.hidden = NO;
    self.secondaryBottomButton.hidden = NO;
    
    [self setToButton: self.secondaryBottomButton firstLabelText:OALocalizedString(@"keep_both") firstLabelFont:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold] firstLabelColor:UIColorFromRGB(color_primary_purple) secondLabelText:OALocalizedString(@"keep_both_desc") secondLabelFont:[UIFont systemFontOfSize:13] secondLabelColor:UIColorFromRGB(color_icon_inactive)];
    
    [self setToButton: self.primaryBottomButton firstLabelText:OALocalizedString(@"replace_all") firstLabelFont:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold] firstLabelColor:[UIColor whiteColor] secondLabelText:OALocalizedString(@"replace_all_desc") secondLabelFont:[UIFont systemFontOfSize:13] secondLabelColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self generateHeaderForTableView:tableView withFirstSessionText:OALocalizedString(@"import_duplicates_description") forSection:section];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self generateHeightForHeaderWithFirstHeaderText:OALocalizedString(@"import_duplicates_description") inSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data[section].count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary *item = _data[indexPath.section][indexPath.row];
    NSString *type = item[@"cellType"];

    if ([type isEqualToString:kMenuSimpleCellNoIcon])
    {
        static NSString* const identifierCell = kMenuSimpleCellNoIcon;
        OAMenuSimpleCellNoIcon* cell;
        cell = (OAMenuSimpleCellNoIcon *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kMenuSimpleCellNoIcon owner:self options:nil];
            cell = (OAMenuSimpleCellNoIcon *)[nib objectAtIndex:0];
            cell.separatorInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
        }
        cell.descriptionView.hidden = NO;
        cell.textView.text = item[@"label"];
        cell.descriptionView.text = item[@"description"];
        return cell;
    }
    else if ([type isEqualToString:kMenuSimpleCell])
    {
        static NSString* const identifierCell = kMenuSimpleCell;
        OAMenuSimpleCell* cell;
        cell = (OAMenuSimpleCell *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kMenuSimpleCell owner:self options:nil];
            cell = (OAMenuSimpleCell *)[nib objectAtIndex:0];
            cell.separatorInset = UIEdgeInsetsMake(0.0, 62., 0.0, 0.0);
        }
        cell.textView.text = item[@"label"];
        
        if (!item[@"description"] || ((NSString *)item[@"description"]).length > 0)
        {
            cell.descriptionView.hidden = NO;
            cell.descriptionView.text = item[@"description"];
        }
        else
        {
            cell.descriptionView.hidden = YES;
        }

        cell.imgView.hidden = NO;
        if (item[@"icon"] && item[@"iconColor"])
        {
            cell.imgView.image = [item[@"icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imgView.tintColor = item[@"iconColor"];
        }
        else if (item[@"icon"])
        {
            cell.imgView.image = item[@"icon"];
        }
        return cell;
    }
    
    else if ([type isEqualToString:kTitleTwoIconsRoundCell])
    {
        static NSString* const identifierCell = kTitleTwoIconsRoundCell;
        OATitleTwoIconsRoundCell* cell;
        cell = (OATitleTwoIconsRoundCell *)[tableView dequeueReusableCellWithIdentifier:identifierCell];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kTitleTwoIconsRoundCell owner:self options:nil];
            cell = (OATitleTwoIconsRoundCell *)[nib objectAtIndex:0];
            cell.separatorInset = UIEdgeInsetsMake(0.0, 62., 0.0, 0.0);
        }
        cell.rightIconView.hidden = YES;
        cell.leftIconView.hidden = NO;
        cell.titleView.text = item[@"label"];
        
        cell.leftIconView.hidden = NO;
        if (item[@"icon"] && item[@"iconColor"])
        {
            cell.leftIconView.image = [item[@"icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.leftIconView.tintColor = item[@"iconColor"];
        }
        else if (item[@"icon"])
        {
            cell.leftIconView.image = item[@"icon"];
        }
        return cell;
    }
    else if ([type isEqualToString:kCellTypeWithActivity])
    {
        static NSString* const identifierCell = kCellTypeWithActivity;
        OAActivityViewWithTitleCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierCell];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifierCell owner:self options:nil];
            cell = (OAActivityViewWithTitleCell *)[nib objectAtIndex:0];
            cell.backgroundColor = UIColor.clearColor;
            cell.contentView.backgroundColor = UIColor.clearColor;
        }
        if (cell)
        {
            cell.titleView.text = item[@"label"];;
            cell.activityIndicatorView.hidden = NO;
            [cell.activityIndicatorView startAnimating];
        }
        return cell;
    }
    return nil;
}

- (void) importItems:(BOOL)shouldReplace
{
    [self setupImportingUI]; //for test
    
    if (_settingsItems && _file)
    {
        [self setupImportingUI];
        for (OASettingsItem *item in _settingsItems)
        {
            [item setShouldReplace:shouldReplace];
        }
        [_settingsHelper importSettings:_file items:_settingsItems latestChanges:@"" version:1 delegate:self];
    }
}

- (IBAction)primaryButtonPressed:(id)sender
{
    [self importItems: YES];
    
    //for test
    //OAImportCompleteViewController* importCompleteVC = [[OAImportCompleteViewController alloc] init];
//    OAImportCompleteViewController* importCompleteVC = [[OAImportCompleteViewController alloc] initWithSettingsItems:_settingsItems fileName:[_file lastPathComponent]];
//    [self.navigationController pushViewController:importCompleteVC animated:YES];
}

- (IBAction)secondaryButtonPressed:(id)sender
{
    [self importItems: NO];
}

#pragma mark - OASettingsImportExportDelegate

- (void)onSettingsImportFinished:(BOOL)succeed items:(nonnull NSArray<OASettingsItem *> *)items {
    if (succeed)
    {
        //app.getRendererRegistry().updateExternalRenderers();
        //AppInitializer.loadRoutingFiles(app, null);
        
        OAImportCompleteViewController* importCompleteVC = [[OAImportCompleteViewController alloc] initWithSettingsItems:items fileName:[_file lastPathComponent]];
        [self.navigationController pushViewController:importCompleteVC animated:YES];
    }
}

@end