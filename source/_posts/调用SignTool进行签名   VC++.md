调用SignTool进行签名 VC++

对单个文件进行签名基本就一个函数搞定。

对一个文件夹下的所有文件进行签名代码也一样，只是要遍历文件夹获取文件路径。

//文件路径：FilePath 。私钥路径：CerPath。私钥密码：CerPK。时间戳：TimeStamp。  
void XXXXX::Sign(CString FilePath, CString CerPath, CString CerPK, CString
TimeStamp)  
{  
CString para = _T(" sign /a ");  
CString SwitchCerPath = _T(" /f ");//证书开关  
CString SwitchCerPK = _T(" /p ");//私钥开关  
CString SwitchTimeStamp = _T(" /t ");//时间戳开关  
para += SwitchCerPath;  
para += CerPath;  
para += SwitchCerPK;  
para += CerPK;  
para += SwitchTimeStamp;  
para += TimeStamp;  
para += _T(" ");  
para += FilePath;  
//MessageBox(para);  
ShellExecute(NULL,_T("open"),_T("signtool.exe"),para,NULL,SW_HIDE); //
打开signtool  
}  

