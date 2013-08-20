#import <Cocoa/Cocoa.h>
#import "./Scrobble Manager/AMScrobbleManager.h"

@interface SimpleScrobblerAppDelegate : NSObject <NSApplicationDelegate, AMScrobbleManagerDelegate>

#pragma mark Initialisation
-(id)init;
-(void)awakeFromNib;
-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;

#pragma mark AMScrobbleManagerDelegate implementations
-(void)requestTokenValidation:(NSString *)Token APIKey:(NSString *)APIKey;
-(void)updateSongData:(AMSongData *)songData;
-(void)updateConnectionState:(BOOL)Connected;
-(void)updateScrobblingState:(BOOL)Scrobbling;
-(void)updateUsername:(NSString *)Username;
-(void)updateAlbumImage:(NSImage *)Image;

#pragma mark NSDistributedNotificationCenter implementations
-(void)updateTrackInfo:(NSNotification *)notification;

#pragma mark IB Actions
-(IBAction)launchPrefsWindow:(id)sender;
-(IBAction)toggleScrobblingState:(NSMenuItem *)sender;
-(IBAction)setScrobblingEnabled;
-(IBAction)setScrobblingDisabled;

#pragma mark IB Outlets
@property (assign) IBOutlet NSWindow *mainWindow;
@property (assign) IBOutlet NSWindow *prefsWindow;

@property (assign) IBOutlet NSTextField *artistDesc;
@property (assign) IBOutlet NSTextField *titleDesc;
@property (assign) IBOutlet NSTextField *albumDesc;
@property (assign) IBOutlet NSTextField *usernameDesc;
@property (assign) IBOutlet NSImageView *albumArt;

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *IBScrobblingState;
@property (assign) IBOutlet NSMenuItem *IBConnectedState;

#pragma mark Other Properties
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) AMScrobbleManager *scrobbler;
@property (nonatomic, retain) NSDistributedNotificationCenter *distNotificationCenter;
@property (nonatomic, retain) NSUserNotificationCenter *userNotificationCenter;

@end