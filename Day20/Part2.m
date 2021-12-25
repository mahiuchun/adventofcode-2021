#import <ObjFW/ObjFW.h>

#define N 50

typedef struct img {
  char data[400][400];
  int w;
  int h;
} Img;

Img imgs[N+1];

int pixel(const Img* im, int i, int j, int fill) {
  if (0 <= i && i < im->h && 0 <= j && j < im->w) {
    return (im->data[i][j] == '#');
  } else {
    return fill;
  }
}

void enhance(const Img *in, Img *out, OFString *e, int fill) {
  int i; int j, idx;
  out->w = in->w + 2;
  out->h = in->h + 2;
  for (i = 0; i< out->h; i++) {
    for (j = 0; j < out->w; j++) {
      idx = 0;
      idx += 256 * pixel(in, i-2, j-2, fill);
      idx += 128 * pixel(in, i-2, j-1, fill);
      idx += 64 * pixel(in, i-2, j, fill);
      idx += 32 * pixel(in, i-1, j-2, fill);
      idx += 16 * pixel(in, i-1, j-1, fill);
      idx += 8 * pixel(in, i-1, j, fill);
      idx += 4 * pixel(in, i, j-2, fill);
      idx += 2 * pixel(in, i, j-1, fill);
      idx += 1 * pixel(in, i, j, fill);
      out->data[i][j] = [e characterAtIndex:idx];
    }
  }
}

@interface Day20: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day20)

@implementation Day20
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s, *e = [f readLine];
  long long tot = 0;
  int i, j;
  if ([e length] != 512) {
    OFLog(@"error!");
  }
  if ([[f readLine] length] != 0) {
    OFLog(@"error!");
  }
  while ((s = [f readLine])) {
    imgs[0].w = [s length];
    for (i = 0; i < imgs[0].w; i++) {
      imgs[0].data[imgs[0].h][i] = [s characterAtIndex:i]; 
    }
    imgs[0].h += 1;
  }
  OFLog(@"w:%d,h:%d",imgs[0].w, imgs[0].h);
  for (int i = 1; i <= N; i++) {
    enhance(&imgs[i-1], &imgs[i], e, (i+1)%2);
  }
  for (i = 0; i < imgs[N].h; i++) {
    for (j = 0; j < imgs[N].w; j++) {
      if (imgs[N].data[i][j] == '#') tot += 1;
    }
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
