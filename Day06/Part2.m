#import <ObjFW/ObjFW.h>

@interface Day6: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day6)

@implementation Day6
- (void)applicationDidFinishLaunching
{
	long long fishes[9] = {0};
	long long next[9];
	long long tot;
	int i, j;
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s = [f readLine];
	OFArray *a = [s componentsSeparatedByString:@","];
	for (i = 0; i < a.count; ++i) {
		fishes[[[a objectAtIndex:i] longLongValue]] += 1;
	}
	for (i = 1; i <= 256; ++i) {
		for (j = 0; j < 9; ++j) next[j] = 0;
		next[6] += fishes[0];
		next[8] += fishes[0];
		for (j = 1; j < 9; ++j) {
			next[j-1] += fishes[j];
		}
		tot = 0;
		for (j = 0; j < 9; ++j) tot += (fishes[j] = next[j]);
		[OFStdOut writeFormat:@"Day %d: %lld\n", i, tot];
	}
	[OFApplication terminate];
}
@end
