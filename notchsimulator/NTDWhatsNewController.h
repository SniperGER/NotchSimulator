#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface NTDWhatsNewController : UIViewController <WKNavigationDelegate> {
	WKWebView* webView;
}

@end