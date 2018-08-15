#define DPKG_PATH "/var/lib/dpkg/info/ml.festival.notchsimulator.list"

@interface SBDashBoardProudLockViewController : UIViewController
- (void)_setIconVisible:(BOOL)arg1 animated:(BOOL)arg2;
- (void)_setIconState:(long long)arg1 animated:(BOOL)arg2;
@end

@interface SBUIProudLockIconView : UIView
@end

@interface SBDashBoardViewController : UIViewController {
	SBDashBoardProudLockViewController* _proudLockViewController;
}
@end

@interface SBDashBoardView : UIView {
	SBUIProudLockIconView* _proudLockIconView;
}
@end

@interface SBUILegibilityLabel : NSObject
- (void)setString:(id)arg1;
@end

@interface SBFLockScreenDateView : UIView {
	SBUILegibilityLabel* _timeLabel;
}
@end

@interface SBDashBoardPasscodeViewController : UIViewController {
	SBUIProudLockIconView* _proudLockIconViewToUpdate;
}
@end

@interface WGWidgetGroupViewController : UIViewController
@end

@interface NCNotificationListCollectionView : UICollectionView
@end
