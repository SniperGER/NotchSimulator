#import "NTDWhatsNewController.h"

@implementation NTDWhatsNewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setTitle:@"Notch'd – What's New"];
	
	UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
	self.navigationItem.rightBarButtonItem = rightButton;
	
	webView = [[WKWebView alloc] initWithFrame:CGRectZero];
	[webView setNavigationDelegate:self];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:///Library/PreferenceBundles/notchsimulator.bundle/WhatsNew/index.html"]]];
	
	[self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[webView setFrame:self.view.bounds];
}

- (void)dismiss {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
	[coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        [webView setFrame:self.view.bounds];
    } completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		if (navigationAction.request.URL) {
			[[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
			decisionHandler(WKNavigationActionPolicyCancel);
		} else {
			decisionHandler(WKNavigationActionPolicyAllow);
		}
	} else {
		decisionHandler(WKNavigationActionPolicyAllow);
	}
}

@end