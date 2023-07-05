//
//  AcapelaSetup.m
//  TTSDemo
//
//  Acapela Group
//
//

#import "AcapelaSetup.h"

@implementation AcapelaSetup
@synthesize Voices;
@synthesize CurrentVoice;
@synthesize CurrentVoiceName;
@synthesize AutoMode;

- (NSString*)SetCurrentVoice:(NSUInteger)row
{
	CurrentVoice = Voices[row];
	NSDictionary *dic = [AcapelaSpeech attributesForVoice:CurrentVoice];
	CurrentVoiceName = [dic valueForKey:AcapelaVoiceName]; 
	return CurrentVoiceName;
}

@end
