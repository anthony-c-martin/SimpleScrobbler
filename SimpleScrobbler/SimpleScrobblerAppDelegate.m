#import "./SimpleScrobblerAppDelegate.h"

NSString *const API_TOKEN_REQUEST_URL = @"http://www.last.fm/api/auth/";

@implementation SimpleScrobblerAppDelegate
@synthesize scrobbler;
@synthesize distNotificationCenter;
@synthesize artistDesc;
@synthesize albumDesc;
@synthesize titleDesc;
@synthesize usernameDesc;
@synthesize albumArt;
@synthesize IBScrobblingState;

#pragma mark Initialisation
-(id)init
{
    self = [super init];
    if (self)
    {
        [self setScrobbler:[[AMScrobbleManager alloc] initWithDelegate:self]];
        [self setDistNotificationCenter:[NSDistributedNotificationCenter defaultCenter]];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]];
    [[self statusItem] setMenu:[self statusMenu]];
    [[self statusItem] setTitle:@"as"];
    [[self statusItem] setHighlightMode:YES];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [distNotificationCenter addObserver:self
                           selector:@selector(updateTrackInfo:)
                               name:@"com.apple.iTunes.playerInfo"
                             object:nil];
    [self updateScrobblingState:[[scrobbler activeData] scrobblingEnabled]];
    [[self mainWindow] makeKeyAndOrderFront:nil];
}

#pragma mark AMScrobbleManagerDelegate implementations
-(void)requestTokenValidation:(NSString *)Token APIKey:(NSString *)APIKey
{
    NSString *validationURL = [NSString stringWithFormat:@"%@?api_key=%@&token=%@",
                               API_TOKEN_REQUEST_URL, APIKey, Token];

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:validationURL]];
}

-(void)updateSongData:(AMSongData *)songData
{
    [[self titleDesc] setStringValue:[songData track]];
    [[self artistDesc] setStringValue:[songData artist]];
    [[self albumDesc] setStringValue:[songData album]];
}

-(void)updateConnectionState:(BOOL)Connected
{
    [[self IBScrobblingState] setState:(Connected ? NSOnState : NSOffState)];
}

-(void)updateScrobblingState:(BOOL)Scrobbling
{
    [[self IBScrobblingState] setState:(Scrobbling ? NSOnState : NSOffState)];
}

-(void)updateUsername:(NSString *)Username
{
    [[self usernameDesc] setStringValue:Username];
}

-(void)updateAlbumImage:(NSImage *)Image
{
    [Image setSize:NSMakeSize(200, 200)];
    [[self albumArt] setImage:Image];
}

#pragma mark NSDistributedNotificationCenter implementations
-(void)updateTrackInfo:(NSNotification *)notification
{
    NSDictionary *notificationInfo = [NSDictionary dictionaryWithDictionary: [notification userInfo]];
    [scrobbler addNotification:notificationInfo];
}

#pragma mark NSUserNotificationCenter implementations
-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark IB Actions
-(IBAction)launchPrefsWindow:(id)sender
{
    [[self prefsWindow] makeKeyAndOrderFront:nil];
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps)];
}

-(IBAction)toggleScrobblingState:(NSMenuItem *)sender
{
    if ([[self scrobbler] scrobblingEnabled])
    {
        [[self scrobbler] setScrobblingEnabled:NO];
    }
    else
    {
        [[self scrobbler] setScrobblingEnabled:YES];
    }
}

-(IBAction)setScrobblingEnabled
{
    [[self scrobbler] setScrobblingEnabled:YES];
}

-(IBAction)setScrobblingDisabled
{
    [[self scrobbler] setScrobblingEnabled:NO];
}

@end