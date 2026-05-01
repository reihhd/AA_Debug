#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
;  REI GOKIL  -  AA_Main.ahk (Stable Webhook + Screenshot)
;  https://github.com/reihhd/AA
; ============================================================

global MacroActive  := false
global ToggleKey    := "F1"
global IsSettingKey := false
global SkillDelay   := 10
global CycleDelay   := 100

global UseZ     := false
global UseX     := false
global UseC     := false
global UseV     := false
global UseG     := false
global UseS     := false
global UseF     := false
global UseE     := false
global UseClick := false

global WebhookURL      := ""
global WebhookActive   := false
global WebhookInterval := 60
global APP_VERSION     := "1.0.1"
global CFG_FILE        := A_ScriptDir "\rg_config.ini"

; --- GDI+ Token untuk screenshot ---
global pToken := 0

; ============================================================
;  HELPERS
; ============================================================
ParseInt(val) {
    return Integer(RegExReplace(String(val), "[,\s]", ""))
}

; ============================================================
;  CHECKBOX HANDLERS
; ============================================================
SetUseZ(ctrl, *) {
    global UseZ
    UseZ := ctrl.Value
}
SetUseX(ctrl, *) {
    global UseX
    UseX := ctrl.Value
}
SetUseC(ctrl, *) {
    global UseC
    UseC := ctrl.Value
}
SetUseV(ctrl, *) {
    global UseV
    UseV := ctrl.Value
}
SetUseG(ctrl, *) {
    global UseG
    UseG := ctrl.Value
}
SetUseS(ctrl, *) {
    global UseS
    UseS := ctrl.Value
}
SetUseF(ctrl, *) {
    global UseF
    UseF := ctrl.Value
}
SetUseE(ctrl, *) {
    global UseE
    UseE := ctrl.Value
}
SetUseClick(ctrl, *) {
    global UseClick
    UseClick := ctrl.Value
}

; ============================================================
;  CONFIG
; ============================================================
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

; ============================================================
;  GUI
; ============================================================
RG := Gui("+AlwaysOnTop -DPIScale", "Rei Gokil")
RG.BackColor := "0A0A0F"

RG.Add("Progress", "x0 y0 w360 h2 Background00CCFF Range0-100", 100)
RG.SetFont("s13 cFFFFFF Bold", "Segoe UI")
RG.Add("Text", "x20 y14", "REI GOKIL")
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x20 y34", "v" APP_VERSION)
RG.SetFont("s8 cAAAAAA Bold", "Segoe UI")
global StatusTxt := RG.Add("Text", "x240 y18 w100 h22 +0x200 Background111120 Center", "READY")
RG.Add("Text", "x0 y52 w360 h1 Background1A1A2A")

RG.SetFont("s9 cCCCCCC", "Segoe UI")
global Tabs := RG.Add("Tab3", "x0 y56 w360 h270 Background0A0A0F", ["  MACRO  ", "  DISCORD  ", "  HELP  "])

; ========== TAB 1 ==========
Tabs.UseTab(1)
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x20 y92", "SKILLS")
RG.Add("Text", "x0 y104 w360 h1 Background111120")

RG.SetFont("s10 cDDDDDD", "Segoe UI")
global CbZ     := RG.Add("CheckBox", "x22  y114 w90 h26 cDDDDDD", "Z")
global CbX     := RG.Add("CheckBox", "x142 y114 w90 h26 cDDDDDD", "X")
global CbC     := RG.Add("CheckBox", "x262 y114 w90 h26 cDDDDDD", "C")
global CbV     := RG.Add("CheckBox", "x22  y144 w90 h26 cDDDDDD", "V")
global CbG     := RG.Add("CheckBox", "x142 y144 w90 h26 cDDDDDD", "G")
global CbS     := RG.Add("CheckBox", "x262 y144 w90 h26 cDDDDDD", "S")
RG.SetFont("s10 cFFAA44", "Segoe UI")
global CbF     := RG.Add("CheckBox", "x22  y174 w90 h26 cFFAA44", "F")
RG.SetFont("s10 c44DDAA", "Segoe UI")
global CbE     := RG.Add("CheckBox", "x142 y174 w90 h26 c44DDAA", "E")
RG.SetFont("s10 c5599FF", "Segoe UI")
global CbClick := RG.Add("CheckBox", "x262 y174 w90 h26 c5599FF", "CLICK")

CbZ.OnEvent("Click", SetUseZ)
CbX.OnEvent("Click", SetUseX)
CbC.OnEvent("Click", SetUseC)
CbV.OnEvent("Click", SetUseV)
CbG.OnEvent("Click", SetUseG)
CbS.OnEvent("Click", SetUseS)
CbF.OnEvent("Click", SetUseF)
CbE.OnEvent("Click", SetUseE)
CbClick.OnEvent("Click", SetUseClick)

RG.Add("Text", "x0 y208 w360 h1 Background111120")
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x22 y218", "DELAY")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global SkillDelayEdit := RG.Add("Edit", "x72 y215 w55 h22 Background111120 cCCCCCC Center", "10")
RG.Add("UpDown", "Range1-500", 10)
RG.SetFont("s8 c333355", "Segoe UI")
RG.Add("Text", "x132 y218", "ms")
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x180 y218", "LOOP")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global CycleDelayEdit := RG.Add("Edit", "x220 y215 w55 h22 Background111120 cCCCCCC Center", "100")
RG.Add("UpDown", "Range10-5000", 100)
RG.SetFont("s8 c333355", "Segoe UI")
RG.Add("Text", "x280 y218", "ms")

RG.Add("Text", "x0 y244 w360 h1 Background111120")
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x22 y254", "HOTKEY")
RG.SetFont("s9 cFFFFFF Bold", "Segoe UI")
global KeyLabel  := RG.Add("Text",   "x80 y251 w70 h22 +0x200 Background111120 Center", ToggleKey)
RG.SetFont("s8 cAAAAAA", "Segoe UI")
global SetKeyBtn := RG.Add("Button", "x162 y251 w60 h22", "SET")
SetKeyBtn.OnEvent("Click", SetToggleKey)

; ========== TAB 2 ==========
Tabs.UseTab(2)
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x20 y92", "WEBHOOK URL")
RG.Add("Text", "x0 y104 w360 h1 Background111120")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global WebhookEdit := RG.Add("Edit", "x20 y112 w318 h22 Background111120 cCCCCCC", WebhookURL)

RG.Add("Text", "x0 y142 w360 h1 Background111120")
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x20 y152", "INTERVAL")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global IntervalEdit := RG.Add("Edit", "x80 y149 w60 h22 Background111120 cCCCCCC Center", String(WebhookInterval))
RG.Add("UpDown", "Range5-3600", WebhookInterval)
RG.SetFont("s8 c333355", "Segoe UI")
RG.Add("Text", "x145 y152", "detik")

RG.Add("Text", "x0 y180 w360 h1 Background111120")
RG.SetFont("s9 cCCCCCC", "Segoe UI")
global CbWebhook := RG.Add("CheckBox", "x20 y190 w280 h24 cCCCCDD", "Enable")
CbWebhook.OnEvent("Click", ToggleWebhook)

RG.Add("Text", "x0 y222 w360 h1 Background111120")
RG.SetFont("s8 c555566", "Segoe UI")
global WebhookStatus := RG.Add("Text", "x20 y230 w320", "tidak aktif")

RG.SetFont("s8 cAAAAAA", "Segoe UI")
global SaveBtn := RG.Add("Button", "x244 y290 w92 h22", "Simpan")
SaveBtn.OnEvent("Click", (ctrl, *) => SaveConfig())

; ========== TAB 3 ==========
Tabs.UseTab(3)
RG.SetFont("s7 c333355", "Segoe UI")
RG.Add("Text", "x20 y92", "KEY REFERENCE")
RG.Add("Text", "x0 y104 w360 h1 Background111120")

helpRows := [
    ["Z",     "Skill 1"],
    ["X",     "Skill 2"],
    ["C",     "Skill 3"],
    ["V",     "Mastery 100"],
    ["S",     "Walk Back"],
    ["E",     "Gadget  (Black Hole recommended)"],
    ["G",     "Ultimate"],
    ["F",     "Saiyan Helper / Revive"],
    ["CLICK", "Auto M1 Mouse Click"],
]
yy := 112
for r in helpRows {
    RG.SetFont("s9 cFFFFFF Bold", "Segoe UI")
    RG.Add("Text", "x22 y" yy " w55", r[1])
    RG.SetFont("s9 c555577", "Segoe UI")
    RG.Add("Text", "x84 y" yy " w256", r[2])
    yy += 20
}

; ========== BOTTOM ==========
Tabs.UseTab(0)
RG.Add("Text", "x0 y328 w360 h1 Background00CCFF")
RG.SetFont("s10 cFFFFFF Bold", "Segoe UI")
global ToggleBtn := RG.Add("Button", "x20 y338 w318 h32", "START  [ " ToggleKey " ]")
ToggleBtn.OnEvent("Click", ToggleMacro)

RG.Add("Text", "x0 y378 w360 h1 Background111120")
RG.SetFont("s7 c222233", "Segoe UI")
RG.Add("Text", "x0 y386 w360 h16 Center", "rei gokil  |  v" APP_VERSION "  |  github.com/reihhd/AA")

; Start GDI+ untuk screenshot
if !Gdip_Startup()
    MsgBox("GDI+ gagal dimulai. Screenshot tidak akan berfungsi.", "Error", 0x10)
OnExit(OnClose)

RG.OnEvent("Close", OnClose)
RG.Show("w360 h404")

HotKey(ToggleKey, (*) => ToggleMacro())

; ============================================================
;  FUNGSI UTAMA
; ============================================================
OnClose(*) {
    SaveConfig()
    Gdip_Shutdown()
    ExitApp()
}

SetToggleKey(ctrl, *) {
    global IsSettingKey, ToggleKey
    if IsSettingKey {
        IsSettingKey   := false
        KeyLabel.Text  := ToggleKey
        SetKeyBtn.Text := "SET"
        return
    }
    IsSettingKey   := true
    KeyLabel.Text  := "..."
    SetKeyBtn.Text := "X"
    SetTimer(WaitForKey, 50)
}

WaitForKey() {
    global IsSettingKey, ToggleKey, MacroActive
    if !IsSettingKey {
        SetTimer(, 0)
        return
    }
    skip := ["LButton","RButton","MButton","","UNKNOWN","Ctrl","Alt","Shift",
             "LCtrl","RCtrl","LAlt","RAlt","LShift","RShift","LWin","RWin"]
    Loop 254 {
        try {
            kName := GetKeyName(Format("vk{:02x}", A_Index))
            if kName = "" || kName = "UNKNOWN"
                continue
            found := false
            for s in skip {
                if kName = s {
                    found := true
                    break
                }
            }
            if !found && GetKeyState(kName, "P") {
                SetTimer(, 0)
                try HotKey(ToggleKey, (*) => ToggleMacro(), "Off")
                ToggleKey      := kName
                HotKey(ToggleKey, (*) => ToggleMacro())
                KeyLabel.Text  := kName
                SetKeyBtn.Text := "SET"
                IsSettingKey   := false
                ToggleBtn.Text := MacroActive
                    ? "STOP  [ " kName " ]"
                    : "START  [ " kName " ]"
                SaveConfig()
                return
            }
        }
    }
}

ToggleMacro(ctrl := unset, info := unset) {
    global MacroActive, SkillDelay, CycleDelay, IsSettingKey
    global UseZ, UseX, UseC, UseV, UseG, UseS, UseF, UseE, UseClick

    if IsSettingKey {
        IsSettingKey   := false
        KeyLabel.Text  := ToggleKey
        SetKeyBtn.Text := "SET"
        SetTimer(, 0)
        return
    }

    MacroActive := !MacroActive

    if MacroActive {
        SkillDelay := ParseInt(SkillDelayEdit.Value)
        CycleDelay := ParseInt(CycleDelayEdit.Value)
        if SkillDelay < 1
            SkillDelay := 1
        if CycleDelay < 10
            CycleDelay := 10

        if !(UseZ || UseX || UseC || UseV || UseG || UseS || UseF || UseE || UseClick) {
            MacroActive := false
            TrayTip("Pilih minimal satu skill", "Rei Gokil", 1)
            return
        }

        StatusTxt.Text := "ACTIVE"
        StatusTxt.SetFont("c00FFAA Bold")
        ToggleBtn.Text := "STOP  [ " ToggleKey " ]"
        SetTimer(MacroLoop, 50)
    } else {
        StatusTxt.Text := "READY"
        StatusTxt.SetFont("cAAAAAA")
        ToggleBtn.Text := "START  [ " ToggleKey " ]"
        SetTimer(MacroLoop, 0)
    }
}

MacroLoop() {
    global MacroActive, SkillDelay, CycleDelay
    global UseZ, UseX, UseC, UseV, UseG, UseS, UseF, UseE, UseClick
    SetTimer(MacroLoop, 0)
    if !MacroActive
        return

    keys := []
    if UseZ     keys.Push("z")
    if UseX     keys.Push("x")
    if UseC     keys.Push("c")
    if UseV     keys.Push("v")
    if UseG     keys.Push("g")
    if UseS     keys.Push("s")
    if UseF     keys.Push("f")
    if UseE     keys.Push("e")

    for k in keys {
        if !MacroActive
            return
        SendInput("{" k " down}")
        Sleep(30)
        SendInput("{" k " up}")
        Sleep(SkillDelay)
    }

    if UseClick && MacroActive {
        Click()
        Sleep(SkillDelay)
    }

    if MacroActive
        SetTimer(MacroLoop, CycleDelay)
}

; ============================================================
;  DISCORD WEBHOOK + SCREENSHOT (GDI+ Stabil)
; ============================================================
ToggleWebhook(ctrl, *) {
    global WebhookActive, WebhookURL, WebhookInterval
    global WebhookEdit, IntervalEdit, WebhookStatus

    WebhookURL      := Trim(WebhookEdit.Value)
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
        WebhookStatus.Text := "aktif  —  setiap " WebhookInterval " detik"
        SetTimer(SendShotAsync, -100)   ; kirim pertama cepat
        SetTimer(SendShotScheduled, WebhookInterval * 1000)
    } else {
        WebhookActive := false
        WebhookStatus.Text := "tidak aktif"
        SetTimer(SendShotScheduled, 0)
    }
}

SendShotScheduled() {
    global WebhookActive
    if !WebhookActive {
        SetTimer(SendShotScheduled, 0)
        return
    }
    SetTimer(SendShotAsync, -50)
}

; --- Screenshot pakai GDI+ (stable) ---
CaptureScreen() {
    ; Ukuran layar
    width := A_ScreenWidth, height := A_ScreenHeight

    ; Dapatkan DC
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", width, "Int", height, "Ptr")
    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm)
    DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", width, "Int", height
        , "Ptr", hdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    ; Konversi ke GDI+ bitmap
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap := 0)

    ; Simpan ke file PNG
    tempFile := A_Temp "\rg_shot_" A_TickCount ".png"
    pCodec := Gdip_GetCodec("image/png")
    DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Str", tempFile, "Ptr", pCodec, "UInt", 0)

    ; Cleanup
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    return tempFile
}

; --- Kirim screenshot via PowerShell (file .ps1 pendamping) ---
SendShotAsync() {
    global WebhookURL, WebhookActive, WebhookStatus, APP_VERSION
    global UseZ, UseX, UseC, UseV, UseG, UseS, UseF, UseE, UseClick, SkillDelay, CycleDelay
    if !WebhookActive
        return

    ; Ambil screenshot
    tmpFile := ""
    try {
        tmpFile := CaptureScreen()
    } catch as e {
        WebhookStatus.Text := "gagal screenshot: " e.Message
        return
    }
    if !FileExist(tmpFile) {
        WebhookStatus.Text := "file screenshot tidak ada"
        return
    }

    ; Buat informasi embed (opsional, bisa diabaikan jika hanya kirim file)
    activeKeys := ""
    if UseZ     activeKeys .= "Z "
    if UseX     activeKeys .= "X "
    if UseC     activeKeys .= "C "
    if UseV     activeKeys .= "V "
    if UseG     activeKeys .= "G "
    if UseS     activeKeys .= "S "
    if UseF     activeKeys .= "F "
    if UseE     activeKeys .= "E "
    if UseClick activeKeys .= "CLICK "
    if activeKeys = ""
        activeKeys := "none"

    ts     := FormatTime(, "dd/MM/yyyy  HH:mm:ss")
    pc     := A_ComputerName
    user   := A_UserName
    uptime := Round(A_TickCount / 60000) " menit"

    json := '{'
    json .= '"username":"Rei Gokil",'
    json .= '"avatar_url":"https://i.imgur.com/4M34hi2.png",'
    json .= '"embeds":[{'
    json .= '"title":"Screenshot Report",'
    json .= '"color":52479,'
    json .= '"fields":['
    json .= '{"name":"Waktu","value":"' ts '","inline":true},'
    json .= '{"name":"PC","value":"' pc '","inline":true},'
    json .= '{"name":"User","value":"' user '","inline":true},'
    json .= '{"name":"Skills Aktif","value":"' Trim(activeKeys) '","inline":true},'
    json .= '{"name":"Delay","value":"' SkillDelay ' ms","inline":true},'
    json .= '{"name":"Loop","value":"' CycleDelay ' ms","inline":true},'
    json .= '{"name":"Uptime","value":"' uptime '","inline":true}'
    json .= '],'
    json .= '"footer":{"text":"rei gokil  v' APP_VERSION '  |  github.com/reihhd/AA"},'
    json .= '"image":{"url":"attachment://screenshot.png"}'
    json .= '}]}'

    jsonFile := A_Temp "\rg_payload_" A_TickCount ".json"
    try FileDelete(jsonFile)
    FileAppend(json, jsonFile, "UTF-8")

    ; Panggil script PowerShell eksternal
    psScript := A_ScriptDir "\send_to_discord.ps1"
    if !FileExist(psScript) {
        WebhookStatus.Text := "File send_to_discord.ps1 tidak ditemukan!"
        try FileDelete(tmpFile), FileDelete(jsonFile)
        return
    }

    cmd := 'powershell.exe -ExecutionPolicy Bypass -File "' psScript '" -webhookUrl "' WebhookURL '" -imagePath "' tmpFile '" -jsonPath "' jsonFile '"'
    try {
        RunWait(cmd, , "Hide")
        WebhookStatus.Text := "terkirim  " FormatTime(, "HH:mm:ss")
    } catch as e {
        WebhookStatus.Text := "gagal kirim: " e.Message
    }

    ; Cleanup
    Sleep(1000)
    try FileDelete(tmpFile), FileDelete(jsonFile)
}

; ============================================================
;  GDI+ LIBRARY
; ============================================================
Gdip_Startup() {
    global pToken
    DllCall("GetModuleHandle", "Str", "gdiplus", "UPtr")
    if (ErrorLevel)
        return 0
    VarSetStrLen(&si, 16, 0)
    NumPut(1, si, 0, "UChar")
    if DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "Ptr", &si, "Ptr", 0) != 0
        return 0
    return pToken
}
Gdip_Shutdown() {
    global pToken
    if pToken
        DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
    pToken := 0
}
Gdip_GetCodec(ext) {
    static codecCount := 0
    if !codecCount {
        DllCall("gdiplus\GdipGetImageEncodersSize", "UInt*", &codecCount := 0, "UInt*", &size := 0)
        encoders := Buffer(size)
        DllCall("gdiplus\GdipGetImageEncoders", "UInt", codecCount, "UInt", size, "Ptr", encoders)
        loop codecCount {
            if StrGet(NumGet(encoders, (A_Index-1)*80 + 76, "UPtr")) = ext {
                return NumGet(encoders, (A_Index-1)*80 + 4, "UPtr")
            }
        }
    }
    return 0
}
