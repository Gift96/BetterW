#import "headers/WAChatSessionCell.h"
#import "headers/WAContactTableViewCell.h"
#import "headers/WAProfilePictureDynamicThumbnailView.h"
#import "headers/WAJID.h"

#import "_Pr0_Utils.h"


bool GLOBAL_AS_DOT = false;


// Function that creates a circular CAShapeLayer at desired pos, the dot indicator.
CAShapeLayer* pr0crustes_createDotIndicator(UIView* view, CGFloat pos) {
	CAShapeLayer* circle = [CAShapeLayer layer];
	circle.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(pos, pos, 10, 10)].CGPath;
	[view.layer addSublayer:circle];
	return circle;
}


CGColor* pr0crustes_indicatorColor(WAJID* jid) {
	NSString* stringJID = [jid stringRepresentation];
	if (FUNCTION_JIDIsGroup(stringJID)) {
		return [UIColor clearColor].CGColor;
	}
	NSLog(@"i4");
	if (FUNCTION_isJidOnline(stringJID)) {
		NSLog(@"i5");
		return [UIColor greenColor].CGColor;
	}
	return [UIColor redColor].CGColor;
}


void pr0crustes_whoIsOnline(WAJID* jid, UIImageView* imageView, CAShapeLayer* layer, CGFloat size) {
	if (GLOBAL_AS_DOT) {
		if (layer == nil) {
			layer = pr0crustes_createDotIndicator(imageView, size);
		}
		layer.fillColor = pr0crustes_indicatorColor(jid);
	} else {
		imageView.layer.borderColor = pr0crustes_indicatorColor(jid);
		imageView.layer.borderWidth = 2.0f;
	}
}


%group GROUP_WHO_IS_ONLINE

	%hook WAChatSessionCell

		%property (nonatomic, retain) CAShapeLayer* pr0crustes_circleLayer;

		-(void)layoutSubviews {
			%orig;
			NSLog(@"1");
			UIImageView* imageView = MSHookIvar<WAProfilePictureDynamicThumbnailView *>(self, "_imageViewContactPicture");
			NSLog(@"2");
			WAJID* jid = [[self chatSession] chatJID];
			NSLog(@"3");
			pr0crustes_whoIsOnline(jid, imageView, self.pr0crustes_circleLayer, 35);
			NSLog(@"4");
		}

	%end
	

	%hook WAContactTableViewCell

		%property (nonatomic, retain) CAShapeLayer* pr0crustes_circleLayer;

		-(void)layoutSubviews {
			%orig;
			NSLog(@"A");
			UIImageView* imageView = MSHookIvar<WAProfilePictureDynamicThumbnailView *>(self, "_imageViewContact");
			NSLog(@"B");
			WAJID* jid = [self profilePictureJID];
			NSLog(@"C");
			pr0crustes_whoIsOnline(jid, imageView, self.pr0crustes_circleLayer, 25);
			NSLog(@"D");
		}

	%end

%end



%ctor {

	if (FUNCTION_prefGetBool(@"pref_online")) {
		FUNCTION_logEnabling(@"Who Is Online");

		if (FUNCTION_prefGetBool(@"pref_as_dot")) {
			FUNCTION_logEnabling(@"... As Dot");
			GLOBAL_AS_DOT = true;
		}

		%init(GROUP_WHO_IS_ONLINE);
	}

}
