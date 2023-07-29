:setEnvironment
echo off
setlocal enabledelayedexpansion
chcp 65001
echo 環境変数の設定完了

:tempFolderDelete
if exist .\temporary\*.* (
	del /Q .\temporary
	echo 残留ファイル削除完了
)

:InputCheck
set filenum=0
for %%F in (.\input\*.zip) do (set /a filenum=filenum+1)
if not %filenum%==1 (
	echo Error01:inputフォルダにはルームデータのzipファイルを1つだけ入れてください
	goto NGExit
)
echo フォルダ事前チェック完了

:LoadChatTabConfig
set n=-1
for /f %%a in (.\input\chat-tab.txt) do (
	set /A n=n+1
	set tabname[!n!]=%%a
)
set /a tabnum=n+1
echo タブ数=%tabnum%
for /l %%b in (0,1,%n%) do ( echo !tabname[%%b]!)
echo チャットタブ出力設定読み込み完了

:Unzip
.\assets\tools\7za.exe x .\input\*.zip -o.\temporary\
echo 一時フォルダに解凍完了
:DefaultCopy
copy .\assets\images\ .\temporary
echo デフォルト画像コピー完了

:DefineOutputFolder
set time_tmp=%time: =0%
set now=%date:/=%%time_tmp:~0,2%%time_tmp:~3,2%%time_tmp:~6,2%
set outputFolder=.\output_%now%
echo %outputFolder%
mkdir %outputFolder%
mkdir %outputFolder%\img
echo 出力フォルダ生成完了

:CopyNeedFiles
dir /b .\temporary\ | findstr ".gif .png .jpg .jpeg .jpe .webp" > .\temporary\UdonSobaImageList.txt
for /f %%a in (.\temporary\UdonSobaImageList.txt) do (
    findstr %%~na .\temporary\chat.xml > nul
    echo %%~na
    if !errorlevel!==0 (
        copy .\temporary\%%a .\%outputFolder%\img
	)
)
echo 使用ファイルのコピー完了

:ChangeExtension
ren %outputFolder%\img\*.jpg *.imagedata
ren %outputFolder%\img\*.jpeg *.imagedata
ren %outputFolder%\img\*.jpe *.imagedata
ren %outputFolder%\img\*.png *.imagedata
ren %outputFolder%\img\*.gif *.imagedata
ren %outputFolder%\img\*.webp *.imagedata
echo 拡張子変更完了
:convert_main
for /l %%c in (0,1,%n%) do (
	.\assets\tools\msxsl.exe .\temporary\chat.xml .\assets\xslt\convert.xsl tabname=!tabname[%%c]! -o %outputFolder%\converted_chatlog_!tabname[%%c]!.html 
)
.\assets\tools\msxsl.exe .\temporary\chat.xml .\assets\xslt\convert.xsl -o %outputFolder%\converted_chatlog.html 
echo HTML出力完了

:Deletezipdata
del /Q .\temporary
echo 一時フォルダ内ファイル削除完了

:OKExit
echo 正常終了
pause
exit /b 0

:NGExit
echo 異常終了
pause
exit /b 1

