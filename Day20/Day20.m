#import <ObjFW/ObjFW.h>

typedef struct img {
  char data[200][200];
  int w;
  int h;
} Img;

Img img0, img1, img2;

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
    img0.w = [s length];
    for (i = 0; i < img0.w; i++) {
      img0.data[img0.h][i] = [s characterAtIndex:i]; 
    }
    img0.h += 1;
  }
  OFLog(@"w:%d,h:%d",img0.w, img0.h);
  enhance(&img0, &img1, e, 0);
  enhance(&img1, &img2, e, 1);
  for (i = 0; i < img2.h; i++) {
    for (j = 0; j < img2.w; j++) {
      if (img2.data[i][j] == '#') tot += 1;
    }
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
