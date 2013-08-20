#import "./AMActiveData.h"

@implementation AMActiveData
@synthesize username;
@synthesize sessionKey;
@synthesize token;
@synthesize scrobblingEnabled;
@synthesize connected;
@synthesize playing;
@synthesize duration;
@synthesize startTime;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.username = [[NSString alloc] init];
        self.sessionKey = [[NSString alloc] init];
        self.token = [[NSString alloc] init];
        self.scrobblingEnabled = NO;
        self.connected = NO;
        self.playing = NO;
        self.duration = 0;
        self.startTime = 0;
        self.songData = [[AMSongData alloc] init];
    }
    return self;
}

-(BOOL)shouldScrobble
{
    if ([self playing] && [self scrobblingEnabled] && [self duration]/2 < [[NSDate date] timeIntervalSince1970] - [self startTime])
    {
        return YES;
    }
    return NO;
}

@end

@implementation AMSongData
@synthesize artist;
@synthesize albumArtist;
@synthesize album;
@synthesize track;
@synthesize trackNumber;
@synthesize timestamp;
@synthesize duration;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.artist = nil;
        self.albumArtist = nil;
        self.album = nil;
        self.track = nil;
        self.trackNumber = nil;
        self.timestamp = nil;
        self.duration = nil;
    }
    return self;
}

@end