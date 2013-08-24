#import "./AMScrobbleManager.h"
#import <LastFMAPI/AMDefinitions.h>
#import "../Supporting Files/Secrets.h"

NSString *const PERSISTENTDATA_DATA_AUTHTOKEN = @"AuthToken";
NSString *const PERSISTENTDATA_DATA_SESSION = @"SessionKey";
NSString *const PERSISTENTDATA_DATA_USERNAME = @"UserName";
NSString *const PERSISTENTDATA_DATA_SCROBBLINGSTATE = @"ScrobblingEnabled";

@implementation AMScrobbleManager

@synthesize trackRequest;
@synthesize authRequest;
@synthesize albumRequest;
@synthesize persistentData;
@synthesize activeData;
@synthesize scrobblerDelegate;
@synthesize responseQueue;
@synthesize nowPlayingResponse;
@synthesize tokenResponse;
@synthesize sessionResponse;
@synthesize albumInfoResponse;
@synthesize albumImageRequest;

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setTrackRequest:[[AMTrackRequest alloc] initWithURL:AM_API_URL Key:AM_API_KEY Secret:AM_API_SECRET]];
        [self setAuthRequest:[[AMAuthRequest alloc] initWithURL:AM_API_URL Key:AM_API_KEY Secret:AM_API_SECRET]];
        [self setAlbumRequest:[[AMAlbumRequest alloc] initWithURL:AM_API_URL Key:AM_API_KEY Secret:AM_API_SECRET]];
        [self setPersistentData:[[AMPersistentData alloc] init]];
        [self setActiveData:[[AMActiveData alloc] init]];
        [[self activeData] setSessionKey:[persistentData getStringWithKey:PERSISTENTDATA_DATA_SESSION]];
        [[self activeData] setToken:[persistentData getStringWithKey:PERSISTENTDATA_DATA_AUTHTOKEN]];
        [[self activeData] setUsername:[persistentData getStringWithKey:PERSISTENTDATA_DATA_USERNAME]];
        [[self activeData] setScrobblingEnabled:[persistentData getBoolWithKey:PERSISTENTDATA_DATA_SCROBBLINGSTATE]];
        [self setResponseQueue:[[NSMutableArray alloc] init]];
        [self setNowPlayingResponse:nil];
        [self setTokenResponse:nil];
        [self setSessionResponse:nil];
        [self setAlbumInfoResponse:nil];
        [self setAlbumImageRequest:nil];
    }
    return self;
}

-(id)initWithDelegate:(id <AMScrobbleManagerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        [self setScrobblerDelegate:delegate];
    }
    return self;
}

-(void)addNotification:(NSDictionary *)information
{    
    if ([[self activeData] shouldScrobble])
    {
        [[self activeData] setPlaying:NO];
        AMTrackResponse *response = [[AMTrackResponse alloc] initWithDelegate:self];
        [trackRequest Scrobble:response
                        Artist:[[[self activeData] songData] artist]
                         Track:[[[self activeData] songData] track]
                     Timestamp:[[[self activeData] songData] timestamp]
                         Album:[[[self activeData] songData] album]
                       Context:nil
                      StreamId:nil
                  ChosenByUser:nil
                   TrackNumber:[[[self activeData] songData] trackNumber]
                          MBID:nil
                   AlbumArtist:[[[self activeData] songData] albumArtist]
                      Duration:[[[self activeData] songData] duration]
                    SessionKey:[[self activeData] sessionKey]];
        [[self responseQueue] addObject:response];
    }
    
    if ([[information valueForKey:@"Player State"] isEqualToString:@"Playing"])
    {
        if (!([[information valueForKey:@"Album"] isEqualToString:[[[self activeData] songData] album]]
            && [[information valueForKey:@"Artist"] isEqualToString:[[[self activeData] songData] artist]]))
        {
            [self setAlbumInfoResponse:[[AMAlbumResponse alloc] initWithDelegate:self]];
            [[self albumRequest] GetInfo:[self albumInfoResponse]
                                  Artist:[information valueForKey:@"Artist"]
                                   Album:[information valueForKey:@"Album"]
                                    MBID:nil
                             Autocorrect:nil
                                Username:[[self activeData] username]
                                    Lang:nil];
        }
        
        [[self activeData] setStartTime:[[NSDate date] timeIntervalSince1970]];
        [[self activeData] setDuration:[[information valueForKey:@"Total Time"] intValue] / 1000];
        
        [[self activeData] setSongData:[[AMSongData alloc] init]];
        [[[self activeData] songData] setArtist:[information valueForKey:@"Artist"]];
        [[[self activeData] songData] setAlbum:[information valueForKey:@"Album"]];
        [[[self activeData] songData] setTrack:[information valueForKey:@"Name"]];
        [[[self activeData] songData] setTrackNumber:[NSNumber numberWithInt:[[information valueForKey:@"Track Number"] intValue]]];
        [[[self activeData] songData] setTimestamp:[NSNumber numberWithInt:[[self activeData] startTime]]];
        [[[self activeData] songData] setDuration:[NSNumber numberWithInt:[[self activeData] duration]]];
        if ([[information valueForKey:@"Album Artist"] isEqualToString:[information valueForKey:@"Artist"]])
        {
            [[[self activeData] songData] setAlbumArtist:[information valueForKey:@"Album Artist"]];
        }

        [[self activeData] setPlaying:YES];
        
        if ([[self scrobblerDelegate] respondsToSelector:@selector(updateSongData:)])
        {
            [[self scrobblerDelegate] updateSongData:[[self activeData] songData]];
        }
        if ([[self activeData] scrobblingEnabled])
        {
            if ([self nowPlayingResponse])
            {
                [self setNowPlayingResponse:nil];
            }
            [self setNowPlayingResponse:[[AMTrackResponse alloc] initWithDelegate:self]];
            [trackRequest UpdateNowPlaying:[self nowPlayingResponse]
                                    Artist:[[[self activeData] songData] artist]
                                     Track:[[[self activeData] songData] track]
                                     Album:[[[self activeData] songData] album]
                               TrackNumber:[[[self activeData] songData] trackNumber]
                                   Context:nil
                                      MBID:nil
                                  Duration:[[[self activeData] songData] duration]
                               AlbumArtist:[[[self activeData] songData] albumArtist]
                                SessionKey:[[self activeData] sessionKey]];
        }
    }
}

-(void)RequestNewToken
{
    [self setTokenResponse:[[AMAuthResponse alloc] initWithDelegate:self]];
    [[self authRequest] GetToken:[self tokenResponse]];
}

-(void)RequestNewSession
{
    [self setSessionResponse:[[AMAuthResponse alloc] initWithDelegate:self]];
    [[self authRequest] GetSession:[self sessionResponse]
                             Token:[[self activeData] token]];
}

-(void)TrackResponse:(AMTrackResponse *)Response Scrobble:(AMScrobbles *)Scrobbles
{
    [[self responseQueue] removeObject:Response];
}

-(void)TrackResponse:(AMTrackResponse *)Response UpdateNowPlaying:(AMNowPlaying *)NowPlaying
{
    if ([self nowPlayingResponse] == Response)
    {
        [self setNowPlayingResponse:nil];
    }
}

-(void)AuthResponse:(AMAuthResponse *)Response GetToken:(AMToken *)Token
{
    if ([Token Token])
    {
        [[self activeData] setToken:[Token Token]];
        [[self persistentData] setString:[Token Token] WithKey:PERSISTENTDATA_DATA_AUTHTOKEN];
        if ([[self scrobblerDelegate] respondsToSelector:@selector(requestTokenValidation:APIKey:)])
        {
            [[self scrobblerDelegate] requestTokenValidation:[Token Token] APIKey:AM_API_KEY];
        }
    }
    [self setTokenResponse:nil];
}

-(void)AuthResponse:(AMAuthResponse *)Response GetSession:(AMSession *)Session
{
    if ([Session Key] && [Session Name])
    {
        [[self activeData] setSessionKey:[Session Key]];
        [[self persistentData] setString:[Session Key] WithKey:PERSISTENTDATA_DATA_SESSION];
        [[self activeData] setUsername:[Session Name]];
        [[self persistentData] setString:[Session Name] WithKey:PERSISTENTDATA_DATA_USERNAME];
    }
    [self setSessionResponse:nil];
}

-(void)AlbumResponse:(AMAlbumResponse *)Response GetInfo:(AMAlbumWithInfo *)AlbumInfo
{
    if ([self albumInfoResponse] == Response)
    {
        if ([[AlbumInfo Images] Large])
        {
            [self setAlbumImageRequest:nil];
            AMImageRequest *imageRequest = [[AMImageRequest alloc] initWithDelegate:self];
            if ([imageRequest initiateReqest:[NSURL URLWithString:[[AlbumInfo Images] Large]]])
            {
                [self setAlbumImageRequest:imageRequest];
            }
        }
        [self setAlbumInfoResponse:nil];
    }
}

-(void)Response:(AMBaseResponse *)Response Error:(NSError *)Error
{
    if ([Error domain] == AM_ERRDOMAIN_LASTFMAPI)
    {
        NSLog(@"%@", Error);
        
        if ([Response Method] == AM_MTHD_AUTH_GETSESSION
            || [Response Method] == AM_MTHD_AUTH_GETTOKEN)
        {
            if ([Error code] == AM_ERR_AUTHENTICATION_FAILED
                || [Error code] == AM_ERR_UNAUTHORISED_TOKEN)
            {
                [[self activeData] setToken:nil];
                [self RequestNewToken];
                return;
            }
        }
        else
        {
            if ([Error code] == AM_ERR_SERVICE_OFFLINE
                || [Error code] == AM_ERR_SERVICE_TEMPORARILY_UNAVAILABLE
                || [Error code] == AM_ERR_OPERATION_FAILED
                || [Error code] == AM_ERR_INVALID_METHOD_SIGNATURE)
            {
                return;
            }
            else if ([Error code] == AM_ERR_INVALID_SESSION_KEY)
            {
                [[self activeData] setSessionKey:nil];
                [self RequestNewSession];
                return;
            }
            else
            {
                if ([Response Method] == AM_MTHD_TRACK_SCROBBLE)
                {
                    [[self responseQueue] removeObject:Response];
                }
                else if ([Response Method] == AM_MTHD_TRACK_UPDATENOWPLAYING)
                {
                    if ([self nowPlayingResponse] == Response)
                    {
                        [self setNowPlayingResponse:nil];
                    }
                }
                return;
            }
        }
    }
}

-(void)setScrobblingEnabled:(BOOL)Scrobbling
{
    [[self activeData] setScrobblingEnabled:Scrobbling];
    [[self persistentData] setBool:Scrobbling WithKey:PERSISTENTDATA_DATA_SCROBBLINGSTATE];
    if ([[self scrobblerDelegate] respondsToSelector:@selector(updateScrobblingState:)])
    {
        [[self scrobblerDelegate] updateScrobblingState:Scrobbling];
    }
}

-(BOOL)scrobblingEnabled
{
    return [[self activeData] scrobblingEnabled];
}

-(void)imageResponseWithImage:(NSImage *)Image
{
    if ([[self scrobblerDelegate] respondsToSelector:@selector(updateAlbumImage:)])
    {
        [[self scrobblerDelegate] updateAlbumImage:Image];
    }
}

-(void)imageResponseWithError:(NSError *)Error
{
    NSLog(@"%@", Error);
}

@end