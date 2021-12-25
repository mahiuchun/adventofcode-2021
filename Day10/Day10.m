#import <ObjFW/ObjFW.h>

@interface Day10: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day10)

@implementation Day10
- (void)applicationDidFinishLaunching
{
	int open[128] = {0};
	int close[128] = {0};
	int score[128] = {0};
	int i;
 	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	long long tot = 0;
	int c, top;
	OFMutableArray *stack = [OFMutableArray array];
	open['('] = open['['] = open['{'] = open['<'] = 1;
	close[')'] = '(';
	close[']'] = '[';
	close['}'] = '{';
	close['>'] = '<';
	score[')'] = 3;
	score[']'] = 57;
	score['}'] = 1197;
	score['>'] = 25137;
	
	while ((s = [f readLine])) {
		[stack removeAllObjects];
		for (i = 0; i < [s length]; ++i) {
			c = [s characterAtIndex:i];
			if (open[c] > 0) {
				[stack addObject:[OFNumber numberWithChar:c]];
			}
			if (close[c] > 0) {
				if ([stack lastObject] != nil) {
					top = [[stack lastObject] charValue];
					if (top != close[c]) {
						tot += score[c];
						break;
					}
					[stack removeLastObject];
				} else {
					break;
				}
			}
 		}
	}
	[OFStdOut writeFormat:@"%lld\n", tot];
	[OFApplication terminate];
}
@end
