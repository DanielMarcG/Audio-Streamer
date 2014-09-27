//
//  TDMultipeerHostViewController.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

@import MediaPlayer;
@import MultipeerConnectivity;
@import AVFoundation;

#import "AudioProcessor.h"
#import "TDMultipeerHostViewController.h"
#import "TDAudioStreamer.h" //imports AudioOutputStreamer
#import "TDSession.h"

@interface TDMultipeerHostViewController () <MPMediaPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;

@property (strong, nonatomic) MPMediaItem *song;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDSession *session;
@property (strong, nonatomic) AudioProcessor *AudioProcessor;
@property (strong, nonatomic) AVPlayer *player;
@property (retain, nonatomic) IBOutlet UISwitch *micSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *talkSwitch;


@end

@implementation TDMultipeerHostViewController
@synthesize micSwitch, talkSwitch;
    NSMutableArray *songsList;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.session = [[TDSession alloc] initWithPeerDisplayName:@"Host"];
    
    //[self setMicSwitch:nil];
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];

    if (self.outputStreamer) return;

    self.song = mediaItemCollection.items[0];


    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"title"] = [self.song valueForProperty:MPMediaItemPropertyTitle] ? [self.song valueForProperty:MPMediaItemPropertyTitle] : @"";
    info[@"artist"] = [self.song valueForProperty:MPMediaItemPropertyArtist] ? [self.song valueForProperty:MPMediaItemPropertyArtist] : @"";

    MPMediaItemArtwork *artwork = [self.song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:self.albumImage.frame.size];
    if (image)
        info[@"artwork"] = image;

    if (info[@"artwork"])
        self.albumImage.image = info[@"artwork"];
    else
        self.albumImage.image = nil;

    self.songTitle.text = info[@"title"];
    self.songArtist.text = info[@"artist"];

    [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:[info copy]]];

    NSArray *peers = [self.session connectedPeers];

    if (peers.count) {
        
        
        // initializes the NSOutputStream, in this case naming it "music" (from OutputStreamForPeer)
        self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peers[0]]];
        [self.outputStreamer streamAudioFromURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL]];
        [self.outputStreamer start];
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Actions

- (IBAction)invite:(id)sender
{
    [self presentViewController:[self.session browserViewControllerForSeriviceType:@"dance-party"] animated:YES completion:nil];
}

- (IBAction)addSongs:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.showsCloudItems = true;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)micSwitch:(id)sender
{
        if (!micSwitch.on) {
            [self.AudioProcessor stop];
            NSLog(@"microphone audio unit stopped");
        } else {
            if (self.AudioProcessor == nil) {
                self.AudioProcessor = [[AudioProcessor alloc] init];
            }
           NSLog(@"Starting up microphone AudioUnit");
            [self.AudioProcessor start];
            NSLog(@"Microphone AudioUnit running");
        }
}


///////experiment songs



///////experiment song end



//MPMediaQuery *everything = [[MPMediaQuery alloc] init];
//[everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
//NSArray *itemsFromGenericQuery = [everything  items];
//songsList = [NSMutableArray arrayWithArray:itemsFromGenericQuery];


@end