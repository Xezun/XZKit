//
//  Example04ViewController.m
//  Example
//
//  Created by Xezun on 2024/10/16.
//

#import "Example04ViewController.h"
#import "Example04TestViewController.h"
@import XZKit;

@interface Example04ViewController ()

@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *XZMLStrings;

@end

@implementation Example04ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.rowHeight = 44.0;
    self.tableView.sectionFooterHeight = 10;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.estimatedSectionFooterHeight = 10.0;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.00001)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.00001)];
    
    self.XZMLStrings = @[
        @[
            @{
                @"title": @"元素位置",
                @"xzml": @"在 <&XZML> 中，<F00#XZML元素>可以插入到<S&任意>位置，<0F0#且元素也可以<00f#单独>使用>。"
            }
        ],

        @[
            @{
                @"title": @"预设值",
                @"xzml": @"在通过 XZML 构造富文本时，可以传入<#预设前景色>，那么在 XZML 中就可以不用指定颜色值。"
            },
            @{
                @"title": @"继承值",
                @"xzml": @"<3a3#父元素拥有绿色前景色，<:eee#子元素继承了绿色前景色，并拥有自己的灰色背景色>，且子元素不影响父元素的样式。>"
            }
        ],

        @[
            @{
                @"title": @"测试普通文本",
                @"xzml": @"日利率 0.02% 0.08%"
            }
        ],
        
        @[
            @{
                @"title": @"文本颜色",
                @"xzml": @"<F00#红色前景色> 就是文本颜色"
            },
            @{
                @"title": @"文本背景色",
                @"xzml": @"<:aaf#蓝色背景色><f11:aaa#红色前景色+灰色背景色>"
            }
        ],

        @[
            @{
                @"title": @"预设字体",
                @"xzml": @"预设字体后，指定字体仅需要一个字体标记符 & 即可。\n日利率 <&0.02% 0.08%> 。"
            },
            @{
                @"title": @"指定字体",
                @"xzml": @"可直接指定字体名，但建议约定并设置字体名缩写，比如下面两种方式的效果是一样的。\n"
                          "日利率 <B&0.02% 0.08%>\n"
                          "日利率 <ChalkboardSE-Bold&0.02% 0.08%>"
            },
            @{
                @"title": @"指定字号",
                @"xzml": @"日利率 <:18&0.02% 0.08%>"
            },
            @{
                @"title": @"指定字体字号",
                @"xzml": @"日利率 <D:18&0.02%> 0.08%"
            },
            @{
                @"title": @"指定字体字号",
                @"xzml": @"日利率 <B:18&0.02%> 0.08%"
            }
        ],

        @[
            @{
                @"title": @"默认删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#$0.08%>"
            },
            @{
                @"title": @"指定删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0$0.08%>"
            },
            @{
                @"title": @"删除线样式",
                @"xzml": @"日利率 <&0.02%> <AAA#0:0$0.08%>"
            },
            @{
                @"title": @"双删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0:1$0.08%>"
            },
            @{
                @"title": @"粗删除线",
                @"xzml": @"日利率 <&0.02%> <AAA#0:2$0.08%>"
            },
            @{
                @"title": @"删除线颜色",
                @"xzml": @"日利率 <&0.02%> <AAA#0:2:F00$0.08%>"
            }
        ],

        @[
            @{
                @"title": @"默认下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1$0.08%>"
            },
            @{
                @"title": @"单下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1:0$0.08%>"
            },
            @{
                @"title": @"双下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1:1$0.08%>"
            },
            @{
                @"title": @"粗下划线",
                @"xzml": @"日利率 <&0.02%> <AAA#1:2$0.08%>"
            },
            @{
                @"title": @"下划线颜色",
                @"xzml": @"日利率 <&0.02%> <AAA#1:2:F00$0.08%>"
            }
        ],

        @[
            @{
                @"title": @"安全文本有样式",
                @"xzml": @"样式属性标记在安全属性标记前，则会成为安全文本的样式。\n"
                          "日利率 <&*0.02%> <AAA#$*0.08%>"
            },
            @{
                @"title": @"安全文本无样式",
                @"xzml": @"样式属性标记在安全属性标记后，则样式会被忽略。\n"
                          "日利率 <*&0.02%> <*AAA#$0.08%>"
            },
            @{
                @"title": @"安全文本继承",
                @"xzml": @"由于安全属性会执行文本替换，因此会忽略子元素的所有样式设置。\n"
                          "日利率 <:4*<&0.02%> <AAA#$0.08%>>"
            },
            @{
                @"title": @"单安全字符",
                @"xzml": @"日利率 <&🔒*0.02%> <AAA#$0.08%>"
            },
            @{
                @"title": @"多安全字符",
                @"xzml": @"日利率 <AAA#谢绝查看*000#&0.02%> <AAA#暂不公开*$0.08%>"
            },
            @{
                @"title": @"安全字符重复",
                @"xzml": @"日利率 <&:4*0.02%> <AAA#:2*$0.08%>"
            }
        ],
        
        @[
            @{
                @"title": @"超链接",
                @"xzml": @"<00F#S&~百度一下> <333#你就知道>"
            }
        ],
        
        @[
            @{
                @"title": @"段落-行高",
                @"xzml": @"<30-45|毛泽东（1893年12月26日-1976年9月9日），字润之（原作咏芝，后改润芝），笔名子任，湖南湘潭人，"
                            "伟大的马克思主义者，伟大的无产阶级革命家、战略家、理论家，"
                            "中国共产党、中国人民解放军和中华人民共和国的主要缔造者和领导人。>"
            },
            @{
                @"title": @"段落-首行缩进",
                @"xzml": @"<0-30:0:40|毛泽东（1893年12月26日-1976年9月9日），字润之（原作咏芝，后改润芝），笔名子任，湖南湘潭人，"
                            "伟大的马克思主义者，伟大的无产阶级革命家、战略家、理论家，"
                            "中国共产党、中国人民解放军和中华人民共和国的主要缔造者和领导人。>"
            }
        ]
    ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.XZMLStrings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.XZMLStrings[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = self.XZMLStrings[indexPath.section][indexPath.row][@"title"];

    return cell;
}

/*
   // Override to support conditional editing of the table view.
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
   }
 */

/*
   // Override to support editing the table view.
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
   }
 */

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"xzml"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Example04TestViewController *nextVC = segue.destinationViewController;
        nextVC.data = self.XZMLStrings[indexPath.section][indexPath.row];
    }
}

@end
