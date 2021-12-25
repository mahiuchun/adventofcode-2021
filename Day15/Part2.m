#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))

int cave[1000][1000];

struct graph {
	int g[1000000][4];
	int c[1000000][4];
	int nb[1000000];
	int dist[1000000];
	BOOL known[1000000];
	int heap[1000000];
	int rheap[1000000];
	int heap_size;
} G;

BOOL valid(int r, int c, int row, int col) {
	if (r < 0 || r >= row) return NO;
	if (c < 0 || c >= col) return NO;
	return YES;
}

#define IDX(r,c) (1000*(r)+(c))
#define ROW(i) (i/1000)
#define COL(i) (i%1000)
#define PARENT(x) (((x)-1)/2)
#define LEFT(x) ((2*(x))+1)
#define RIGHT(x) ((2*(x))+2)

void min_heapify(int i) {
	int l = LEFT(i);
	int r = RIGHT(i);
	int smallest, t;
	if (l < G.heap_size && G.dist[G.heap[l]] < G.dist[G.heap[i]])
		smallest = l;
	else
		smallest = i;
	if (r < G.heap_size && G.dist[G.heap[r]] < G.dist[G.heap[smallest]])
		smallest = r;
	if (smallest != i) {
		G.rheap[G.heap[smallest]] = i;
		G.rheap[G.heap[i]] = smallest;
		t = G.heap[i];
		G.heap[i] = G.heap[smallest];
		G.heap[smallest] = t;
		min_heapify(smallest);
	}
}

int extract_min() {
	int min = G.heap[0];
	G.heap[0] = G.heap[G.heap_size-1];
	G.rheap[G.heap[G.heap_size-1]] = 0;
	G.heap_size -= 1;
	min_heapify(0);
	return min;
}

void decrease_key(int i) {
	int t;
	while (i > 0 && G.dist[G.heap[i]] < G.dist[G.heap[PARENT(i)]]) {
		G.rheap[G.heap[PARENT(i)]] = i;
		G.rheap[G.heap[i]] = PARENT(i);
		t = G.heap[i];
		G.heap[i] = G.heap[PARENT(i)];
		G.heap[PARENT(i)] = t;
		i = PARENT(i);
	}
}

@interface Day15: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day15)

@implementation Day15
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s;
	int row = 0, col;
	int i, j, ii, jj, r, c, k;
	int last, v, x;
	while ((s = [f readLine])) {
		col = [s length];
		for (i = 0; i < col; i++) {
			cave[row][i] = [s characterAtIndex:i] - '0';
		}
		row += 1;
	}
	[OFStdErr writeFormat:@"row:%d col:%d\n", row, col];
	for (ii = 0; ii < 5; ++ii) {
		for (jj = 0; jj < 5; ++jj) {
			if (ii == 0 && jj == 0) continue;
			for (i = 0; i < row; ++i) {
				for (j = 0; j < col; j++) {
					cave[ii*row+i][jj*col+j] = cave[i][j]+ii+jj;
				}
			}
		} 
	}
	row *= 5;
	col *= 5;	
	for (i = 0; i < row; ++i) {
		for (j = 0; j < col; j++) {
			if (cave[i][j] > 9) cave[i][j] -= 9;
		}
	}
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
	// Prepare heap	
	for (i = 0; i < row; i++) {
		for (j = 0; j < col; j++) {
			G.heap[G.heap_size] = IDX(i, j);
			G.rheap[IDX(i,j)] = G.heap_size;
			G.heap_size += 1;
			decrease_key(G.heap_size - 1);
		}
	}	
	last = IDX(0,0);
	while (last != IDX(row-1,col-1)) {
		v = extract_min();
		for (i = 0; i < G.nb[v]; ++i) {
			x = G.g[v][i];
			G.dist[x] = MIN(G.dist[x], G.dist[v] + G.c[v][i]);
			decrease_key(G.rheap[x]);
		}
		last = v;
		G.known[v] = YES;
	}
	[OFStdOut writeFormat:@"%d\n", G.dist[IDX(row-1,col-1)]];
	[OFApplication terminate];
}
@end
