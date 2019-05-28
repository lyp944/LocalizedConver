//
//  ViewController.m
//  LocalizedConver
//
//  Created by Mega on 2019/5/23.
//

#import "LYPRegExp.h"
#import "YouDao.h"
#import "ViewController.h"


@interface ViewController ()
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *skipCurrentFileButton;
@property (unsafe_unretained) IBOutlet NSTextView *leftTextView;

@property (unsafe_unretained) IBOutlet NSTextView *rightTextView;
@property (weak) IBOutlet NSTextField *prefixTextField;
@property (weak) IBOutlet NSTextField *currentFileName;

@property (weak) IBOutlet NSTextField *textFileDirLabel;

@property (strong , nonatomic) NSFileManager *manager;

@property (strong , nonatomic) NSMutableArray *allFileArray;

@property (assign , nonatomic) NSInteger currentFileIndex;
@property (copy , nonatomic) void(^replaceContentBlock)(void);


@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allFileArray = [NSMutableArray new];
    self.manager = [NSFileManager defaultManager];
    
    
    [[self.rightTextView superview] setPostsBoundsChangedNotifications: YES];
    //找个合适的地儿，注册通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter] ;
    [center addObserver: self
               selector: @selector(boundsDidChangeNotification:)
                   name: NSViewBoundsDidChangeNotification
                 object: [self.rightTextView superview]];
    
}

-(void)boundsDidChangeNotification:(NSNotification*) notification {
    
    // 在这里进行处理
    NSClipView *changedContentView=[notification object];
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;
    NSClipView *scrollview = ( NSClipView *)(self.leftTextView.superview);
    [scrollview scrollToPoint:changedBoundsOrigin];
}

#pragma mark - IBAction
- (IBAction)chooseDirOrFile:(id)sender {
    
    [self.allFileArray removeAllObjects];
    self.currentFileIndex = 0;
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setPrompt: @"打开"];
    
    openPanel.directoryURL = nil;
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == NSModalResponseOK) {
            
            NSURL *fileUrl = [[openPanel URLs] objectAtIndex:0];
            NSString *filePath = fileUrl.path;
            
            //find and log all path
            [self findAllfileAtPath:filePath];
            
            NSLog(@"%@",self.allFileArray);
            
            NSString *string = [NSString new];
            for (NSString *path in self.allFileArray) {
                string = [string stringByAppendingFormat:@"%@\n",path];
            }
        
            
            NSString *currentPath = self.allFileArray[self.currentFileIndex];
            @autoreleasepool {
                [self dealFileAtPath:currentPath completion:nil];
            }
            
        }
    }];
}
- (IBAction)chooseDirForTextFIle:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setPrompt: @"确定"];
    openPanel.canChooseFiles = NO;
    
    openPanel.directoryURL = nil;
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == NSModalResponseOK) {
            
            NSURL *fileUrl = [[openPanel URLs] objectAtIndex:0];
            NSString *filePath = fileUrl.path;
            
            self.textFileDirLabel.stringValue = filePath;
            
        }
    }];
    
}


- (IBAction)skipFile:(id)sender {
    self.replaceContentBlock = nil;
    [self nextStep:self.nextButton];
}

- (IBAction)nextStep:(id)sender {
    
    if (self.textFileDirLabel.stringValue.length < 1) {
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText:@"请选择生成text.strings文件路径"];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    if (self.replaceContentBlock) {
        self.replaceContentBlock();
    }
    self.currentFileIndex ++;
    self.replaceContentBlock = nil;
    
    
    if (self.currentFileIndex >= self.allFileArray.count) {
        //结束
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText:@"文件处理完毕"];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            [self.allFileArray removeAllObjects];
            self.currentFileIndex = 0;
            self.replaceContentBlock = nil;
            self.currentFileName.stringValue = @"";
        }];
    }else{
        
        NSString *currentPath = self.allFileArray[self.currentFileIndex];
        @autoreleasepool {
            [self dealFileAtPath:currentPath completion:nil];
        }
    }
    
}

- (IBAction)replaceAllFile:(id)sender {
    
    if (self.replaceContentBlock) {
        self.replaceContentBlock();
    }
    self.currentFileIndex ++;
    self.replaceContentBlock = nil;
    
    NSLog(@"%ld",(long)self.currentFileIndex);
    
    if (self.currentFileIndex >= self.allFileArray.count) {
        //结束
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText:@"文件处理完毕"];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            [self.allFileArray removeAllObjects];
            self.currentFileIndex = 0;
            self.replaceContentBlock = nil;
            self.currentFileName.stringValue = @"";
        }];
    }else{
        
        NSString *currentPath = self.allFileArray[self.currentFileIndex];
        @autoreleasepool {
            [self dealFileAtPath:currentPath completion:^{
                [self replaceAllFile:sender];
            }];
        }
    }
    
}


#pragma mark - file methods

-(void)findAllfileAtPath:(NSString*) path {
    
    BOOL isDir = NO;
    BOOL isExist = [self.manager fileExistsAtPath:path isDirectory:&isDir];
    
    if (!isExist) {
        NSLog(@"文件不存在！:%@",path);
        return ;
    }
    
    if (isDir) {
        NSError *error;
        NSArray *dirArray = [self.manager contentsOfDirectoryAtPath:path error:&error];
        
        for (NSString *subPath in dirArray) {
            NSString *subFilePath = [path stringByAppendingPathComponent:subPath];
            
            [self findAllfileAtPath:subFilePath];
        }
    }else{
        //.m 文件
        if ([path.pathExtension isEqualToString:@"m"]) {
            [self.allFileArray addObject:path];
        }
    }
}

-(void)dealFileAtPath:(NSString*) path completion:(void(^)(void)) completion{
    
    self.currentFileName.stringValue = path.lastPathComponent;
    
    self.nextButton.enabled = NO;
    
    NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *readString = [[NSString alloc] initWithData:readFileHandle.availableData encoding:NSUTF8StringEncoding];
    

    
    NSArray *arrays = [LYPRegExp fourArrayMatchesInString:readString];
    
    //eg:@"你好"
    NSMutableArray *stringRangeArray = arrays[0];
    NSMutableArray *stringArray = arrays[1];
    
    //eg:你好
    __unused NSMutableArray *subStringRangeArray = arrays[2];
    NSMutableArray *subStringArray = arrays[3];
    
    
    
    //红色展示
    NSMutableAttributedString *attrReadString = [[NSMutableAttributedString alloc]initWithString:readString attributes:@{NSForegroundColorAttributeName:[NSColor blackColor]}];
    for (NSValue *rangeValue in stringRangeArray) {
        [attrReadString setAttributes:@{NSForegroundColorAttributeName:[NSColor redColor]} range:rangeValue.rangeValue];
    }
    
    [self.leftTextView.textStorage deleteCharactersInRange:NSMakeRange(0, self.leftTextView.textStorage.length)];
    [self.leftTextView.textStorage appendAttributedString:attrReadString];
    
    
    NSInteger endCount = stringArray.count;
    __block NSInteger beginCount = 0;
    
    NSMutableArray *translationArray = [NSMutableArray arrayWithCapacity:endCount];
    for (int i = 0; i < endCount; i++) {
        [translationArray addObject:@"-"];
    }
    
    
    if (endCount < 1) {
        self.nextButton.enabled = YES;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:@"没有需要替换的文字" attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}];

        [self.rightTextView.textStorage deleteCharactersInRange:NSMakeRange(0, self.rightTextView.textStorage.length)];
        [self.rightTextView.textStorage appendAttributedString:text];
        NSLog(@"❌ %@ 无需替换",path.lastPathComponent);
        if(completion) completion();
        return;
    }
    
    NSMutableDictionary *bindsDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *localizedBindDic = [NSMutableDictionary dictionary];

    
    for (int i = 0; i < endCount; i ++) {
        NSString *string = subStringArray[i];
        [YouDao translate:string completion:^(id  _Nonnull response) {
            NSArray *responseArray = (NSArray *)response;
            [translationArray replaceObjectAtIndex:i withObject:responseArray.firstObject];
            
            beginCount += 1;
            
            NSString *translateString = translationArray[i];
            
            NSString *prefixText = self.prefixTextField.stringValue.length > 0? self.prefixTextField.stringValue:@"";
            NSString *prefixTranslateString = [NSString stringWithFormat:@"%@%@",prefixText,translateString];
            
            NSString *needTranslateString = subStringArray[i];
            NSString *replaceString = stringArray[i];
            
            [bindsDic setObject:prefixTranslateString forKey:replaceString];
            
            [localizedBindDic setObject:prefixTranslateString forKey:needTranslateString];
            
            if (beginCount == endCount) {
                //翻译结束
                
                //拼接字符串
                __block NSString *localizedString = @"";
                
                [localizedBindDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                    localizedString = [localizedString stringByAppendingString:[NSString stringWithFormat:@"\"%@\"=\"%@\";\n",obj,key]];
                }];
                NSLog(@"%@",localizedString);
                
                
                //预览替换后的字符串
                NSMutableString *replacedReadString = readString.mutableCopy;
                
                NSInteger addLocation = 0;
                NSMutableArray *replacedRangeArray = [NSMutableArray new];
                for (NSValue *value in stringRangeArray) {
                    
                    NSRange range = value.rangeValue;
                    NSString *key = [readString substringWithRange:NSMakeRange(range.location, range.length)];
                    
                    NSString *translatedString = bindsDic[key];
                    NSString *newString = [NSString stringWithFormat:@"SDString(@\"%@\")",translatedString];
                    
                    NSRange replacedRange = NSMakeRange(range.location + addLocation, range.length);
                    [replacedReadString replaceCharactersInRange:replacedRange withString:newString];
                    [replacedRangeArray addObject:[NSValue valueWithRange:NSMakeRange(replacedRange.location, newString.length)]];
                    
                    //文件内容对其
                    addLocation += newString.length - key.length;
                    
                    //                    NSLog(@"%@,%lu,%d,%@,%@",key,(unsigned long)key.length,newString.length,NSStringFromRange(range),NSStringFromRange(replacedRange));
                    
                }
                
                //蓝色展示
                NSMutableAttributedString *attrReplacedString = [[NSMutableAttributedString alloc]initWithString:replacedReadString attributes:@{NSForegroundColorAttributeName:[NSColor blackColor]}];
                for (NSValue *rangeValue in replacedRangeArray) {
                    [attrReplacedString setAttributes:@{NSForegroundColorAttributeName:[NSColor blueColor]} range:rangeValue.rangeValue];
                }
                
                
                [self.rightTextView.textStorage deleteCharactersInRange:NSMakeRange(0, self.rightTextView.textStorage.length)];
                [self.rightTextView.textStorage appendAttributedString:attrReplacedString];
                
                self.nextButton.enabled = YES;
                
                
                __weak typeof(self) w_self = self;
                self.replaceContentBlock = ^() {
                    __strong typeof(w_self) self = w_self;
                    @autoreleasepool {
                        NSFileHandle *updateHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
                        [updateHandle truncateFileAtOffset:0];
                        [updateHandle writeData:[replacedReadString dataUsingEncoding:NSUTF8StringEncoding]];
                        [updateHandle closeFile];
                        
                        
                        NSString *localizedPath = [self.textFileDirLabel.stringValue stringByAppendingPathComponent:@"text.strings"];
                        BOOL isDir = NO;
                        if (![self.manager fileExistsAtPath:localizedPath isDirectory:&isDir]) {
                            [self.manager createFileAtPath:localizedPath contents:nil attributes:nil];
                        }
                        
                        if (self.prefixTextField.stringValue.length > 0) {
                            //注释换行
                            localizedString = [NSString stringWithFormat:@"//%@\n%@",self.prefixTextField.stringValue,localizedString];
                        }
                        
                        NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:localizedPath];
                        [writeHandle seekToEndOfFile];
                        [writeHandle writeData:[localizedString dataUsingEncoding:NSUTF8StringEncoding]];
                        [writeHandle closeFile];
                        
                        NSLog(@"✅ %@ 替换完成",path.lastPathComponent);
                        
                    }
                    
                };
                
                
                if(completion) completion();
            }
        }];
    }
    
}



//-(void)dealString:(NSString*)string withPattern:(NSString*) pattern onlyFind:(BOOL) onlyFind{
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
//
//    NSMutableArray *array = [NSMutableArray array];
//
//    for (NSTextCheckingResult *match in matches) {
//
//        for (int i = 1; i < [match numberOfRanges]; i++) {
//
//            if (onlyFind) {
//
//            }else{
//
//            }
//
//            NSString *component = [string substringWithRange:];
//            //            component = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除空格
//            [array addObject:component];
//
//        }
//
//    }
//}


@end
