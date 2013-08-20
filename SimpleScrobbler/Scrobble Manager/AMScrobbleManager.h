#import <Foundation/Foundation.h>
#import "../Persistent Data/AMPersistentData.h"
#import "../Active Data/AMActiveData.h"
#import <LastFMAPI/AMTrackRequest.h>
#import <LastFMAPI/AMAuthRequest.h>
#import <LastFMAPI/AMAlbumRequest.h>
#import "../Image Request/AMImageRequest.h"

@protocol AMScrobbleManagerDelegate <NSObject>
@optional
-(void)requestTokenValidation:(NSString *)Token APIKey:(NSString *)APIKey;
-(void)updateSongData:(AMSongData *)Data;
-(void)updateUsername:(NSString *)Username;
-(void)updateAlbumImage:(NSImage *)Image;
-(void)updateConnectionState:(BOOL)Connected;
-(void)updateScrobblingState:(BOOL)Scrobbling;
@end

@interface AMScrobbleManager : NSObject <AMTrackResponseDelegate, AMAuthResponseDelegate, AMAlbumResponseDelegate, AMImageRequestDelegate>
@property (nonatomic, retain) AMTrackRequest *trackRequest;
@property (nonatomic, retain) AMAuthRequest *authRequest;
@property (nonatomic, retain) AMAlbumRequest *albumRequest;
@property (nonatomic, retain) AMPersistentData *persistentData;
@property (nonatomic, retain) AMActiveData *activeData;
@property (nonatomic, assign) id <AMScrobbleManagerDelegate> scrobblerDelegate;
@property (nonatomic, retain) NSMutableArray *responseQueue;
@property (nonatomic, retain) AMTrackResponse *nowPlayingResponse;
@property (nonatomic, retain) AMAuthResponse *tokenResponse;
@property (nonatomic, retain) AMAuthResponse *sessionResponse;
@property (nonatomic, retain) AMAlbumResponse *albumInfoResponse;
@property (nonatomic, retain) AMImageRequest *albumImageRequest;

-(id)init;
-(id)initWithDelegate:(id <AMScrobbleManagerDelegate>)delegate;
-(void)addNotification:(NSDictionary *)information;
-(void)TrackResponse:(AMTrackResponse *)Response UpdateNowPlaying:(AMNowPlaying *)NowPlaying;
-(void)TrackResponse:(AMTrackResponse *)Response Scrobble:(AMScrobbles *)Scrobbles;
-(void)AuthResponse:(AMAuthResponse *)Response GetToken:(AMToken *)Token;
-(void)AuthResponse:(AMAuthResponse *)Response GetSession:(AMSession *)Session;
-(void)AlbumResponse:(AMAlbumResponse *)Response GetInfo:(AMAlbumWithInfo *)AlbumInfo;
-(void)Response:(AMBaseResponse *)Response Error:(NSError *)Error;
-(void)setScrobblingEnabled:(BOOL)Scrobbling;
-(BOOL)scrobblingEnabled;
-(void)imageResponseWithImage:(NSImage *)Image;
-(void)imageResponseWithError:(NSError *)Error;

@end