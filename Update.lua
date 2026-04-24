require "import"
import "android.app.AlertDialog"
import "android.view.WindowManager"
import "android.content.DialogInterface"
import "android.content.Context"
import "android.content.Intent"
import "android.net.Uri"
import "android.location.LocationManager"
import "android.location.Geocoder"
import "java.io.File"
import "java.io.FileOutputStream"
import "java.io.FileInputStream"
import "java.io.BufferedReader"
import "java.io.InputStreamReader"
import "com.androlua.Http"
import "org.json.JSONObject"
import "android.os.Handler"
import "android.os.Looper"
import "java.util.Calendar"
import "java.util.Date"
import "java.text.SimpleDateFormat"
import "java.util.Locale"
import "android.os.Build"
import "android.widget.LinearLayout"
import "android.widget.TextView"
import "android.widget.Button"
import "android.widget.ScrollView"
import "android.view.Gravity"
import "android.graphics.Color"
import "android.graphics.Typeface"
import "android.graphics.drawable.ColorDrawable"
import "android.provider.Settings"
import "java.lang.String"
import "java.lang.Runnable"
import "java.lang.Thread"

local currentVersion = 2.0
local versionUrl = "https://raw.githubusercontent.com/hafiztasleem85-cmyk/Advance-islamic-assistant/refs/heads/main/Version.txt"
local updateUrl = "https://raw.githubusercontent.com/hafiztasleem85-cmyk/Advance-islamic-assistant/refs/heads/main/Update.lua"
local currentPluginPath = debug.getinfo(1, "S").source
if currentPluginPath:sub(1, 1) == "@" then
  currentPluginPath = currentPluginPath:sub(2)
end

local CONFIG_PATH = "/storage/emulated/0/解说/IslamicAssistantConfig.txt"

local langData = {
  ["1"] = {
    months = {"मुहर्रम उल हराम", "सफर उल मुज़फ्फर", "रबी उल अव्वल", "रबी उल सानी", "जमादी उल अव्वल", "जमादी उल सानी", "रजब उल मुरज्जब", "शाबान उल मुअज़्ज़म", "रमज़ान उल मुबारक", "शव्वाल उल मुकर्रम", "ज़ीकादा", "ज़िल हिज्जा"},
    days = {[0]="इतवार", [1]="पीर", [2]="मंगल", [3]="बुध", [4]="जुम्मेरात", [5]="जुम्मा", [6]="सनीचर"},
    prayers = {Fajr="फजर", Sunrise="तुलू-ए-आफ़ताब", Dhuhr="ज़ोहर", Asr="असर", Maghrib="मगरिब", Isha="ईशा"},
    locUnknown = "आपकी लोकेशन", hours = " घंटे ", mins = " मिनट",
    ramadanDataErr = "सर्वर से रमज़ान का डेटा हासिल करने में दुश्वारी पेश आ रही है, बराए करम कुछ देर बाद दोबारा कोशिश करें।",
    netErr = "इंटरनेट कनेक्शन मौजूद नहीं है, बराए करम अपना नेटवर्क चेक करें और दोबारा कोशिश करें।",
    serverErr = "सर्वर से राब्ता करने में दुश्वारी हो रही है।",
    aboutTitle = "इस्लामिक असिस्टेंट",
    upcomingTitle = "Upcoming Features",
    targetDone = "टारगेट मुकम्मल हुआ",
    resetDone = "तस्बीह रीसेट हुई",
    targetSet = "टारगेट अपडेट हुआ",
    dataSaved = "तस्बीह सेव हुई",
    dataDeleted = "तस्बीह डिलीट हुई",
    emptyName = "पहले तस्बीह का नाम दर्ज करें",
    convInvalid = "बराए करम सही तारीख दर्ज करें",
    convWait = "तारीख कनवर्ट हो रही है, इंतज़ार करें",
    eventTitle = "Islamic Events",
    eventLoad = "इवेंट्स लोड हो रहे हैं, बराए करम इंतज़ार करें, इस प्लगइन को तस्लीम रज़ा ने बनाया है",
    updateAvailableTitle = "नया अपडेट दस्तयाब है",
    noUpdateMsg = "अभी कोई नया अपडेट दस्तयाब नहीं है, आपका मौजूदा वर्ज़न %s बिल्कुल अप टू डेट है।",
    checkingUpdate = "चेक किया जा रहा है, इंतज़ार करें",
    updateDownloading = "अपडेट हो रहा है, इंतज़ार करें",
    updateSuccess = "प्लगइन कामयाबी के साथ अपडेट हो गया है",
    updateSaveErr = "अपडेट महफूज़ करने में दिक्कत आई",
    updateDownErr = "अपडेट डाउनलोड नहीं हो सका"
  },
  ["2"] = {
    months = {"محرم الحرام", "صفر المظفر", "ربیع الاول", "ربیع الثانی", "جمادی الاول", "جمادی الثانی", "رجب المرجب", "شعبان المعظم", "رمضان مبارک", "شوال المکرم", "ذیقعدہ", "ذوالحجہ"},
    days = {[0]="اتوار", [1]="پیر", [2]="منگل", [3]="بدھ", [4]="جمعرات", [5]="جمعہ", [6]="ہفتہ"},
    prayers = {Fajr="فجر", Sunrise="طلوعِ آفتاب", Dhuhr="ظہر", Asr="عصر", Maghrib="مغرب", Isha="عشاء"},
    locUnknown = "آپ کی لوکیشن", hours = " گھنٹے ", mins = " منٹ",
    ramadanDataErr = "سرور سے رمضان کا ڈیٹا حاصل کرنے میں دشواری پیش آ رہی ہے، برائے کرم کچھ دیر بعد دوبارہ کوشش کریں۔",
    netErr = "انٹرنیٹ کنکشن موجود نہیں ہے، برائے کرم اپنا نیٹ ورک چیک کریں اور دوبارہ کوشش کریں۔",
    serverErr = "سرور سے رابطہ کرنے میں دشواری ہو رہی ہے۔",
    aboutTitle = "اسلامک اسسٹنٹ",
    upcomingTitle = "Upcoming Features",
    targetDone = "ٹارگٹ مکمل ہوا",
    resetDone = "تسبیح ری سیٹ ہوئی",
    targetSet = "ٹارگٹ اپڈیٹ ہوا",
    dataSaved = "تسبیح سیو ہوئی",
    dataDeleted = "تسبیح ڈیلیٹ ہوئی",
    emptyName = "پہلے تسبیح کا نام درج کریں",
    convInvalid = "برائے کرم صحیح تاریخ درج کریں",
    convWait = "تاریخ کنورٹ ہو رہی ہے، انتظار کریں",
    eventTitle = "Islamic Events",
    eventLoad = "ایونٹس لوڈ ہو رہے ہیں، برائے کرم انتظار کریں، اس پلگ ان کو تسلیم رضا نے بنایا ہے",
    updateAvailableTitle = "نیا اپڈیٹ دستیاب ہے",
    noUpdateMsg = "ابھی کوئی نیا اپڈیٹ دستیاب نہیں ہے، آپ کا موجودہ ورژن %s بالکل اپ ٹو ڈیٹ ہے۔",
    checkingUpdate = "چیک کیا جا رہا ہے، انتظار کریں",
    updateDownloading = "اپڈیٹ ہو رہا ہے، انتظار کریں",
    updateSuccess = "پلگ ان کامیابی کے ساتھ اپڈیٹ ہو گیا ہے",
    updateSaveErr = "اپڈیٹ محفوظ کرنے میں دقت آئی",
    updateDownErr = "اپڈیٹ ڈاؤنلوڈ نہیں ہو سکا"
  },
  ["3"] = {
    months = {"Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani", "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"},
    days = {[0]="Sunday", [1]="Monday", [2]="Tuesday", [3]="Wednesday", [4]="Thursday", [5]="Friday", [6]="Saturday"},
    prayers = {Fajr="Fajr", Sunrise="Sunrise", Dhuhr="Dhuhr", Asr="Asr", Maghrib="Maghrib", Isha="Isha"},
    locUnknown = "Your location", hours = " hours ", mins = " minutes",
    ramadanDataErr = "Error fetching Ramadan data from the server, Please try again later.",
    netErr = "No internet connection, Please check your network and try again.",
    serverErr = "Having trouble communicating with the server.",
    aboutTitle = "Islamic Assistant",
    upcomingTitle = "Upcoming Features",
    targetDone = "Target completed",
    resetDone = "Reset completed",
    targetSet = "Target updated",
    dataSaved = "Tasbeeh saved",
    dataDeleted = "Tasbeeh deleted",
    emptyName = "Tasbeeh name is required",
    convInvalid = "Please enter a valid date",
    convWait = "Converting date, please wait",
    eventTitle = "Islamic Events",
    eventLoad = "Loading events, please wait, this plugin created by, Tasleem Razaa",
    updateAvailableTitle = "New Update Available",
    noUpdateMsg = "No new update is available right now. Your current version %s is completely up to date.",
    checkingUpdate = "Checking for updates, please wait",
    updateDownloading = "Updating, please wait",
    updateSuccess = "Plugin updated successfully",
    updateSaveErr = "Error saving update",
    updateDownErr = "Error downloading update"
  }
}

local remoteNotes = nil
local function fetchRemoteNotes(callback)
  if remoteNotes then
    if callback then callback() end
    return
  end
  local notesUrl = "https://raw.githubusercontent.com/hafiztasleem85-cmyk/Advance-islamic-assistant/refs/heads/main/Notes.json"
  Http.get(notesUrl, nil, "utf-8", nil, function(code, res)
    if code == 200 and res then
      pcall(function() remoteNotes = JSONObject(res) end)
    end
    if callback then callback() end
  end)
end

local cachedConfigJsonStr = nil

local function readConfigFile()
  if cachedConfigJsonStr then return cachedConfigJsonStr end
  local file = io.open(CONFIG_PATH, "r")
  if not file then return nil end
  cachedConfigJsonStr = file:read("*a")
  file:close()
  return cachedConfigJsonStr
end

local function writeConfigFile(jsonString)
  cachedConfigJsonStr = jsonString
  Thread(Runnable({
    run = function()
      pcall(function()
        local f = File(CONFIG_PATH)
        local fos = FileOutputStream(f)
        fos.write(String(jsonString).getBytes())
        fos.close()
      end)
    end
  })).start()
end

local function getQiblaBearing(userLat, userLng)
  local kaabaLat = math.rad(21.422487)
  local kaabaLng = math.rad(39.826206)
  local lat1 = math.rad(userLat)
  local lng1 = math.rad(userLng)
  local dLng = kaabaLng - lng1
  local y = math.sin(dLng) * math.cos(kaabaLat)
  local x = math.cos(lat1) * math.sin(kaabaLat) - math.sin(lat1) * math.cos(kaabaLat) * math.cos(dLng)
  local bearing = math.deg(math.atan2(y, x))
  return (bearing + 360) % 360
end

local cachedSettings = nil

local function getSettings()
  if cachedSettings then return cachedSettings end
  local defaultSettings = {lang="0", adjust="-1", school="1", calcMethod="1", adjFajr="0", adjDhuhr="0", adjAsr="0", adjMaghrib="0", adjIsha="0"}
  local jsonStr = readConfigFile()
  if not jsonStr or jsonStr == "" then return defaultSettings end
  local status, res = pcall(function() 
    local j = JSONObject(jsonStr)
    return {lang=j.optString("lang","0"), adjust=j.optString("adjust","-1"), school=j.optString("school","1"), calcMethod=j.optString("calcMethod","1"), adjFajr=j.optString("adjFajr","0"), adjDhuhr=j.optString("adjDhuhr","0"), adjAsr=j.optString("adjAsr","0"), adjMaghrib=j.optString("adjMaghrib","0"), adjIsha=j.optString("adjIsha","0")}
  end)
  if status then cachedSettings = res else cachedSettings = defaultSettings end
  return cachedSettings
end

local function saveSettings(settings)
  cachedSettings = settings
  Thread(Runnable({
    run = function()
      pcall(function()
        local rootJson = JSONObject()
        local jsonStr = readConfigFile()
        if jsonStr and jsonStr ~= "" then
          pcall(function() rootJson = JSONObject(jsonStr) end)
        end
        rootJson.put("lang", settings.lang)
        rootJson.put("adjust", settings.adjust)
        rootJson.put("school", settings.school)
        rootJson.put("calcMethod", settings.calcMethod)
        rootJson.put("adjFajr", settings.adjFajr)
        rootJson.put("adjDhuhr", settings.adjDhuhr)
        rootJson.put("adjAsr", settings.adjAsr)
        rootJson.put("adjMaghrib", settings.adjMaghrib)
        rootJson.put("adjIsha", settings.adjIsha)
        writeConfigFile(rootJson.toString())
      end)
    end
  })).start()
end

local function adjustPrayerTimeMinute(timeStr, offsetMinStr)
  local offset = tonumber(offsetMinStr) or 0
  if offset == 0 then return timeStr end
  local h = tonumber(timeStr:sub(1,2))
  local m = tonumber(timeStr:sub(4,5))
  local totalMins = (h * 60) + m + offset
  if totalMins < 0 then totalMins = totalMins + (24 * 60) end
  if totalMins >= (24 * 60) then totalMins = totalMins - (24 * 60) end
  return string.format("%02d:%02d", math.floor(totalMins / 60), totalMins % 60)
end

local function getAdjustedHijri(day, month, year, adjust, langCode)
  local safeLang = (langCode == "0") and "1" or langCode
  local mNameList = langData[safeLang].months
  local d, m, y, adj = tonumber(day), tonumber(month), tonumber(year), tonumber(adjust)
  d = d + adj
  if d <= 0 then
    m = m - 1 d = 30 + d 
    if m < 1 then m = 12 y = y - 1 end
  elseif d > 30 then
    d = d - 30 m = m + 1
    if m > 12 then m = 1 y = y + 1 end
  end
  return d, mNameList[m], y
end

local function getLocationData()
  local lm = service.getSystemService(Context.LOCATION_SERVICE)
  local loc = nil
  pcall(function()
    loc = lm.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
    if not loc then loc = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER) end
  end)
  if not loc then return nil, nil, nil end
  local lat, lng, cityName = loc.getLatitude(), loc.getLongitude(), "Unknown City"
  pcall(function()
      local geo = Geocoder(service, Locale.getDefault())
      local addresses = geo.getFromLocation(lat, lng, 1)
      if addresses and addresses.size() > 0 then
          local addr = addresses.get(0)
          cityName = addr.getLocality() 
          if not cityName then cityName = addr.getSubAdminArea() end
      end
  end)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  if cityName == "Unknown City" then cityName = langData[safeLang].locUnknown end
  return lat, lng, cityName
end

local function formatTime12(time24)
  local h = tonumber(time24:sub(1,2))
  local m = time24:sub(4,5)
  local suffix = "AM"
  if h >= 12 then suffix = "PM" if h > 12 then h = h - 12 end end
  if h == 0 then h = 12 end
  return string.format("%02d:%02s %s", h, m, suffix)
end

local function getCurrentTimeDecimal()
  local cal = Calendar.getInstance()
  return cal.get(Calendar.HOUR_OF_DAY) + (cal.get(Calendar.MINUTE)/60)
end

local function getRemainingTimeStr(targetTimeStr, langCode)
  local safeLang = (langCode == "0") and "1" or langCode
  local nowDec = getCurrentTimeDecimal()
  local targetDec = tonumber(targetTimeStr:sub(1,2)) + (tonumber(targetTimeStr:sub(4,5))/60)
  if targetDec < nowDec then targetDec = targetDec + 24 end
  local diff = targetDec - nowDec
  local diffH = math.floor(diff)
  local diffM = math.floor((diff - diffH) * 60)
  local res = ""
  if diffH > 0 then res = res .. diffH .. langData[safeLang].hours end
  return res .. diffM .. langData[safeLang].mins
end

local function getSavedTasbeehs()
  local jsonStr = readConfigFile()
  if not jsonStr or jsonStr == "" then return {} end
  local status, res = pcall(function()
    local rootJson = JSONObject(jsonStr)
    if not rootJson.has("tasbeehData") then return {} end
    local j = rootJson.getJSONObject("tasbeehData")
    local keys = j.keys()
    local list = {}
    while keys.hasNext() do
      local k = keys.next()
      local item = j.getJSONObject(k)
      table.insert(list, {id = k, name = item.getString("name"), count = item.getString("count"), target = item.getString("target"), total = item.optString("total", item.getString("count")), time = item.optString("time", "No date")})
    end
    return list
  end)
  if status then return res else return {} end
end

local function saveTasbeehData(id, name, count, target, total)
  local rootJson = JSONObject()
  local jsonStr = readConfigFile()
  if jsonStr and jsonStr ~= "" then
    pcall(function() rootJson = JSONObject(jsonStr) end)
  end
  local j = JSONObject()
  if rootJson.has("tasbeehData") then j = rootJson.getJSONObject("tasbeehData") end
  local itemJson = JSONObject()
  itemJson.put("name", name)
  itemJson.put("count", tostring(count))
  itemJson.put("target", tostring(target))
  itemJson.put("total", tostring(total))
  itemJson.put("time", SimpleDateFormat("dd-MM-yyyy hh:mm a", Locale.getDefault()).format(Date()))
  j.put(id, itemJson)
  rootJson.put("tasbeehData", j)
  writeConfigFile(rootJson.toString())
end

local function deleteTasbeehData(id)
  local jsonStr = readConfigFile()
  if not jsonStr or jsonStr == "" then return end
  local rootJson = JSONObject()
  pcall(function() rootJson = JSONObject(jsonStr) end)
  if rootJson.has("tasbeehData") then
    local j = rootJson.getJSONObject("tasbeehData")
    j.remove(id)
    rootJson.put("tasbeehData", j)
    writeConfigFile(rootJson.toString())
  end
end

local openTasbeehCounter, showTasbeehList
local checkUpdate, reopenMainScreen
local mainFunction, showSettingsMenu, showSmartDialog
local showMainMenu, showDateConverter, loadIslamicEvents
local showSmartDualCalendar, loadCalendarData
local showSmartMasjidFinder, showQiblaDirection

local function isUpdateAvailable(current, online)
  local function splitVersion(ver)
    local parts = {}
    for part in string.gmatch(tostring(ver), "%d+") do
      table.insert(parts, tonumber(part))
    end
    return parts
  end
  local cParts = splitVersion(current)
  local oParts = splitVersion(online)
  for i = 1, math.max(#cParts, #oParts) do
    local c = cParts[i] or 0
    local o = oParts[i] or 0
    if o > c then return true end
    if o < c then return false end
  end
  return false
end

reopenMainScreen = function(screenData)
  if screenData and screenData.mainMessage then
    showSmartDialog(screenData)
  else
    mainFunction(nil)
  end
end

checkUpdate = function(isManual, screenData, parentDialog)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  if isManual then
    service.speak(langData[safeLang].checkingUpdate)
  end
  Http.get(versionUrl, nil, "utf-8", nil, function(code, res)
    if code == 200 and res then
      if isUpdateAvailable(currentVersion, res) then
        local updateMessage = langData[safeLang].updateAvailableTitle
        if remoteNotes and remoteNotes.has("update_message") then
          pcall(function() updateMessage = remoteNotes.getJSONObject("update_message").getString(safeLang) end)
        end
        local builder = AlertDialog.Builder(service)
        builder.setTitle(langData[safeLang].updateAvailableTitle)
        builder.setMessage(updateMessage)
        builder.setNegativeButton("Update Now", nil)
        builder.setPositiveButton("Maybe Later", nil)
        local dialog = builder.create()
        if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        if parentDialog then pcall(function() parentDialog.dismiss() end) end
        dialog.show()
        dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
        dialog.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
        dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setOnClickListener(function(v)
          dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setEnabled(false)
          dialog.getButton(DialogInterface.BUTTON_POSITIVE).setEnabled(false)
          service.speak(langData[safeLang].updateDownloading)
          Http.get(updateUrl, nil, "utf-8", nil, function(code2, res2)
            if code2 == 200 and res2 then
              local f = io.open(currentPluginPath, "w")
              if f then
                f:write(res2)
                f:close()
                service.speak(langData[safeLang].updateSuccess)
                Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() pcall(function() dialog.dismiss() dofile(currentPluginPath) end) end}), 1000)
              else
                service.speak(langData[safeLang].updateSaveErr)
                dialog.dismiss()
                reopenMainScreen(screenData)
              end
            else
              service.speak(langData[safeLang].updateDownErr)
              dialog.dismiss()
              reopenMainScreen(screenData)
            end
          end)
        end)
        dialog.getButton(DialogInterface.BUTTON_POSITIVE).setOnClickListener(function(v)
          dialog.dismiss()
          reopenMainScreen(screenData)
        end)
      else
        if isManual then
          local msg = string.format(langData[safeLang].noUpdateMsg, tostring(currentVersion))
          service.speak(msg)
          local builder = AlertDialog.Builder(service)
          builder.setTitle(langData[safeLang].aboutTitle)
          builder.setMessage(msg)
          builder.setPositiveButton("OK", function() reopenMainScreen(screenData) end)
          local dialog = builder.create()
          if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
          if parentDialog then pcall(function() parentDialog.dismiss() end) end
          dialog.show()
          dialog.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
        else
          if parentDialog then pcall(function() parentDialog.dismiss() end) end
          reopenMainScreen(screenData)
        end
      end
    else
      if isManual then
        local msg = langData[safeLang].netErr
        service.speak(msg)
        local builder = AlertDialog.Builder(service)
        builder.setTitle("Error")
        builder.setMessage(msg)
        builder.setPositiveButton("OK", function() reopenMainScreen(screenData) end)
        local dialog = builder.create()
        if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        if parentDialog then pcall(function() parentDialog.dismiss() end) end
        dialog.show()
        dialog.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
      else
        if parentDialog then pcall(function() parentDialog.dismiss() end) end
        reopenMainScreen(screenData)
      end
    end
  end)
end

openTasbeehCounter = function(tasbeehId, tasbeehName, startCount, startTarget, startTotal, parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local currentCount = tonumber(startCount) or 0
  local currentTarget = tonumber(startTarget) or 33
  local totalCount = tonumber(startTotal) or currentCount
  local targetReached = false
  if currentCount >= currentTarget then targetReached = true end
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local function speakSafe(text)
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
    speechRunnable = Runnable({run = function() service.speak(text) end})
    speechHandler.postDelayed(speechRunnable, 500)
  end
  local builder = AlertDialog.Builder(service)
  local screenHeight = service.getResources().getDisplayMetrics().heightPixels
  local layout = LinearLayout(service)
  layout.setOrientation(1)
  layout.setLayoutParams(LinearLayout.LayoutParams(-1, screenHeight))
  layout.setMinimumHeight(screenHeight)
  local tvTitle = TextView(service)
  tvTitle.setText(tasbeehName or "New Tasbeeh")
  tvTitle.setTextSize(20)
  tvTitle.setGravity(Gravity.CENTER)
  tvTitle.setPadding(0, 10, 0, 10)
  layout.addView(tvTitle)
  local btnTap = Button(service)
  btnTap.setText("tap here")
  btnTap.setAllCaps(false)
  btnTap.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 0.65))
  layout.addView(btnTap)
  local countLayout = LinearLayout(service)
  countLayout.setOrientation(0)
  local tvTotal = TextView(service)
  tvTotal.setText("Total: " .. totalCount)
  tvTotal.setTextSize(24)
  tvTotal.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1.0))
  tvTotal.setGravity(Gravity.LEFT)
  tvTotal.setPadding(30, 40, 0, 40)
  local tvCount = TextView(service)
  tvCount.setText(currentCount .. " / " .. currentTarget)
  tvCount.setTextSize(24)
  tvCount.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1.0))
  tvCount.setGravity(Gravity.RIGHT)
  tvCount.setPadding(0, 40, 30, 40)
  countLayout.addView(tvTotal)
  countLayout.addView(tvCount)
  layout.addView(countLayout)
  local bottomBar = LinearLayout(service)
  bottomBar.setOrientation(0)
  bottomBar.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 0.15))
  local btnTarget = Button(service)
  local btnSave = Button(service)
  local btnReset = Button(service)
  btnTarget.setText("target " .. currentTarget)
  btnSave.setText("save")
  btnReset.setText("reset")
  btnTarget.setAllCaps(false)
  btnSave.setAllCaps(false)
  btnReset.setAllCaps(false)
  local lpParams = LinearLayout.LayoutParams(0, -1, 1.0)
  btnTarget.setLayoutParams(lpParams)
  btnSave.setLayoutParams(lpParams)
  btnReset.setLayoutParams(lpParams)
  btnSave.setEnabled(totalCount > 0)
  btnReset.setEnabled(totalCount > 0)
  bottomBar.addView(btnTarget)
  bottomBar.addView(btnSave)
  bottomBar.addView(btnReset)
  layout.addView(bottomBar)
  local btnBackMenu = Button(service)
  btnBackMenu.setText("back to menu")
  btnBackMenu.setAllCaps(false)
  btnBackMenu.setPadding(0, 10, 0, 10)
  layout.addView(btnBackMenu)
  builder.setView(layout)
  local dialog = builder.create()
  if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
  dialog.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) 
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end 
    layout = nil dialog = nil 
  end})
  local vibrator = service.getSystemService(Context.VIBRATOR_SERVICE)
  btnTap.setOnClickListener(function(v)
    if targetReached then
      currentCount = 1
      targetReached = false
    else
      currentCount = currentCount + 1
    end
    totalCount = totalCount + 1
    tvCount.setText(currentCount .. " / " .. currentTarget)
    tvTotal.setText("Total: " .. totalCount)
    btnSave.setEnabled(true)
    btnReset.setEnabled(true)
    pcall(function() if vibrator then vibrator.vibrate(50) end end)
    if currentCount == currentTarget then
       targetReached = true
       speakSafe(langData[safeLang].targetDone)
       pcall(function() if vibrator then vibrator.vibrate(500) end end)
       pcall(function()
         local tg = luajava.bindClass("android.media.ToneGenerator")(5, 100)
         tg.startTone(24, 200)
         Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() tg.release() end}), 300)
       end)
    end
  end)
  btnReset.setOnClickListener(function(v)
    currentCount = 0
    totalCount = 0
    targetReached = false
    tvCount.setText(currentCount .. " / " .. currentTarget)
    tvTotal.setText("Total: " .. totalCount)
    btnSave.setEnabled(false)
    btnReset.setEnabled(false)
    speakSafe(langData[safeLang].resetDone)
  end)
  btnTarget.setOnClickListener(function(v)
    local options = {"11", "33", "41", "99", "Custom"}
    local bTarget = AlertDialog.Builder(service)
    bTarget.setTitle("Select Target")
    bTarget.setItems(options, DialogInterface.OnClickListener{
      onClick = function(d, w)
        if w == 4 then
           local input = luajava.bindClass("android.widget.EditText")(service)
           input.setInputType(2)
           local bCustom = AlertDialog.Builder(service)
           bCustom.setTitle("Enter Custom Target")
           bCustom.setView(input)
           bCustom.setPositiveButton("ok", DialogInterface.OnClickListener{
             onClick = function(d2, w2)
               local val = tonumber(input.getText().toString())
               if val and val > 0 then
                 currentTarget = val
                 btnTarget.setText("target " .. currentTarget)
                 tvCount.setText(currentCount .. " / " .. currentTarget)
                 if currentCount >= currentTarget then targetReached = true else targetReached = false end
                 speakSafe(langData[safeLang].targetSet)
               end
             end
           })
           bCustom.setNegativeButton("cancel", nil)
           local dCustom = bCustom.create()
           if Build.VERSION.SDK_INT >= 22 then dCustom.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dCustom.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
           dCustom.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function() dCustom = nil input = nil end})
           dCustom.show()
           dCustom.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
           dCustom.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
        else
           currentTarget = tonumber(options[w+1])
           btnTarget.setText("target " .. currentTarget)
           tvCount.setText(currentCount .. " / " .. currentTarget)
           if currentCount >= currentTarget then targetReached = true else targetReached = false end
           speakSafe(langData[safeLang].targetSet)
        end
      end
    })
    bTarget.setNegativeButton("cancel", nil)
    local dTarget = bTarget.create()
    if Build.VERSION.SDK_INT >= 22 then dTarget.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dTarget.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    dTarget.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function() dTarget = nil end})
    dTarget.show()
    dTarget.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
  end)
  btnSave.setOnClickListener(function(v)
    if tasbeehId then
      saveTasbeehData(tasbeehId, tasbeehName, totalCount, currentTarget, totalCount)
      speakSafe(langData[safeLang].dataSaved)
      dialog.dismiss()
      showTasbeehList(parentDialog, screenData)
    else
      local input = luajava.bindClass("android.widget.EditText")(service)
      local bSave = AlertDialog.Builder(service)
      bSave.setTitle("Please type tasbeeh name")
      bSave.setView(input)
      bSave.setPositiveButton("save", nil)
      bSave.setNegativeButton("cancel", nil)
      local dSave = bSave.create()
      if Build.VERSION.SDK_INT >= 22 then dSave.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dSave.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dSave.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function() dSave = nil input = nil end})
      dSave.show()
      dSave.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
      dSave.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
      dSave.getButton(DialogInterface.BUTTON_POSITIVE).setOnClickListener(function(btnV)
         local tName = input.getText().toString()
         if tName ~= "" then
            tasbeehId = tostring(os.time())
            tasbeehName = tName
            saveTasbeehData(tasbeehId, tasbeehName, totalCount, currentTarget, totalCount)
            tvTitle.setText(tasbeehName)
            speakSafe(langData[safeLang].dataSaved)
            dSave.dismiss()
            dialog.dismiss()
            showTasbeehList(parentDialog, screenData)
         else
            speakSafe(langData[safeLang].emptyName)
         end
      end)
    end
  end)
  btnBackMenu.setOnClickListener(function(v) 
    dialog.dismiss() 
    showTasbeehList(parentDialog, screenData)
  end)
  dialog.show()
end

showTasbeehList = function(parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local savedList = getSavedTasbeehs()
  local displayNames = {}
  local isEmpty = false
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local function speakSafe(text)
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
    speechRunnable = Runnable({run = function() service.speak(text) end})
    speechHandler.postDelayed(speechRunnable, 500)
  end
  if #savedList == 0 then
    isEmpty = true
  else
    for i, v in ipairs(savedList) do
      table.insert(displayNames, v.name .. ", Count: " .. v.count .. ", Target: " .. v.target .. ", Last Saved: " .. v.time)
    end
  end
  local builder = AlertDialog.Builder(service)
  local titleLayout = LinearLayout(service)
  titleLayout.setOrientation(1)
  local tvTitle = TextView(service)
  tvTitle.setText("Smart Tasbeeh Counter")
  tvTitle.setTextSize(22)
  tvTitle.setPadding(40, 40, 40, 20)
  tvTitle.setTextColor(0xFF000000)
  titleLayout.addView(tvTitle)
  local btnStart = Button(service)
  btnStart.setText("start new tasbeeh")
  btnStart.setAllCaps(false)
  local lpStart = LinearLayout.LayoutParams(-1, -2)
  lpStart.setMargins(30, 0, 30, 20)
  btnStart.setLayoutParams(lpStart)
  titleLayout.addView(btnStart)
  builder.setCustomTitle(titleLayout)
  if isEmpty then
    builder.setMessage("No saved tasbeeh available")
  else
    builder.setItems(displayNames, DialogInterface.OnClickListener{
      onClick = function(d, which)
          local selected = savedList[which+1]
          local options = {"continue tasbeeh", "rename", "delete", "go back"}
          local bOpt = AlertDialog.Builder(service)
          bOpt.setTitle(selected.name)
          bOpt.setItems(options, DialogInterface.OnClickListener{
            onClick = function(dOpt, wOpt)
              if wOpt == 0 then
                openTasbeehCounter(selected.id, selected.name, selected.count, selected.target, selected.total, parentDialog, screenData)
                dOpt.dismiss()
                d.dismiss()
              elseif wOpt == 1 then
                local input = luajava.bindClass("android.widget.EditText")(service)
                input.setText(selected.name)
                local bRen = AlertDialog.Builder(service)
                bRen.setTitle("Rename Tasbeeh")
                bRen.setView(input)
                bRen.setPositiveButton("save", DialogInterface.OnClickListener{
                  onClick = function(dRen, wRen)
                     local newName = input.getText().toString()
                     if newName ~= "" then
                        saveTasbeehData(selected.id, newName, selected.count, selected.target, selected.total)
                        speakSafe(langData[safeLang].dataSaved)
                        showTasbeehList(parentDialog, screenData)
                     end
                  end
                })
                bRen.setNegativeButton("cancel", nil)
                local dRen = bRen.create()
                if Build.VERSION.SDK_INT >= 22 then dRen.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dRen.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
                dRen.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function() dRen = nil input = nil end})
                dRen.show()
                dRen.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
                dRen.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
                dOpt.dismiss()
                d.dismiss()
              elseif wOpt == 2 then
                deleteTasbeehData(selected.id)
                speakSafe(langData[safeLang].dataDeleted)
                showTasbeehList(parentDialog, screenData)
                dOpt.dismiss()
                d.dismiss()
              elseif wOpt == 3 then
                showTasbeehList(parentDialog, screenData)
                dOpt.dismiss()
                d.dismiss()
              end
            end
          })
          local dOpt = bOpt.create()
          if Build.VERSION.SDK_INT >= 22 then dOpt.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dOpt.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
          dOpt.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function() dOpt = nil end})
          dOpt.show()
      end
    })
  end
  local bottomLayout = LinearLayout(service)
  bottomLayout.setOrientation(1)
  local btnBack = Button(service)
  btnBack.setText("go back")
  btnBack.setAllCaps(false)
  btnBack.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
  bottomLayout.addView(btnBack)
  builder.setView(bottomLayout)
  local dialog = builder.create()
  if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dialog.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) 
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end 
    titleLayout = nil bottomLayout = nil dialog = nil 
  end})
  btnStart.setOnClickListener(function(v)
    openTasbeehCounter(nil, "New Tasbeeh", 0, 33, 0, parentDialog, screenData)
    dialog.dismiss()
  end)
  btnBack.setOnClickListener(function(v)
    dialog.dismiss()
    showMainMenu(parentDialog, screenData)
  end)
  dialog.show()
end
showQiblaDirection = function(parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local lat, lng, cityName = getLocationData()
  if not lat then
    Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak("लोकेशन मालूम नहीं हो सकी।") end}), 500)
    return
  end
  local qiblaBearing = getQiblaBearing(lat, lng)
  local GeomagneticField = luajava.bindClass("android.hardware.GeomagneticField")
  local geoField = GeomagneticField(luajava.new(luajava.bindClass("float"), lat), luajava.new(luajava.bindClass("float"), lng), luajava.new(luajava.bindClass("float"), 0), os.time() * 1000)
  local declination = geoField.getDeclination()
  local sm = service.getSystemService(Context.SENSOR_SERVICE)
  local Sensor = luajava.bindClass("android.hardware.Sensor")
  local SensorManager = luajava.bindClass("android.hardware.SensorManager")
  local accSensor = sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
  local magSensor = sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
  if not accSensor or not magSensor then
    Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak("आपके फोन में कंपास सेंसर मौजूद नहीं है।") end}), 500)
    return
  end
  local calibMsgs = {
    ["1"] = "आपके फोन का कंपास सही सम्त नहीं पकड़ पा रहा है। इसे ठीक करने के लिए, फोन को अपने हाथ में लेकर कुछ सेकंड तक हर तरफ थोड़ा सा घुमाएं और पलटें।",
    ["2"] = "آپ کے فون کا کمپاس صحیح سمت نہیں پکڑ پا رہا ہے۔ اسے ٹھیک کرنے کے لیے، فون کو اپنے ہاتھ میں لے کر کچھ سیکنڈ تک ہر طرف تھوڑا سا گھمائیں اور پلٹیں۔",
    ["3"] = "Your phone's compass is unable to catch the right direction. To fix this, hold the phone in your hand and gently tilt and move it in different directions for a few seconds."
  }
  local dirMsgs = {
    ["1"] = {pT="आप बिल्कुल सही क़िबले के रुख पर हैं।", pV="आप बिल्कुल सही क़िबले के रुख पर हैं।", rT="थोड़ा दाईं तरफ मुड़ें।", rV="दाईं तरफ मुड़ें", lT="थोड़ा बाईं तरफ मुड़ें।", lV="बाईं तरफ मुड़ें"},
    ["2"] = {pT="آپ بالکل صحیح قبلے کے رخ پر ہیں۔", pV="آپ بالکل صحیح قبلے کے رخ پر ہیں۔", rT="تھوڑا دائیں طرف مڑیں۔", rV="دائیں طرف مڑیں", lT="تھوڑا بائیں طرف مڑیں۔", lV="بائیں طرف مڑیں"},
    ["3"] = {pT="You are exactly on the Qibla direction.", pV="You are exactly on the Qibla direction.", rT="Turn slightly to the right.", rV="Turn right", lT="Turn slightly to the left.", lV="Turn left"}
  }
  local builder = AlertDialog.Builder(service)
  builder.setTitle("Qibla Direction")
  local layout = LinearLayout(service)
  layout.setOrientation(1)
  layout.setPadding(40, 40, 40, 40)
  local tvStatus = TextView(service)
  tvStatus.setText("फ़ोन को समतल (Flat) पकड़ें और धीरे धीरे घूमें।")
  tvStatus.setTextSize(18)
  tvStatus.setTextColor(0xFF000000)
  tvStatus.setGravity(1)
  layout.addView(tvStatus)
  builder.setView(layout)
  builder.setNegativeButton("go back", nil)
  local dialog = builder.create()
  if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  local lastAcc, lastMag = nil, nil
  local filterFactor = 0.15
  local lastSpokenTime = 0
  local lastCalibSpokenTime = 0
  local isFound = false
  local isLowAccuracy = false
  local function applyLowPassFilter(input, output)
    if not output then
      local arr = luajava.newArray(luajava.bindClass("float"), 3)
      for i = 0, 2 do arr[i] = input[i] end
      return arr
    end
    for i = 0, 2 do output[i] = output[i] + filterFactor * (input[i] - output[i]) end
    return output
  end
  local SensorEventListener = luajava.bindClass("android.hardware.SensorEventListener")
  local sensorListener
  sensorListener = SensorEventListener{
    onAccuracyChanged = function(sensor, accuracy) 
       if sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD then
          if accuracy == 0 or accuracy == 1 then
             isLowAccuracy = true
          else
             isLowAccuracy = false
          end
       end
    end,
    onSensorChanged = function(event)
      if event.sensor.getType() == Sensor.TYPE_ACCELEROMETER then 
        lastAcc = applyLowPassFilter(event.values, lastAcc)
      elseif event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD then 
        lastMag = applyLowPassFilter(event.values, lastMag)
      end
      if lastAcc and lastMag then
        local R = luajava.newArray(luajava.bindClass("float"), 9)
        local I = luajava.newArray(luajava.bindClass("float"), 9)
        if SensorManager.getRotationMatrix(R, I, lastAcc, lastMag) then
          local orientation = luajava.newArray(luajava.bindClass("float"), 3)
          SensorManager.getOrientation(R, orientation)
          local azimuth = math.deg(orientation[0])
          azimuth = azimuth + declination
          azimuth = (azimuth + 360) % 360
          local diff = qiblaBearing - azimuth
          if diff < -180 then diff = diff + 360 elseif diff > 180 then diff = diff - 360 end
          local currentTime = os.time()
          if isLowAccuracy then
             isFound = false
             if currentTime - lastCalibSpokenTime >= 15 then
                lastCalibSpokenTime = currentTime
                tvStatus.setText(calibMsgs[safeLang])
                Handler(Looper.getMainLooper()).post(Runnable({run = function() service.speak(calibMsgs[safeLang]) end}))
             end
          else
             if math.abs(diff) <= 8 then
               if not isFound then
                 isFound = true
                 tvStatus.setText(dirMsgs[safeLang].pT)
                 pcall(function() service.getSystemService(Context.VIBRATOR_SERVICE).vibrate(500) end)
                 Handler(Looper.getMainLooper()).post(Runnable({run = function() service.speak(dirMsgs[safeLang].pV) end}))
               end
             else
               isFound = false
               if currentTime - lastSpokenTime >= 4 then
                 lastSpokenTime = currentTime
                 if diff > 0 then
                   tvStatus.setText(dirMsgs[safeLang].rT)
                   Handler(Looper.getMainLooper()).post(Runnable({run = function() service.speak(dirMsgs[safeLang].rV) end}))
                 else
                   tvStatus.setText(dirMsgs[safeLang].lT)
                   Handler(Looper.getMainLooper()).post(Runnable({run = function() service.speak(dirMsgs[safeLang].lV) end}))
                 end
               end
             end
          end
        end
      end
    end
  }
  local isQiblaActive = true
  local qiblaTimerHandler = Handler(Looper.getMainLooper())
  local qiblaTimeoutRunnable = Runnable({
    run = function()
      if isQiblaActive then
        isQiblaActive = false
        pcall(function() sm.unregisterListener(sensorListener) end)
        if dialog then pcall(function() dialog.dismiss() end) end
        local timeoutMsg = ""
        if safeLang == "1" then timeoutMsg = "बैटरी बचाने के लिए क़िबला कंपास को बंद कर दिया गया है।"
        elseif safeLang == "2" then timeoutMsg = "بیٹری بچانے کے لیے قبلہ کمپاس کو بند کر دیا گیا ہے۔"
        else timeoutMsg = "Qibla compass has been closed to save battery." end
        Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(timeoutMsg) end}), 500)
      end
    end
  })
  qiblaTimerHandler.postDelayed(qiblaTimeoutRunnable, 300000)
  dialog.setOnDismissListener(DialogInterface.OnDismissListener{
    onDismiss = function(d) 
       isQiblaActive = false
       pcall(function() qiblaTimerHandler.removeCallbacks(qiblaTimeoutRunnable) end)
       pcall(function() sm.unregisterListener(sensorListener) end) 
       layout = nil 
       dialog = nil 
    end
  })
  dialog.setOnCancelListener(DialogInterface.OnCancelListener{
    onCancel = function(d) 
       isQiblaActive = false
       pcall(function() qiblaTimerHandler.removeCallbacks(qiblaTimeoutRunnable) end)
       pcall(function() sm.unregisterListener(sensorListener) end) 
    end
  })
  dialog.show()
  dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
  dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setOnClickListener(function(v)
     dialog.dismiss()
     showMainMenu(parentDialog, screenData)
  end)
  pcall(function() sm.unregisterListener(sensorListener) end)
  pcall(function()
    sm.registerListener(sensorListener, accSensor, SensorManager.SENSOR_DELAY_UI)
    sm.registerListener(sensorListener, magSensor, SensorManager.SENSOR_DELAY_UI)
  end)
end

showSmartMasjidFinder = function(parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local lat, lng, cityName = getLocationData()
  if not lat then
    Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak("लोकेशन मालूम नहीं हो सकी।") end}), 500)
    return
  end
  local noteMsg = langData[safeLang].netErr
  pcall(function() noteMsg = remoteNotes.getJSONObject("masjid_note").getString(safeLang) end)
  local bNote = AlertDialog.Builder(service)
  local layout = LinearLayout(service)
  layout.setOrientation(1)
  layout.setPadding(30, 30, 30, 30)
  local tvNote = TextView(service)
  tvNote.setText(noteMsg)
  tvNote.setTextSize(16)
  tvNote.setTextColor(0xFF000000)
  tvNote.setPadding(0, 0, 0, 30)
  layout.addView(tvNote)
  local btnSearch = Button(service)
  btnSearch.setText("Search on Map")
  btnSearch.setAllCaps(false)
  btnSearch.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
  layout.addView(btnSearch)
  local btnBack = Button(service)
  btnBack.setText("go back")
  btnBack.setAllCaps(false)
  btnBack.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
  layout.addView(btnBack)
  bNote.setView(layout)
  local dNote = bNote.create()
  if Build.VERSION.SDK_INT >= 22 then dNote.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dNote.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dNote.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() layout = nil dNote = nil end })
  dNote.show()
  btnBack.setOnClickListener(function(v)
    dNote.dismiss()
    showMainMenu(parentDialog, screenData)
  end)
  btnSearch.setOnClickListener(function(v)
    dNote.dismiss()
    local loadMsg = langData[safeLang].netErr
    if safeLang == "1" then loadMsg = "मस्जिदें तलाश की जा रही हैं, बराए करम इंतज़ार करें, इस प्लगइन को तस्लीम रज़ा ने बनाया है।"
    elseif safeLang == "2" then loadMsg = "مسجدیں تلاش کی جا رہی ہیں، برائے کرم انتظار کریں، اس پلگ ان کو تسلیم رضا نے بنایا ہے۔"
    else loadMsg = "Searching for mosques, please wait, this plugin created by Tasleem Razaa." end
    local loadBuilder = AlertDialog.Builder(service)
    local loadLayout = LinearLayout(service)
    loadLayout.setPadding(40,40,40,40)
    local tvLoad = TextView(service)
    tvLoad.setText(loadMsg)
    tvLoad.setTextSize(18)
    tvLoad.setTextColor(0xFF000000)
    loadLayout.addView(tvLoad)
    loadBuilder.setView(loadLayout)
    loadBuilder.setCancelable(false)
    local loadDialog = loadBuilder.create()
    if Build.VERSION.SDK_INT >= 22 then loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    local speechHandler = Handler(Looper.getMainLooper())
    local speechRunnable = Runnable({run = function() service.speak(loadMsg) end})
    local actionRunnable = Runnable({
      run = function()
        pcall(function() loadDialog.dismiss() end)
        if parentDialog then pcall(function() parentDialog.dismiss() end) end
      end
    })
    loadDialog.setOnDismissListener(DialogInterface.OnDismissListener{
      onDismiss = function(d)
        pcall(function() speechHandler.removeCallbacks(speechRunnable) end)
        pcall(function() speechHandler.removeCallbacks(actionRunnable) end)
        loadLayout = nil loadDialog = nil
      end
    })
    loadDialog.show()
    speechHandler.postDelayed(speechRunnable, 500)
    pcall(function()
      local uri = Uri.parse("geo:" .. lat .. "," .. lng .. "?q=Mosque")
      local intent = Intent(Intent.ACTION_VIEW, uri)
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      service.startActivity(intent)
    end)
    speechHandler.postDelayed(actionRunnable, 3000)
  end)
end

showMainMenu = function(parentDialog, screenData)
    local menuOptions = {
        "Smart Dual Calendar", 
        "Islamic Events", 
        "Smart Date Converter", 
        "Smart Masjid Finder", 
        "Smart Tasbeeh Counter", 
        "Qibla Direction", 
        "Upcoming Features", 
        "Settings", 
        "Help & Feedback", 
        "About Us",
        "Check for Updates"
    }
    local bMenu = AlertDialog.Builder(service)
    bMenu.setTitle("Menu")
    bMenu.setItems(menuOptions, DialogInterface.OnClickListener{
        onClick = function(dMenu2, which)
            if which ~= 10 then
                dMenu2.dismiss()
            end
            if which == 0 then
                showSmartDualCalendar(parentDialog, screenData)
            elseif which == 1 then
                local defaultYear = (screenData and screenData.currentHijriYear) or tostring(math.floor((Calendar.getInstance().get(Calendar.YEAR) - 622) * 33 / 32))
                loadIslamicEvents(defaultYear, parentDialog, screenData)
            elseif which == 2 then
                showDateConverter(parentDialog, screenData)
            elseif which == 3 then
                showSmartMasjidFinder(parentDialog, screenData)
            elseif which == 4 then
                showTasbeehList(parentDialog, screenData)
            elseif which == 5 then
                showQiblaDirection(parentDialog, screenData)
            elseif which == 6 then
                local sets = getSettings()
                local safeLang = (sets.lang == "0") and "1" or sets.lang
                local bUp = AlertDialog.Builder(service)
                bUp.setTitle(langData[safeLang].upcomingTitle)
                local upMsg = langData[safeLang].netErr
                pcall(function() upMsg = remoteNotes.getJSONObject("upcoming").getString(safeLang) end)
                bUp.setMessage(upMsg)
                bUp.setPositiveButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
                local dUp = bUp.create()
                if Build.VERSION.SDK_INT >= 22 then dUp.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dUp.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
                dUp.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dUp = nil end })
                dUp.show()
                dUp.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
            elseif which == 7 then
                showSettingsMenu(parentDialog, screenData)
            elseif which == 8 then
                local bHelp = AlertDialog.Builder(service)
                bHelp.setTitle("Help & Feedback")
                local helpOptions = {
                  "Send feedback to developer, Tasleem Razaa", 
                  "Message on Instagram"
                }
                bHelp.setItems(helpOptions, DialogInterface.OnClickListener{
                  onClick=function(dHelp, wHelp)
                    local url = ""
                    if wHelp == 0 then
                        url = "https://wa.me/919795801895"
                    elseif wHelp == 1 then
                        url = "https://www.instagram.com/tasleemraza_0786?igsh=MW5iank1MDZ3eGR0eg=="
                    end
                    local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    service.startActivity(intent)
                  end
                })
                bHelp.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
                local dHelp = bHelp.create()
                if Build.VERSION.SDK_INT >= 22 then dHelp.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dHelp.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
                dHelp.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dHelp = nil end })
                dHelp.show()
                dHelp.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
            elseif which == 9 then
                local sets = getSettings()
                local safeLang = (sets.lang == "0") and "1" or sets.lang
                local bAbout = AlertDialog.Builder(service)
                bAbout.setTitle(langData[safeLang].aboutTitle)
                local abtMsg = langData[safeLang].netErr
                pcall(function() abtMsg = remoteNotes.getJSONObject("about").getString(safeLang) end)
                bAbout.setMessage(abtMsg)
                bAbout.setPositiveButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
                local dAbout = bAbout.create()
                if Build.VERSION.SDK_INT >= 22 then dAbout.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dAbout.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
                dAbout.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dAbout = nil end })
                dAbout.show()
                dAbout.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
            elseif which == 10 then
                checkUpdate(true, screenData, dMenu2)
            end
        end
    })
    bMenu.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() reopenMainScreen(screenData) end })
    local dMenu2 = bMenu.create()
    if Build.VERSION.SDK_INT >= 22 then dMenu2.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dMenu2.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    dMenu2.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dMenu2 = nil end })
    dMenu2.show()
    dMenu2.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
end

local function reverseAdjustHijri(d, m, y, adj)
    local dNum, mNum, yNum, adjNum = tonumber(d), tonumber(m), tonumber(y), tonumber(adj)
    dNum = dNum - adjNum
    if dNum <= 0 then
        mNum = mNum - 1
        dNum = 30 + dNum
        if mNum < 1 then mNum = 12 yNum = yNum - 1 end
    elseif dNum > 30 then
        dNum = dNum - 30
        mNum = mNum + 1
        if mNum > 12 then mNum = 1 yNum = yNum + 1 end
    end
    return dNum, mNum, yNum
end

loadIslamicEvents = function(selectedYear, parentDialog, screenData)
    local sets = getSettings()
    local safeLang = (sets.lang == "0") and "1" or sets.lang
    local events = {}
    pcall(function()
        local evArray = remoteNotes.getJSONObject("events").getJSONArray(safeLang)
        for i = 0, evArray.length() - 1 do
            local evObj = evArray.getJSONObject(i)
            table.insert(events, {n=evObj.getString("n"), d=evObj.getString("d"), m=evObj.getString("m")})
        end
    end)
    if #events == 0 then
        Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].netErr) end}), 500)
        return
    end
    local currentHijriYearStr = tostring(screenData.currentHijriYear)
    local selectedYearStr = tostring(selectedYear)
    local rootJson = JSONObject()
    local jsonStr = readConfigFile()
    if jsonStr and jsonStr ~= "" then
        pcall(function() rootJson = JSONObject(jsonStr) end)
    end
    local results = {}
    local useCache = false
    if selectedYearStr == currentHijriYearStr and rootJson.has("eventsCache") then
        pcall(function()
            local cache = rootJson.getJSONObject("eventsCache")
            if cache.optString("year") == selectedYearStr and cache.optString("lang") == sets.lang and cache.has("data") then
                local cachedData = cache.getJSONArray("data")
                if cachedData.length() == #events then
                    for i = 0, cachedData.length() - 1 do
                        table.insert(results, cachedData.getString(i))
                    end
                    useCache = true
                end
            end
        end)
    end
    local loadDialog = nil
    local speechHandler = Handler(Looper.getMainLooper())
    local speechRunnable1 = nil
    local speechRunnable2 = nil
    local handler = Handler(Looper.getMainLooper())
    local timeoutRunnable = nil
    if not useCache then
        local loadMsg = ""
        if safeLang == "1" then loadMsg = "इवेंट्स लोड हो रहे हैं, बराए करम इंतज़ार करें, इस प्लगइन को तस्लीम रज़ा ने बनाया है"
        elseif safeLang == "2" then loadMsg = "ایونٹس لوڈ ہو رہے ہیں، برائے کرم انتظار کریں، اس پلگ ان کو تسلیم رضا نے بنایا ہے"
        else loadMsg = "Loading events, please wait, this plugin created by, Tasleem Razaa" end
        local loadBuilder = AlertDialog.Builder(service)
        local loadLayout = LinearLayout(service)
        loadLayout.setPadding(40,40,40,40)
        local tvLoad = TextView(service)
        tvLoad.setText(loadMsg)
        tvLoad.setTextSize(18) tvLoad.setTextColor(0xFF000000)
        loadLayout.addView(tvLoad)
        loadBuilder.setView(loadLayout)
        loadBuilder.setCancelable(false)
        loadDialog = loadBuilder.create()
        if Build.VERSION.SDK_INT >= 22 then loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        loadDialog.setOnDismissListener(DialogInterface.OnDismissListener{
          onDismiss = function(d)
            if speechRunnable1 then pcall(function() speechHandler.removeCallbacks(speechRunnable1) end) end
            if speechRunnable2 then pcall(function() speechHandler.removeCallbacks(speechRunnable2) end) end
            if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
            loadLayout = nil loadDialog = nil
          end
        })
        loadDialog.show()
        local engMsg = "loading events, please wait, this plugin created by, tasleem razaa"
        if safeLang == "1" then
            speechRunnable1 = Runnable({run = function() service.speak("इवेंट्स लोड हो रहे हैं, बराए करम इंतज़ार करें, इस प्लगइन को तस्लीम रज़ा ने बनाया है") end})
            speechRunnable2 = Runnable({run = function() service.speak(engMsg) end})
            speechHandler.postDelayed(speechRunnable1, 500)
            speechHandler.postDelayed(speechRunnable2, 3500)
        elseif safeLang == "2" then
            speechRunnable1 = Runnable({run = function() service.speak("ایونٹس لوڈ ہو رہے ہیں، برائے کرم انتظار کریں، اس پلگ ان کو تسلیم رضا نے بنایا ہے") end})
            speechRunnable2 = Runnable({run = function() service.speak(engMsg) end})
            speechHandler.postDelayed(speechRunnable1, 500)
            speechHandler.postDelayed(speechRunnable2, 3500)
        else
            speechRunnable1 = Runnable({run = function() service.speak(engMsg) end})
            speechHandler.postDelayed(speechRunnable1, 500)
        end
    end
    local dEv = nil
    local function showResults()
        if loadDialog then pcall(function() loadDialog.dismiss() end) end
        local bEv = AlertDialog.Builder(service)
        bEv.setTitle(langData[safeLang].eventTitle)
        local layout = LinearLayout(service)
        layout.setOrientation(1)
        layout.setPadding(30, 30, 30, 30)
        local btnYear = Button(service)
        btnYear.setText("hijri year: " .. selectedYearStr .. " (tap to change)")
        btnYear.setAllCaps(false)
        btnYear.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
        layout.addView(btnYear)
        btnYear.setOnClickListener(function(v)
            local years = {}
            for y = 1430, 1460 do table.insert(years, tostring(y)) end
            local currentIdx = tonumber(selectedYearStr) - 1430
            if currentIdx < 0 or currentIdx > 30 then currentIdx = 0 end
            local bY = AlertDialog.Builder(service)
            bY.setTitle("Select Hijri Year")
            bY.setSingleChoiceItems(years, currentIdx, DialogInterface.OnClickListener{
                onClick=function(dY, wY)
                    dY.dismiss()
                    if dEv then pcall(function() dEv.dismiss() end) end
                    loadIslamicEvents(tostring(years[wY+1]), parentDialog, screenData)
                end
            })
            local dY = bY.create()
            if Build.VERSION.SDK_INT >= 22 then dY.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dY.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
            dY.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dY = nil end })
            dY.show()
        end)
        local scroll = ScrollView(service)
        scroll.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 1.0))
        local listLayout = LinearLayout(service)
        listLayout.setOrientation(1)
        for i = 1, #events do
            local tv = TextView(service)
            tv.setText(results[i])
            tv.setTextSize(18)
            tv.setTextColor(0xFF000000)
            tv.setPadding(0, 20, 0, 20)
            listLayout.addView(tv)
            if i < #events then
                local ViewClass = luajava.bindClass("android.view.View")
                local divider = ViewClass(service)
                divider.setBackgroundColor(0xFFCCCCCC)
                divider.setLayoutParams(LinearLayout.LayoutParams(-1, 2))
                listLayout.addView(divider)
            end
        end
        scroll.addView(listLayout)
        layout.addView(scroll)
        local btnGoBack = Button(service)
        btnGoBack.setText("go back")
        btnGoBack.setAllCaps(false)
        btnGoBack.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
        layout.addView(btnGoBack)
        bEv.setView(layout)
        dEv = bEv.create()
        if Build.VERSION.SDK_INT >= 22 then dEv.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dEv.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        dEv.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() layout = nil dEv = nil end })
        dEv.show()
        btnGoBack.setOnClickListener(function(v)
            dEv.dismiss()
            showMainMenu(parentDialog, screenData)
        end)
    end
    if useCache then
        showResults()
        return
    end
    local function fetchEvent(index)
        if index > #events then
            if selectedYearStr == currentHijriYearStr then
                pcall(function()
                    local cacheObj = JSONObject()
                    cacheObj.put("year", selectedYearStr)
                    cacheObj.put("lang", sets.lang)
                    local org_json_JSONArray = luajava.bindClass("org.json.JSONArray")
                    local dataArr = org_json_JSONArray()
                    for i, v in ipairs(results) do dataArr.put(v) end
                    cacheObj.put("data", dataArr)
                    rootJson.put("eventsCache", cacheObj)
                    writeConfigFile(rootJson.toString())
                end)
            end
            showResults()
            return
        end
        local ev = events[index]
        local aD, aM, aY = reverseAdjustHijri(ev.d, ev.m, selectedYearStr, sets.adjust)
        local url = "https://api.aladhan.com/v1/hToG?date=" .. string.format("%02d-%02d-%04d", aD, aM, aY)
        local isDone = false
        if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
        timeoutRunnable = Runnable({
            run = function()
                if not isDone then
                    isDone = true
                    if loadDialog then pcall(function() loadDialog.dismiss() end) end
                    Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak("Having trouble communicating with the server.") end}), 500)
                end
            end
        })
        handler.postDelayed(timeoutRunnable, 45000)
        Http.get(url, nil, "utf-8", nil, function(code, res)
            if not isDone then
                isDone = true
                if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
                local gDay, gMonthName, gYear, localWeekday = "??", "??", "????", ""
                if code == 200 and res then
                    pcall(function()
                        local data = JSONObject(res).getJSONObject("data")
                        local g = data.getJSONObject("gregorian")
                        local gWeekdayEn = g.getJSONObject("weekday").getString("en")
                        local dayMap = {Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6}
                        localWeekday = langData[safeLang].days[dayMap[gWeekdayEn] or 0]
                        gDay = g.getString("day")
                        gMonthName = g.getJSONObject("month").getString("en")
                        gYear = g.getString("year")
                    end)
                end
                local hMonthName = langData[safeLang].months[tonumber(ev.m)]
                local pD = tonumber(ev.d)
                local dayStr = tostring(pD)
                if safeLang == "3" then
                    if pD == 1 or pD == 21 or pD == 31 then dayStr = pD .. "st"
                    elseif pD == 2 or pD == 22 then dayStr = pD .. "nd"
                    elseif pD == 3 or pD == 23 then dayStr = pD .. "rd"
                    else dayStr = pD .. "th" end
                end
                local finalStr = ""
                if localWeekday ~= "" then
                    finalStr = dayStr .. " " .. hMonthName .. " " .. selectedYearStr .. ", " .. localWeekday .. ",\n " .. ev.n .. "   ➔   " .. gDay .. " " .. gMonthName .. " " .. gYear
                else
                    finalStr = dayStr .. " " .. hMonthName .. " " .. selectedYearStr .. "\n" .. ev.n .. "   ➔   Error fetching date"
                end
                results[index] = finalStr
                fetchEvent(index + 1)
            end
        end)
    end
    fetchEvent(1)
end

showSmartDualCalendar = function(parentDialog, screenData)
  local options = {"Gregorian to Hijri Calendar", "Hijri to Gregorian Calendar"}
  local bCal = AlertDialog.Builder(service)
  bCal.setTitle("Smart Dual Calendar")
  bCal.setItems(options, DialogInterface.OnClickListener{
    onClick = function(d, w)
      d.dismiss()
      local isGregorianBase = (w == 0)
      local cal = Calendar.getInstance()
      local currentYear = isGregorianBase and tostring(cal.get(Calendar.YEAR)) or tostring(screenData.currentHijriYear)
      local currentMonth = isGregorianBase and tostring(cal.get(Calendar.MONTH) + 1) or tostring(screenData.currentHijriMonthNum or "1")
      loadCalendarData(isGregorianBase, currentYear, currentMonth, parentDialog, screenData)
    end
  })
  bCal.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
  local dCal = bCal.create()
  if Build.VERSION.SDK_INT >= 22 then dCal.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dCal.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dCal.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dCal = nil end })
  dCal.show()
  dCal.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
end

loadCalendarData = function(isGregorianBase, selectedYear, selectedMonth, parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local events = {}
  pcall(function()
      local evArray = remoteNotes.getJSONObject("events").getJSONArray(safeLang)
      for i = 0, evArray.length() - 1 do
          local evObj = evArray.getJSONObject(i)
          table.insert(events, {n=evObj.getString("n"), d=evObj.getString("d"), m=evObj.getString("m")})
      end
  end)
  local cal = Calendar.getInstance()
  local actualCurrentYear = isGregorianBase and tostring(cal.get(Calendar.YEAR)) or tostring(screenData.currentHijriYear)
  local rootJson = JSONObject()
  local jsonStr = readConfigFile()
  if jsonStr and jsonStr ~= "" then
    pcall(function() rootJson = JSONObject(jsonStr) end)
  end
  local cacheKey = isGregorianBase and "calG_" or "calH_"
  cacheKey = cacheKey .. selectedYear .. "_" .. selectedMonth
  local useCache = false
  local results = {}
  if selectedYear == actualCurrentYear and rootJson.has(cacheKey) then
    pcall(function()
      local cacheObj = rootJson.getJSONObject(cacheKey)
      if cacheObj.optString("lang") == sets.lang and cacheObj.optString("adj") == sets.adjust and cacheObj.has("data") then
        local cachedData = cacheObj.getJSONArray("data")
        for i = 0, cachedData.length() - 1 do
          table.insert(results, cachedData.getString(i))
        end
        useCache = true
      end
    end)
  end
  local loadDialog = nil
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local handler = Handler(Looper.getMainLooper())
  local timeoutRunnable = nil
  if not useCache then
    local loadMsg = ""
    if safeLang == "1" then loadMsg = "लोडिंग हो रही है, बराए करम इंतज़ार करें"
    elseif safeLang == "2" then loadMsg = "لوڈنگ ہو رہی ہے، برائے کرم انتظار کریں"
    else loadMsg = "Loading, please wait" end
    local loadBuilder = AlertDialog.Builder(service)
    local loadLayout = LinearLayout(service)
    loadLayout.setPadding(40,40,40,40)
    local tvLoad = TextView(service)
    tvLoad.setText(loadMsg)
    tvLoad.setTextSize(18)
    tvLoad.setTextColor(0xFF000000)
    loadLayout.addView(tvLoad)
    loadBuilder.setView(loadLayout)
    loadBuilder.setCancelable(false)
    loadDialog = loadBuilder.create()
    if Build.VERSION.SDK_INT >= 22 then loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    speechRunnable = Runnable({run = function() service.speak(loadMsg) end})
    loadDialog.setOnDismissListener(DialogInterface.OnDismissListener{
      onDismiss = function(d)
        if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
        if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
        loadLayout = nil loadDialog = nil
      end
    })
    loadDialog.show()
    speechHandler.postDelayed(speechRunnable, 500)
  end
  local function showResults()
    if loadDialog then pcall(function() loadDialog.dismiss() end) end
    local bRes = AlertDialog.Builder(service)
    local dialogTitle = ""
    if safeLang == "1" then dialogTitle = "स्मार्ट डुअल कैलेंडर, आज की तारीख: "
    elseif safeLang == "2" then dialogTitle = "سمارٹ ڈوئل کیلنڈر، آج کی تاریخ: "
    else dialogTitle = "Smart Dual Calendar, Today's Date: " end
    local todayText = ""
    if isGregorianBase then
        todayText = dialogTitle .. (screenData.todayGregorianStr or "") .. ", " .. (screenData.todayDayName or "") .. ", " .. (screenData.todayHijriStr or "")
    else
        todayText = dialogTitle .. (screenData.todayHijriStr or "") .. ", " .. (screenData.todayDayName or "") .. ", " .. (screenData.todayGregorianStr or "")
    end
    bRes.setTitle(todayText)
    local layout = LinearLayout(service)
    layout.setOrientation(1)
    layout.setPadding(30, 30, 30, 30)
    local topBar = LinearLayout(service)
    topBar.setOrientation(0)
    topBar.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    local btnYear = Button(service)
    btnYear.setText(selectedYear .. ", tap to change year")
    btnYear.setAllCaps(false)
    btnYear.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1.0))
    local btnMonth = Button(service)
    local gMonths = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
    local mNameDisplay = isGregorianBase and gMonths[tonumber(selectedMonth)] or langData[safeLang].months[tonumber(selectedMonth)]
    btnMonth.setText(mNameDisplay .. ", tap to change month")
    btnMonth.setAllCaps(false)
    btnMonth.setLayoutParams(LinearLayout.LayoutParams(0, -2, 1.0))
    topBar.addView(btnYear)
    topBar.addView(btnMonth)
    layout.addView(topBar)
    local scroll = ScrollView(service)
    scroll.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 1.0))
    local listLayout = LinearLayout(service)
    listLayout.setOrientation(1)
    for i = 1, #results do
      local tv = TextView(service)
      tv.setText(results[i])
      tv.setTextSize(18)
      tv.setTextColor(0xFF000000)
      tv.setPadding(0, 20, 0, 20)
      listLayout.addView(tv)
      if i < #results then
        local ViewClass = luajava.bindClass("android.view.View")
        local divider = ViewClass(service)
        divider.setBackgroundColor(0xFFCCCCCC)
        divider.setLayoutParams(LinearLayout.LayoutParams(-1, 2))
        listLayout.addView(divider)
      end
    end
    scroll.addView(listLayout)
    layout.addView(scroll)
    local btnGoBack = Button(service)
    btnGoBack.setText("go back")
    btnGoBack.setAllCaps(false)
    btnGoBack.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
    layout.addView(btnGoBack)
    bRes.setView(layout)
    local dRes = bRes.create()
    if Build.VERSION.SDK_INT >= 22 then dRes.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dRes.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    dRes.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() layout = nil dRes = nil end })
    dRes.show()
    btnGoBack.setOnClickListener(function(v)
      dRes.dismiss()
      showSmartDualCalendar(parentDialog, screenData)
    end)
    btnYear.setOnClickListener(function(v)
      local years = {}
      local startY = isGregorianBase and 1900 or 1300
      local endY = isGregorianBase and 2100 or 1500
      for y = startY, endY do table.insert(years, tostring(y)) end
      local selectedIdx = tonumber(selectedYear) - startY
      if selectedIdx < 0 or selectedIdx >= #years then selectedIdx = 0 end
      local bY = AlertDialog.Builder(service)
      bY.setTitle("Select Year")
      bY.setSingleChoiceItems(years, selectedIdx, DialogInterface.OnClickListener{
        onClick = function(dY, wY)
          dY.dismiss()
          dRes.dismiss()
          loadCalendarData(isGregorianBase, years[wY+1], selectedMonth, parentDialog, screenData)
        end
      })
      local dY = bY.create()
      if Build.VERSION.SDK_INT >= 22 then dY.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dY.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dY.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dY = nil end })
      dY.show()
    end)
    btnMonth.setOnClickListener(function(v)
      local mList = isGregorianBase and gMonths or langData[safeLang].months
      local bM = AlertDialog.Builder(service)
      bM.setTitle("Select Month")
      bM.setItems(mList, DialogInterface.OnClickListener{
        onClick = function(dM, wM)
          dM.dismiss()
          dRes.dismiss()
          loadCalendarData(isGregorianBase, selectedYear, tostring(wM+1), parentDialog, screenData)
        end
      })
      local dM = bM.create()
      if Build.VERSION.SDK_INT >= 22 then dM.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dM.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dM.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dM = nil end })
      dM.show()
    end)
  end
  if useCache then
    showResults()
    return
  end
  if isGregorianBase then
    local url = "https://api.aladhan.com/v1/gToHCalendar/" .. selectedMonth .. "/" .. selectedYear
    local isDone = false
    timeoutRunnable = Runnable({
      run = function()
        if not isDone then
          isDone = true
          if loadDialog then pcall(function() loadDialog.dismiss() end) end
          Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].serverErr) end}), 500)
        end
      end
    })
    handler.postDelayed(timeoutRunnable, 30000)
    Http.get(url, nil, "utf-8", nil, function(code, res)
      if not isDone then
        isDone = true
        if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
        if code == 200 and res then
          pcall(function()
            local dataArray = JSONObject(res).getJSONArray("data")
            local expectedHMonthName = langData[safeLang].months[tonumber(selectedMonth)]
            for i = 0, dataArray.length() - 1 do
              local dayData = dataArray.getJSONObject(i)
              local g = dayData.getJSONObject("gregorian")
              local h = dayData.getJSONObject("hijri")
              local gWeekdayEn = g.getJSONObject("weekday").getString("en")
              local dayMap = {Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6}
              local localWeekday = langData[safeLang].days[dayMap[gWeekdayEn] or 0]
              local gDateStr = g.getString("day") .. " " .. g.getJSONObject("month").getString("en") .. " " .. g.getString("year")
              local hDay, hMonthName, hYear = getAdjustedHijri(h.getString("day"), h.getJSONObject("month").getInt("number"), h.getString("year"), sets.adjust, safeLang)
              local hDateStr = hDay .. " " .. hMonthName .. " " .. hYear
              local eventSuffix = ""
              for _, ev in ipairs(events) do
                if tonumber(ev.d) == hDay and langData[safeLang].months[tonumber(ev.m)] == hMonthName then
                  eventSuffix = " (" .. ev.n .. ")"
                  break
                end
              end
              table.insert(results, gDateStr .. ", " .. localWeekday .. "\n" .. hDateStr .. eventSuffix)
            end
            if selectedYear == actualCurrentYear then
              local cacheObj = JSONObject()
              cacheObj.put("lang", sets.lang)
              cacheObj.put("adj", sets.adjust)
              local dataArr = luajava.bindClass("org.json.JSONArray")()
              for i, v in ipairs(results) do dataArr.put(v) end
              cacheObj.put("data", dataArr)
              rootJson.put(cacheKey, cacheObj)
              writeConfigFile(rootJson.toString())
            end
          end)
          showResults()
        else
          if loadDialog then pcall(function() loadDialog.dismiss() end) end
          Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].serverErr) end}), 500)
        end
      end
    end)
  else
    local adjNum = tonumber(sets.adjust) or 0
    local mNum = tonumber(selectedMonth)
    local extraMonth, extraYear = nil, tonumber(selectedYear)
    if adjNum < 0 then
        extraMonth = mNum + 1
        if extraMonth > 12 then extraMonth = 1 extraYear = extraYear + 1 end
    elseif adjNum > 0 then
        extraMonth = mNum - 1
        if extraMonth < 1 then extraMonth = 12 extraYear = extraYear - 1 end
    end
    local allDays = {}
    local expectedHMonthName = langData[safeLang].months[mNum]
    local function processCombinedDays()
        pcall(function()
            for k = 1, #allDays do
                local hIndex = k + adjNum
                if hIndex >= 1 and hIndex <= #allDays then
                    local gData = allDays[k].g
                    local hData = allDays[hIndex].h
                    local hMonthNum = hData.getJSONObject("month").getInt("number")
                    local hMonthNameAPI = langData[safeLang].months[hMonthNum]
                    if hMonthNameAPI == expectedHMonthName then
                        local gDateStr = gData.getString("day") .. " " .. gData.getJSONObject("month").getString("en") .. " " .. gData.getString("year")
                        local gWeekdayEn = gData.getJSONObject("weekday").getString("en")
                        local dayMap = {Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6}
                        local localWeekday = langData[safeLang].days[dayMap[gWeekdayEn] or 0]
                        local hDayStr = hData.getString("day")
                        local hYearStr = hData.getString("year")
                        local hDateStr = tonumber(hDayStr) .. " " .. hMonthNameAPI .. " " .. hYearStr
                        local eventSuffix = ""
                        for _, ev in ipairs(events) do
                            if tonumber(ev.d) == tonumber(hDayStr) and tonumber(ev.m) == hMonthNum then
                                eventSuffix = " (" .. ev.n .. ")"
                                break
                            end
                        end
                        table.insert(results, hDateStr .. ", " .. localWeekday .. "\n" .. gDateStr .. eventSuffix)
                    end
                end
            end
            if selectedYear == actualCurrentYear then
              local cacheObj = JSONObject()
              cacheObj.put("lang", sets.lang)
              cacheObj.put("adj", sets.adjust)
              local dataArr = luajava.bindClass("org.json.JSONArray")()
              for i, v in ipairs(results) do dataArr.put(v) end
              cacheObj.put("data", dataArr)
              rootJson.put(cacheKey, cacheObj)
              writeConfigFile(rootJson.toString())
            end
        end)
        showResults()
    end
    local isDone = false
    timeoutRunnable = Runnable({
      run = function()
        if not isDone then
          isDone = true
          if loadDialog then pcall(function() loadDialog.dismiss() end) end
          Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].serverErr) end}), 500)
        end
      end
    })
    handler.postDelayed(timeoutRunnable, 30000)
    local url1 = "https://api.aladhan.com/v1/hToGCalendar/" .. selectedMonth .. "/" .. selectedYear
    Http.get(url1, nil, "utf-8", nil, function(code1, res1)
        if not isDone then
            if code1 == 200 and res1 then
                pcall(function()
                    local arr1 = JSONObject(res1).getJSONArray("data")
                    if adjNum >= 0 then
                        for i = 0, arr1.length() - 1 do
                            local dd = arr1.getJSONObject(i)
                            table.insert(allDays, {g = dd.getJSONObject("gregorian"), h = dd.getJSONObject("hijri")})
                        end
                    else
                        local temp1 = {}
                        for i = 0, arr1.length() - 1 do
                            local dd = arr1.getJSONObject(i)
                            table.insert(temp1, {g = dd.getJSONObject("gregorian"), h = dd.getJSONObject("hijri")})
                        end
                        allDays = temp1
                    end
                end)
                if extraMonth then
                    local url2 = "https://api.aladhan.com/v1/hToGCalendar/" .. extraMonth .. "/" .. extraYear
                    Http.get(url2, nil, "utf-8", nil, function(code2, res2)
                        if not isDone then
                            isDone = true
                            if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
                            if code2 == 200 and res2 then
                                pcall(function()
                                    local arr2 = JSONObject(res2).getJSONArray("data")
                                    if adjNum > 0 then
                                        local tempAll = {}
                                        for i = 0, arr2.length() - 1 do
                                            local dd = arr2.getJSONObject(i)
                                            table.insert(tempAll, {g = dd.getJSONObject("gregorian"), h = dd.getJSONObject("hijri")})
                                        end
                                        for i = 1, #allDays do table.insert(tempAll, allDays[i]) end
                                        allDays = tempAll
                                    elseif adjNum < 0 then
                                        for i = 0, arr2.length() - 1 do
                                            local dd = arr2.getJSONObject(i)
                                            table.insert(allDays, {g = dd.getJSONObject("gregorian"), h = dd.getJSONObject("hijri")})
                                        end
                                    end
                                end)
                            end
                            processCombinedDays()
                        end
                    end)
                else
                    isDone = true
                    if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
                    processCombinedDays()
                end
            else
                isDone = true
                if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
                if loadDialog then pcall(function() loadDialog.dismiss() end) end
                Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].serverErr) end}), 500)
            end
        end
    end)
  end
end

showDateConverter = function(parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local events = {}
  pcall(function()
      local evArray = remoteNotes.getJSONObject("events").getJSONArray(safeLang)
      for i = 0, evArray.length() - 1 do
          local evObj = evArray.getJSONObject(i)
          table.insert(events, {n=evObj.getString("n"), d=evObj.getString("d"), m=evObj.getString("m")})
      end
  end)
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local function speakSafe(text)
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
    speechRunnable = Runnable({run = function() service.speak(text) end})
    speechHandler.postDelayed(speechRunnable, 500)
  end
  local options = {"Gregorian to Hijri", "Hijri to Gregorian"}
  local bConv = AlertDialog.Builder(service)
  bConv.setTitle("Smart Date Converter")
  bConv.setItems(options, DialogInterface.OnClickListener{
    onClick = function(d, w)
      d.dismiss()
      local isGToH = (w == 0)
      local bInput = AlertDialog.Builder(service)
      bInput.setTitle(options[w+1])
      local layout = LinearLayout(service)
      layout.setOrientation(1)
      layout.setPadding(30, 30, 30, 30)
      local editDate = luajava.bindClass("android.widget.EditText")(service)
      editDate.setHint("dd-mm-yyyy")
      editDate.setInputType(4) 
      local InputFilter = luajava.bindClass("android.text.InputFilter")
      local LengthFilter = luajava.bindClass("android.text.InputFilter$LengthFilter")
      local filterArray = luajava.newArray(InputFilter, 1)
      filterArray[0] = LengthFilter(10)
      editDate.setFilters(filterArray)
      local isFormatting = false
      editDate.addTextChangedListener(luajava.bindClass("android.text.TextWatcher"){
        beforeTextChanged = function(s, start, count, after) end,
        onTextChanged = function(s, start, before, count) end,
        afterTextChanged = function(s)
            if isFormatting then return end
            isFormatting = true
            local str = s.toString():gsub("[^0-9]", "")
            if string.len(str) == 8 and string.len(s.toString()) ~= 10 then
                local formatted = string.sub(str, 1, 2) .. "-" .. string.sub(str, 3, 4) .. "-" .. string.sub(str, 5, 8)
                editDate.setText(formatted)
                editDate.setSelection(string.len(formatted))
            end
            isFormatting = false
        end
      })
      local btnCalendar = Button(service)
      btnCalendar.setText("open calendar")
      btnCalendar.setAllCaps(false)
      local lpCal = LinearLayout.LayoutParams(-1, -2)
      lpCal.setMargins(0, 0, 0, 30)
      btnCalendar.setLayoutParams(lpCal)
      btnCalendar.setOnClickListener(function(v)
          local cal = Calendar.getInstance()
          local curGYear = cal.get(Calendar.YEAR)
          local curGMonth = cal.get(Calendar.MONTH) + 1
          local curGDay = cal.get(Calendar.DAY_OF_MONTH)
          local curHYear = tonumber(screenData.currentHijriYear) or 1446
          local curHMonth = tonumber(screenData.currentHijriMonthNum) or 1
          local curHDay = screenData.todayHijriStr and tonumber(screenData.todayHijriStr:match("^%d+")) or 15
          local selM = isGToH and curGMonth or curHMonth
          local selY = isGToH and tostring(curGYear) or tostring(curHYear)
          local selD = tostring(isGToH and curGDay or curHDay)
          local bCust = AlertDialog.Builder(service)
          bCust.setTitle("Select Date")
          local lCust = LinearLayout(service)
          lCust.setOrientation(1)
          lCust.setPadding(30, 30, 30, 30)
          local btnD = Button(service)
          btnD.setText(selD .. " (Day)")
          btnD.setAllCaps(false)
          local btnM = Button(service)
          local gMonths = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
          local mList = isGToH and gMonths or langData[safeLang].months
          btnM.setText(mList[selM] .. " (Month)")
          btnM.setAllCaps(false)
          local btnY = Button(service)
          btnY.setText(selY .. " (Year)")
          btnY.setAllCaps(false)
          lCust.addView(btnD)
          lCust.addView(btnM)
          lCust.addView(btnY)
          btnD.setOnClickListener(function()
              local days = {}
              for i = 1, 31 do table.insert(days, tostring(i)) end
              local dDialog = AlertDialog.Builder(service)
              dDialog.setItems(days, DialogInterface.OnClickListener{
                  onClick = function(dd, wd)
                      selD = days[wd+1]
                      btnD.setText(selD .. " (Day)")
                      dd.dismiss()
                  end
              })
              local dObj = dDialog.create()
              if Build.VERSION.SDK_INT >= 22 then dObj.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dObj.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
              dObj.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dObj = nil end })
              dObj.show()
          end)
          btnM.setOnClickListener(function()
              local mDialog = AlertDialog.Builder(service)
              mDialog.setItems(mList, DialogInterface.OnClickListener{
                  onClick = function(dm, wm) 
                      selM = wm + 1
                      btnM.setText(mList[selM] .. " (Month)") 
                      dm.dismiss() 
                  end
              })
              local mObj = mDialog.create()
              if Build.VERSION.SDK_INT >= 22 then mObj.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else mObj.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
              mObj.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() mObj = nil end })
              mObj.show()
          end)
          btnY.setOnClickListener(function()
              local years = {}
              local startY = isGToH and 1900 or 1300
              local endY = isGToH and 2100 or 1500
              for y = startY, endY do table.insert(years, tostring(y)) end
              local cleanY = btnY.getText():gsub(" %(Year%)", "")
              local selectedIdx = tonumber(cleanY) - startY
              if selectedIdx < 0 or selectedIdx >= #years then selectedIdx = 0 end
              local yDialog = AlertDialog.Builder(service)
              yDialog.setSingleChoiceItems(years, selectedIdx, DialogInterface.OnClickListener{
                  onClick = function(dy, wy)
                      selY = years[wy+1]
                      btnY.setText(selY .. " (Year)")
                      dy.dismiss()
                  end
              })
              local yObj = yDialog.create()
              if Build.VERSION.SDK_INT >= 22 then yObj.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else yObj.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
              yObj.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() yObj = nil end })
              yObj.show()
          end)
          local btnDone = Button(service)
          btnDone.setText("Done")
          btnDone.setAllCaps(false)
          local lpDone = LinearLayout.LayoutParams(-1, -2)
          lpDone.setMargins(0, 30, 0, 0)
          btnDone.setLayoutParams(lpDone)
          lCust.addView(btnDone)
          bCust.setView(lCust)
          local dCust = bCust.create()
          if Build.VERSION.SDK_INT >= 22 then dCust.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dCust.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
          dCust.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() lCust = nil dCust = nil end })
          btnDone.setOnClickListener(function()
              local finalDate = string.format("%02d-%02d-%04d", tonumber(selD), selM, tonumber(selY))
              editDate.setText(finalDate)
              dCust.dismiss()
          end)
          dCust.show()
      end)
      local btnConvert = Button(service)
      btnConvert.setText("convert")
      btnConvert.setAllCaps(false)
      btnConvert.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
      local btnGoBack = Button(service)
      btnGoBack.setText("go back")
      btnGoBack.setAllCaps(false)
      btnGoBack.setLayoutParams(LinearLayout.LayoutParams(-1, -2))
      layout.addView(editDate)
      layout.addView(btnCalendar)
      layout.addView(btnConvert)
      layout.addView(btnGoBack)
      bInput.setView(layout)
      local handler = Handler(Looper.getMainLooper())
      local timeoutRunnable = nil
      local dInput = bInput.create()
      if Build.VERSION.SDK_INT >= 22 then dInput.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dInput.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dInput.setOnDismissListener(DialogInterface.OnDismissListener{
         onDismiss = function(d) 
            if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end 
            if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
            layout = nil dInput = nil 
         end
      })
      dInput.show()
      btnGoBack.setOnClickListener(function(v)
         dInput.dismiss()
         showDateConverter(parentDialog, screenData)
      end)
      btnConvert.setOnClickListener(function(btnV)
         local rawInput = editDate.getText().toString()
         local cleanDate = rawInput:gsub("[^0-9]", "") 
         if string.len(cleanDate) ~= 8 then
            speakSafe(langData[safeLang].convInvalid)
            return
         end
         local pDay, pMonth, pYear = cleanDate:sub(1,2), cleanDate:sub(3,4), cleanDate:sub(5,8)
         local apiDateStr = isGToH and string.format("%02d-%02d-%04d", tonumber(pDay), tonumber(pMonth), tonumber(pYear)) or string.format("%02d-%02d-%04d", reverseAdjustHijri(pDay, pMonth, pYear, sets.adjust))
         btnConvert.setEnabled(false)
         local url = isGToH and ("https://api.aladhan.com/v1/gToH?date=" .. apiDateStr) or ("https://api.aladhan.com/v1/hToG?date=" .. apiDateStr)
         local isDone = false
         if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
         timeoutRunnable = Runnable({
           run = function()
             if not isDone then
               isDone = true
               pcall(function() btnConvert.setEnabled(true) end)
               speakSafe(langData[safeLang].serverErr)
             end
           end
         })
         handler.postDelayed(timeoutRunnable, 30000)
         Http.get(url, nil, "utf-8", nil, function(code, res)
            if not isDone then
               isDone = true
               if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
               pcall(function() btnConvert.setEnabled(true) end)
               if code == 200 and res then
                  pcall(function()
                     local data = JSONObject(res).getJSONObject("data")
                     local gWeekdayEn = data.getJSONObject("gregorian").getJSONObject("weekday").getString("en")
                     local dayMap = {Sunday=0, Monday=1, Tuesday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6}
                     local localWeekday = langData[safeLang].days[dayMap[gWeekdayEn] or 0]
                     local gDateStr = data.getJSONObject("gregorian").getString("day") .. " " .. data.getJSONObject("gregorian").getJSONObject("month").getString("en") .. " " .. data.getJSONObject("gregorian").getString("year")
                     local hDay, hMonthName, hYear = getAdjustedHijri(data.getJSONObject("hijri").getString("day"), data.getJSONObject("hijri").getJSONObject("month").getInt("number"), data.getJSONObject("hijri").getString("year"), sets.adjust, safeLang)
                     local hDateStr = hDay .. " " .. hMonthName .. " " .. hYear
                     local resultText = ""
                     if isGToH then
                         resultText = gDateStr .. ", " .. localWeekday .. ", " .. hDateStr
                     else
                         resultText = hDateStr .. ", " .. localWeekday .. ", " .. gDateStr
                     end
                     Handler(Looper.getMainLooper()).post(Runnable({
                        run = function()
                           dInput.dismiss()
                           speakSafe(resultText)
                           local bRes = AlertDialog.Builder(service)
                           local resultLayout = LinearLayout(service)
                           resultLayout.setOrientation(1)
                           resultLayout.setPadding(40, 40, 40, 40)
                           local tvRes = TextView(service)
                           tvRes.setText(resultText)
                           tvRes.setTextSize(18)
                           tvRes.setTextColor(0xFF000000)
                           tvRes.setLineSpacing(0, 1.2)
                           resultLayout.addView(tvRes)
                           bRes.setView(resultLayout)
                           bRes.setPositiveButton("go back", DialogInterface.OnClickListener{ onClick=function() showDateConverter(parentDialog, screenData) end })
                           local dRes = bRes.create()
                           if Build.VERSION.SDK_INT >= 22 then dRes.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dRes.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
                           dRes.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end resultLayout = nil dRes = nil end})
                           dRes.show()
                           dRes.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
                        end
                     }))
                  end)
               else speakSafe(langData[safeLang].serverErr) end
            end
         end)
      end)
    end
  })
  bConv.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
  local dConv = bConv.create()
  if Build.VERSION.SDK_INT >= 22 then dConv.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dConv.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dConv.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dConv = nil end })
  dConv.show()
  dConv.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
end

showSettingsMenu = function(parentDialog, screenData)
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local daySuffix = (sets.adjust == "1" or sets.adjust == "-1") and " Day" or " Days"
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local function speakSafe(text)
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
    speechRunnable = Runnable({run = function() service.speak(text) end})
    speechHandler.postDelayed(speechRunnable, 500)
  end
  local options = {"Choose a Language", "Hijri Date Adjustment: " .. sets.adjust .. daySuffix, "Prayer Time Adjustment", "Asr Method: " .. (sets.school == "1" and "Hanafi" or "Shafi'i"), "Refresh Location"}
  local builder = AlertDialog.Builder(service)
  builder.setTitle("Settings")
  builder.setItems(options, DialogInterface.OnClickListener{
    onClick=function(d, which)
      if which == 0 then
        local langs, langNames = {"1", "2", "3"}, {"हिंदी (Hindi)", "اردو (Urdu)", "English"}
        local checkedIdx = 0
        for i, v in ipairs(langs) do if v == sets.lang then checkedIdx = i - 1 break end end
        local bLang = AlertDialog.Builder(service)
        bLang.setTitle("Select Language")
        bLang.setSingleChoiceItems(langNames, checkedIdx, DialogInterface.OnClickListener{
          onClick=function(dLang, wLang)
            sets.lang = langs[wLang+1] saveSettings(sets) 
            speakSafe("Language saved successfully")
            dLang.dismiss() mainFunction()
          end
        })
        bLang.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showSettingsMenu(parentDialog, screenData) end })
        local dLang = bLang.create()
        if Build.VERSION.SDK_INT >= 22 then dLang.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dLang.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        dLang.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end dLang = nil end})
        dLang.show()
        dLang.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
      elseif which == 1 then
        local adjs, adjNames = {"-2", "-1", "0", "1"}, {"-2 Days", "-1 Day (Default)", "0 (No change)", "+1 Day"}
        local checkedIdx = 1 
        for i, v in ipairs(adjs) do if v == sets.adjust then checkedIdx = i - 1 break end end
        local b2 = AlertDialog.Builder(service)
        b2.setTitle("Adjust Hijri Date")
        b2.setSingleChoiceItems(adjNames, checkedIdx, DialogInterface.OnClickListener{
          onClick=function(d2, w2)
            sets.adjust = adjs[w2+1] saveSettings(sets) 
            speakSafe("Settings saved successfully")
            d2.dismiss() mainFunction()
          end
        })
        b2.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showSettingsMenu(parentDialog, screenData) end })
        local d2 = b2.create()
        if Build.VERSION.SDK_INT >= 22 then d2.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else d2.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        d2.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end d2 = nil end})
        d2.show()
        d2.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
      elseif which == 2 then
        local prayers, prayerKeys = {"Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"}, {"adjFajr", "adjDhuhr", "adjAsr", "adjMaghrib", "adjIsha"}
        local prayerNamesWithStatus = {}
        for i, p in ipairs(prayers) do
           local val = tonumber(sets[prayerKeys[i]]) or 0
           table.insert(prayerNamesWithStatus, p .. ": " .. (val > 0 and "+" or "") .. val .. " Minutes")
        end
        local bPrayer = AlertDialog.Builder(service)
        bPrayer.setTitle("Select Prayer to Adjust")
        bPrayer.setItems(prayerNamesWithStatus, DialogInterface.OnClickListener{
          onClick=function(dp, wp)
             local pName, pKey = prayers[wp+1], prayerKeys[wp+1]
             local minValues, minNames, currentVal, checkedMinIdx, idx = {}, {}, tonumber(sets[pKey]) or 0, 10, 0
             for i = -10, 10 do
                 table.insert(minValues, tostring(i))
                 local suffix = (i == 1 or i == -1) and " Minute" or " Minutes"
                 table.insert(minNames, i == 0 and "0 Minutes (Default)" or (i > 0 and "+" .. i or tostring(i)) .. suffix)
                 if i == currentVal then checkedMinIdx = idx end
                 idx = idx + 1
             end
             local bMin = AlertDialog.Builder(service)
             bMin.setTitle("Adjust " .. pName .. " Time")
             bMin.setSingleChoiceItems(minNames, checkedMinIdx, DialogInterface.OnClickListener{
                 onClick=function(dm, wm)
                     sets[pKey] = minValues[wm+1] saveSettings(sets) 
                     speakSafe("Settings saved successfully")
                     dm.dismiss() mainFunction()
                 end
             })
             bMin.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showSettingsMenu(parentDialog, screenData) end })
             local dMin = bMin.create()
             if Build.VERSION.SDK_INT >= 22 then dMin.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dMin.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
             dMin.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end dMin = nil end})
             dMin.show()
             dMin.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
          end
        })
        bPrayer.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showSettingsMenu(parentDialog, screenData) end })
        local dPrayer = bPrayer.create()
        if Build.VERSION.SDK_INT >= 22 then dPrayer.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dPrayer.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        dPrayer.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dPrayer = nil end })
        dPrayer.show()
        dPrayer.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
      elseif which == 3 then
        local schools, schoolNames = {"1", "0"}, {"Hanafi (Later)", "Shafi'i (Earlier)"}
        local b2 = AlertDialog.Builder(service)
        b2.setTitle("Choose Asr method")
        b2.setSingleChoiceItems(schoolNames, sets.school == "1" and 0 or 1, DialogInterface.OnClickListener{
          onClick=function(d2, w2)
            sets.school = schools[w2+1] saveSettings(sets) 
            speakSafe("Settings saved successfully")
            d2.dismiss() mainFunction()
          end
        })
        b2.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showSettingsMenu(parentDialog, screenData) end })
        local d2 = b2.create()
        if Build.VERSION.SDK_INT >= 22 then d2.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else d2.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        d2.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end d2 = nil end})
        d2.show()
        d2.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
      elseif which == 4 then
        local loadMsg = ""
        if safeLang == "1" then loadMsg = "लोडिंग हो रही है, बराए करम इंतज़ार करें"
        elseif safeLang == "2" then loadMsg = "لوڈنگ ہو رہی ہے، برائے کرم انتظار کریں"
        else loadMsg = "Loading, please wait" end
        speakSafe(loadMsg)
        local bPd = AlertDialog.Builder(service).setMessage(loadMsg)
        local pd = bPd.create()
        if Build.VERSION.SDK_INT >= 22 then pd.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else pd.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
        local lm = service.getSystemService(Context.LOCATION_SERVICE)
        local hasResponded = false
        local handler = Handler(Looper.getMainLooper())
        local LocationListener = luajava.bindClass("android.location.LocationListener")
        local locationListener
        local timeoutRunnable = nil
        pd.setOnDismissListener(DialogInterface.OnDismissListener{
           onDismiss = function(d) 
              if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end 
              if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
              pd = nil 
           end
        })
        pd.show()
        locationListener = LocationListener{
          onLocationChanged = function(loc)
            if not hasResponded then
              hasResponded = true
              if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
              pcall(function() lm.removeUpdates(locationListener) end)
              mainFunction(pd)
            end
          end,
          onStatusChanged = function(p, s, e) end,
          onProviderEnabled = function(p) end,
          onProviderDisabled = function(p) end
        }
        timeoutRunnable = Runnable({
          run = function()
            if not hasResponded then
              hasResponded = true
              pcall(function() lm.removeUpdates(locationListener) end)
              mainFunction(pd)
            end
          end
        })
        pcall(function()
          lm.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 0, 0, locationListener)
          lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, locationListener)
        end)
        handler.postDelayed(timeoutRunnable, 15000)
      end
    end
  })
  builder.setNegativeButton("go back", DialogInterface.OnClickListener{ onClick=function() showMainMenu(parentDialog, screenData) end })
  local dialog = builder.create()
  if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dialog.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dialog = nil end })
  dialog.show()
  dialog.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
end

local function showFullTimetable(screenData)
  local dataArray = screenData.dataArray
  local currentDayIndex = screenData.currentDayIndex
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local pNames = langData[safeLang].prayers
  local layout = LinearLayout(service)
  layout.setOrientation(1)
  layout.setPadding(30, 30, 30, 30)
  local btnDate = Button(service)
  btnDate.setAllCaps(false)
  layout.addView(btnDate)
  local scroll = ScrollView(service)
  scroll.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 1.0))
  scroll.setPadding(0, 30, 0, 0)
  local prayersListLayout = LinearLayout(service)
  prayersListLayout.setOrientation(1)
  local tvFajr, tvSunrise, tvDhuhr, tvAsr, tvMaghrib, tvIsha = TextView(service), TextView(service), TextView(service), TextView(service), TextView(service), TextView(service)
  local function styleTextView(tv)
      tv.setTextSize(18) tv.setTextColor(0xFF000000) tv.setPadding(0, 15, 0, 15) prayersListLayout.addView(tv)
  end
  styleTextView(tvFajr) styleTextView(tvSunrise) styleTextView(tvDhuhr) styleTextView(tvAsr) styleTextView(tvMaghrib) styleTextView(tvIsha)
  scroll.addView(prayersListLayout)
  layout.addView(scroll)
  local function updatePrayerDisplay(index)
      local dayData = dataArray.getJSONObject(index)
      local gregorian = dayData.getJSONObject("date").getJSONObject("gregorian")
      local dateText = gregorian.getString("day") .. " " .. gregorian.getJSONObject("month").getString("en") .. " " .. gregorian.getString("year")
      if index == currentDayIndex then dateText = dateText .. ", Today" end
      btnDate.setText(dateText .. ", tap to change date")
      local timings = dayData.getJSONObject("timings")
      tvFajr.setText(pNames.Fajr .. ": " .. formatTime12(adjustPrayerTimeMinute(timings.getString("Fajr"):sub(1,5), sets.adjFajr)))
      tvSunrise.setText(pNames.Sunrise .. ": " .. formatTime12(timings.getString("Sunrise"):sub(1,5)))
      tvDhuhr.setText(pNames.Dhuhr .. ": " .. formatTime12(adjustPrayerTimeMinute(timings.getString("Dhuhr"):sub(1,5), sets.adjDhuhr)))
      tvAsr.setText(pNames.Asr .. ": " .. formatTime12(adjustPrayerTimeMinute(timings.getString("Asr"):sub(1,5), sets.adjAsr)))
      tvMaghrib.setText(pNames.Maghrib .. ": " .. formatTime12(adjustPrayerTimeMinute(timings.getString("Maghrib"):sub(1,5), sets.adjMaghrib)))
      tvIsha.setText(pNames.Isha .. ": " .. formatTime12(adjustPrayerTimeMinute(timings.getString("Isha"):sub(1,5), sets.adjIsha)))
  end
  updatePrayerDisplay(currentDayIndex)
  btnDate.setOnClickListener(function(v)
      local dateNames, selectedIdx = {}, 0
      local currentBtnCleanText = btnDate.getText():gsub(", tap to change date", "")
      for i = 0, dataArray.length() - 1 do
          local g = dataArray.getJSONObject(i).getJSONObject("date").getJSONObject("gregorian")
          local dText = g.getString("day") .. " " .. g.getJSONObject("month").getString("en") .. " " .. g.getString("year")
          if i == currentDayIndex then dText = dText .. ", Today" end
          table.insert(dateNames, dText)
          if dText:lower() == currentBtnCleanText:lower() then selectedIdx = i end
      end
      local bDate = AlertDialog.Builder(service)
      bDate.setTitle("Select Date")
      bDate.setSingleChoiceItems(dateNames, selectedIdx, DialogInterface.OnClickListener{
          onClick = function(d2, w2) 
              updatePrayerDisplay(w2) 
              Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(dateNames[w2+1]) end}), 500)
              d2.dismiss() 
          end
      })
      bDate.setNegativeButton("close", nil)
      local d2 = bDate.create()
      if Build.VERSION.SDK_INT >= 22 then d2.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else d2.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      d2.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() d2 = nil end })
      d2.show()
      d2.getButton(DialogInterface.BUTTON_NEGATIVE).setAllCaps(false)
  end)
  local builder = AlertDialog.Builder(service)
  local tTitle = "Timetable"
  if safeLang == "1" then tTitle = "नमाज़ के औकात"
  elseif safeLang == "2" then tTitle = "نماز کے اوقات" end
  builder.setTitle(tTitle)
  builder.setView(layout)
  builder.setPositiveButton("go back", DialogInterface.OnClickListener{ onClick=function() reopenMainScreen(screenData) end })
  local dialog = builder.create()
  if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  dialog.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() layout = nil dialog = nil end })
  dialog.show()
  dialog.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
end

local function showRamadanTimetable(screenData)
  local hijriYear = screenData.rYear
  local lat = screenData.rLat
  local lng = screenData.rLng
  local method = screenData.rMethod
  local school = screenData.rSchool
  local sets = getSettings()
  local safeLang = (sets.lang == "0") and "1" or sets.lang
  local loadMsg = ""
  if safeLang == "1" then loadMsg = "लोडिंग हो रही है, बराए करम इंतज़ार करें, इस प्लगइन को तस्लीम रज़ा ने बनाया है"
  elseif safeLang == "2" then loadMsg = "لوڈنگ ہو رہی ہے، برائے کرم انتظار کریں، اس پلگ ان کو تسلیم رضا نے بنایا ہے"
  else loadMsg = "Loading, please wait, this plugin created by, Tasleem Razaa" end
  local loadBuilder = AlertDialog.Builder(service)
  local loadLayout = LinearLayout(service)
  loadLayout.setPadding(40,40,40,40)
  local tvLoad = TextView(service)
  tvLoad.setText(loadMsg)
  tvLoad.setTextSize(18)
  tvLoad.setTextColor(0xFF000000)
  loadLayout.addView(tvLoad)
  loadBuilder.setView(loadLayout)
  loadBuilder.setCancelable(false)
  local loadDialog = loadBuilder.create()
  if Build.VERSION.SDK_INT >= 22 then loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else loadDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = Runnable({run = function() service.speak(loadMsg) end})
  local handler = Handler(Looper.getMainLooper())
  local timeoutRunnable = nil
  loadDialog.setOnDismissListener(DialogInterface.OnDismissListener{
    onDismiss = function(d)
      if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
      if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
      loadLayout = nil loadDialog = nil
    end
  })
  loadDialog.show()
  speechHandler.postDelayed(speechRunnable, 500)
  local adj = tonumber(sets.adjust) or -1
  local ramadanMonthName = langData[safeLang].months[9]
  local allDays, extraMonth, extraYear = {}, nil, tonumber(hijriYear)
  local processAllDays = function()
      local list = {}
      for _, item in ipairs(allDays) do
          local timings = item.data.getJSONObject("timings")
          local sehri = formatTime12(adjustPrayerTimeMinute(timings.getString("Fajr"):sub(1,5), sets.adjFajr))
          local iftar = formatTime12(adjustPrayerTimeMinute(timings.getString("Maghrib"):sub(1,5), sets.adjMaghrib))
          local adjDay, adjMonthName, adjYear = getAdjustedHijri(item.data.getJSONObject("date").getJSONObject("hijri").getString("day"), item.apiMonth, item.apiYear, sets.adjust, safeLang)
          if adjMonthName == ramadanMonthName then 
              local row = ""
              if safeLang == "1" then row = adjDay .. " रमज़ान - सहरी: " .. sehri .. ", इफ्तार: " .. iftar
              elseif safeLang == "2" then row = adjDay .. " رمضان - سحری: " .. sehri .. ", افطار: " .. iftar
              elseif safeLang == "3" then row = adjDay .. " Ramadan - Sehri: " .. sehri .. ", Iftar: " .. iftar end
              table.insert(list, row)
          end
      end
      Handler(Looper.getMainLooper()).post(Runnable({
        run = function()
          if loadDialog then loadDialog.dismiss() end
          local builder = AlertDialog.Builder(service)
          local title = ""
          if safeLang == "1" then title = "रमज़ान उल मुबारक, " .. hijriYear .. " हिजरी टाइम टेबल"
          elseif safeLang == "2" then title = "رمضان المبارک، " .. hijriYear .. " ہجری ٹائم ٹیبل"
          elseif safeLang == "3" then title = "Ramadan ul Mubarak, " .. hijriYear .. " Hijri Timetable" end
          builder.setTitle(title)
          builder.setItems(list, nil)
          builder.setPositiveButton("go back", DialogInterface.OnClickListener{ onClick=function() reopenMainScreen(screenData) end })
          local dialog = builder.create()
          if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
          dialog.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() dialog = nil end })
          dialog.show()
          dialog.getButton(DialogInterface.BUTTON_POSITIVE).setAllCaps(false)
        end
      }))
  end
  local handleExtraMonth = function(codeE, resE)
      if codeE == 200 and resE then
          local status, err = pcall(function()
              local dataE = JSONObject(resE).getJSONArray("data")
              if adj < 0 then
                  for i = 0, dataE.length() - 1 do table.insert(allDays, { data = dataE.getJSONObject(i), apiMonth = extraMonth, apiYear = extraYear }) end
              else
                  local tempDays = {}
                  for i = 0, dataE.length() - 1 do table.insert(tempDays, { data = dataE.getJSONObject(i), apiMonth = extraMonth, apiYear = extraYear }) end
                  for _, item in ipairs(allDays) do table.insert(tempDays, item) end
                  allDays = tempDays
              end
              processAllDays()
          end)
          if not status then processAllDays() end
      else processAllDays() end
  end
  local handleNinthMonth = function(code9, res9)
      if timeoutRunnable then pcall(function() handler.removeCallbacks(timeoutRunnable) end) end
      if code9 == 200 and res9 then
        local status, err = pcall(function()
          local data9 = JSONObject(res9).getJSONArray("data")
          for i = 0, data9.length() - 1 do table.insert(allDays, { data = data9.getJSONObject(i), apiMonth = 9, apiYear = extraYear }) end
          if adj < 0 then extraMonth = 10 elseif adj > 0 then extraMonth = 8 end
          if extraMonth then
              Http.get("https://api.aladhan.com/v1/hijriCalendar?latitude=" .. lat .. "&longitude=" .. lng .. "&method=" .. method .. "&school=" .. school .. "&month=" .. extraMonth .. "&year=" .. extraYear, nil, "utf-8", nil, handleExtraMonth)
          else processAllDays() end
        end)
        if not status then
            if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
            speechRunnable = Runnable({run = function() service.speak(langData[safeLang].serverErr) end})
            speechHandler.postDelayed(speechRunnable, 500)
            if loadDialog then loadDialog.dismiss() end 
        end
      else 
        if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
        speechRunnable = Runnable({run = function() service.speak(langData[safeLang].ramadanDataErr) end})
        speechHandler.postDelayed(speechRunnable, 500)
        if loadDialog then loadDialog.dismiss() end 
      end
  end
  local isDone = false
  timeoutRunnable = Runnable({
    run = function()
      if not isDone then
        isDone = true
        if loadDialog then pcall(function() loadDialog.dismiss() end) end
        Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() service.speak(langData[safeLang].serverErr) end}), 500)
      end
    end
  })
  handler.postDelayed(timeoutRunnable, 30000)
  Http.get("https://api.aladhan.com/v1/hijriCalendar?latitude=" .. lat .. "&longitude=" .. lng .. "&method=" .. method .. "&school=" .. school .. "&month=9&year=" .. hijriYear, nil, "utf-8", nil, handleNinthMonth)
end

showSmartDialog = function(screenData)
  if currentSmartDialog then
    pcall(function() currentSmartDialog.dismiss() end)
    currentSmartDialog = nil
  end
  Handler(Looper.getMainLooper()).post(Runnable({
    run = function()
      local builder = AlertDialog.Builder(service)
      local screenHeight = service.getResources().getDisplayMetrics().heightPixels
      local layout = LinearLayout(service)
      layout.setOrientation(1)
      layout.setLayoutParams(LinearLayout.LayoutParams(-1, screenHeight))
      layout.setMinimumHeight(screenHeight)
      layout.setPadding(0, 0, 0, 0) 
      local topBar = LinearLayout(service)
      topBar.setOrientation(0)
      topBar.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 0.20))
      topBar.setGravity(Gravity.CENTER)
      topBar.setVisibility(4)
      
      local btnClose = Button(service)
      btnClose.setText("close")
      btnClose.setAllCaps(false)
      btnClose.setLayoutParams(LinearLayout.LayoutParams(0, -1, 0.25))
      
      local tvTopTitle = TextView(service)
      tvTopTitle.setText("Advance Islamic Assistant")
      tvTopTitle.setTextSize(14)
      tvTopTitle.setTextColor(0xFF000000)
      tvTopTitle.setGravity(Gravity.CENTER)
      tvTopTitle.setLayoutParams(LinearLayout.LayoutParams(0, -1, 0.50))
      
      local btnMenu = Button(service)
      btnMenu.setText("open menu")
      btnMenu.setAllCaps(false)
      btnMenu.setLayoutParams(LinearLayout.LayoutParams(0, -1, 0.25))
      
      topBar.addView(btnClose)
      topBar.addView(tvTopTitle)
      topBar.addView(btnMenu)
      
      local scroll = ScrollView(service)
      scroll.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 0.60))
      scroll.setPadding(30, 20, 30, 20)
      local tvMsg = TextView(service)
      tvMsg.setText(screenData.mainMessage)
      tvMsg.setTextSize(18)
      tvMsg.setTextColor(0xFF000000)
      tvMsg.setGravity(Gravity.CENTER)
      scroll.addView(tvMsg)
      local bottomBar = LinearLayout(service)
      bottomBar.setOrientation(0)
      bottomBar.setLayoutParams(LinearLayout.LayoutParams(-1, 0, 0.20))
      bottomBar.setGravity(Gravity.CENTER)
      local btnAll = Button(service)
      btnAll.setText("view all prayer times")
      btnAll.setAllCaps(false)
      local dialog = nil
      if screenData.isRamadan then
        local btnRamadan = Button(service)
        btnRamadan.setText("view all ramadan timetable")
        btnRamadan.setAllCaps(false)
        btnAll.setLayoutParams(LinearLayout.LayoutParams(0, -1, 1.0))
        btnRamadan.setLayoutParams(LinearLayout.LayoutParams(0, -1, 1.0))
        bottomBar.addView(btnAll)
        bottomBar.addView(btnRamadan)
        btnRamadan.setOnClickListener(function(v)
          if dialog then dialog.dismiss() end
          currentSmartDialog = nil
          showRamadanTimetable(screenData)
        end)
      else
        btnAll.setLayoutParams(LinearLayout.LayoutParams(-1, -1))
        bottomBar.addView(btnAll)
      end
      layout.addView(topBar)
      layout.addView(scroll)
      layout.addView(bottomBar)
      builder.setView(layout)
      dialog = builder.create()
      currentSmartDialog = dialog
      if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dialog.setOnDismissListener(DialogInterface.OnDismissListener{ onDismiss = function() layout = nil dialog = nil currentSmartDialog = nil end })
      btnClose.setOnClickListener(function(v)
        dialog.dismiss()
        currentSmartDialog = nil
      end)
      btnAll.setOnClickListener(function(v)
        dialog.dismiss()
        currentSmartDialog = nil
        showFullTimetable(screenData)
      end)
      btnMenu.setOnClickListener(function(v) 
          dialog.dismiss()
          currentSmartDialog = nil
          showMainMenu(dialog, screenData)
      end)
      dialog.show()
      pcall(function()
          local window = dialog.getWindow()
          window.setBackgroundDrawable(ColorDrawable(0xFFFFFFFF)) 
          window.getDecorView().setPadding(0, 0, 0, 0)
          local lp = window.getAttributes()
          lp.width = WindowManager.LayoutParams.MATCH_PARENT
          lp.height = WindowManager.LayoutParams.MATCH_PARENT
          window.setAttributes(lp)
      end)
      Handler(Looper.getMainLooper()).postDelayed(Runnable({run = function() pcall(function() topBar.setVisibility(0) end) end}), 1000)
    end
  }))
end

mainFunction = function(loadingDialog)
  local sets = getSettings()
  local speechHandler = Handler(Looper.getMainLooper())
  local speechRunnable = nil
  local function speakSafe(text)
    if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end
    speechRunnable = Runnable({run = function() service.speak(text) end})
    speechHandler.postDelayed(speechRunnable, 500)
  end
  if sets.lang == "0" then
      if loadingDialog then pcall(function() loadingDialog.dismiss() end) end
      local langs, langNames = {"1", "2", "3"}, {"हिंदी (Hindi)", "اردو (Urdu)", "English"}
      local bLang = AlertDialog.Builder(service)
      bLang.setTitle("Select Language")
      bLang.setCancelable(false)
      bLang.setSingleChoiceItems(langNames, -1, DialogInterface.OnClickListener{
        onClick=function(dLang, wLang)
          sets.lang = langs[wLang+1] 
          saveSettings(sets) 
          speakSafe("Language saved successfully")
          dLang.dismiss() 
          mainFunction() 
        end
      })
      bLang.setNegativeButton("Close", DialogInterface.OnClickListener{ onClick=function(d) d.dismiss() end })
      local dLang = bLang.create()
      if Build.VERSION.SDK_INT >= 22 then dLang.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dLang.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
      dLang.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end dLang = nil end})
      dLang.show()
      return 
  end
  
  if not loadingDialog then
      local procMsg = ""
      if sets.lang == "1" then procMsg = "प्रोसेसिंग हो रही है, बराए करम इंतज़ार करें"
      elseif sets.lang == "2" then procMsg = "پروسیسنگ ہو رہی ہے، برائے کرم انتظار کریں"
      else procMsg = "Processing, please wait" end
      speakSafe(procMsg)
  end

  fetchRemoteNotes(nil)

  local lat, lng, cityName = getLocationData()
  if not lat then
    if loadingDialog then pcall(function() loadingDialog.dismiss() end) end
    local locAlertMsgs = {
      ["1"] = "नमाज़ के दुरुस्त औकात और हिजरी तारीख का एक्यूरेट डेटा हासिल करने के लिए, सिस्टम को आपकी मौजूदा लोकेशन दरकार है। फिलहाल प्लगइन लोकेशन डिटेक्ट करने में नाकाम है।\n\nइस टेक्निकल मसले को हल करने के लिए बराए करम इन दो स्टेप्स को फॉलो करें:\n1. नीचे मौजूद 'Settings' बटन पर क्लिक करके अपने डिवाइस का GPS यानी लोकेशन ऑन करें।\n2. CSR को लोकेशन एक्सेस की मुकम्मल परमिशन फराहम करें।\n\nखास टेक्निकल हिदायत:\nचूँकि यह प्लगइन बैकग्राउंड से भी रन होता है, इसलिए सिर्फ 'While using the app' परमिशन यहाँ कारगर नहीं होगी। आपको CSR की App Info में जाकर, Permissions के सेक्शन में Location को 'Allow all the time' पर सेट करना लाज़िमी है।\n\nइस मुकम्मल परमिशन के बगैर होम स्क्रीन से प्लगइन रेस्पॉन्ड नहीं करेगा। बराए मेहरबानी सेटिंग्स दुरुस्त करने के बाद दोबारा कोशिश करें।",
      ["2"] = "نماز کے درست اوقات اور ہجری تاریخ کا ایکوریٹ ڈیٹا حاصل کرنے کے لیے، سسٹم کو آپ کی موجودہ لوکیشن درکار ہے۔ فی الحال پلگ ان لوکیشن ڈیٹیکٹ کرنے میں ناکام ہے۔\n\nاس ٹیکنیکل مسئلے کو حل کرنے کے لیے برائے کرم ان دو سٹیپس کو فالو کریں:\n1. نیچے موجود 'Settings' بٹن پر کلک کر کے اپنے ڈیوائس کا GPS یعنی لوکیشن آن کریں۔\n2. CSR کو لوکیشن ایکسیس کی مکمل پرمیشن فراہم کریں۔\n\nخاص ٹیکنیکل ہدایت:\nچونکہ یہ پلگ ان بیک گراؤنڈ سے بھی رن ہوتا ہے، اس لیے صرف 'While using the app' پرمیشن یہاں کارگر نہیں ہوگی۔ آپ کو CSR کی App Info میں جا کر، Permissions کے سیکشن میں Location کو 'Allow all the time' پر سیٹ کرنا لازمی ہے۔\n\nاس مکمل پرمیشن کے بغیر ہوم سکرین سے پلگ ان ریسپانڈ نہیں کرے گا۔ برائے مہربانی سیٹنگز درست کرنے کے بعد دوبارہ کوشش کریں۔",
      ["3"] = "To get accurate data for prayer times and Hijri date, the system requires your current location. Currently, the plugin failed to detect your location.\n\nTo resolve this technical issue, please follow these two steps:\n1. Click the 'Settings' button below to turn on your device's GPS/Location.\n2. Grant full location access permission to CSR.\n\nSpecial Technical Instruction:\nSince this plugin also runs in the background, just the 'While using the app' permission will not be effective here. You must go to the App Info of CSR, and in the Permissions section, set Location to 'Allow all the time'.\n\nWithout this full permission, the plugin will not respond from the home screen. Please try again after correcting the settings."
    }
    local locTitles = {["1"]="लोकेशन अलर्ट", ["2"]="لوکیشن الرٹ", ["3"]="Location Alert"}
    local errMsg = locAlertMsgs[sets.lang]
    speakSafe(errMsg)
    local builder = AlertDialog.Builder(service)
    builder.setTitle(locTitles[sets.lang]) builder.setMessage(errMsg) builder.setPositiveButton("Close", nil)
    builder.setNeutralButton("Settings", DialogInterface.OnClickListener{ onClick=function(d,w) pcall(function() service.startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) end) end })
    local dialog = builder.create()
    if Build.VERSION.SDK_INT >= 22 then dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY) else dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT) end
    dialog.setOnDismissListener(DialogInterface.OnDismissListener{onDismiss = function(d) if speechRunnable then pcall(function() speechHandler.removeCallbacks(speechRunnable) end) end dialog = nil end})
    dialog.show() return 
  end
  local cal = Calendar.getInstance()
  local currentYear, currentMonth, currentDay = cal.get(Calendar.YEAR), cal.get(Calendar.MONTH) + 1, cal.get(Calendar.DAY_OF_MONTH)
  local finalizeOutput = function(adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, nextPrayerTime, isRam, rYr, rLat, rLng, rMeth, rSch, fullDataArray, currDayIdx, rawMonth)
      if loadingDialog then pcall(function() loadingDialog.dismiss() end) end
      local remainingStr, nextP_Display, weekDayNum = getRemainingTimeStr(nextPrayerTime, sets.lang), formatTime12(nextPrayerTime), tonumber(os.date("%w")) 
      local currentDayName = langData[sets.lang].days[weekDayNum]
      local isMubarak = (weekDayNum == 1 or weekDayNum == 4 or weekDayNum == 5)
      local speechText = ""
      if sets.lang == "1" then
          speechText = "आज " .. currentDayName .. " का" .. (isMubarak and " मुबारक" or "") .. " दिन है, और " .. finalMonthName .. " की " .. finalDay .. " तारीख है। " .. finalYear .. " हिजरी चल रही है। " .. cityName .. " में, " .. currentStatus .. "। "
          if nextPrayerName == langData["1"].prayers.Sunrise then
              speechText = speechText .. "फजर का वक्त खत्म होने (यानी तुलू-ए-आफ़ताब) में अभी " .. remainingStr .. " बाकी हैं, जो " .. nextP_Display .. " पर होगा।"
          else
              speechText = speechText .. "अगली नमाज़ " .. nextPrayerName .. " की है, जिसका वक्त " .. nextP_Display .. " पर शुरू होगा। " .. nextPrayerName .. " का वक्त शुरू होने में, अभी " .. remainingStr .. " बाकी हैं।"
          end
          if isRam then speechText = speechText .. " आज ख़त्म-ए-सहरी " .. formatTime12(adjTimingsTable.Fajr) .. " पर, और वक़्त-ए-इफ़्तार " .. formatTime12(adjTimingsTable.Maghrib) .. " पर है।" end
          speechText = speechText .. " एक ज़रूरी गुज़ारिश, सिस्टम का डिफ़ॉल्ट टाइम आपके मुक़ामी इलाके से अलग हो सकता है, इसलिए सही मालूमात हासिल होने पर सेटिंग्स में जाकर, तारीख़ और नमाज़ का वक़्त एडजस्ट करें।"
      elseif sets.lang == "2" then
          speechText = "آج " .. currentDayName .. " کا" .. (isMubarak and " مبارک" or "") .. " دن ہے، اور " .. finalMonthName .. " کی " .. finalDay .. " تاریخ ہے۔ " .. finalYear .. " ہجری چل رہی ہے۔ " .. cityName .. " میں، " .. currentStatus .. "۔ "
          if nextPrayerName == langData["2"].prayers.Sunrise then
              speechText = speechText .. "فجر کا وقت ختم ہونے (یعنی طلوعِ آفتاب) میں ابھی " .. remainingStr .. " باقی ہیں، جو " .. nextP_Display .. " پر ہوگا۔"
          else
              speechText = speechText .. "اگلی نماز " .. nextPrayerName .. " کی ہے، جس کا وقت " .. nextP_Display .. " پر شروع ہوگا۔ " .. nextPrayerName .. " کا وقت شروع ہونے میں، ابھی " .. remainingStr .. " باقی ہیں۔"
          end
          if isRam then speechText = speechText .. " آج ختمِ سحری " .. formatTime12(adjTimingsTable.Fajr) .. " پر، اور وقتِ افطار " .. formatTime12(adjTimingsTable.Maghrib) .. " پر ہے۔" end
          speechText = speechText .. " ایک ضروری گزارش، سسٹم کا ڈیفالٹ ٹائم آپ کے مقامی علاقے سے الگ ہو سکتا ہے، اس لیے صحیح معلومات حاصل ہونے پر سیٹنگز میں جا کر، تاریخ اور نماز کا وقت ایڈجسٹ کریں۔"
      elseif sets.lang == "3" then
          speechText = "Today is a" .. (isMubarak and " blessed " or " ") .. currentDayName .. ", and it is the " .. finalDay .. " of " .. finalMonthName .. ". The current Hijri year is " .. finalYear .. ". In " .. cityName .. ", " .. currentStatus .. ". "
          if nextPrayerName == langData["3"].prayers.Sunrise then
              speechText = speechText .. "There are " .. remainingStr .. " remaining until Fajr ends (Sunrise), which will be at " .. nextP_Display .. "."
          else
              speechText = speechText .. "The next prayer is " .. nextPrayerName .. ", which will start at " .. nextP_Display .. ". There are " .. remainingStr .. " remaining until " .. nextPrayerName .. " begins."
          end
          if isRam then speechText = speechText .. " Today, Sehri ends at " .. formatTime12(adjTimingsTable.Fajr) .. ", and Iftar is at " .. formatTime12(adjTimingsTable.Maghrib) .. "." end
          speechText = speechText .. " An important disclaimer, The system's default time may differ from your local area. Please adjust the date and prayer times in the settings once you have accurate local information."
      end
      local gMonthNamesList = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
      local screenData = {todayGregorianStr = currentDay .. " " .. gMonthNamesList[currentMonth] .. " " .. currentYear, todayHijriStr = finalDay .. " " .. finalMonthName .. " " .. finalYear, todayDayName = currentDayName, mainMessage = speechText, timings = adjTimingsTable, speechText = speechText, isRamadan = isRam, rYear = rYr, rLat = rLat, rLng = rLng, rMethod = rMeth, rSchool = rSch, dataArray = fullDataArray, currentDayIndex = currDayIdx, currentHijriYear = finalYear, currentHijriMonthNum = tostring(rawMonth)}
      
      checkUpdate(false, screenData)
  end
  local function handleNextMonthResponse(c2, r2, adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, tFajrStr, isRamMonth, rawYear, dataArray, todayIndex, rawMonth)
      local nextPrayerTime = tFajrStr
      if c2 == 200 and r2 then 
          pcall(function() 
              nextPrayerTime = adjustPrayerTimeMinute(JSONObject(r2).getJSONArray("data").getJSONObject(0).getJSONObject("timings").getString("Fajr"):sub(1,5), sets.adjFajr) 
          end)
      end
      finalizeOutput(adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, nextPrayerTime, isRamMonth, rawYear, lat, lng, sets.calcMethod, sets.school, dataArray, todayIndex, rawMonth)
  end
  local handleCurrentMonth = function(code, res)
      if code == 200 and res then
        local status, err = pcall(function()
          local dataArray = JSONObject(res).getJSONArray("data")
          local todayIndex = currentDay - 1
          local todayData = dataArray.getJSONObject(todayIndex)
          local hijri = todayData.getJSONObject("date").getJSONObject("hijri")
          local rawDay, rawMonth, rawYear = hijri.getString("day"), hijri.getJSONObject("month").getInt("number"), hijri.getString("year")
          local finalDay, finalMonthName, finalYear = getAdjustedHijri(rawDay, rawMonth, rawYear, sets.adjust, sets.lang)
          local timings = todayData.getJSONObject("timings")
          local function toDec(tStr) return tonumber(tStr:sub(1,2)) + (tonumber(tStr:sub(4,5))/60) end
          local nowDec = getCurrentTimeDecimal()
          local tFajrStr, tSunriseStr, tDhuhrStr, tAsrStr, tMaghribStr, tIshaStr = adjustPrayerTimeMinute(timings.getString("Fajr"):sub(1,5), sets.adjFajr), timings.getString("Sunrise"):sub(1,5), adjustPrayerTimeMinute(timings.getString("Dhuhr"):sub(1,5), sets.adjDhuhr), adjustPrayerTimeMinute(timings.getString("Asr"):sub(1,5), sets.adjAsr), adjustPrayerTimeMinute(timings.getString("Maghrib"):sub(1,5), sets.adjMaghrib), adjustPrayerTimeMinute(timings.getString("Isha"):sub(1,5), sets.adjIsha)
          local adjTimingsTable = { Fajr = tFajrStr, Sunrise = tSunriseStr, Dhuhr = tDhuhrStr, Asr = tAsrStr, Maghrib = tMaghribStr, Isha = tIshaStr }
          local tFajr, tSunrise, tDhuhr, tAsr, tMaghrib, tIsha = toDec(tFajrStr), toDec(tSunriseStr), toDec(tDhuhrStr), toDec(tAsrStr), toDec(tMaghribStr), toDec(tIshaStr)
          local currentStatus, nextPrayerName, nextPrayerTime, needNextMonthData = "", "", "", false
          
          local statusTable = {
             Tahajjud = {["1"]="फिलहाल तहज्जूद और सहरी का वक्त है", ["2"]="فی الحال تہجد اور سحری کا وقت ہے", ["3"]="Currently, it is time for Tahajjud and Sehri"},
             FajrOngoing = {["1"]="अभी फजर का वक्त जारी है", ["2"]="ابھی فجر کا وقت جاری ہے", ["3"]="Fajr time is currently ongoing"},
             FajrEnded = {["1"]="फजर का वक्त खत्म हो चुका है", ["2"]="فجر کا وقت ختم ہو چکا ہے", ["3"]="Fajr time has ended"},
             DhuhrOngoing = {["1"]="अभी ज़ोहर का वक्त चल रहा है", ["2"]="ابھی ظہر کا وقت چل رہا ہے", ["3"]="Dhuhr time is currently ongoing"},
             AsrOngoing = {["1"]="अभी असर का वक्त चल रहा है", ["2"]="ابھی عصر کا وقت چل رہا ہے", ["3"]="Asr time is currently ongoing"},
             MaghribOngoing = {["1"]="अभी मगरिब का वक्त चल रहा है", ["2"]="ابھی مغرب کا وقت چل رہا ہے", ["3"]="Maghrib time is currently ongoing"},
             IshaOngoing = {["1"]="फिलहाल ईशा का वक्त चल रहा है", ["2"]="فی الحال عشاء کا وقت چل رہا ہے", ["3"]="Isha time is currently ongoing"}
          }
          local pNames = langData[sets.lang].prayers

          if nowDec < tFajr then currentStatus, nextPrayerName, nextPrayerTime = statusTable.Tahajjud[sets.lang], pNames.Fajr, tFajrStr
          elseif nowDec < tSunrise then currentStatus, nextPrayerName, nextPrayerTime = statusTable.FajrOngoing[sets.lang], pNames.Sunrise, tSunriseStr
          elseif nowDec < tDhuhr then currentStatus, nextPrayerName, nextPrayerTime = statusTable.FajrEnded[sets.lang], pNames.Dhuhr, tDhuhrStr
          elseif nowDec < tAsr then currentStatus, nextPrayerName, nextPrayerTime = statusTable.DhuhrOngoing[sets.lang], pNames.Asr, tAsrStr
          elseif nowDec < tMaghrib then currentStatus, nextPrayerName, nextPrayerTime = statusTable.AsrOngoing[sets.lang], pNames.Maghrib, tMaghribStr
          elseif nowDec < tIsha then currentStatus, nextPrayerName, nextPrayerTime = statusTable.MaghribOngoing[sets.lang], pNames.Isha, tIshaStr
          else
             currentStatus, nextPrayerName = statusTable.IshaOngoing[sets.lang], pNames.Fajr
             if currentDay < dataArray.length() then nextPrayerTime = adjustPrayerTimeMinute(dataArray.getJSONObject(currentDay).getJSONObject("timings").getString("Fajr"):sub(1,5), sets.adjFajr)
             else needNextMonthData = true end
          end

          if needNextMonthData then
               local nextM, nextY = currentMonth + 1, currentYear
               if nextM > 12 then nextM, nextY = 1, nextY + 1 end
               local handleNextMonth = function(c2, r2)
                   if c2 == 200 and r2 then pcall(function() nextPrayerTime = adjustPrayerTimeMinute(JSONObject(r2).getJSONArray("data").getJSONObject(0).getJSONObject("timings").getString("Fajr"):sub(1,5), sets.adjFajr) finalizeOutput(adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, nextPrayerTime, (rawMonth == 9), rawYear, lat, lng, sets.calcMethod, sets.school, dataArray, todayIndex, rawMonth) end)
                   else finalizeOutput(adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, tFajrStr, (rawMonth == 9), rawYear, lat, lng, sets.calcMethod, sets.school, dataArray, todayIndex, rawMonth) end
               end
               Http.get("https://api.aladhan.com/v1/calendar?latitude=" .. lat .. "&longitude=" .. lng .. "&method=" .. sets.calcMethod .. "&school=" .. sets.school .. "&month=" .. nextM .. "&year=" .. nextY, nil, "utf-8", nil, handleNextMonth)
          else finalizeOutput(adjTimingsTable, finalDay, finalMonthName, finalYear, currentStatus, nextPrayerName, nextPrayerTime, (rawMonth == 9), rawYear, lat, lng, sets.calcMethod, sets.school, dataArray, todayIndex, rawMonth) end
        end)
        if not status then 
           if loadingDialog then pcall(function() loadingDialog.dismiss() end) end
           speakSafe(langData[sets.lang].serverErr)
        end
      else 
        if loadingDialog then pcall(function() loadingDialog.dismiss() end) end
        speakSafe(langData[sets.lang].netErr) 
      end
  end

  Http.get("https://api.aladhan.com/v1/calendar?latitude=" .. lat .. "&longitude=" .. lng .. "&method=" .. sets.calcMethod .. "&school=" .. sets.school .. "&month=" .. currentMonth .. "&year=" .. currentYear, nil, "utf-8", nil, handleCurrentMonth)
end

mainFunction()
return true
