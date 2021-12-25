#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))

int cave[100][100];

struct graph {
	int g[10000][4];
	int c[10000][4];
	int nb[10000];
	int dist[10000];
	BOOL known[10000];
} G;

BOOL valid(int r, int c, int row, int col) {
	if (r < 0 || r >= row) return NO;
	if (c < 0 || c >= col) return NO;
	return YES;
}

#define IDX(r,c) (100*(r)+(c))
#define ROW(i) (i/100)
#define COL(i) (i%100)

@interface Day15: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day15)

@implementation Day15
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	int row = 0, col;
	int i, j, r, c, k;
	int last, v, x, best;
	while ((s = [f readLine])) {
		col = [s length];
		for (i = 0; i < col; i++) {
			cave[row][i] = [s characterAtIndex:i] - '0';
		}
		row += 1;
	}
	[OFStdErr writeFormat:@"row:%d col:%d\n", row, col];
	for (i = 0; i < row; ++i) {
		for (j = 0; j < col; j++) {
			r = i-1; c = j;
			if (valid(r, c, row, col)) {
				k = G.nb[IDX(i, j)]++;
				G.g[IDX(i,j)][k] = IDX(r, c);
				G.c[IDX(i,j)][k] = cave[r][c];
			}
			r = i+1; c = j;
			if (valid(r, c, row, col)) {
				k = G.nb[IDX(i, j)]++;
				G.g[IDX(i,j)][k] = IDX(r, c);
				G.c[IDX(i,j)][k] = cave[r][c];

			}
			r = i; c = j-1;
			if (valid(r, c, row, col)) {
				k = G.nb[IDX(i, j)]++;
				G.g[IDX(i,j)][k] = IDX(r, c);
				G.c[IDX(i,j)][k] = cave[r][c];
			}
			r = i; c = j+1;
			if (valid(r, c, row, col)) {
				k = G.nb[IDX(i, j)]++;
				G.g[IDX(i,j)][k] = IDX(r, c);
				G.c[IDX(i,j)][k] = cave[r][c];
			}
			// [OFStdErr writeFormat:@"nb:%d\n", G.nb[IDX(i,j)]];
		}
	}
	// Dijkstra
	for (i = 0; i < row; i++) {
		for (j = 0; j < col; j++) {
			G.dist[IDX(i,j)] = 987654321;
			G.known[IDX(i,j)] = NO;
		}
	}
	G.dist[IDX(0,0)] = 0;
	G.known[IDX(0,0)] = YES;
	for (i = 0; i < G.nb[IDX(0,0)]; ++i) {
		v = G.g[IDX(0,0)][i];
		[OFStdErr writeFormat:@"v:%d\n", v];
		G.dist[v] = G.c[IDX(0,0)][i];
	}
	last = IDX(0,0);
	while (last != IDX(row-1,col-1)) {
		best = 987654321;
		for (i = 0; i < row; ++i) {
			for (j = 0; j < col; ++j) {
				x = IDX(i, j);
				if (!G.known[x] && G.dist[x] <= best) {
					v = x;
					best = G.dist[x];
				}
			}
		}
		// [OFStdErr writeFormat:@"best:%d\n", best];
		for (i = 0; i < G.nb[v]; ++i) {
			x = G.g[v][i];
			G.dist[x] = MIN(G.dist[x], G.dist[v] + G.c[v][i]);
		}
		last = v;
		G.known[v] = YES;
	}
	[OFStdOut writeFormat:@"%d\n", G.dist[IDX(row-1,col-1)]];
	[OFApplication terminate];
}
@end
