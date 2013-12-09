//
//  ViewController.h
//  mYoutubeTestApp
//
//  Created by Kabkee Moon on 2013. 12. 8..
//  Copyright (c) 2013년 Kabkee Moon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTMOAuth2Authentication;

@interface ViewController : UIViewController{
    int mNetworkActivityCounter;
}

@property (strong, nonatomic) IBOutlet UIButton *btnSignInOut;
@property (strong, nonatomic) IBOutlet UIButton *btnFetchProfile;
@property GTMOAuth2Authentication *auth;

- (void)signInToGoogle;
- (void)signOut;
- (BOOL)isSignedIn;

- (void)updateUI;

@end
