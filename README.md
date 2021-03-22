# OneDriveDemo

本demo针对于OneDrive的主要功能做了简单的集成和测试，对你应该会有帮助，可以少走一些弯路。
功能点主要有以下:

1.登陆退出onedrive，多账号管理（OneDrive本身不提倡）。
 
2.未在官方找到回收站的graphAPI，所以只能做到一半，点到为止🙃️。

3.文件夹与文件的分页浏览，创建文件夹，修改名称，删除，移动，复制。

4.上传下载，大文件分片上传。

5.搜索OneDrive内容。

这是注册Microsoft Azure的APP的网址

https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps

注册完成后，需要编辑APP的各平台信息。同时后台服务器要配置一个


*特别要注意 API配置 这个选项 如果不配置则不能访问这些功能
User.Read
Files.ReadWrite.All
Demo中GraphAuthSettings.plist文件内改为对应你的appid 以及这些scopes

如果遇到了一些问题，可以issue我一同探究。
qq：12087014

