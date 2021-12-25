#import <ObjFW/ObjFW.h>

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

int space(int x) {
	x = x % 10;
	return x == 0 ? 10 : x;
}

int next(int roll) {
	if (roll < 100)
		return roll + 1;
	else {
		return 1;
	}
}

@interface Day21: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day21)

@implementation Day21
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	int n_player = 0;
	int player;
	int players[2] = {0};
	long long scores[2] = {0};
	long long times;
	int roll, i;
	int three;
	while ((s = [f readLine])) {
		players[n_player] = (int)[[s substringFromIndex:28] longLongValue];
		n_player++;
	}
	player = 0;
	roll = 1;
	for (times = 3; ; times += 3) {
		three = 0;
		for (i = 0; i < 3; i++) {
			three += roll;
			roll = next(roll);
		}
		scores[player] += (players[player] = space(players[player] + three));
		if (scores[0] >= 1000 || scores[1] >= 1000) break;
		player = 1 - player;
	}
	[OFStdOut writeFormat:@"%lld\n", times * MIN(scores[0], scores[1])];
	[OFApplication terminate];
}
@end
