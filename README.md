正在收集工作区信息# QQTweak设置界面演示

## 项目概述

该项目演示了如何通过Hook技术向QQ设置界面中添加自定义设置项。通过分析和Hook QQ的UI组件层级与数据流，实现在不修改原始应用代码的情况下插入新的功能入口。

## 功能特点

- 在QQ设置界面添加"QQTweak设置"选项
- 动态提取类结构和实例数据信息
- 支持点击事件响应和交互
- 自定义图标与详细文本展示

## 技术原理

整个数据流结构如下：
```
QQNewSettingsViewController
 └── viewProvider (QQNewSettingsViewProvider)
      └── setupDataSource() → NSArray<QUIListSectionModel>
           └── rowModelArray → NSArray<QUIListSingleLineConfig>
QUIListView
 └── dataArray 绑定 SectionModel
```

通过Hook `QQNewSettingsViewProvider` 的 `setupDataSource` 方法，该方法返回了设置页面所有选项的数据模型。项目在原始数据源基础上添加了自定义配置，修改返回值后UI自动更新。

### 核心类解析

- **QQNewSettingsViewController**: 设置页面主控制器
- **QQNewSettingsViewProvider**: 负责提供设置页面的数据源
- **QUIListView**: 列表视图组件，用于展示设置选项
- **QUIListSectionModel**: 列表分区模型
- **QUIListSingleLineConfig**: 单行列表项配置
- **QUIListItemStyle**: 列表项样式配置

## 实现细节

关键部分实现代码：

```objc
// Hook QQNewSettingsViewProvider类
%hook QQNewSettingsViewProvider
- (id)setupDataSource {
    id originalDataSource = %orig;
    
    // 在原有数据源基础上修改
    if ([originalDataSource isKindOfClass:[NSArray class]]) {
        NSArray *sectionsArray = (NSArray *)originalDataSource;
        if (sectionsArray.count > 1) {
            // 获取第二个分区
            id secondSection = sectionsArray[1];
            
            // 创建自定义配置
            id QQTweakModel = [[%c(QUIListSingleLineConfig) alloc] init];
            
            // 设置左侧样式
            id leftStyle = [[leftStyleClass alloc] init];
            [leftStyle setValue:@"QQTweak设置" forKey:@"title"];
            UIImage *icon = [UIImage systemImageNamed:@"gear"]; 
            [leftStyle setValue:icon forKey:@"image"];
            [QQTweakModel setValue:leftStyle forKey:@"leftStyle"];
            
            // 设置右侧样式
            id rightStyle = [[rightStyleClass alloc] init];
            [rightStyle setValue:@(YES) forKey:@"showArrow"];
            [rightStyle setValue:@"1.0.0" forKey:@"detailText"];
            [QQTweakModel setValue:rightStyle forKey:@"rightStyle"];
            
            // 将新配置添加到列表中
            QUIListSectionModel *sectionModel = (QUIListSectionModel *)secondSection;
            NSMutableArray *updatedRowModelArray = [sectionModel.rowModelArray mutableCopy];
            [updatedRowModelArray insertObject:QQTweakModel atIndex:0];
            sectionModel.rowModelArray = [updatedRowModelArray copy];
        }
    }
    
    return originalDataSource;
}
%end
```

## 工具函数

项目包含两个实用工具函数：

1. `dumpObjectProperties`: 通过运行时获取对象的所有属性及其值
2. `dumpClassInfo`: 提取类的完整接口定义，包括属性和方法

## 注意事项

- 本项目仅用于学习和研究目的
