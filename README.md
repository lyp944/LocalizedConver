# LocalizedConver
老项目国际化的一个小工具

### 此工具还不是通用版本，需要根据自己的项目修改部分代码，才可以应用的其他项目
### 使用前请做好备份，切记不要一上来就直接替换
### 使用前请做好备份，切记不要一上来就直接替换
### 使用前请做好备份，切记不要一上来就直接替换

1. 根据正则表达式找到中文字符串，可以过滤掉注释（/**/，//）和NSLog中的中文字符串
2. 使用有道翻译api，生成国际化对应的 "prefix.key":"value"; 的文件
3. 在没有点击`下一步`（下一步会一个文件一个文件替换，避免不符合要求）和`替换全部`之前不会修改源文件，但是可以提前预览源文件及修改后的文件
4. 当有特殊字符的时候 比如：< " 等，有时候有道翻译并不能，处理的很好，这部分需要自己收到再处理一下
5. 使用前请做好备份，切记不要一上来就直接替换