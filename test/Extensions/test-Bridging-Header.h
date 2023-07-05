//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


#import "ImageUtility.h"
#import "acaLicenseFiles.h"
#import "AcapelaLicense.h"
#import "AcapelaSetup.h"
#import "AcapelaSpeech.h"
#import "acattsioslicense.h"

@interface NSObject (AcapelaSpeechDelegate)
- (void)speechSynthesizer:(AcapelaSpeech *)sender didFinishSpeaking:(BOOL)finishedSpeaking;
- (void)speechSynthesizer:(AcapelaSpeech *)sender didFinishSpeaking:(BOOL)finishedSpeaking textIndex:(int)index;
- (void)speechSynthesizer:(AcapelaSpeech *)sender willSpeakWord:(NSRange)characterRange ofString:(NSString *)string;
- (void)speechSynthesizer:(AcapelaSpeech *)sender willSpeakViseme:(short)visemeCode;
- (void)speechSynthesizer:(AcapelaSpeech *)sender didEncounterSyncMessage:(NSString *)errorMessage;
@end

