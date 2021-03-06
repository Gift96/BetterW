#import "headers/WAStatusViewerViewController.h"
#import "headers/WAActionSheetPresenter.h"

#import "_Pr0_Utils.h"


%group GROUP_STATUS_DOWNLOADER

	%hook WAStatusViewerViewController

		-(void)addButtonsToActionSheet:(WAActionSheetPresenter *)actionSheet forIncomingStatusMessage:(id)arg2 {
			[actionSheet addButtonWithTitle:@"Save" image:nil useBoldText:NO handler:^(UIAlertAction * action) {
				[self pr0crustes_saveStatus];
            }];
			return %orig;
		}

		%new
		-(void)pr0crustes_saveStatus {
			NSString* mediaPath = [[[self currentStatusItem] message] mediaPath];
			if (mediaPath) {
				UIImage *image = [UIImage imageNamed:mediaPath];
				if (image) {  // Try save as image
					UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
				} else {  // Is video
					UISaveVideoAtPathToSavedPhotosAlbum(mediaPath, nil, nil, nil);
				}
			}
		}

	%end
	
%end



%ctor {

	if (F_prefGetBool(@"pref_status_downloader")) {
		F_logEnabling(@"Status Downloader");
		%init(GROUP_STATUS_DOWNLOADER);
	}

}
