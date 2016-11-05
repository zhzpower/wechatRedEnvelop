
#import "WeChatRedEnvelop.h"

//------------------------------------配置抢红包--------------------------------------

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray       *titleArray;

// 红包组
@property (nonatomic, strong) NSArray      *redArray;
@property (nonatomic, strong) UISwitch     *redSwitch;

// 步数
@property (nonatomic, strong) NSArray       *stepArray;
@property (nonatomic, strong) UISwitch      *stepSwitch;

@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红包配置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.titleArray = @[@"抢红包延时设置", @"微信步数倍数"];
    
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"redIsOn"];
    self.redArray = [self getRedSectionArray:isOn];
    self.stepArray = @[@"x1", @"x2", @"x3", @"x4"];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark -
- (void)setupUI
{
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 35;
    [self.view addSubview:self.tableView];
    
    self.redSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 5, 40, 15)];
    [self.redSwitch addTarget:self action:@selector(changeRedStatus:) forControlEvents:UIControlEventValueChanged];
    
    self.stepSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 5, 60, 15)];
    [self.stepSwitch addTarget:self action:@selector(changeRedStatus:) forControlEvents:UIControlEventValueChanged];
    
}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0)
    {
        count = self.redArray.count;
    }
    else if (section == 1){
        count = self.stepArray.count;
    }
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"laozizidingyideid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    if (indexPath.section == 0)
    {
        [[cell textLabel] setText:self.redArray[indexPath.row]];
    }
    else {
        [[cell textLabel] setText:self.stepArray[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"redAfterSeconds"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row+1 forKey:@"stepTimes"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleArray[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    [backgroudView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:1 alpha:0.5]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 40)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [backgroudView addSubview:titleLabel];
    
    NSString *title = self.titleArray[section];
    if (section == 0) {
        BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"redIsOn"];
        self.redSwitch.on = isOn;
        [backgroudView addSubview:self.redSwitch];
    
        NSInteger redAfterSeconds = [[NSUserDefaults standardUserDefaults] integerForKey:@"redAfterSeconds"];
        if (isOn) {
            title = [NSString stringWithFormat:@"%@ (%zds)", title, redAfterSeconds];
        }
        else
        {
            title = [NSString stringWithFormat:@"%@ (已关闭)", title];
        }
    }
    else
    {
        NSInteger stepTimes = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepTimes"];
        if (!stepTimes) {
            stepTimes = 1;
        }
        title = [NSString stringWithFormat:@"%@ (%zd倍)", title, stepTimes];
    }
    
    [titleLabel setText:title];

    return backgroudView;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)changeRedStatus:(UISwitch *)redSwitch
{
    self.redArray = [self getRedSectionArray:redSwitch.isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool:redSwitch.isOn forKey:@"redIsOn"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSArray *)getRedSectionArray:(BOOL)isOn
{
    if (!isOn) {
        return @[];
    }
    else
    {
        return @[@"0s", @"1s", @"2s", @"3s", @"4s"];
    }
}

@end


// 主控制器
%hook NewMainFrameViewController
- (void)viewDidAppear:(BOOL)animated
{
    %orig;

	// 添加一个leftbarItem
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"设置" forState:UIControlStateNormal];
    button.frame = CGRectMake(18, 0, 60, 44);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
	[button addTarget:self action:@selector(clickLeftItem:) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *leftItem = [[objc_getClass("MMBarButtonItem") alloc] initWithCustomView:button];
	[[self navigationItem] setLeftBarButtonItem:leftItem];
}


//------添加新方法 %new---如果self调用, 这要声明----
%new 
- (void)clickLeftItem:(UIButton *)button
{
    [[self navigationController] pushViewController:[[ViewController alloc] init] animated:YES];
}
%end

//------------------------------------抢红包--------------------------------------
%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	
	// 是否开启抢红包
	BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"redIsOn"];
	if (!isOn) return;

	switch(wrap.m_uiMessageType) {
	case 49: { // AppNode

		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CContact *selfContact = [contactManager getSelfContact];

		BOOL isMesasgeFromMe = NO;
		if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
			isMesasgeFromMe = YES;
		}

		if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
			if ([wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound ||
				(isMesasgeFromMe && [wrap.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound)) { // 群组红包或群组里自己发的红包

				NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
				nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

				NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

				/** 构造参数 */
				NSMutableDictionary *params = [@{} mutableCopy];
				params[@"msgType"] = nativeUrlDict[@"msgtype"] ?: @"1";
				params[@"sendId"] = nativeUrlDict[@"sendid"] ?: @"";
				params[@"channelId"] = nativeUrlDict[@"channelid"] ?: @"1";
				params[@"nickName"] = [selfContact getContactDisplayName] ?: @"zhz";
				params[@"headImg"] = [selfContact m_nsHeadImgUrl] ?: @"";
				params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl] ?: @"";
				params[@"sessionUserName"] = wrap.m_nsFromUsr ?: @"";

				WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];

       			 NSInteger redAfterSeconds = [[NSUserDefaults standardUserDefaults] integerForKey:@"redAfterSeconds"];
				 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(redAfterSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        			[logicMgr OpenRedEnvelopesRequest:params];
    			});
				
			}
		}	
		break;
	}
	default:
		break;
	}
	
}
%end

//------------------------------------步数--------------------------------------
%hook WCDeviceStepObject

- (unsigned int)m7StepCount
{
	NSInteger stepTimes = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepTimes"];
    if (!stepTimes) {
        stepTimes = 1;
    }
    return %orig * stepTimes;
}

- (unsigned int)hkStepCount
{
	NSInteger stepTimes = [[NSUserDefaults standardUserDefaults] integerForKey:@"stepTimes"];
    if (!stepTimes) {
        stepTimes = 1;
    }
    return %orig * stepTimes;
}

%end




