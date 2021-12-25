#import <ObjFW/ObjFW.h>

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

int space(int x) {
	x = x % 10;
	return x == 0 ? 10 : x;
}

int fwd[10];
long long dp[11][11][50][50][2];

long long rec_with_memo(int p1, int p2, int s1, int s2, int turn) {
	long long res;
	int i, p1_, p2_;
	if (dp[p1][p2][s1][s2][turn] >= 0) {
		return dp[p1][p2][s1][s2][turn];
	}
	res = 0;
	if (p1 > s1 && p2 > s2) {
		;
	} else if (turn == 0) {
		for (i = 1; i <= 9; i++) {
			p2_ = space(p2 + 10 - i);
			if (p2 <= s2) {
				res += fwd[i] * rec_with_memo(p1, p2_, s1, s2-p2, 1);
			}
		}
	} else if (turn == 1) {
		for (i = 1; i <= 9; i++) {
			p1_ = space(p1 + 10 - i);
			if (p1 <= s1) {
				res += fwd[i] * rec_with_memo(p1_, p2, s1-p1, s2, 0);
			}
		}
	}
	
	
	return (dp[p1][p2][s1][s2][turn] = res);
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
	int players[2] = {0};
	int p1, p2, s1, s2, turn;
	int i, j, k;
	long long w[2] = {0};
	while ((s = [f readLine])) {
		players[n_player] = (int)[[s substringFromIndex:28] longLongValue];
		n_player++;
	}
	for (i = 1; i <= 3; i++) {
		for (j = 1; j <= 3; j++) {
			for (k = 1; k <= 3; k++) {
				fwd[i+j+k] += 1;
			}
		}
	}
	for (p1 = 1; p1 <= 10; p1++) {
		for (p2 = 1; p2 <= 10; p2++) {
			for (s1 = 0; s1 < 50; s1++) {
				for (s2 = 0; s2 < 50; s2++) {
					for (turn = 0; turn <= 1; turn++) {
						dp[p1][p2][s1][s2][turn] = -1;
					}
				}
			}
		}
	}
	dp[players[0]][players[1]][0][0][0] = 1;
	for (p1 = 1; p1 <= 10; p1++) {
		for (p2 = 1; p2 <= 10; p2++) {
			for (s1 = 21; s1 <= 30; s1++) {
				for (s2 = 0; s2 <= 20; s2++) {
					if (s1 - p1 <= 20)
						w[0] += rec_with_memo(p1, p2, s1, s2, 1);
				}
			}
			for (s1 = 0; s1 <= 20; s1++) {
				for (s2 = 21; s2 <= 30; s2++) {
					if (s2 - p2 <= 20)
						w[1] += rec_with_memo(p1, p2, s1, s2, 0);
				}
			}
		}
	}
	[OFStdOut writeFormat:@"%lld\n", MAX(w[0], w[1])];
	[OFApplication terminate];
}
@end
