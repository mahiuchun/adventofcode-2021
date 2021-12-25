#import <ObjFW/ObjFW.h>

@interface Day2: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day2)

@implementation Day2
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s = [f readLine];
	long long horizontal = 0, depth = 0, aim = 0;
	while (s != nil) {
		OFArray *a = [s componentsSeparatedByString:@" "];
		OFString *command = [a objectAtIndex:0];
		long long value = [[a objectAtIndex:1] longLongValue];
		if ([command compare:@"forward"] == OFOrderedSame) {
			horizontal += value;
			depth += aim * value;
		}
		if ([command compare:@"down"] == OFOrderedSame) {
			aim += value;
		}
		if ([command compare:@"up"] == OFOrderedSame) {
			aim -= value;
		}
		s = [f readLine];
	}
	long long result = horizontal * depth;
	[OFStdOut writeFormat:@"%lld\n", result];
	[OFApplication terminate];
}
@end
