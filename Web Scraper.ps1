Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$script:isEnglish = $false
$initTime = (Get-Date).ToString('HH:mm:ss')
$script:LogHistoryAR = New-Object System.Collections.Generic.List[string]
$script:LogHistoryAR.Add("[$initTime] النظام جاهز للبدء...")
$script:LogHistoryEN = New-Object System.Collections.Generic.List[string]
$script:LogHistoryEN.Add("[$initTime] System is ready to start...")
$signature = @'
[DllImport("user32.dll")] public static extern bool ReleaseCapture();
[DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
'@
if (-not ([System.Management.Automation.PSTypeName]"Win32.WindowMover").Type) {
    Add-Type -MemberDefinition $signature -Name "WindowMover" -Namespace "Win32"
}
$win32Code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {[DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);[DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
}
"@
if (-not ([System.Management.Automation.PSTypeName]"Win32").Type) {
    Add-Type -TypeDefinition $win32Code
}
function Test-NodeJS {
    $check = Get-Command "node" -ErrorAction SilentlyContinue
    if ($check) {
        return $true
    }
    else {
        return $false
    }
}
function New-SchoWindow {
    param([string]$Title, [int]$Width, [int]$Height)
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1E1E1E")
    $form.FormBorderStyle = "None"
    $form.RightToLeft = if ($script:isEnglish) { "No" } else { "Yes" }
    $pnlHeader = New-Object System.Windows.Forms.Panel
    $pnlHeader.SetBounds(1, 1, ($Width - 2), 35)
    $pnlHeader.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D2D")
    $form.Controls.Add($pnlHeader)
    $lblHeaderTitle = New-Object System.Windows.Forms.Label
    $lblHeaderTitle.Text = $Title; $lblHeaderTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#d4d4d4")
    $lblHeaderTitle.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblHeaderTitle.TextAlign = "MiddleCenter"; $lblHeaderTitle.Dock = "Fill"
    $pnlHeader.Controls.Add($lblHeaderTitle)
    $OnMove = {
        [Win32.WindowMover]::ReleaseCapture() | Out-Null
        [Win32.WindowMover]::SendMessage($this.FindForm().Handle, 0xA1, 0x2, 0) | Out-Null
    }
    $pnlHeader.Add_MouseDown($OnMove)
    $lblHeaderTitle.Add_MouseDown($OnMove)
    $form.Add_MouseDown($OnMove)
    $borderColor = [System.Drawing.ColorTranslator]::FromHtml("#555555")
    $pnlBorderTop = New-Object System.Windows.Forms.Panel; $pnlBorderTop.SetBounds(0, 0, $Width, 1); $pnlBorderTop.BackColor = $borderColor; $form.Controls.Add($pnlBorderTop)
    $pnlBorderBottom = New-Object System.Windows.Forms.Panel; $pnlBorderBottom.SetBounds(0, $Height - 1, $Width, 1); $pnlBorderBottom.BackColor = $borderColor; $form.Controls.Add($pnlBorderBottom)
    $pnlBorderLeft = New-Object System.Windows.Forms.Panel; $pnlBorderLeft.SetBounds(0, 0, 1, $Height); $pnlBorderLeft.BackColor = $borderColor; $form.Controls.Add($pnlBorderLeft)
    $pnlBorderRight = New-Object System.Windows.Forms.Panel; $pnlBorderRight.SetBounds($Width - 1, 0, 1, $Height); $pnlBorderRight.BackColor = $borderColor; $form.Controls.Add($pnlBorderRight)
    return @($form, $pnlHeader, $lblHeaderTitle)
}
function Show-SchoMessage {
    param([string]$Message, [string]$Type = "Success")
    $msgWidth = 380; $msgHeight = 160
    $msgForm = New-Object System.Windows.Forms.Form
    $msgForm.Size = New-Object System.Drawing.Size($msgWidth, $msgHeight)
    $msgForm.StartPosition = "CenterParent"
    $msgForm.FormBorderStyle = "None"
    $msgForm.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1E1E1E")
    $msgForm.Opacity = 0
    $msgForm.RightToLeft = if ($script:isEnglish) { "No" } else { "Yes" }
    $hexColor = if ($Type -eq "Error") { "#A64444" } else { "#007ACC" }
    $bColor = [System.Drawing.ColorTranslator]::FromHtml($hexColor)
    $OnMoveMsg = { [Win32.WindowMover]::ReleaseCapture() | Out-Null
        [Win32.WindowMover]::SendMessage($this.FindForm().Handle, 0xA1, 0x2, 0) | Out-Null
    }
    $msgForm.Add_MouseDown($OnMoveMsg)
    $msgHeader = New-Object System.Windows.Forms.Panel
    $msgHeader.SetBounds(0, 0, $msgWidth, 35)
    $msgHeader.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D2D")
    $msgHeader.Add_MouseDown($OnMoveMsg)
    $msgForm.Controls.Add($msgHeader)
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = if ($script:isEnglish) { "SULAIMAN SHO | System Message" } else { "رسالة نظام | SULAIMAN SHO " }
    $lblTitle.ForeColor = [System.Drawing.Color]::White
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $lblTitle.TextAlign = "MiddleCenter"
    $lblTitle.Dock = "Fill"
    $lblTitle.Add_MouseDown($OnMoveMsg)
    $msgHeader.Controls.Add($lblTitle)
    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = $Message
    $lblMsg.ForeColor = [System.Drawing.Color]::White
    $lblMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblMsg.TextAlign = "MiddleCenter"
    $lblMsg.SetBounds(10, 35, ($msgWidth - 20), 75)
    $lblMsg.Add_MouseDown($OnMoveMsg)
    $msgForm.Controls.Add($lblMsg)
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = if ($script:isEnglish) { "OK" } else { "موافق" }
    $btnOk.Size = New-Object System.Drawing.Size(100, 30)
    $btnOk.Location = New-Object System.Drawing.Point(140, 115)
    $btnOk.FlatStyle = "Flat"
    $btnOk.FlatAppearance.BorderSize = 0
    $btnOk.ForeColor = [System.Drawing.Color]::White
    $btnOk.BackColor = $bColor
    $btnOk.Cursor = "Hand"
    $btnOk.Add_Click({ $msgForm.Close() })
    $msgForm.Controls.Add($btnOk)
    $pTop = New-Object System.Windows.Forms.Panel; $pTop.SetBounds(0, 0, $msgWidth, 1); $pTop.BackColor = $bColor; $msgForm.Controls.Add($pTop); $pTop.BringToFront()
    $pBot = New-Object System.Windows.Forms.Panel; $pBot.SetBounds(0, $msgHeight - 1, $msgWidth, 1); $pBot.BackColor = $bColor; $msgForm.Controls.Add($pBot); $pBot.BringToFront()
    $pLft = New-Object System.Windows.Forms.Panel; $pLft.SetBounds(0, 0, 1, $msgHeight); $pLft.BackColor = $bColor; $msgForm.Controls.Add($pLft); $pLft.BringToFront()
    $pRgt = New-Object System.Windows.Forms.Panel; $pRgt.SetBounds($msgWidth - 1, 0, 1, $msgHeight); $pRgt.BackColor = $bColor; $msgForm.Controls.Add($pRgt); $pRgt.BringToFront()
    $fadeTimer = New-Object System.Windows.Forms.Timer
    $fadeTimer.Interval = 10
    $fadeTimer.Add_Tick({
            if ($msgForm.Opacity -lt 1) { $msgForm.Opacity += 0.1 }
            else { $fadeTimer.Stop() }
        })
    $msgForm.Add_Load({ $fadeTimer.Start() })
    $msgForm.ShowDialog() | Out-Null
}
function Show-NodeJsDialog {
    $dialogTitle = if ($script:isEnglish) { "SULAIMAN SHO | Missing Node.js" } else { "SULAIMAN SHO | تنبيه المتطلبات" }
    $ui = New-SchoWindow -Title $dialogTitle -Width 490 -Height 430
    $dlg = $ui[0]
    $pnlHeader = $ui[1]
    $btnClose = New-Object System.Windows.Forms.Label
    $btnClose.Text = "✕"
    $btnClose.SetBounds(455, 5, 25, 25)
    $btnClose.ForeColor = "White"
    $btnClose.Cursor = "Hand"
    $btnClose.TextAlign = "MiddleCenter"
    $btnClose.Add_Click({ $dlg.Close() })
    $btnClose.Add_MouseEnter({ $btnClose.ForeColor = [System.Drawing.Color]::Red })
    $btnClose.Add_MouseLeave({ $btnClose.ForeColor = "White" })
    $pnlHeader.Controls.Add($btnClose)
    $btnClose.BringToFront()
    $lblIcon = New-Object System.Windows.Forms.Label
    $lblIcon.Text = "!"
    $lblIcon.ForeColor = [System.Drawing.Color]::Gold
    $lblIcon.Font = New-Object System.Drawing.Font("Segoe UI", 45, [System.Drawing.FontStyle]::Bold)
    $lblIcon.SetBounds(0, 40, 490, 60)
    $lblIcon.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblIcon)
    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = if ($script:isEnglish) {
        "Node.js is missing! Choose your OS and architecture for a direct download:"
    }
    else {
        "عذراً، برنامج Node.js غير مثبت!`nاختر نظام التشغيل ومعمارية جهازك للتحميل المباشر:"
    }
    $lblMsg.ForeColor = [System.Drawing.Color]::White
    $lblMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblMsg.SetBounds(10, 105, 470, 50)
    $lblMsg.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblMsg)
    $lblWin10 = New-Object System.Windows.Forms.Label
    $lblWin10.Text = if ($script:isEnglish) { "Latest (Windows 10 / 11)" } else { "أحدث إصدار (ويندوز 10 / 11)" }
    $lblWin10.SetBounds(20, 160, 450, 20); $lblWin10.ForeColor = "LightGray"; $lblWin10.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblWin10)
    $lblWin8 = New-Object System.Windows.Forms.Label
    $lblWin8.Text = if ($script:isEnglish) { "Windows 8 / 8.1 (v14.21.3)" } else { "ويندوز 8 / 8.1 (الإصدار 14)" }
    $lblWin8.SetBounds(20, 240, 450, 20); $lblWin8.ForeColor = "LightGray"; $lblWin8.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblWin8)
    $lblWin7 = New-Object System.Windows.Forms.Label
    $lblWin7.Text = if ($script:isEnglish) { "Windows 7 (v13.14.0)" } else { "ويندوز 7 (الإصدار 13)" }
    $lblWin7.SetBounds(20, 320, 450, 20); $lblWin7.ForeColor = "LightGray"; $lblWin7.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblWin7)
    function Add-SmartButton ($Text, $X, $Y, $BaseColor, $HoverColor, $ShadowColor, $Url, $W = 200) {
        $shadow = New-Object System.Windows.Forms.Panel
        $shadow.SetBounds(($X + 5), ($Y + 5), $W, 35)
        $shadow.BackColor = [System.Drawing.ColorTranslator]::FromHtml($ShadowColor)
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $Text
        $btn.SetBounds($X, $Y, $W, 35)
        $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BaseColor)
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatStyle = "Flat"
        $btn.FlatAppearance.BorderSize = 0
        $btn.Cursor = "Hand"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $btn.RightToLeft = "No"
        $btn.Tag = @{ Base = $BaseColor; Hover = $HoverColor; Link = $Url; Window = $dlg }
        $btn.Add_MouseEnter({
                $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml($this.Tag.Hover)
                $this.Left += 2; $this.Top += 2
            })
        $btn.Add_MouseLeave({
                $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml($this.Tag.Base)
                $this.Left -= 2; $this.Top -= 2
            })
        $btn.Add_Click({
                Start-Process $this.Tag.Link
                $this.Tag.Window.Close()
            })
        $dlg.Controls.Add($btn)
        $dlg.Controls.Add($shadow)
        $dlg.Controls.SetChildIndex($btn, 0)
        $dlg.Controls.SetChildIndex($shadow, 1)
    }
    try {
        $nodeData = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json"
        $latestLtsVer = ($nodeData | Where-Object { $_.lts -ne $false })[0].version
    }
    catch {
        $latestLtsVer = "v24.14.0"
    }
    $linkWin10_64 = "https://nodejs.org/dist/$latestLtsVer/node-$latestLtsVer-x64.msi"
    $linkWin10_32 = "https://nodejs.org/dist/$latestLtsVer/node-$latestLtsVer-x86.msi"
    Add-SmartButton "Win 10/11 (64-bit LTS)" 30 185 "#4CAF50" "#5cb860" "#2e6b31" $linkWin10_64 430
    Add-SmartButton "Win 8 (64-bit)"     260 265 "#2E5A88" "#34679a" "#1B3651" "https://nodejs.org/dist/v14.21.3/node-v14.21.3-x64.msi"
    Add-SmartButton "Win 8 (32-bit)"     30  265 "#2E5A88" "#34679a" "#1B3651" "https://nodejs.org/dist/v14.21.3/node-v14.21.3-x86.msi"
    Add-SmartButton "Win 7 (64-bit)"     260 345 "#476b6b" "#5c8a8a" "#293d3d" "https://nodejs.org/dist/v13.14.0/node-v13.14.0-x64.msi"
    Add-SmartButton "Win 7 (32-bit)"     30  345 "#476b6b" "#5c8a8a" "#293d3d" "https://nodejs.org/dist/v13.14.0/node-v13.14.0-x86.msi"
    $moveAction = {
        [Win32.WindowMover]::ReleaseCapture() | Out-Null
        [Win32.WindowMover]::SendMessage($this.FindForm().Handle, 0xA1, 0x2, 0) | Out-Null
    }
    $lblIcon.Add_MouseDown($moveAction)
    $lblMsg.Add_MouseDown($moveAction)
    $lblWin10.Add_MouseDown($moveAction)
    $lblWin8.Add_MouseDown($moveAction)
    $lblWin7.Add_MouseDown($moveAction)
    $dlg.Add_MouseDown($moveAction)
    $dlg.ShowDialog() | Out-Null
}
function Show-ConfirmDialog {
    param([string]$Message)
    $ui = New-SchoWindow -Title "SULAIMAN SHO | Smart Installer" -Width 420 -Height 210
    $confirmDlg = $ui[0]
    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = $Message; $lblMsg.ForeColor = [System.Drawing.Color]::White
    $lblMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblMsg.SetBounds(20, 50, 380, 85); $lblMsg.TextAlign = "MiddleCenter"; $confirmDlg.Controls.Add($lblMsg)
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = if ($script:isEnglish) { "OK" } else { "موافق" }
    $btnOk.SetBounds(220, 150, 100, 35); $btnOk.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#4CAF50")
    $btnOk.ForeColor = [System.Drawing.Color]::White; $btnOk.FlatStyle = "Flat"
    $btnOk.Cursor = "Hand"; $btnOk.Add_Click({ $confirmDlg.DialogResult = [System.Windows.Forms.DialogResult]::OK; $confirmDlg.Close() })
    $confirmDlg.Controls.Add($btnOk)
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = if ($script:isEnglish) { "Cancel" } else { "إلغاء الأمر" }
    $btnCancel.SetBounds(100, 150, 100, 35); $btnCancel.BackColor = [System.Drawing.Color]::Gray
    $btnCancel.ForeColor = [System.Drawing.Color]::White; $btnCancel.FlatStyle = "Flat"
    $btnCancel.Cursor = "Hand"; $btnCancel.Add_Click({ $confirmDlg.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; $confirmDlg.Close() })
    $confirmDlg.Controls.Add($btnCancel)
    return $confirmDlg.ShowDialog()
}
function Update-DevViewUI {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $status = Get-ItemProperty -Path $regPath -Name "HideFileExt"
    if ($status.HideFileExt -eq 0) {
        $btnDevView.Text = if ($script:isEnglish) { "$([char]0x1F441) User View" } else { "$([char]0x1F441) وضع المستخدم" }
        $tip = if ($script:isEnglish) { "Restore normal view (Hide hidden files)" } else { "العودة للوضع العادي (إخفاء الملفات والامتدادات)" }
    }
    else {
        $btnDevView.Text = if ($script:isEnglish) { "$([char]0x1F441) Dev View" } else { "$([char]0x1F441) رؤية المطور" }
        $tip = if ($script:isEnglish) { "Enable developer view (Show hidden files)" } else { "تفعيل رؤية المطور (إظهار الملفات المخفية والامتدادات)" }
    }
    $toolTip.SetToolTip($btnDevView, $tip)
}
function Set-DevView {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $status = Get-ItemProperty -Path $regPath -Name "HideFileExt"
    if ($status.HideFileExt -eq 1) {
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 0
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value 1
        $msg = if ($script:isEnglish) { "Developer View Enabled!" } else { "تم تفعيل رؤية المطور" }
    }
    else {
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 1
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value 2
        $msg = if ($script:isEnglish) { "User View Enabled!" } else { "تم تفعيل وضع المستخدم العادي" }
    }
    $refreshCode = '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);'
    $type = Add-Type -MemberDefinition $refreshCode -Name "Shell32Refresh$([guid]::NewGuid().ToString('N'))" -PassThru
    $type::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)
    (New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $_.Refresh() }
    Update-DevViewUI
    Show-SchoMessage -Message $msg -Type "Success"
}
$schoUI = New-SchoWindow -Title "مدير إضافات VS Code" -Width 1300 -Height 700
$mainForm = $schoUI[0]
$pnlMainHeader = $schoUI[1]
$lblMainHeaderTitle = $schoUI[2]
$mainForm.Add_Load({
        $WS_MINIMIZEBOX = 0x20000; $GWL_STYLE = -16
        $currentStyle = [Win32]::GetWindowLong($mainForm.Handle, $GWL_STYLE)
        [Win32]::SetWindowLong($mainForm.Handle, $GWL_STYLE, ($currentStyle -bor $WS_MINIMIZEBOX)) | Out-Null
    })
$btnCloseApp = New-Object System.Windows.Forms.Label
$btnCloseApp.Text = "✕"; $btnCloseApp.SetBounds(1265, 5, 25, 25); $btnCloseApp.ForeColor = "White"; $btnCloseApp.Cursor = "Hand"; $btnCloseApp.TextAlign = "MiddleCenter"
$btnCloseApp.Add_Click({ $mainForm.Close() })
$btnCloseApp.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#E81123") }); $btnCloseApp.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::Transparent })
$pnlMainHeader.Controls.Add($btnCloseApp); $btnCloseApp.BringToFront()
$btnMinimizeApp = New-Object System.Windows.Forms.Label
$btnMinimizeApp.Text = "—"; $btnMinimizeApp.SetBounds(1235, 5, 25, 25); $btnMinimizeApp.ForeColor = "White"; $btnMinimizeApp.Cursor = "Hand"; $btnMinimizeApp.TextAlign = "MiddleCenter"
$btnMinimizeApp.Add_Click({ $mainForm.WindowState = 'Minimized' })
$btnMinimizeApp.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") }); $btnMinimizeApp.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::Transparent })
$pnlMainHeader.Controls.Add($btnMinimizeApp); $btnMinimizeApp.BringToFront()
$btnLangToggle = New-Object System.Windows.Forms.Label
$btnLangToggle.Text = "EN"; $btnLangToggle.SetBounds(1205, 5, 25, 25); $btnLangToggle.ForeColor = "White"; $btnLangToggle.Cursor = "Hand"; $btnLangToggle.TextAlign = "MiddleCenter"; $btnLangToggle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnLangToggle.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") }); $btnLangToggle.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::Transparent })
$pnlMainHeader.Controls.Add($btnLangToggle); $btnLangToggle.BringToFront()
$btnInstallVS = New-Object System.Windows.Forms.Label
$btnInstallVS.Text = "🖥️"
$btnInstallVS.SetBounds(1115, 5, 25, 25)
$btnInstallVS.ForeColor = "White"
$btnInstallVS.Cursor = "Hand"
$btnInstallVS.TextAlign = "MiddleCenter"
$btnInstallVS.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$toolTip.SetToolTip($btnInstallVS, "تحميل وتثبيت VS Code | Download & Install VS Code")
$btnInstallVS.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnInstallVS.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::Transparent })
$btnInstallVS.Add_Click({
        $btnInstallVS.Enabled = $false;
        $lblStats.Text = if ($script:isEnglish) { "Checking VS Code version..." } else { "جاري فحص إصدار VS Code..." };
        [System.Windows.Forms.Application]::DoEvents();
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        try {
            $apiData = Invoke-RestMethod -Uri "https://update.code.visualstudio.com/api/releases/stable" -Headers @{ "User-Agent" = "PowerShell" } -TimeoutSec 10;
            $latestVersion = $apiData[0];
        }
        catch {
            $latestVersion = "Unknown";
        }
        $codeCommand = Get-Command "code" -ErrorAction SilentlyContinue;
        $installedVersion = $null;
        if ($codeCommand) {
            $rawVersion = (& $codeCommand.Source --version)[0];
            if ($rawVersion -match "(\d+\.\d+\.\d+)") {
                $installedVersion = $matches[1];
            }
            else {
                $installedVersion = $rawVersion;
            }
        }
        $LRE = [char]0x202A; $PDF = [char]0x202C;
        $showLatest = "$LRE$latestVersion$PDF";
        $showInstalled = if ($installedVersion) { "$LRE$installedVersion$PDF" } else { "" };
        $shouldInstall = $false;
        if (-not $installedVersion) {
            $msg = if ($script:isEnglish) { "VS Code is not installed.`nLatest version available: $showLatest`n`nDo you want to install it?" } else { "برنامج VS Code غير مثبت على جهازك.`nأحدث إصدار متوفر: $showLatest`n`nهل تريد تثبيته الآن؟" };
            $res = [System.Windows.Forms.MessageBox]::Show($msg, "Install VS Code", "YesNo", "Information");
            if ($res -eq "Yes") { $shouldInstall = $true };
        }
        elseif ($installedVersion -eq $latestVersion) {
            $msg = if ($script:isEnglish) { "You already have the latest version of VS Code!`nInstalled Version: $showInstalled" } else { "أنت تمتلك أحدث إصدار بالفعل!`nالإصدار المثبت: $showInstalled" };
            Show-SchoMessage -Message $msg -Type "Success"
        }
        else {
            $msg = if ($script:isEnglish) { "VS Code is installed but there is an update.`n`nYour Version: $showInstalled`nLatest Version: $showLatest`n`nDo you want to upgrade?" } else { "يوجد تحديث متوفر لبرنامج VS Code.`n`nالإصدار الحالي لديك: $showInstalled`nالإصدار الجديد: $showLatest`n`nهل تريد الترقية الآن؟" };
            $res = [System.Windows.Forms.MessageBox]::Show($msg, "Upgrade VS Code", "YesNo", "Question");
            if ($res -eq "Yes") { $shouldInstall = $true };
        }
        if ($shouldInstall) {
            $downloadUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user";
            $installerPath = Join-Path $env:TEMP "VSCodeSetup.exe";
            Write-Log "📥 جاري تحميل الإصدار ($latestVersion)..." "📥 Downloading version ($latestVersion)...";
            $downloadSuccess = Download-FileWithProgress -url $downloadUrl -destination $installerPath;
            if ($downloadSuccess) {
                Write-Log "⚙️ جاري التثبيت في الخلفية (صامت)... يرجى الانتظار" "⚙️ Installing silently... please wait";
                $lblStats.Text = if ($script:isEnglish) { "Installing VS Code..." } else { "جاري تثبيت VS Code..." };
                [System.Windows.Forms.Application]::DoEvents();
                $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /MERGETASKS=!runcode" -Wait -PassThru;
                if ($installProcess.ExitCode -eq 0) {
                    Write-Log "🎉 تم التثبيت بنجاح!" "🎉 Successfully installed!";
                    $successMsg = if ($script:isEnglish) { "VS Code has been installed successfully!" } else { "تم تثبيت برنامج VS Code بنجاح على جهازك!" }
                    Show-SchoMessage -Message $successMsg -Type "Success"
                    $localAppData = [Environment]::GetFolderPath('LocalApplicationData');
                    $codeExe = "$localAppData\Programs\Microsoft VS Code\Code.exe";
                    Write-Log "🚀 جاري فتح البرنامج..." "🚀 Opening VS Code...";
                    if (Test-Path $codeExe) { Start-Process -FilePath $codeExe }
                    else { Start-Process "cmd.exe" -ArgumentList "/c code" -WindowStyle Hidden }
                }
                else {
                    Write-Log "❌ حدث خطأ أثناء التثبيت." "❌ Error during installation.";
                    $errorMsg = if ($script:isEnglish) { "An error occurred during the installation process." } else { "حدث خطأ مفاجئ أثناء محاولة تثبيت البرنامج." }
                    Show-SchoMessage -Message $errorMsg -Type "Error"
                }
                if (Test-Path $installerPath) { Remove-Item $installerPath -Force };
            }
        }
        $btnInstallVS.Enabled = $true;
        $lblStats.Text = if ($script:isEnglish) { "✅ Ready." } else { "✅ النظام جاهز." };
    })


$pnlActionButtons = New-Object System.Windows.Forms.FlowLayoutPanel
$pnlActionButtons.SetBounds(45, 125, 1210, 45)
$pnlActionButtons.BackColor = [System.Drawing.Color]::Transparent
$pnlActionButtons.FlowDirection = "RightToLeft"
$pnlActionButtons.WrapContents = $false
$pnlActionButtons.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
$pnlActionButtons.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 0)
$pnlActionButtons.Anchor = [System.Windows.Forms.AnchorStyles]::None
$mainForm.Controls.Add($pnlActionButtons)


$btnDevView = New-Object System.Windows.Forms.Label
$btnDevView.Size = New-Object System.Drawing.Size(160, 35)
$btnDevView.ForeColor = "White"; $btnDevView.Cursor = "Hand"; $btnDevView.TextAlign = "MiddleCenter"
$btnDevView.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnDevView.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$toolTip.SetToolTip($btnDevView, "تفعيل رؤية المطور | Enable DevView")
$btnDevView.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnDevView.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnDevView.Add_Click({ Set-DevView })
$btnDevView.BringToFront()
$picIcon = New-Object System.Windows.Forms.PictureBox
$picIcon.SetBounds(10, 7, 20, 20); $picIcon.SizeMode = "Zoom"
$pnlMainHeader.Controls.Add($picIcon); $picIcon.BringToFront()
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text = if ($script:isEnglish) { "- Remember Allah -" } else { "- اذكر الله يذكرك -" }
$lblFooter.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#888888")
$lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblFooter.SetBounds(20, 678, 1260, 20); $lblFooter.TextAlign = "MiddleCenter"
$mainForm.Controls.Add($lblFooter)
try {
    $currentPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $myIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($currentPath); $mainForm.Icon = $myIcon; $picIcon.Image = $myIcon.ToBitmap()
}
catch { $picIcon.Image = [System.Drawing.SystemIcons]::Application.ToBitmap() }
$pnlMainHeader.Controls.Add($picIcon); $picIcon.BringToFront()
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.InitialDelay = 300; $toolTip.ReshowDelay = 100
$toolTip.SetToolTip($btnCloseApp, "إغلاق البرنامج"); $toolTip.SetToolTip($btnMinimizeApp, "تصغير النافذة"); $toolTip.SetToolTip($btnLangToggle, "تغيير لغة الواجهة")
$extensionGroups = [ordered]@{
    "Themes"       = @{
        TitleAR = "المظهر والثيمات"; TitleEN = "Themes & UI"
        Extensions = [ordered]@{
            "One Dark Pro Theme"      = @{ ID = "zhuangtongfa.Material-theme"; DescAR = "ثيم ألوان داكنة احترافي مريح للعين"; DescEN = "Professional dark theme, comfortable for eyes" }
            "Dracula Official Theme"  = @{ ID = "dracula-theme.theme-dracula"; DescAR = "الثيم الليلي الشهير والمفضل للمبرمجين"; DescEN = "Famous dark theme loved by developers" }
            "GitHub Theme Theme"      = @{ ID = "GitHub.github-vscode-theme"; DescAR = "ثيمات جيتهاب الرسمية (الفاتحة والداكنة)"; DescEN = "Official GitHub themes (Light & Dark)" }
            "Deepdark Material Theme" = @{ ID = "Nimda.deepdark-material"; DescAR = "ثيم داكن جداً مبني على ماتيريال ديزاين"; DescEN = "Very dark theme based on Material Design" }
            "Material Icon Theme"     = @{ ID = "PKief.material-icon-theme"; DescAR = "أيقونات بتصميم ماتيريال لملفات المشروع"; DescEN = "Material design icons for project files" }
        }
    }
    "Web"          = @{
        TitleAR = "تطوير الويب"; TitleEN = "Web Development"
        Extensions = [ordered]@{
            "Auto Close Tag"               = @{ ID = "formulahendry.auto-close-tag"; DescAR = "إغلاق وسوم HTML/XML تلقائياً لتوفير الوقت"; DescEN = "Automatically close HTML/XML tags" }
            "Auto Complete Tag"            = @{ ID = "formulahendry.auto-complete-tag"; DescAR = "إكمال تلقائي لوسوم HTML/XML"; DescEN = "Auto completion for HTML/XML tags" }
            "Auto Rename Tag"              = @{ ID = "formulahendry.auto-rename-tag"; DescAR = "تعديل اسم وسم البداية والنهاية معاً"; DescEN = "Auto rename paired HTML/XML tags" }
            "HTML End Tag Labels"          = @{ ID = "anteprimorac.html-end-tag-labels"; DescAR = "إضافة تعليق يوضح نهاية وسم HTML"; DescEN = "Add comments to HTML end tags" }
            "html tag wrapper"             = @{ ID = "hwencc.html-tag-wrapper"; DescAR = "تغليف النص المحدد بوسم HTML"; DescEN = "Wrap selected code with HTML tags" }
            "CSS Peek"                     = @{ ID = "pranaygp.vscode-css-peek"; DescAR = "الوصول السريع لملفات CSS من داخل HTML"; DescEN = "Quickly peek and jump to CSS rules from HTML" }
            "Tailwind CSS IntelliSense"    = @{ ID = "bradlc.vscode-tailwindcss"; DescAR = "إكمال تلقائي وتلميحات لكلاسات Tailwind"; DescEN = "Intelligent Tailwind CSS completions" }
            "Bootstrap Class Autocomplete" = @{ ID = "torresgol10.bootstrap-class-autocomplete"; DescAR = "إكمال تلقائي لكلاسات إطار عمل Bootstrap"; DescEN = "Autocomplete for Bootstrap classes" }
            "Live Server"                  = @{ ID = "ritwickdey.LiveServer"; DescAR = "تشغيل سيرفر محلي وتحديث الصفحة تلقائياً"; DescEN = "Launch a local server with live reload" }
            "Live Preview"                 = @{ ID = "ms-vscode.live-server"; DescAR = "معاينة حية لصفحات الويب داخل المحرر"; DescEN = "Host a local server to preview web pages" }
            "Live Sass Compiler"           = @{ ID = "glenn2223.live-sass"; DescAR = "تحويل ملفات Sass/Scss إلى CSS في الوقت الفعلي"; DescEN = "Compile Sass/Scss to CSS in real-time" }
            "JavaScript (ES6) Snippets"    = @{ ID = "xabikos.JavaScriptSnippets"; DescAR = "مقتطفات جاهزة لأكواد جافاسكريبت ES6"; DescEN = "Code snippets for JavaScript in ES6 syntax" }
            "ES7 React/Redux Snippets"     = @{ ID = "dsznajder.es7-react-js-snippets"; DescAR = "مقتطفات سريعة لأكواد React و Redux"; DescEN = "Snippets for React, Redux and GraphQL" }
            "es6-string-html"              = @{ ID = "Tobermory.es6-string-html"; DescAR = "تلوين أكواد HTML داخل نصوص جافاسكريبت"; DescEN = "Syntax highlighting for HTML in ES6 strings" }
            "ESLint"                       = @{ ID = "dbaeumer.vscode-eslint"; DescAR = "اكتشاف الأخطاء وتنسيق كود الجافاسكربت"; DescEN = "Find and fix problems in JavaScript code" }
        }
    }
    "Productivity" = @{
        TitleAR = "أدوات الإنتاجية والكود"; TitleEN = "Productivity & Tools"
        Extensions = [ordered]@{
            "Prettier - Formatter" = @{ ID = "esbenp.prettier-vscode"; DescAR = "منسق أكواد احترافي يدعم أغلب اللغات"; DescEN = "An opinionated code formatter" }
            "Code Spell Checker"   = @{ ID = "streetsidesoftware.code-spell-checker"; DescAR = "مدقق إملائي للكلمات الإنجليزية داخل الأكواد"; DescEN = "Spelling checker for source code" }
            "Better Comments"      = @{ ID = "aaron-bond.better-comments"; DescAR = "تلوين وتنسيق التعليقات لتصبح مقروءة أكثر"; DescEN = "Improve your code commenting by color-coding" }
            "Bookmarks"            = @{ ID = "alefragnani.Bookmarks"; DescAR = "وضع علامات مرجعية للتنقل السريع في الكود"; DescEN = "Mark lines and jump to them easily" }
            "TODO Highlight"       = @{ ID = "wayou.vscode-todo-highlight"; DescAR = "تلوين وإبراز كلمات TODO و FIXME للرجوع إليها"; DescEN = "Highlight TODO, FIXME and other annotations" }
            "Separators"           = @{ ID = "alefragnani.separators"; DescAR = "إضافة خطوط فاصلة لترتيب وتنظيم الكود"; DescEN = "Add separator lines to organize code" }
            "Path Intellisense"    = @{ ID = "christian-kohler.path-intellisense"; DescAR = "إكمال تلقائي لمسارات الملفات والمجلدات"; DescEN = "Autocompletes filenames and paths" }
            "Image preview"        = @{ ID = "kisstkondoros.vscode-gutter-preview"; DescAR = "معاينة الصور مباشرة في هامش المحرر"; DescEN = "Shows image preview in the gutter" }
            "CodeSnap"             = @{ ID = "adpyke.codesnap"; DescAR = "التقاط صور احترافية للكود لمشاركتها"; DescEN = "Take beautiful screenshots of your code" }
            "GitHub Copilot Chat"  = @{ ID = "GitHub.copilot-chat"; DescAR = "مساعد الذكاء الاصطناعي لكتابة وشرح الأكواد"; DescEN = "AI pair programmer and chat assistant" }
            "PowerShell"           = @{ ID = "ms-vscode.PowerShell"; DescAR = "تطوير ودعم سكريبتات باورشيل داخل المحرر"; DescEN = "Develop PowerShell scripts in VS Code" }
        }
    }
}
$chromeExtensions = [ordered]@{
    "Security & Privacy" = @{
        TitleAR = "الأمان والخصوصية"; TitleEN = "Security & Privacy"
        Extensions = [ordered]@{
            "uBlock Origin"     = @{ ID = "bbdpgcaljkaaigfcomhidmneffjjjfgp"; DescAR = "مانع إعلانات قوي وخفيف"; DescEN = "Efficient ad blocker" }
            "Privacy Badger"    = @{ ID = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; DescAR = "حظر أدوات التتبع تلقائياً"; DescEN = "Blocks trackers automatically" }
            "McAfee WebAdvisor" = @{ ID = "hkflippjghmgogabcfmijhamoimhapkh"; DescAR = "الحماية من المواقع الضارة"; DescEN = "Protection against malicious sites" }
            "Planet VPN"        = @{ ID = "hipncndjamdcmphkgngojegjblibadbe"; DescAR = "خدمة VPN مجانية وسريعة"; DescEN = "Free and fast VPN service" }
        }
    }
    "Developer Tools"    = @{
        TitleAR = "أدوات المطورين"; TitleEN = "Developer Tools"
        Extensions = [ordered]@{
            "Tampermonkey"      = @{ ID = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; DescAR = "إدارة سكريبتات المستخدم"; DescEN = "Userscript manager" }
            "VisBug"            = @{ ID = "cdockenadnadldjbbgcallicgledbeoc"; DescAR = "أدوات تصميم المواقع"; DescEN = "Web design tools" }
            "Vue.js devtools"   = @{ ID = "nhdogjmejiglipccpnnnanhbledajbpd"; DescAR = "تصحيح تطبيقات Vue.js"; DescEN = "Vue.js debugging tools" }
            "Mobile Simulator"  = @{ ID = "ckejmhbmlajgoklhgbapkiccekfoccmk"; DescAR = "محاكاة الهواتف الذكية"; DescEN = "Smartphone simulator" }
            "CSS Peeper"        = @{ ID = "mbnbehikldjhnfehhnaidhjhoofhpehk"; DescAR = "فحص تنسيقات CSS"; DescEN = "Inspect CSS styles" }
            "Web Developer"     = @{ ID = "bfbameneiokkgbdmiekhjnmfkcnldhhm"; DescAR = "أدوات تطوير الويب الشاملة"; DescEN = "Comprehensive developer tools" }
            "Responsive Tester" = @{ ID = "ppbjpbekhmnekpphljbmeafemfiolbki"; DescAR = "اختبار تجاوب المواقع"; DescEN = "Responsive design tester" }
        }
    }
    "Productivity"       = @{
        TitleAR = "أدوات الإنتاجية"; TitleEN = "Productivity Tools"
        Extensions = [ordered]@{
            "Google Docs Offline" = @{ ID = "ghbmnnjooekpmoecnnnilnnbdlolhkhi"; DescAR = "تعديل المستندات بدون إنترنت"; DescEN = "Edit docs offline" }
            "Compose AI"          = @{ ID = "ddlbpiadoechcolndfeaonajmngmhblj"; DescAR = "مساعد كتابة ذكي"; DescEN = "AI writing assistant" }
            "Buster: Captcha"     = @{ ID = "mpbjkejclgfgadiemmefgebjfooflfhl"; DescAR = "حل الكابتشا تلقائياً"; DescEN = "Solve CAPTCHAs automatically" }
            "Chrome Remote"       = @{ ID = "inomeogfingihgjfjlpeplalcfajhgai"; DescAR = "الوصول لسطح المكتب عن بعد"; DescEN = "Remote desktop access" }
        }
    }
    "Media & Design"     = @{
        TitleAR = "الوسائط والتصميم"; TitleEN = "Media & Design"
        Extensions = [ordered]@{
            "ColorZilla"       = @{ ID = "bhlhnicpbhignbdhedgjhgdocnmhomnp"; DescAR = "أداة التقاط الألوان"; DescEN = "Color picker tool" }
            "GoFullPage"       = @{ ID = "fdpohaocaechififmbbbbbknoalclacl"; DescAR = "تصوير الصفحة بالكامل"; DescEN = "Full page screen capture" }
            "Fonts Ninja"      = @{ ID = "eljapbgkmlngdpckoiiibecpemleclhh"; DescAR = "التعرف على الخطوط"; DescEN = "Identify fonts on sites" }
            "Image Downloader" = @{ ID = "cnpniohnfphhjihaiiggeabnkjhpaldj"; DescAR = "تحميل صور المواقع"; DescEN = "Download website images" }
            "WhatFont"         = @{ ID = "jabopobgcpjmedljpbcaablpmlmfcogm"; DescAR = "أداة فحص الخطوط"; DescEN = "Font inspector tool" }
            "WebP Converter"   = @{ ID = "pbcfbdlbkdfobidmdoondbgdfpjolhci"; DescAR = "تحويل صور WebP"; DescEN = "WebP image converter" }
            "What the Font"    = @{ ID = "kmbggdhhanillmfflpmdmnkpheodlmdn"; DescAR = "اكتشاف أنواع الخطوط"; DescEN = "Identify font types" }
        }
    }
}
$titleFont = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$regularFont = New-Object System.Drawing.Font("Segoe UI", 10)
$smallFont = New-Object System.Drawing.Font("Segoe UI", 9)
$consoleFont = New-Object System.Drawing.Font("Consolas", 9)
$lblBodyTitle = New-Object System.Windows.Forms.Label
$lblBodyTitle.Text = "مدير إضافات VS Code الاحترافي"; $lblBodyTitle.Font = $titleFont; $lblBodyTitle.Location = New-Object System.Drawing.Point(0, 45)
$lblBodyTitle.Size = New-Object System.Drawing.Size(1300, 35); $lblBodyTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC"); $lblBodyTitle.TextAlign = "MiddleCenter"
$mainForm.Controls.Add($lblBodyTitle)
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.Location = New-Object System.Drawing.Point(20, 170)
$flowLayoutPanel.Size = New-Object System.Drawing.Size(1260, 295)
$flowLayoutPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1E1E1E")
$flowLayoutPanel.AutoScroll = $true
$mainForm.Controls.Add($flowLayoutPanel)
function Update-Display {
    param($data, [bool]$isChromeList)
    $flowLayoutPanel.Controls.Clear()
    foreach ($groupKey in $data.Keys) {
        $groupData = $data[$groupKey]
        $pnlHeaderGroup = New-Object System.Windows.Forms.Panel
        $pnlHeaderGroup.Size = New-Object System.Drawing.Size(1200, 40)
        $pnlHeaderGroup.Margin = New-Object System.Windows.Forms.Padding(10, 20, 0, 5)
        $lblGroupHeader = New-Object System.Windows.Forms.Label
        $lblGroupHeader.Text = $(if ($script:isEnglish) { $groupData.TitleEN } else { $groupData.TitleAR })
        $lblGroupHeader.Tag = @{ TitleAR = $groupData.TitleAR; TitleEN = $groupData.TitleEN }
        $lblGroupHeader.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0098FF")
        $lblGroupHeader.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $lblGroupHeader.AutoSize = $true
        $lblGroupHeader.Dock = $(if ($script:isEnglish) { "Left" } else { "Right" })
        $pnlHeaderGroup.Controls.Add($lblGroupHeader)
        if (-not $isChromeList) {
            $groupButtons = New-Object System.Collections.Generic.List[System.Windows.Forms.Button]
            $btnSelectAll = New-Object System.Windows.Forms.Button
            $btnSelectAll.Text = $(if ($script:isEnglish) { "Select All" } else { "تحديد القسم" })
            $btnSelectAll.Tag = @{ Type = "SelectAll"; Buttons = $groupButtons }
            $btnSelectAll.Size = New-Object System.Drawing.Size(120, 28)
            $btnSelectAll.FlatStyle = "Flat"
            $btnSelectAll.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#252526")
            $btnSelectAll.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0098FF")
            $btnSelectAll.Location = New-Object System.Drawing.Point($(if ($script:isEnglish) { 1075 } else { 5 }), 7)
            $btnSelectAll.Add_Click({
                    $activeColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC")
                    $allSelected = $true
                    foreach ($b in $this.Tag.Buttons) { if ($b.BackColor.ToArgb() -ne $activeColor.ToArgb()) { $allSelected = $false; break } }
                    foreach ($b in $this.Tag.Buttons) {
                        if (-not $allSelected) {
                            $b.BackColor = $activeColor; $b.ForeColor = [System.Drawing.Color]::White; if (-not $b.Text.StartsWith("✓ ")) { $b.Text = "✓ " + $b.Text }
                        }
                        else {
                            $b.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30"); $b.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC"); if ($b.Text.StartsWith("✓ ")) { $b.Text = $b.Text.Substring(2) }
                        }
                    }
                })
            $pnlHeaderGroup.Controls.Add($btnSelectAll)
        }
        $flowLayoutPanel.Controls.Add($pnlHeaderGroup)
        foreach ($ext in $groupData.Extensions.GetEnumerator()) {
            $btnExt = New-Object System.Windows.Forms.Button
            $btnExt.Text = $ext.Key; $btnExt.Tag = $ext.Value; $btnExt.Size = New-Object System.Drawing.Size(235, 38)
            $btnExt.Margin = New-Object System.Windows.Forms.Padding(5); $btnExt.FlatStyle = "Flat"
            $btnExt.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30"); $btnExt.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC")
            $btnExt.Cursor = [System.Windows.Forms.Cursors]::Hand
            $toolTip.SetToolTip($btnExt, $(if ($script:isEnglish) { $ext.Value.DescEN } else { $ext.Value.DescAR }))
            $btnExt.Add_Click({
                    if ($isChromeList) {
                        $isCurrentlySelected = ($this.BackColor.ToArgb() -eq [System.Drawing.ColorTranslator]::FromHtml("#007ACC").ToArgb())
                        if (-not $isCurrentlySelected) {
                            $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC")
                            $this.ForeColor = [System.Drawing.Color]::White
                            if (-not $this.Text.Contains("✓")) { $this.Text = $this.Text + " ✓" }
                        }
                        else {
                            $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
                            $this.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC")
                            $this.Text = $this.Text.Replace(" ✓", "").Trim()
                        }
                    }
                    else {
                        $activeColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC")
                        if ($this.BackColor.ToArgb() -ne $activeColor.ToArgb()) {
                            $this.BackColor = $activeColor; $this.ForeColor = [System.Drawing.Color]::White; if (-not $this.Text.Contains("✓")) { $this.Text = "✓ " + $this.Text }
                        }
                        else {
                            $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30"); $this.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#CCCCCC"); if ($this.Text.Contains("✓ ")) { $this.Text = $this.Text.Replace("✓ ", "") }
                        }
                    }
                })
            $flowLayoutPanel.Controls.Add($btnExt)
            if (-not $isChromeList) { $groupButtons.Add($btnExt) }
        }
    }
}
function Animate-TabTransition {
    param([int]$TargetY, [int]$TargetHeight)
    $flowLayoutPanel.Visible = $false
    $flowLayoutPanel.Location = New-Object System.Drawing.Point(20, ($TargetY + 30))
    $flowLayoutPanel.Size = New-Object System.Drawing.Size(1260, $TargetHeight)
    $flowLayoutPanel.Visible = $true
    $global:animTimer = New-Object System.Windows.Forms.Timer
    $global:animTimer.Interval = 10
    $global:animTimer.Add_Tick({
            if ($flowLayoutPanel.Top -gt $TargetY) {
                $flowLayoutPanel.Top -= 5
            }
            else {
                $flowLayoutPanel.Top = $TargetY
                $global:animTimer.Stop()
            }
        })
    $global:animTimer.Start()
}
$pnlTabs = New-Object System.Windows.Forms.Panel
$pnlTabs.SetBounds(5, 5, 320, 25)
$pnlMainHeader.Controls.Add($pnlTabs)
$pnlTabs.BringToFront()
$btnTabVS = New-Object System.Windows.Forms.Button
$btnTabVS.Text = "VS Code"; $btnTabVS.Size = New-Object System.Drawing.Size(150, 25); $btnTabVS.Dock = "Left"
$btnTabVS.FlatStyle = "Flat"; $btnTabVS.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC"); $btnTabVS.ForeColor = "White"
$btnTabVS.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$btnTabVS.Add_Click({
        $script:isChromeTab = $false
        $this.BackColor = "#007ACC"; $btnTabChrome.BackColor = "#2D2D30"
        Update-Display -data $extensionGroups -isChromeList $false
        $btnInstallAll.Visible = $true
        $btnInstallSelected.Width = 615
        $btnInstallSelected.Location = New-Object System.Drawing.Point(665, 630)
        $lblMainHeaderTitle.Text = if ($script:isEnglish) { "VS Code Extensions Manager" } else { "مدير إضافات VS Code" }
        $btnExport.Visible = $true
        $btnImport.Visible = $true
        $btnInstallVS.Visible = $true
        $btnInstallNode.Visible = $true
        $btnDevView.Visible = $true
        $btnInstallGit.Visible = $true
        $btnUpdateExts.Visible = $true
        $flowLayoutPanel.Location = New-Object System.Drawing.Point(20, 170)
        $flowLayoutPanel.Size = New-Object System.Drawing.Size(1260, 295)
        $lblBodyTitle.Text = if ($script:isEnglish) { "VS Code Pro Extension Manager" } else { "مدير إضافات VS Code الاحترافي" }
    })
$btnTabChrome = New-Object System.Windows.Forms.Button
$btnTabChrome.Text = "Chrome"; $btnTabChrome.Size = New-Object System.Drawing.Size(150, 25); $btnTabChrome.Dock = "Right"
$btnTabChrome.FlatStyle = "Flat"; $btnTabChrome.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30"); $btnTabChrome.ForeColor = "White"
$btnTabChrome.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$btnTabChrome.Add_Click({
        $script:isChromeTab = $true
        $this.BackColor = "#007ACC"; $btnTabVS.BackColor = "#2D2D30"
        Update-Display -data $chromeExtensions -isChromeList $true
        $btnInstallAll.Visible = $false
        $btnInstallSelected.Width = 1260
        $btnInstallSelected.Location = New-Object System.Drawing.Point(20, 630)
        $lblMainHeaderTitle.Text = if ($script:isEnglish) { "Chrome Extensions Manager" } else { "مدير إضافات Chrome" }
        $btnExport.Visible = $false
        $btnImport.Visible = $false
        $btnInstallVS.Visible = $false
        $btnInstallNode.Visible = $false
        $btnDevView.Visible = $false
        $btnInstallGit.Visible = $false
        $btnUpdateExts.Visible = $false
        $flowLayoutPanel.Location = New-Object System.Drawing.Point(20, 125)
        $flowLayoutPanel.Size = New-Object System.Drawing.Size(1260, 340)
        $lblBodyTitle.Text = if ($script:isEnglish) { "Chrome Pro Extension Manager" } else { "مدير إضافات Chrome الاحترافي" }
    })
$pnlTabs.Controls.Add($btnTabVS)
$pnlTabs.Controls.Add($btnTabChrome)
$script:placeholderAR = "ادخل أسم الاضافة ...🔍"
$script:placeholderEN = "🔍... Enter the extension name"
$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Size = New-Object System.Drawing.Size(400, 30)
$txtSearch.Location = New-Object System.Drawing.Point(450, 85)
$txtSearch.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#252526")
$txtSearch.ForeColor = [System.Drawing.Color]::Gray
$txtSearch.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtSearch.BorderStyle = "FixedSingle"
$txtSearch.TextAlign = "Center"
$txtSearch.Text = if ($script:isEnglish) { $script:placeholderEN } else { $script:placeholderAR }
$txtSearch.Add_Enter({
        if ($this.Text -eq $script:placeholderAR -or $this.Text -eq $script:placeholderEN) {
            $this.Text = ""
            $this.ForeColor = [System.Drawing.Color]::White
        }
    })
$txtSearch.Add_Leave({
        if ([string]::IsNullOrWhiteSpace($this.Text)) {
            $this.ForeColor = [System.Drawing.Color]::Gray
            $this.Text = if ($script:isEnglish) { $script:placeholderEN } else { $script:placeholderAR }
        }
    })
$txtSearch.Add_TextChanged({
        $currentText = $this.Text
        if ($currentText -eq $script:placeholderAR -or $currentText -eq $script:placeholderEN -or [string]::IsNullOrWhiteSpace($currentText)) {
            foreach ($ctrl in $flowLayoutPanel.Controls) { $ctrl.Visible = $true }
            return
        }
        $searchTerm = $currentText.ToLower().Trim()
        foreach ($ctrl in $flowLayoutPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button]) {
                $cleanName = $ctrl.Text.Replace("✓ ", "").ToLower()
                $ctrl.Visible = $cleanName.Contains($searchTerm)
            }
        }
        foreach ($ctrl in $flowLayoutPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) {
            }
        }
    })
$mainForm.Controls.Add($txtSearch)
$lblListSubtitle.Location = New-Object System.Drawing.Point(20, 90)
$lblListSubtitle.Size = New-Object System.Drawing.Size(400, 25)
$lblListSubtitle.Location = New-Object System.Drawing.Point(300, 90)
$panelProgressBg = New-Object System.Windows.Forms.Panel
$panelProgressBg.Location = New-Object System.Drawing.Point(20, 480); $panelProgressBg.Size = New-Object System.Drawing.Size(1260, 16); $panelProgressBg.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#333333"); $mainForm.Controls.Add($panelProgressBg)
$panelProgressFill = New-Object System.Windows.Forms.Panel
$panelProgressFill.Location = New-Object System.Drawing.Point(0, 0); $panelProgressFill.Size = New-Object System.Drawing.Size(0, 16); $panelProgressFill.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0098FF"); $panelProgressBg.Controls.Add($panelProgressFill)
$lblStats = New-Object System.Windows.Forms.Label
$lblStats.Text = "في انتظار بدء العمليات..."; $lblStats.Font = $smallFont; $lblStats.Location = New-Object System.Drawing.Point(20, 505); $lblStats.Size = New-Object System.Drawing.Size(1260, 20); $lblStats.ForeColor = [System.Drawing.Color]::LightGray; $lblStats.TextAlign = "MiddleCenter"; $mainForm.Controls.Add($lblStats)
$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 530); $txtLog.Size = New-Object System.Drawing.Size(1260, 85); $txtLog.Font = $consoleFont; $txtLog.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#111111"); $txtLog.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#4AF626")
$txtLog.BorderStyle = "None"; $txtLog.ReadOnly = $true; $txtLog.RightToLeft = [System.Windows.Forms.RightToLeft]::Yes; $txtLog.Text = ($script:LogHistoryAR.ToArray() -join "`n") + "`n"
$mainForm.Controls.Add($txtLog)
$btnInstallAll = New-Object System.Windows.Forms.Button
$btnInstallAll = New-Object System.Windows.Forms.Button
$btnInstallAll.Text = "تثبيت الكل"; $btnInstallAll.Location = New-Object System.Drawing.Point(20, 630); $btnInstallAll.Size = New-Object System.Drawing.Size(615, 45); $btnInstallAll.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold); $btnInstallAll.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC"); $btnInstallAll.ForeColor = [System.Drawing.Color]::White; $btnInstallAll.FlatStyle = "Flat"; $btnInstallAll.FlatAppearance.BorderSize = 0; $btnInstallAll.Cursor = [System.Windows.Forms.Cursors]::Hand; $mainForm.Controls.Add($btnInstallAll)
$btnInstallSelected = New-Object System.Windows.Forms.Button
$btnInstallSelected = New-Object System.Windows.Forms.Button
$btnInstallSelected.Text = "تثبيت المحدد"; $btnInstallSelected.Location = New-Object System.Drawing.Point(665, 630); $btnInstallSelected.Size = New-Object System.Drawing.Size(615, 45); $btnInstallSelected.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold); $btnInstallSelected.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0E639C"); $btnInstallSelected.ForeColor = [System.Drawing.Color]::White; $btnInstallSelected.FlatStyle = "Flat"; $btnInstallSelected.FlatAppearance.BorderSize = 0; $btnInstallSelected.Cursor = [System.Windows.Forms.Cursors]::Hand; $mainForm.Controls.Add($btnInstallSelected)
$btnLangToggle.Add_Click({
        $script:isEnglish = -not $script:isEnglish
        if ($script:isEnglish) {
            # // التبديل للانجليزية: ترتيب من اليسار لليمين
            $pnlActionButtons.FlowDirection = "LeftToRight"
            # // الموقع ثابت في النقطة 30 لضمان التوسيط
            $pnlActionButtons.Location = New-Object System.Drawing.Point(30, 125) 
        }
        else {
            # // التبديل للعربية: ترتيب من اليمين لليسار
            $pnlActionButtons.FlowDirection = "RightToLeft"
            # // الموقع ثابت تماماً في النقطة 30 عند العودة للعربية
            $pnlActionButtons.Location = New-Object System.Drawing.Point(30, 125)
        }
        $btnLangToggle.Text = if ($script:isEnglish) { "AR" } else { "EN" }
        $mainForm.RightToLeft = if ($script:isEnglish) { "No" } else { "Yes" }
        $flowLayoutPanel.RightToLeft = if ($script:isEnglish) { "No" } else { "Yes" }
        $txtLog.RightToLeft = if ($script:isEnglish) { "No" } else { "Yes" }
        if ($script:isChromeTab) {
            $lblMainHeaderTitle.Text = if ($script:isEnglish) { "Chrome Extensions Manager" } else { "مدير إضافات Chrome" }
        }
        else {
            $lblMainHeaderTitle.Text = if ($script:isEnglish) { "VS Code Extensions Manager" } else { "مدير إضافات VS Code" }
        }
        if ($script:isChromeTab) {
            $lblBodyTitle.Text = if ($script:isEnglish) { "Chrome Pro Extension Manager" } else { "مدير إضافات Chrome الاحترافي" }
        }
        else {
            $lblBodyTitle.Text = if ($script:isEnglish) { "VS Code Pro Extension Manager" } else { "مدير إضافات VS Code الاحترافي" }
        }
        $btnExport.Text = if ($script:isEnglish) { "$([char]0x21F1) Export" } else { "تصدير $([char]0x21F1)" }
        $btnImport.Text = if ($script:isEnglish) { "Import $([char]0x21F2)" } else { "$([char]0x21F2) استيراد" }
        $btnInstallVS.Text = if ($script:isEnglish) { "Install VS Code" } else { "تثبيت VS Code" }
        $btnInstallNode.Text = if ($script:isEnglish) { "Install Node.js" } else { "تثبيت Node.js" }
        $btnInstallGit.Text = if ($script:isEnglish) { "Install Git" } else { "تثبيت Git" }
        $btnUpdateExts.Text = if ($script:isEnglish) { "Update All Exts" } else { "تحديث كل الإضافات" }
        $btnWorkEnv.Text = if ($script:isEnglish) { "Dev Env Installer" } else { "أداة تثبيت بيئة العمل" }
        Update-DevViewUI
        $btnWorkEnv.Text = if ($script:isEnglish) { "Dev Env Installer" } else { "أداة تثبيت بيئة العمل" }
        $lblListSubtitle.Text = if ($script:isEnglish) { "Click on the extensions to install:" } else { "انقر على الإضافات التي ترغب بتثبيتها:" }
        $btnInstallAll.Text = if ($script:isEnglish) { "Install All" } else { "تثبيت الكل" }
        $btnInstallSelected.Text = if ($script:isEnglish) { "Install Selected" } else { "تثبيت المحدد" }
        $nodeTip = if ($script:isEnglish) { "Check & Install Node.js" } else { "فحص وتحميل Node.js" }
        $toolTip.SetToolTip($btnInstallNode, $nodeTip)
        $toolTip.SetToolTip($btnExport, (if ($script:isEnglish) { "Backup installed extensions" } else { "نسخ احتياطي للإضافات المثبتة" }))
        $toolTip.SetToolTip($btnImport, (if ($script:isEnglish) { "Import extensions from file" } else { "استيراد إضافات من ملف نصي" }))
        $toolTip.SetToolTip($btnInstallVS, (if ($script:isEnglish) { "Download & Install VS Code" } else { "تحميل وتثبيت برنامج Visual Studio Code" }))
        $toolTip.SetToolTip($btnInstallNode, (if ($script:isEnglish) { "Download & Install Node.js" } else { "تحميل وتثبيت بيئة البرمجة Node.js" }))
        $lblFooter.Text = if ($script:isEnglish) { "- Remember Allah -" } else { "- اذكر الله يذكرك -" }
        if ($txtSearch.Text -eq $script:placeholderAR -or $txtSearch.Text -eq $script:placeholderEN) {
            $txtSearch.Text = if ($script:isEnglish) { $script:placeholderEN } else { $script:placeholderAR }
        }
        $txtLog.Text = if ($script:isEnglish) { ($script:LogHistoryEN.ToArray() -join "`n") } else { ($script:LogHistoryAR.ToArray() -join "`n") }
        foreach ($ctrl in $flowLayoutPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Panel]) {
                foreach ($sub in $ctrl.Controls) {
                    if ($null -ne $sub.Tag) {
                        if ($sub.Tag.TitleAR) {
                            $sub.Text = if ($script:isEnglish) { $sub.Tag.TitleEN } else { $sub.Tag.TitleAR }
                            $sub.Dock = if ($script:isEnglish) { "Left" } else { "Right" }
                        }
                        if ($sub.Tag.Type -eq "SelectAll") {
                            $sub.Text = if ($script:isEnglish) { "Select All" } else { "تحديد القسم" }
                            $sub.Location = New-Object System.Drawing.Point($(if ($script:isEnglish) { 1075 } else { 5 }), 7)
                        }
                    }
                }
            }
            elseif ($ctrl -is [System.Windows.Forms.Button]) {
                $toolTip.SetToolTip($ctrl, $(if ($script:isEnglish) { $ctrl.Tag.DescEN } else { $ctrl.Tag.DescAR }))
            }
        }
        $txtLog.SelectionStart = $txtLog.Text.Length; $txtLog.ScrollToCaret()
        $flowLayoutPanel.Visible = $true; $txtLog.Visible = $true
        $mainForm.Refresh()
    })
$btnExport = New-Object System.Windows.Forms.Label
$btnExport.Text = "تصدير $([char]0x21F1)"
$btnExport.Size = New-Object System.Drawing.Size(120, 35)
$btnExport.ForeColor = "White"; $btnExport.Cursor = "Hand"; $btnExport.TextAlign = "MiddleCenter"
$btnExport.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnExport.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnExport.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnExport.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnExport.Add_Click({
        $saveFile = New-Object System.Windows.Forms.SaveFileDialog
        $saveFile.Filter = "Text Files (*.txt)|*.txt"
        $saveFile.FileName = "VSCode_Extensions_Backup.txt"
        if ($saveFile.ShowDialog() -eq "OK") {
            Write-Log "📂 جاري استخراج قائمة الإضافات..." "📂 Exporting extensions list..."
            $codeCommand = Get-Command "code" -ErrorAction SilentlyContinue
            if ($codeCommand) {
                & $codeCommand.Source --list-extensions | Out-File $saveFile.FileName
                Write-Log "✅ تم الحفظ بنجاح في: $($saveFile.FileName)" "✅ Backup saved successfully!"
            }
        }
    })
$btnImport = New-Object System.Windows.Forms.Label
$btnImport.Text = "$([char]0x21F2) استيراد"
$btnImport.Size = New-Object System.Drawing.Size(120, 35)
$btnImport.ForeColor = "White"; $btnImport.Cursor = "Hand"; $btnImport.TextAlign = "MiddleCenter"
$btnImport.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnImport.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnImport.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnImport.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnImport.Add_Click({
        $openFile = New-Object System.Windows.Forms.OpenFileDialog
        $openFile.Filter = "Text Files (*.txt)|*.txt"
        if ($openFile.ShowDialog() -eq "OK") {
            $exts = Get-Content $openFile.FileName | Where-Object { $_ -match '\.' }
            if ($exts.Count -gt 0) {
                $msg = if ($script:isEnglish) { "Install $($exts.Count) extensions?" } else { "تثبيت $($exts.Count) إضافة؟" }
                if ((Show-ConfirmDialog $msg) -eq "OK") { Install-Extensions -itemsToInstall $exts }
            }
        }
    })
$btnInstallVS = New-Object System.Windows.Forms.Label
$btnInstallVS.Text = "$([char]0x1F4BB) تثبيت VS Code"
$btnInstallVS.Size = New-Object System.Drawing.Size(160, 35)
$btnInstallVS.ForeColor = "White"; $btnInstallVS.Cursor = "Hand"; $btnInstallVS.TextAlign = "MiddleCenter"
$btnInstallVS.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnInstallVS.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnInstallVS.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnInstallVS.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnInstallVS.Add_Click({
        $btnInstallVS.Enabled = $false
        $lblStats.Text = if ($script:isEnglish) { "Checking VS Code..." } else { "جاري فحص VS Code..." }
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $apiData = Invoke-RestMethod -Uri "https://update.code.visualstudio.com/api/releases/stable" -Headers @{ "User-Agent" = "PowerShell" }
            $latestVersion = $apiData[0]
        }
        catch { $latestVersion = "Unknown" }
        $codeCommand = Get-Command "code" -ErrorAction SilentlyContinue
        $installedVersion = $null
        if ($codeCommand) {
            $rawVersion = (& $codeCommand.Source --version)[0]
            if ($rawVersion -match "(\d+\.\d+\.\d+)") { $installedVersion = $matches[1] } else { $installedVersion = $rawVersion }
        }
        $codeProcess = Get-Process "Code" -ErrorAction SilentlyContinue
        if ($installedVersion -eq $latestVersion -and $installedVersion -ne $null) {
            $msg = if ($script:isEnglish) { "You have the latest version!" } else { "أنت تملك أحدث إصدار بالفعل!" }
            Show-SchoMessage -Message $msg -Type "Success"
        }
        elseif ($codeProcess) {
            $msg = if ($script:isEnglish) { "Please close VS Code to update." } else { "يرجى إغلاق VS Code لتثبيت التحديث." }
            Show-SchoMessage -Message $msg -Type "Error"
        }
        else {
            $msg = if ($installedVersion) { if ($script:isEnglish) { "Update to $latestVersion?" } else { "هل تريد التحديث إلى $latestVersion؟" } }
            else { if ($script:isEnglish) { "Install VS Code $latestVersion?" } else { "تثبيت VS Code إصدار $latestVersion؟" } }
            if ((Show-ConfirmDialog $msg) -eq "OK") {
                $installerPath = Join-Path $env:TEMP "VSCodeSetup.exe"
                if (Download-FileWithProgress -url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -destination $installerPath) {
                    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait
                    if (Test-Path $installerPath) { Remove-Item $installerPath -Force }
                }
            }
        }
        $btnInstallVS.Enabled = $true
        $lblStats.Text = if ($script:isEnglish) { "✅ Ready." } else { "✅ النظام جاهز." }
    })
$btnInstallVS.BringToFront()
$btnInstallNode = New-Object System.Windows.Forms.Label
$btnInstallNode.Text = "تثبيت Node.js"
$btnInstallNode.Size = New-Object System.Drawing.Size(160, 35)
$btnInstallNode.ForeColor = "White"; $btnInstallNode.Cursor = "Hand"; $btnInstallNode.TextAlign = "MiddleCenter"
$btnInstallNode.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnInstallNode.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnInstallNode.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnInstallNode.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnInstallNode.Add_Click({
        if (-not (Test-NodeJS)) {
            Show-NodeJsDialog
        }
        else {
            $msg = if ($script:isEnglish) { "Node.js is already installed!" } else { "برنامج Node.js مثبت بالفعل على جهازك!" }
            Show-SchoMessage -Message $msg -Type "Success"
        }
    })
$btnInstallNode.BringToFront()
$btnInstallGit = New-Object System.Windows.Forms.Label
$btnInstallGit.Text = if ($script:isEnglish) { "Install Git" } else { "تثبيت Git" }
$btnInstallGit.Size = New-Object System.Drawing.Size(120, 35)
$btnInstallGit.ForeColor = "White"; $btnInstallGit.Cursor = "Hand"; $btnInstallGit.TextAlign = "MiddleCenter"
$btnInstallGit.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnInstallGit.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnInstallGit.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnInstallGit.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnInstallGit.BringToFront()
$btnInstallGit.Add_Click({
        $btnInstallGit.Enabled = $false
        $lblStats.Text = if ($script:isEnglish) { "Checking Git version..." } else { "جاري فحص إصدار Git..." }
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $gitApi = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest"
            $latestGitVer = $gitApi.tag_name.Replace("v", "")
            $gitDownloadUrl = ($gitApi.assets | Where-Object { $_.name -match "64-bit.exe" })[0].browser_download_url
        }
        catch { $latestGitVer = "Unknown" }
        $gitCheck = Get-Command "git" -ErrorAction SilentlyContinue
        $installedGitVer = $null
        if ($gitCheck) {
            $gitRaw = (& "git" --version)
            if ($gitRaw -match "(\d+\.\d+\.\d+)") { $installedGitVer = $matches[1] }
        }
        $shouldInstallGit = $false
        if (-not $installedGitVer) {
            $msg = if ($script:isEnglish) { "Git is not installed. Install version $latestGitVer?" } else { "برنامج Git غير مثبت. هل تريد تثبيت الإصدار $latestGitVer؟" }
            if ((Show-ConfirmDialog $msg) -eq "OK") { $shouldInstallGit = $true }
        }
        elseif ($installedGitVer -ne $latestGitVer) {
            $msg = if ($script:isEnglish) { "New Git update found! Upgrade to $latestGitVer?" } else { "يوجد تحديث لبرنامج Git! هل تريد الترقية للإصدار $latestGitVer؟" }
            if ((Show-ConfirmDialog $msg) -eq "OK") { $shouldInstallGit = $true }
        }
        else {
            $msg = if ($script:isEnglish) { "Git is already up to date!" } else { "لديك أحدث إصدار من Git بالفعل!" }
            Show-SchoMessage -Message $msg -Type "Success"
        }
        if ($shouldInstallGit) {
            $gitInstallerPath = Join-Path $env:TEMP "GitSetup.exe"
            Write-Log "📥 جاري تحميل Git إصدار ($latestGitVer)..." "📥 Downloading Git ($latestGitVer)..."
            if (Download-FileWithProgress -url $gitDownloadUrl -destination $gitInstallerPath) {
                Write-Log "⚙️ جاري تثبيت Git صامتاً..." "⚙️ Installing Git silently..."
                $gitProcess = Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS" -Wait -PassThru
                if ($gitProcess.ExitCode -eq 0) {
                    Write-Log "🎉 تم تثبيت Git بنجاح!" "🎉 Git installed successfully!"
                    Show-SchoMessage -Message (if ($script:isEnglish) { "Git installed!" } else { "تم تثبيت Git بنجاح!" })
                }
                if (Test-Path $gitInstallerPath) { Remove-Item $gitInstallerPath -Force }
            }
        }
        $btnInstallGit.Enabled = $true
        $lblStats.Text = if ($script:isEnglish) { "✅ Ready." } else { "✅ النظام جاهز." }
    })
$btnUpdateExts = New-Object System.Windows.Forms.Label
$btnUpdateExts.Text = if ($script:isEnglish) { "Update All Exts" } else { "تحديث كل الإضافات" }
$btnUpdateExts.Size = New-Object System.Drawing.Size(150, 35)
$btnUpdateExts.ForeColor = "White"; $btnUpdateExts.Cursor = "Hand"; $btnUpdateExts.TextAlign = "MiddleCenter"
$btnUpdateExts.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnUpdateExts.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)
$btnUpdateExts.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnUpdateExts.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })
$btnUpdateExts.BringToFront()



$btnWorkEnv = New-Object System.Windows.Forms.Label
$btnWorkEnv.Text = if ($script:isEnglish) { "Dev Env Installer" } else { "أداة تثبيت بيئة العمل" }
$btnWorkEnv.Size = New-Object System.Drawing.Size(180, 35) # عرض الزر أكبر قليلاً ليناسب النص
$btnWorkEnv.ForeColor = "White"; $btnWorkEnv.Cursor = "Hand"; $btnWorkEnv.TextAlign = "MiddleCenter"
$btnWorkEnv.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$btnWorkEnv.Font = New-Object System.Drawing.Font("Segoe UI Symbol", 10, [System.Drawing.FontStyle]::Bold)

# إضافة تأثيرات الألوان عند مرور الماوس
$btnWorkEnv.Add_MouseEnter({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#3F3F41") })
$btnWorkEnv.Add_MouseLeave({ $this.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30") })

# برمجة ما سيحدث عند الضغط على الزر (تحميل وتشغيل الملف)
$btnWorkEnv.Add_Click({
        Start-Process "https://github.com/SULAIMAN-SHO/WebBuilder-push/releases/download/v1.0.0.0/WebBuilder.exe"
    })


$btnUpdateExts.Add_Click({
        $codeCommand = Get-Command "code" -ErrorAction SilentlyContinue
        if (-not $codeCommand) {
            Show-SchoMessage -Message (if ($script:isEnglish) { "VS Code not found!" } else { "لم يتم العثور على VS Code!" }) -Type "Error"
            return
        }
        $btnUpdateExts.Enabled = $false
        Write-Log "🔍 جاري البحث عن تحديثات حقيقية... انتظر قليلاً" "🔍 Checking for actual updates... please wait"
        [System.Windows.Forms.Application]::DoEvents()
        $outdatedRaw = & $codeCommand.Source --outdated
        $toUpdate = @()
        if ($outdatedRaw.Count -gt 2) {
            for ($i = 2; $i -lt $outdatedRaw.Count; $i++) {
                if ($outdatedRaw[$i] -match '^([^\s]+)') {
                    $toUpdate += $matches[1]
                }
            }
        }
        if ($toUpdate.Count -gt 0) {
            $msg = if ($script:isEnglish) { "Found $($toUpdate.Count) updates. Start now?" } else { "تم العثور على $($toUpdate.Count) تحديث حقيقي. هل نبدأ الآن؟" }
            if ((Show-ConfirmDialog $msg) -eq "OK") {
                Install-Extensions -itemsToInstall $toUpdate
            }
        }
        else {
            Write-Log "✅ مبروك! كل إضافاتك محدثة لآخر إصدار." "✅ Congrats! All your extensions are up to date."
            Show-SchoMessage -Message (if ($script:isEnglish) { "Everything is up to date!" } else { "كل شيء محدث بالفعل!" }) -Type "Success"
        }
        $btnUpdateExts.Enabled = $true
        $lblStats.Text = if ($script:isEnglish) { "✅ Ready." } else { "✅ النظام جاهز." }
    })


#! 8. تصدير
$pnlActionButtons.Controls.Add($btnExport)

#! 7. استيراد
$pnlActionButtons.Controls.Add($btnImport)

#! 6. أداة تثبيت بيئة العمل
$pnlActionButtons.Controls.Add($btnWorkEnv)

#! 5. وضع المطور / المستخدم
$pnlActionButtons.Controls.Add($btnDevView)

#! 4. تحديث الإضافات
$pnlActionButtons.Controls.Add($btnUpdateExts)

#! 3. تثبيت Git
$pnlActionButtons.Controls.Add($btnInstallGit)

#! 2. تثبيت Node.js
$pnlActionButtons.Controls.Add($btnInstallNode)

#! 1. تثبيت VS Code
$pnlActionButtons.Controls.Add($btnInstallVS)



$toolTip.SetToolTip($btnExport, "نسخ احتياطي للإضافات المثبتة")
$toolTip.SetToolTip($btnImport, "استيراد إضافات من ملف نصي")
$toolTip.SetToolTip($btnInstallVS, "تحميل وتثبيت برنامج Visual Studio Code")
$toolTip.SetToolTip($btnInstallNode, "تحميل وتثبيت بيئة البرمجة Node.js")
$toolTip.SetToolTip($btnDevView, "إظهار الملفات المخفية وامتدادات الأسماء في ويندوز")
function Update-SchoStatus {
    param([string]$StatusText, [string]$HexColor = "#0098FF")
    $lblStats.Text = $StatusText
    $panelProgressFill.BackColor = [System.Drawing.ColorTranslator]::FromHtml($HexColor)
    [System.Windows.Forms.Application]::DoEvents()
}
function Write-Log {
    param([string]$MsgAR, [string]$MsgEN = "")
    if ([string]::IsNullOrWhiteSpace($MsgEN)) { $MsgEN = $MsgAR }
    $time = (Get-Date).ToString('HH:mm:ss')
    $script:LogHistoryAR.Add("[$time] $MsgAR"); $script:LogHistoryEN.Add("[$time] $MsgEN")
    if ($script:isEnglish) { $txtLog.Text = ($script:LogHistoryEN.ToArray() -join "`n") + "`n" } else { $txtLog.Text = ($script:LogHistoryAR.ToArray() -join "`n") + "`n" }
    $txtLog.SelectionStart = $txtLog.Text.Length
    $txtLog.ScrollToCaret(); [System.Windows.Forms.Application]::DoEvents()
}
function Download-FileWithProgress($url, $destination) {
    try {
        if (Test-Path $destination) { Remove-Item $destination -Force }
        $request = [System.Net.HttpWebRequest]::Create($url); $request.Method = "GET"; $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        $request.Accept = "*/*"; $request.AllowAutoRedirect = $true; $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        $response = $request.GetResponse()
    }
    catch {
        Write-Log "❌ خطأ في الاتصال بالسيرفر للملف المختار." "❌ Error connecting to server for selected file."
        return $false
    }
    $totalBytes = $response.ContentLength
    $stream = $response.GetResponseStream(); $fileStream = [System.IO.File]::Create($destination)
    $buffer = New-Object byte[] 8192; $stopwatch = [System.Diagnostics.Stopwatch]::StartNew(); $downloadedBytes = 0
    try {
        while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fileStream.Write($buffer, 0, $read); $downloadedBytes += $read
            if ($stopwatch.ElapsedMilliseconds -gt 50) {
                $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds; $speedStr = ""
                if ($elapsedSeconds -gt 0) {
                    $speed = $downloadedBytes / $elapsedSeconds
                    if ($speed -gt 1MB) { $speedStr = "$([math]::Round($speed / 1MB, 2)) MB/s" } else { $speedStr = "$([math]::Round($speed / 1KB, 2)) KB/s" }
                }
                $downStr = "$([math]::Round($downloadedBytes / 1MB, 2)) MB"
                if ($totalBytes -gt 0) {
                    $percent = [math]::Round(($downloadedBytes / $totalBytes) * 100); $totalStr = "$([math]::Round($totalBytes / 1MB, 2)) MB"
                    $calculatedWidth = [int](($downloadedBytes / $totalBytes) * $panelProgressBg.Width)
                    $panelProgressFill.Width = [math]::Min($calculatedWidth, $panelProgressBg.Width)
                    Update-SchoStatus -StatusText (if ($script:isEnglish) { "Speed: $speedStr | $downStr / $totalStr | Progress: $percent%" } else { "السرعة: $speedStr | $downStr / $totalStr | التقدم: $percent%" }) -HexColor "#E67E22"
                }
                else {
                    $panelProgressFill.Width = $panelProgressBg.Width
                    $lblStats.Text = if ($script:isEnglish) { "Speed: $speedStr | Downloaded: $downStr | Total Size: Unknown" } else { "السرعة: $speedStr | تم تحميل: $downStr | الحجم الكلي: غير معروف" }
                }
                [System.Windows.Forms.Application]::DoEvents(); $stopwatch.Restart()
            }
        }
        $panelProgressFill.Width = $panelProgressBg.Width
        $completeMsg = if ($script:isEnglish) { "✅ Download complete! Installing silently..." } else { "✅ اكتمل التحميل! جاري التثبيت المخفي..." }
        Update-SchoStatus -StatusText $completeMsg -HexColor "#28A745"
        [System.Windows.Forms.Application]::DoEvents()
    }
    finally {
        $fileStream.Close(); $stream.Close(); $response.Close()
    }
    if ((Get-Item $destination).Length -lt 10KB) { Write-Log "⚠️ تنبيه: الملف المحمل صغير جداً، قد يكون معطوباً." "⚠️ Warning: File is very small and might be corrupted."; return $false }
    return $true
}
function Install-Extensions ($itemsToInstall) {
    $confirmMsg = if ($script:isEnglish) { "Installing... Click OK to continue. Fill the waiting time with the remembrance of Allah." } else { "جاري التثبيت… اضغط موافق للمتابعة، واملأ وقت الانتظار بذكر الله واستغفر الله، ففيهما أجر عظيم" }
    $msgResult = Show-ConfirmDialog $confirmMsg
    if ($msgResult -ne "OK") { return }
    $codeCommand = Get-Command "code" -ErrorAction SilentlyContinue
    if (-not $codeCommand) {
        Write-Log "❌ خطأ: لم يتم العثور على VS Code في نظامك." "❌ Error: VS Code not found on your system."
        return
    }
    $codePath = $codeCommand.Source
    $btnInstallSelected.Enabled = $false; $btnInstallAll.Enabled = $false
    $totalCount = $itemsToInstall.Count
    $currentIdx = 0
    Write-Log "🔍 جاري فحص الإضافات لتخطي المكرر..." "🔍 Scanning installed extensions..."; [System.Windows.Forms.Application]::DoEvents()
    $procInfoList = New-Object System.Diagnostics.ProcessStartInfo; $procInfoList.FileName = "cmd.exe"; $procInfoList.Arguments = "/c `"`"$codePath`" --list-extensions`""; $procInfoList.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden; $procInfoList.CreateNoWindow = $true; $procInfoList.UseShellExecute = $false; $procInfoList.RedirectStandardOutput = $true
    $processList = [System.Diagnostics.Process]::Start($procInfoList); $installedOutput = $processList.StandardOutput.ReadToEnd(); $processList.WaitForExit()
    $installedExtensions = $installedOutput -split "`r`n|`n" | Where-Object { $_ -match '\S' }
    foreach ($extId in $itemsToInstall) {
        $currentIdx++
        $overallPercent = [int](($currentIdx / $totalCount) * 100)
        if ($installedExtensions | Where-Object { $_ -imatch "^$([regex]::Escape($extId))$" }) {
            Write-Log "⏭️ تم تخطي: $extId (مثبتة مسبقاً)" "⏭️ Skipped: $extId (Already installed)"
            $panelProgressFill.Width = [int](($currentIdx / $totalCount) * $panelProgressBg.Width)
            continue
        }
        try {
            $parts = $extId -split '\.'
            $publisher = $parts[0]; $extName = $parts[1]
            $downloadUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$extName/latest/vspackage"
            $vsixPath = Join-Path $env:TEMP "$extId.vsix"
            Write-Log "📥 جاري معالجة [$currentIdx/$totalCount]: $extId" "📥 Processing [$currentIdx/$totalCount]: $extId"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            if (Download-FileWithProgress -url $downloadUrl -destination $vsixPath) {
                Write-Log "⚙️ جاري التثبيت داخل VS Code..." "⚙️ Installing inside VS Code..."
                $procInfo = New-Object System.Diagnostics.ProcessStartInfo; $procInfo.FileName = "cmd.exe"; $procInfo.Arguments = "/c `"`"$codePath`" --install-extension `"$vsixPath`" --force`""; $procInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden; $procInfo.CreateNoWindow = $true; $procInfo.UseShellExecute = $false
                $process = [System.Diagnostics.Process]::Start($procInfo)
                $ticks = 0
                while (-not $process.WaitForExit(100)) {
                    $ticks++
                    $loadingIcons = @("|", "/", "-", "\")
                    $icon = $loadingIcons[$ticks % 4]
                    $lblStats.Text = if ($script:isEnglish) { "$icon Installing $extId... Please wait" } else { "$icon جاري تثبيت $extId... يرجى الانتظار" }
                    if ($ticks % 5 -eq 0) { $panelProgressFill.Width = [math]::Max(0, $panelProgressFill.Width - 2) }
                    else { $panelProgressFill.Width = [math]::Min($panelProgressBg.Width, $panelProgressFill.Width + 2) }
                    [System.Windows.Forms.Application]::DoEvents()
                }
                if ($process.ExitCode -eq 0) { Write-Log "🎉 نجح التثبيت: $extId" "🎉 Success: $extId" }
                else { Write-Log "❌ فشل التثبيت: $extId" "❌ Failed: $extId" }
                if (Test-Path $vsixPath) { Remove-Item $vsixPath -Force }
            }
        }
        catch { Write-Log "❌ خطأ: $($_.Exception.Message)" }
        $panelProgressFill.Width = [int](($currentIdx / $totalCount) * $panelProgressBg.Width)
        Write-Log "----------------------------------------"
    }
    Write-Log "🎊 انتهت جميع العمليات!" "🎊 All operations completed!"
    $finalMsg = if ($script:isEnglish) { "✅ All Done! Ready." } else { "✅ انتهى العمل! النظام جاهز." }
    Update-SchoStatus -StatusText $finalMsg -HexColor "#007ACC"
    $btnInstallSelected.Enabled = $true; $btnInstallAll.Enabled = $true
}
$btnInstallSelected.Add_Click({
        $selectedButtons = @(); $activeColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC").ToArgb()
        foreach ($ctrl in $flowLayoutPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button] -and $ctrl.BackColor.ToArgb() -eq $activeColor) {
                if ($null -ne $ctrl.Tag.ID) { $selectedButtons += $ctrl }
            }
        }
        if ($selectedButtons.Count -eq 0) { Write-Log "⚠️ حدد إضافة واحدة على الأقل." "⚠️ Select at least one extension."; return }
        if ($script:isChromeTab) {
            Write-Log "🌐 جاري فتح صفحات الإضافات لتتمكن من تفعيلها..." "🌐 Opening extension pages for activation..."
            foreach ($btn in $selectedButtons) {
                $extID = $btn.Tag.ID
                $extName = $btn.Text.Replace('✓ ', '')
                $url = "https://chromewebstore.google.com/detail/$extID"
                Write-Log "🔗 فتح صفحة: $extName" "🔗 Opening page: $extName"
                Start-Process $url
                Start-Sleep -Milliseconds 500
            }
            Write-Log "✅ انتهى! اضغط على 'إضافة إلى Chrome' في الصفحات المفتوحة." "✅ Done! Click 'Add to Chrome' in the opened pages."
        }
        else {
            $ids = $selectedButtons | ForEach-Object { $_.Tag.ID }
            Install-Extensions -itemsToInstall $ids
        }
    })
$btnInstallAll.Add_Click({
        $allButtons = @(); $activeColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC").ToArgb()
        foreach ($ctrl in $flowLayoutPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button]) {
                if ($ctrl.BackColor.ToArgb() -ne $activeColor) {
                    $ctrl.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#007ACC"); $ctrl.ForeColor = [System.Drawing.Color]::White; if (-not $ctrl.Text.StartsWith("✓ ")) { $ctrl.Text = "✓ " + $ctrl.Text }
                }
                if ($null -ne $ctrl.Tag.ID) { $allButtons += $ctrl }
            }
        }
        if ($allButtons.Count -eq 0) { return }
        if ($script:isChromeTab) {
            Write-Log "⚙️ جاري تسجيل جميع الإضافات في سجل النظام..." "⚙️ Registering all extensions in registry..."
            foreach ($btn in $allButtons) {
                $extID = $btn.Tag.ID
                $extName = $btn.Text.Replace('✓ ', '')
                try {
                    $regPath = "HKCU:\Software\Google\Chrome\Extensions\$extID"
                    if (Test-Path $regPath) {
                        Remove-Item -Path $regPath -Force -Recurse | Out-Null
                    }
                    New-Item -Path $regPath -Force | Out-Null
                    $updateUrl = "https://clients2.google.com/service/update2/crx"
                    New-ItemProperty -Path $regPath -Name "update_url" -Value $updateUrl -PropertyType String -Force | Out-Null
                    Write-Log "➕ تم تنشيط تسجيل: $extName" "➕ Refreshed registration: $extName"
                }
                catch {
                    Write-Log "❌ فشل تسجيل: $extName" "❌ Failed: $extName"
                }
            }
            Write-Log "🎊 انتهى التسجيل! يرجى إعادة تشغيل متصفح كروم لتفعيلها." "🎊 Done! Please restart Chrome to activate them."
        }
        else {
            $ids = $allButtons | ForEach-Object { $_.Tag.ID }
            Install-Extensions -itemsToInstall $ids
        }
    })
Update-DevViewUI
$mainForm.Add_Shown({
        $btnTabVS.PerformClick()
    })
[System.Windows.Forms.Application]::Run($mainForm)