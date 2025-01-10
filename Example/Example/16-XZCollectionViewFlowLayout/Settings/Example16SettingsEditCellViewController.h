//
//  Example16SettingsEditCellViewController.h
//  Example
//
//  Created by 徐臻 on 2024/6/5.
//

#import <UIKit/UIKit.h>
#import "Example16CollectonViewSectionModel.h"
#import "Example16CollectonViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Example16SettingsEditCellViewController : UITableViewController

@property (nonatomic) CGSize size;
@property (nonatomic) XZCollectionViewInteritemAlignment interitemAlignment;
@property (nonatomic, setter=setCustomized:) BOOL isCustomized;

@property (nonatomic) NSIndexPath *indexPath;

- (void)setDataWithModel:(Example16CollectonViewSectionModel *)model indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
