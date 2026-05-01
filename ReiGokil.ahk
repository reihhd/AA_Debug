#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
;  REI GOKIL - FINAL (Stable Webhook + Screenshot)
; ============================================================

global MacroActive  := false
global ToggleKey    := "F1"
global IsSettingKey := false
global SkillDelay   := 10
global CycleDelay   := 100

global UseZ := false, UseX := false, UseC := false, UseV := false
global UseG := false, UseS := false, UseF := false, UseE := false, UseClick := false

global WebhookURL      := ""
global WebhookActive   := false
global WebhookInterval := 60
global APP_VERSION     := "1.0.2"
global CFG_FILE        := A_ScriptDir "\rg_config.ini"

; ========== Helper ==========
ParseInt(val) => Integer(RegExReplace(String(val), "[,\s]", ""))

; ========== Config ==========
LoadConfig() {
    global CFG_FILE, WebhookURL, WebhookInterval, ToggleKey
    if !FileExist(CFG_FILE)
        return
    WebhookURL      := IniRead(CFG_FILE, "Discord", "WebhookURL", "")
    WebhookInterval := Integer(IniRead(CFG_FILE, "Discord", "Interval", "60"))
    ToggleKey       := IniRead(CFG_FILE, "Macro", "ToggleKey", "F1")
}
SaveConfig() {
    global CFG_FILE, WebhookURL, WebhookInterval, ToggleKey, WebhookEdit, IntervalEdit
    WebhookURL      := WebhookEdit.Value
    WebhookInterval := ParseInt(IntervalEdit.Value)
    IniWrite(WebhookURL,              CFG_FILE, "Discord", "WebhookURL")
    IniWrite(String(WebhookInterval), CFG_FILE, "Discord", "Interval")
    IniWrite(ToggleKey,               CFG_FILE, "Macro",   "ToggleKey")
}
LoadConfig()

; ========== GUI ==========
RG := Gui("+AlwaysOnTop -DPIScale", "Rei Gokil")
RG.BackColor := "0A0A0F"
RG.SetFont("s13 cFFFFFF Bold", "Segoe UI")
RG.Add("Text", "x20 y14", "REI GOKIL")
RG.SetFont("s8 cAAAAAA Bold", "Segoe UI")
global StatusTxt := RG.Add("Text", "x240 y18 w100 h22 +0x200 Background111120 Center", "READY")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global Tabs := RG.Add("Tab3", "x0 y56 w360 h270 Background0A0A0F", ["  MACRO  ", "  DISCORD  ", "  HELP  "])

; === Tab Macro ===
Tabs.UseTab(1)
RG.SetFont("s10 cDDDDDD", "Segoe UI")
global CbZ := RG.Add("CheckBox", "x22 y114 w90", "Z")
global CbX := RG.Add("CheckBox", "x142 y114 w90", "X")
global CbC := RG.Add("CheckBox", "x262 y114 w90", "C")
global CbV := RG.Add("CheckBox", "x22 y144 w90", "V")
global CbG := RG.Add("CheckBox", "x142 y144 w90", "G")
global CbS := RG.Add("CheckBox", "x262 y144 w90", "S")
RG.SetFont("s10 cFFAA44", "Segoe UI")
global CbF := RG.Add("CheckBox", "x22 y174 w90", "F")
RG.SetFont("s10 c44DDAA", "Segoe UI")
global CbE := RG.Add("CheckBox", "x142 y174 w90", "E")
RG.SetFont("s10 c5599FF", "Segoe UI")
global CbClick := RG.Add("CheckBox", "x262 y174 w90", "CLICK")

CbZ.OnEvent("Click", (*) => (UseZ := CbZ.Value))
CbX.OnEvent("Click", (*) => (UseX := CbX.Value))
CbC.OnEvent("Click", (*) => (UseC := CbC.Value))
CbV.OnEvent("Click", (*) => (UseV := CbV.Value))
CbG.OnEvent("Click", (*) => (UseG := CbG.Value))
CbS.OnEvent("Click", (*) => (UseS := CbS.Value))
CbF.OnEvent("Click", (*) => (UseF := CbF.Value))
CbE.OnEvent("Click", (*) => (UseE := CbE.Value))
CbClick.OnEvent("Click", (*) => (UseClick := CbClick.Value))

global SkillDelayEdit := RG.Add("Edit", "x72 y215 w55", "10")
RG.Add("UpDown", "Range1-500", 10)
global CycleDelayEdit := RG.Add("Edit", "x220 y215 w55", "100")
RG.Add("UpDown", "Range10-5000", 100)
global KeyLabel := RG.Add("Text", "x80 y251 w70 h22 +0x200 Background111120 Center", ToggleKey)
global SetKeyBtn := RG.Add("Button", "x162 y251 w60", "SET")
SetKeyBtn.OnEvent("Click", SetToggleKey)

; === Tab Discord ===
Tabs.UseTab(2)
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global WebhookEdit := RG.Add("Edit", "x20 y112 w318 h22", WebhookURL)
global IntervalEdit := RG.Add("Edit", "x80 y149 w60", String(WebhookInterval))
RG.Add("UpDown", "Range5-3600", WebhookInterval)
global CbWebhook := RG.Add("CheckBox", "x20 y190 w280", "Enable")
CbWebhook.OnEvent("Click", ToggleWebhook)
global WebhookStatus := RG.Add("Text", "x20 y230 w320", "tidak aktif")
global SaveBtn := RG.Add("Button", "x244 y290 w92", "Simpan")
SaveBtn.OnEvent("Click", (*) => SaveConfig())

; === Tab Help ===
Tabs.UseTab(3)
RG.SetFont("s9 cFFFFFF Bold", "Segoe UI")
yy := 112
for r in [["Z","Skill 1"],["X","Skill 2"],["C","Skill 3"],["V","Mastery 100"],["S","Walk Back"],["E","Gadget"],["G","Ultimate"],["F","Revive"],["CLICK","Auto M1"]] {
    RG.Add("Text", "x22 y" yy " w55", r[1])
    RG.SetFont("s9 c555577", "Segoe UI")
    RG.Add("Text", "x84 y" yy " w256", r[2])
    yy += 20
}

Tabs.UseTab(0)
global ToggleBtn := RG.Add("Button", "x20 y338 w318 h32", "START  [ " ToggleKey " ]")
ToggleBtn.OnEvent("Click", ToggleMacro)
RG.OnEvent("Close", (*) => (SaveConfig(), ExitApp()))
RG.Show("w360 h404")
HotKey(ToggleKey, (*) => ToggleMacro())

; ========== Functions ==========
SetToggleKey(ctrl, *) {
    global IsSettingKey, ToggleKey
    if IsSettingKey {
        IsSettingKey := false
        KeyLabel.Text := ToggleKey
        SetKeyBtn.Text := "SET"
        return
    }
    IsSettingKey := true
    KeyLabel.Text := "..."
    SetKeyBtn.Text := "X"
    SetTimer(WaitForKey, 50)
}
WaitForKey() {
    global IsSettingKey, ToggleKey, MacroActive
    if !IsSettingKey {
        SetTimer(, 0)
        return
    }
    Loop 254 {
        kName := GetKeyName(Format("vk{:02x}", A_Index))
        if kName = "" || kName = "UNKNOWN"
            continue
        if !InStr("LButton,RButton,MButton,LCtrl,RCtrl,LAlt,RAlt,LShift,RShift,LWin,RWin,Ctrl,Alt,Shift", kName) && GetKeyState(kName, "P") {
            SetTimer(, 0)
            try HotKey(ToggleKey, (*) => ToggleMacro(), "Off")
            ToggleKey := kName
            HotKey(ToggleKey, (*) => ToggleMacro())
            KeyLabel.Text := kName
            SetKeyBtn.Text := "SET"
            IsSettingKey := false
            ToggleBtn.Text := (MacroActive ? "STOP" : "START") "  [ " kName " ]"
            SaveConfig()
            return
        }
    }
}
ToggleMacro(*) {
    global MacroActive, SkillDelay, CycleDelay, IsSettingKey
    if IsSettingKey {
        IsSettingKey := false
        KeyLabel.Text := ToggleKey
        SetKeyBtn.Text := "SET"
        SetTimer(, 0)
        return
    }
    MacroActive := !MacroActive
    if MacroActive {
        SkillDelay := ParseInt(SkillDelayEdit.Value)
        CycleDelay := ParseInt(CycleDelayEdit.Value)
        if SkillDelay < 1 || CycleDelay < 10
            return
        if !(UseZ||UseX||UseC||UseV||UseG||UseS||UseF||UseE||UseClick) {
            MacroActive := false
            TrayTip("Pilih skill", "Rei Gokil", 1)
            return
        }
        StatusTxt.Text := "ACTIVE"
        ToggleBtn.Text := "STOP  [ " ToggleKey " ]"
        SetTimer(MacroLoop, 50)
    } else {
        StatusTxt.Text := "READY"
        ToggleBtn.Text := "START  [ " ToggleKey " ]"
        SetTimer(MacroLoop, 0)
    }
}
MacroLoop() {
    global MacroActive, SkillDelay, CycleDelay, UseZ, UseX, UseC, UseV, UseG, UseS, UseF, UseE, UseClick
    SetTimer(MacroLoop, 0)
    if !MacroActive
        return
    keys := []
    if UseZ keys.Push("z"), UseX keys.Push("x"), UseC keys.Push("c"), UseV keys.Push("v")
    if UseG keys.Push("g"), UseS keys.Push("s"), UseF keys.Push("f"), UseE keys.Push("e")
    for k in keys {
        if !MacroActive return
        SendInput("{" k " down}"), Sleep(30), SendInput("{" k " up}"), Sleep(SkillDelay)
    }
    if UseClick && MacroActive
        Click(), Sleep(SkillDelay)
    if MacroActive
        SetTimer(MacroLoop, CycleDelay)
}

; ========== Webhook + Screenshot (GDI+) ==========
GdipStartup() {
    static pToken := 0
    VarSetStrLen(&si, 16, 0), NumPut(1, si, 0, "UChar")
    if DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken, "Ptr", &si, "Ptr", 0) = 0
        return pToken
    return 0
}
GdipShutdown(pToken) => DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
GdipGetCodec(ext) {
    static codec := 0
    if !codec {
        DllCall("gdiplus\GdipGetImageEncodersSize", "UInt*", &n:=0, "UInt*", &size:=0)
        enc := Buffer(size)
        DllCall("gdiplus\GdipGetImageEncoders", "UInt", n, "UInt", size, "Ptr", enc)
        loop n {
            if StrGet(NumGet(enc, (A_Index-1)*80 + 76, "UPtr")) = ext {
                codec := NumGet(enc, (A_Index-1)*80 + 4, "UPtr")
                break
            }
        }
    }
    return codec
}

global pToken := GdipStartup()
if !pToken
    MsgBox("GDI+ gagal dimulai. Screenshot tidak akan berfungsi.", "Error", 0x10)
OnExit((*) => (SaveConfig(), GdipShutdown(pToken)))

CaptureScreen() {
    width := A_ScreenWidth, height := A_ScreenHeight
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", width, "Int", height, "Ptr")
    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm)
    DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap:=0)
    tmp := A_Temp "\rg_shot_" A_TickCount ".png"
    DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Str", tmp, "Ptr", GdipGetCodec("image/png"), "UInt", 0)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    return tmp
}

ToggleWebhook(ctrl, *) {
    global WebhookActive, WebhookURL, WebhookInterval, WebhookEdit, IntervalEdit, WebhookStatus
    WebhookURL := Trim(WebhookEdit.Value)
    WebhookInterval := ParseInt(IntervalEdit.Value)
    if WebhookInterval < 5
        WebhookInterval := 5
    if ctrl.Value {
        if WebhookURL = "" {
            ctrl.Value := 0
            WebhookStatus.Text := "URL webhook tidak boleh kosong"
            return
        }
        WebhookActive := true
        WebhookStatus.Text := "aktif — setiap " WebhookInterval " detik"
        SetTimer(SendShotAsync, -100)
        SetTimer(SendShotScheduled, WebhookInterval * 1000)
    } else {
        WebhookActive := false
        WebhookStatus.Text := "tidak aktif"
        SetTimer(SendShotScheduled, 0)
    }
}
SendShotScheduled() {
    global WebhookActive
    if !WebhookActive
        SetTimer(SendShotScheduled, 0)
    else
        SetTimer(SendShotAsync, -50)
}
SendShotAsync() {
    global WebhookURL, WebhookActive, WebhookStatus, APP_VERSION
    global UseZ, UseX, UseC, UseV, UseG, UseS, UseF, UseE, UseClick, SkillDelay, CycleDelay
    if !WebhookActive
        return
    tmpFile := CaptureScreen()
    if !FileExist(tmpFile) {
        WebhookStatus.Text := "gagal screenshot"
        return
    }
    activeKeys := ""
    if UseZ activeKeys .= "Z ", UseX activeKeys .= "X ", UseC activeKeys .= "C ", UseV activeKeys .= "V "
    if UseG activeKeys .= "G ", UseS activeKeys .= "S ", UseF activeKeys .= "F ", UseE activeKeys .= "E "
    if UseClick activeKeys .= "CLICK "
    if activeKeys = "" activeKeys := "none"
    ts := FormatTime(, "dd/MM/yyyy HH:mm:ss")
    pc := A_ComputerName, user := A_UserName
    uptime := Round(A_TickCount / 60000) " menit"
    json := '{ "username":"Rei Gokil", "avatar_url":"https://i.imgur.com/4M34hi2.png", "embeds":[{ "title":"Screenshot Report", "color":52479, "fields":[' .
            '{"name":"Waktu","value":"' ts '","inline":true},' .
            '{"name":"PC","value":"' pc '","inline":true},' .
            '{"name":"User","value":"' user '","inline":true},' .
            '{"name":"Skills","value":"' Trim(activeKeys) '","inline":true},' .
            '{"name":"Delay","value":"' SkillDelay ' ms","inline":true},' .
            '{"name":"Loop","value":"' CycleDelay ' ms","inline":true},' .
            '{"name":"Uptime","value":"' uptime '","inline":true} ],' .
            '"footer":{"text":"rei gokil v' APP_VERSION '"}, "image":{"url":"attachment://screenshot.png"} }] }'
    jsonFile := A_Temp "\rg_payload_" A_TickCount ".json"
    FileDelete(jsonFile)
    FileAppend(json, jsonFile, "UTF-8")
    psScript := A_ScriptDir "\send_to_discord.ps1"
    if !FileExist(psScript) {
        WebhookStatus.Text := "send_to_discord.ps1 tidak ditemukan!"
        FileDelete(tmpFile), FileDelete(jsonFile)
        return
    }
    cmd := 'powershell.exe -ExecutionPolicy Bypass -File "' psScript '" -webhookUrl "' WebhookURL '" -imagePath "' tmpFile '" -jsonPath "' jsonFile '"'
    try {
        RunWait(cmd, , "Hide")
        WebhookStatus.Text := "terkirim " FormatTime(, "HH:mm:ss")
    } catch as e {
        WebhookStatus.Text := "gagal: " e.Message
    }
    Sleep(1000)
    FileDelete(tmpFile), FileDelete(jsonFile)
}
