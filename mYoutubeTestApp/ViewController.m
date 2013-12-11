//
//  ViewController.m
//  mYoutubeTestApp
//
//  Created by Kabkee Moon on 2013. 12. 8..
//  Copyright (c) 2013년 Kabkee Moon. All rights reserved.
//

#import "ViewController.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"

#import "GTLUtilities.h"
#import "GTMHTTPUploadFetcher.h"
#import "GTMHTTPFetcherLogging.h"

enum {
    // Playlist pop-up menu item tags.
    kUploadsTag = 0,
    kLikesTag = 1,
    kFavoritesTag = 2,
    kWatchHistoryTag = 3,
    kWatchLaterTag = 4
};

static NSString *const kKeychainItemName = @"mYoutubeTestApp : youtube";
NSString *clientID = @"433777687178.apps.googleusercontent.com";
NSString *clientSecret = @"ZdlMSq6ZWY1GgQDvFnJpnHwN";


@interface ViewController ()
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;
- (void)doAnAuthenticatedAPIFetch;
- (void)displayAlertWithMessage:(NSString *)str;

- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)signInNetworkLostOrFound:(NSNotification *)notify;
//- (GTMOAuth2Authentication *)authForDailyMotion;
//- (BOOL)shouldSaveInKeychain;
//- (void)saveClientIDValues;
//- (void)loadClientIDValues;

@property (nonatomic, readonly) GTLServiceYouTube *youTubeService;

@end


@implementation ViewController
@synthesize auth;
@synthesize btnSignInOut;
@synthesize videoTableView;
@synthesize _myPlaylists;
@synthesize _playlistItemList;

static NSString *const kGoogleClientIDKey          = @"GoogleClientID";
static NSString *const kGoogleClientSecretKey      = @"GoogleClientSecret";
static NSString *const kGoogleProfileKey      = @"GoogleProfile";

//GTLYouTubeChannelContentDetailsRelatedPlaylists *_myPlaylists;
GTLServiceTicket *_channelListTicket;
NSError *_channelListFetchError;

//GTLYouTubePlaylistItemListResponse *_playlistItemList;
GTLServiceTicket *_playlistItemListTicket;
NSError *_playlistFetchError;

GTLServiceTicket *_uploadFileTicket;
NSURL *_uploadLocationURL;  // URL for restarting an upload.

NSDictionary *googleProfile = nil;

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)anAuth
                 error:(NSError *)error{
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
        self.auth = nil;
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //  [auth authorizeRequest:myNSURLMutableRequest
        //       completionHandler:^(NSError *error) {
        //         if (error == nil) {
        //           // request here has been authorized
        //         }
        //       }];
        //
        // or store the authentication object into a fetcher or a Google API service
        // object like
        //
        //   [fetcher setAuthorizer:auth];
        
        // save the authentication object
        self.auth = anAuth;
        self.youTubeService.authorizer = anAuth;

        googleProfile = viewController.signIn.userProfile;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:googleProfile forKey:kGoogleProfileKey];

    }
    
    [self updateUI];
}
- (void)doAnAuthenticatedAPIFetch {
//    NSString *urlStr;
//    urlStr = @"https://www.googleapis.com/plus/v1/people/me/activities/public";
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [self.auth authorizeRequest:request
//              completionHandler:^(NSError *error) {
//                  NSString *output = nil;
//                  if (error) {
//                      output = [error description];
//                  } else {
//                      // Synchronous fetches like this are a really bad idea in Cocoa applications
//                      //
//                      // For a very easy async alternative, we could use GTMHTTPFetcher
//                      NSURLResponse *response = nil;
//                      NSData *data = [NSURLConnection sendSynchronousRequest:request
//                                                           returningResponse:&response
//                                                                       error:&error];
//                      if (data) {
//                          // API fetch succeeded
//                          output = [[NSString alloc] initWithData:data
//                                                          encoding:NSUTF8StringEncoding];
//                      } else {
//                          // fetch failed
//                          output = [error description];
//                      }
//                  }
//                  
//                  [self displayAlertWithMessage:output];
//                  
//                  // the access token may have changed
//                  [self updateUI];
//              }];
    NSString *stringGoogleProfile = [NSString stringWithFormat:@"googleProfile : %@", googleProfile];
    [self displayAlertWithMessage: stringGoogleProfile];
}

- (void)displayAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mYoutubeTestApp"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

- (void)signInToGoogle{
   [self signOut];
    
    // For Google APIs, the scope strings are available
    // in the service constant header files.
//    NSString *scope = @"https://www.googleapis.com/auth/plus.me";
    
    // Typically, applications will hardcode the client ID and client secret
    // strings into the source code; they should not be user-editable or visible.
    //
    // But for this sample code, they are editable.
    
    // Note:
    // GTMOAuth2ViewControllerTouch is not designed to be reused. Make a new
    // one each time you are going to show it.
    
    // Display the autentication view.
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeYouTube
                                                              clientID:clientID
                                                          clientSecret:clientSecret
                                                      keychainItemName:kKeychainItemName
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    
    // You can set the title of the navigationItem of the controller here, if you
    // want.
    
    // If the keychainItemName is not nil, the user's authorization information
    // will be saved to the keychain. By default, it saves with accessibility
    // kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, but that may be
    // customized here. For example,
    //
    //   viewController.keychainItemAccessibility = kSecAttrAccessibleAlways;
    
    // During display of the sign-in window, loss and regain of network
    // connectivity will be reported with the notifications
    // kGTMOAuth2NetworkLost/kGTMOAuth2NetworkFound
    //
    // See the method signInNetworkLostOrFound: for an example of handling
    // the notification.
    
    // Optional: Google servers allow specification of the sign-in display
    // language as an additional "hl" parameter to the authorization URL,
    // using BCP 47 language codes.
    //
    // For this sample, we'll force English as the display language.
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                       forKey:@"hl"];
    viewController.signIn.additionalAuthorizationParameters = params;
    viewController.signIn.shouldFetchGoogleUserProfile = YES;
    
    // By default, the controller will fetch the user's email, but not the rest of
    // the user's profile.  The full profile can be requested from Google's server
    // by setting this property before sign-in:
    //
    //   viewController.signIn.shouldFetchGoogleUserProfile = YES;
    //
    // The profile will be available after sign-in as
    //
    //   NSDictionary *profile = viewController.signIn.userProfile;
    

    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=white><div align=center>Loading sign-in page...</div></body></html>";
    viewController.initialHTMLString = html;
    
    [[self navigationController] pushViewController:viewController animated:YES];
    
    // The view controller will be popped before signing in has completed, as
    // there are some additional fetches done by the sign-in controller.
    // The kGTMOAuth2UserSignedIn notification will be posted to indicate
    // that the view has been popped and those additional fetches have begun.
    // It may be useful to display a temporary UI when kGTMOAuth2UserSignedIn is
    // posted, just until the finished selector is invoked.
}
- (void)signOut{
    if ([self.auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kGoogleProfileKey];
    googleProfile = nil;
    
    // Discard our retained authentication object.
    self.auth = nil;
    
    [self updateUI];
}
- (BOOL)isSignedIn{
    BOOL isSignedIn = auth.canAuthorize;
    return isSignedIn;
}
- (IBAction)signInOutClicked:(id)sender {
    
    if (![self isSignedIn]) {
        // Sign in
        [self signInToGoogle];

    } else {
        // Sign out
        [self signOut];
    
    }
    [self updateUI];
}

- (IBAction)fetchClicked:(id)sender {
    // Just to prove we're signed in, we'll attempt an authenticated fetch for the
    // signed-in user
    [self doAnAuthenticatedAPIFetch];
}
- (IBAction)getVideosClicked:(id)sender{
    if ( self._myPlaylists == nil) {
        [self fetchMyChannelList];
    } else {
        [self fetchSelectedPlaylist];
    }
}

#pragma mark - Fetch Playlist

- (void)fetchMyChannelList {
    self._myPlaylists = nil;
    _channelListFetchError = nil;
    
//    NSLog(@"self.youTubeService : %@", self.youTubeService);
    GTLServiceYouTube *service = self.youTubeService;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForChannelsListWithPart:@"contentDetails"];
    query.mine = YES;
    
    // maxResults specifies the number of results per page.  Since we earlier
    // specified shouldFetchNextPages=YES, all results should be fetched,
    // though specifying a larger maxResults will reduce the number of fetches
    // needed to retrieve all pages.
    query.maxResults = 50;
    
    // We can specify the fields we want here to reduce the network
    // bandwidth and memory needed for the fetched collection.
    //
    // For example, leave query.fields as nil during development.
    // When ready to test and optimize your app, specify just the fields needed.
    // For example, this sample app might use
    //
    // query.fields = @"kind,etag,items(id,etag,kind,contentDetails)";
    
    _channelListTicket = [service executeQuery:query
                             completionHandler:^(GTLServiceTicket *ticket,
                                                 GTLYouTubeChannelListResponse *channelList,
                                                 NSError *error) {
                                 // Callback
                                 
                                 // The contentDetails of the response has the playlists available for
                                 // "my channel".
                                 if ([[channelList items] count] > 0) {
                                     GTLYouTubeChannel *channel = channelList[0];
                                     self._myPlaylists = channel.contentDetails.relatedPlaylists;
                                 }
                                 _channelListFetchError = error;
                                 _channelListTicket = nil;
                                 
                                 if (self._myPlaylists) {
                                     [self fetchSelectedPlaylist];
                                 }
//
//                                 [self fetchVideoCategories];
                             }];
    
    [self updateUI];
}

- (void)fetchSelectedPlaylist {
    NSString *playlistID = nil;
//    NSInteger tag = [_playlistPopup selectedTag];
    
    // Only UploadsTag used for test
    NSInteger tag = kUploadsTag;
    switch(tag) {
        case kUploadsTag:      playlistID = self._myPlaylists.uploads; break;
        case kLikesTag:        playlistID = _myPlaylists.likes; break;
        case kFavoritesTag:    playlistID = _myPlaylists.favorites; break;
        case kWatchHistoryTag: playlistID = _myPlaylists.watchHistory; break;
        case kWatchLaterTag:   playlistID = _myPlaylists.watchLater; break;
        default: NSAssert(0, @"Unexpected tag: %ld", (long)tag);
    }
    
    if ([playlistID length] > 0) {
        GTLServiceYouTube *service = self.youTubeService;
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForPlaylistItemsListWithPart:@"snippet,contentDetails"];
        query.playlistId = playlistID;
        query.maxResults = 50;
        
        _playlistItemListTicket = [service executeQuery:query
                                      completionHandler:^(GTLServiceTicket *ticket,
                                                          GTLYouTubePlaylistItemListResponse *playlistItemList,
                                                          NSError *error) {
                                          // Callback
                                          _playlistItemList = playlistItemList;
                                          _playlistFetchError = error;
                                          _playlistItemListTicket = nil;
                                          
                                          [self updateUI];
                                      }];
    }
    [self updateUI];
}


- (void)updateUI{
    // update the text showing the signed-in state and the button title
    // A real program would use NSLocalizedString() for strings shown to the user.
    if (_channelListFetchError) {
        NSString *errorMsg = [NSString stringWithFormat:@"fetchChannelList Error : %@",_channelListFetchError];
        [self displayAlertWithMessage:errorMsg];
    }
    if (_playlistFetchError) {
        NSString *errorMsg = [NSString stringWithFormat:@"fetcPlayList Error : %@",_playlistFetchError];
        [self displayAlertWithMessage:errorMsg];
    }
    [self.videoTableView reloadData];
    
    
    if ([self isSignedIn]) {
        // signed in
        [btnSignInOut setTitle:@"Sign Out" forState:UIControlStateNormal];
        self.LbSignInID.text = self.auth.userEmail;
        
    } else {
        // signed out
         [btnSignInOut setTitle:@"Sign In" forState:UIControlStateNormal];
        self.LbSignInID.text = @"Nothing Yet";
    }
    
    
}

#pragma mark - TableView delegate and data source methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateUI];
}

// Table view data source methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == videoTableView) {
        return [_playlistItemList.items count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    if (tableView == videoTableView) {
        GTLYouTubePlaylistItem *item = _playlistItemList[0];
        NSString *title = item.snippet.title;
        cell.textLabel.text = title;
    }
    
    return cell;
}


- (void)awakeFromNib
{
    // Listen for network change notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2WebViewStartedLoading object:nil];
    [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2WebViewStoppedLoading object:nil];
    [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2FetchStarted object:nil];
    [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2FetchStopped object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkLost  object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkFound object:nil];
    
    // First, we'll try to get the saved Google authentication, if any, from
    // the keychain
    
    // Normal applications will hardcode in their client ID and client secret,
    // but the sample app allows the user to enter them in a text field, and
    // saves them in the preferences

    GTMOAuth2Authentication *anAuth = nil;
    
    anAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                     clientID:clientID
                                                                 clientSecret:clientSecret];
    
    // Save the authentication object, which holds the auth tokens and
    // the scope string used to obtain the token.  For Google services,
    // the auth object also holds the user's email address.
    self.auth = anAuth;
    self.youTubeService.authorizer = anAuth;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    googleProfile = [defaults objectForKey:kGoogleProfileKey];
    
    
    [self updateUI];
    
    
    NSString *mSign = nil;
    if ([self isSignedIn]) {
        mSign = @"YES";
        
    }else{
        mSign = @"NO";
    }
    NSLog(@"isSignin : %@",mSign);

}

- (void)incrementNetworkActivity:(NSNotification *)notify {
    ++mNetworkActivityCounter;
    if (mNetworkActivityCounter == 1) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
    --mNetworkActivityCounter;
    if (mNetworkActivityCounter == 0) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)signInNetworkLostOrFound:(NSNotification *)notify {
    if ([[notify name] isEqual:kGTMOAuth2NetworkLost]) {
        // network connection was lost; alert the user, or dismiss
        // the sign-in view with
        //   [[[notify object] delegate] cancelSigningIn];
    } else {
        // network connection was found again
    }
}
- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!videoTableView) {
        videoTableView = [[UITableView alloc]init];
    }
    videoTableView.delegate = self;
    videoTableView.dataSource = self;
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
