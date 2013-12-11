//
//  ViewController.h
//  mYoutubeTestApp
//
//  Created by Kabkee Moon on 2013. 12. 8..
//  Copyright (c) 2013년 Kabkee Moon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLYouTube.h"

@class GTMOAuth2Authentication;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    int mNetworkActivityCounter;
}
@property (strong, nonatomic) IBOutlet UILabel *LbSignInID;
@property (strong, nonatomic) IBOutlet UITableView *videoTableView;

@property (strong, nonatomic) IBOutlet UIButton *btnSignInOut;
@property (strong, nonatomic) IBOutlet UIButton *btnFetchProfile;
@property GTMOAuth2Authentication *auth;
@property GTLYouTubeChannelContentDetailsRelatedPlaylists *_myPlaylists;
@property GTLYouTubePlaylistItemListResponse *_playlistItemList;

- (IBAction)getVideosClicked:(id)sender;

- (void)signInToGoogle;
- (void)signOut;
- (BOOL)isSignedIn;

- (void)updateUI;

- (void)fetchMyChannelList;
- (void)fetchSelectedPlaylist;

@end
