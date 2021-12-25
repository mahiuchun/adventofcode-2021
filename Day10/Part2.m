#import <ObjFW/ObjFW.h>

@interface Day10: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day10)

@implementation Day10
- (void)applicationDidFinishLaunching
{
	int open[128] = {0};
	int close[128] = {0};
	int point[128] = {0};
	int i;
 	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	int c, top;
	long long score;
	OFMutableArray *stack = [OFMutableArray array];
	OFMutableArray *scores = [OFMutableArray array];
	open['('] = ')';
	open['['] = ']';
	open['{'] = '}';
	open['<'] = '>';
	close[')'] = '(';
	close[']'] = '[';
	close['}'] = '{';
	close['>'] = '<';
	point[')'] = 1;
	point[']'] = 2;
	point['}'] = 3;
	point['>'] = 4;
	
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
						break;
					}
					[stack removeLastObject];
				} else {
					break;
				}
			}
 		}
		if (i != [s length]) continue;
		score = 0;
		while ([stack lastObject]) {
			top = [[stack lastObject] charValue];
			score = 5 * score + point[open[top]];
			[stack removeLastObject];
		}
		if (score > 0) {
			[scores addObject:[OFNumber numberWithLongLong:score]];
			[OFStdErr writeFormat:@"Got score: %lld\n", score];
		}
	}
	[scores sort];
	[OFStdOut writeFormat:@"%lld\n", [[scores objectAtIndex:scores.count/2] longLongValue]];
	[OFApplication terminate];
}
@end
