//
//  OAIPFSImageCard.mm
//  OsmAnd
//
//  Created by Skalii on 06.07.2021.
//  Copyright (c) 2021 OsmAnd. All rights reserved.
//

#import "OAIPFSImageCard.h"
#import "OAWebViewController.h"
#import "OAMapPanelViewController.h"

@interface OAIPFSImageCard ()

@property (nonatomic) NSString *url;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *imageHiresUrl;
@property (nonatomic) NSString *topIcon;

@end

@implementation OAIPFSImageCard

@dynamic url, imageUrl, imageHiresUrl, topIcon;

- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super initWithData:data];
    if (self)
    {
        NSString *imageUrl = [NSString stringWithFormat:@"%@api/ipfs/image?cid=%@&hash=%@&ext=%@", OPR_BASE_URL, data[@"cid"], data[@"hash"], data[@"extension"]];
        self.url = imageUrl;
        self.imageHiresUrl = self.url;
        self.imageUrl = self.url;
        self.topIcon = @"ic_custom_logo_openplacereviews.png";
    }
    return self;
}

- (void)onCardPressed:(OAMapPanelViewController *) mapPanel
{
    NSString *cardUrl = [self getSuitableUrl];
    OAWebViewController *viewController = [[OAWebViewController alloc] initWithUrlAndTitle:cardUrl title:mapPanel.getCurrentTargetPoint.title];
    [mapPanel.navigationController pushViewController:viewController animated:YES];
}

@end
