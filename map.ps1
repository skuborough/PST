$BASE_PATH = Split-Path -Parent $MyInvocation.MyCommand.Path
$RLIST_NAME = "rlist.csv"
$JLIST_NAME = "jlist.csv"
$ELIST_NAME = "elist.csv"
$GLIST_NAME = "glist.csv"
$RLIST_PATH = Join-Path $BASE_PATH $RLIST_NAME
$JLIST_PATH = Join-Path $BASE_PATH $JLIST_NAME
$ELIST_PATH = Join-Path $BASE_PATH $ELIST_NAME
$GLIST_PATH = Join-Path $BASE_PATH $GLIST_NAME
$EDITOR = "D:\LYNX\App\npp.8.2.1.portable.x64\notepad++.exe"
$BROWSER = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

function Check-Alias($STR) {
  if (Test-Path Alias:$STR) {
    Remove-Item Alias:$STR
  }
}

$RList = @()
$rlines = Import-Csv $RLIST_PATH -Encoding UTF8
foreach ($rline in $rlines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $rline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $rline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $rline.Path
  $obj | Add-Member -MemberType NoteProperty -Name Argument -Value $rline.Argument
  $RList += $obj
  Check-Alias $rline.Alias
  $exp = "function $($rline.Alias)() {"
  $exp += "Start-Process `"$($rline.Path)`""
  if ($rline.Argument -ne "") {
    $exp += " -ArgumentList `"$($rline.Argument)`""
  }
  $exp += "}" 
  Invoke-Expression $exp
}
function rlist() {
  $RList
}

$JList = @()
$jlines = Import-Csv $JLIST_PATH -Encoding UTF8
Check-Alias j
$exp = "function j(`$STR) {switch(`$STR){"
foreach ($jline in $jlines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $jline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $jline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $jline.Path
  $JList += $obj
  $exp += "$($jline.Alias) {Start-Process `"$($jline.Path)`"; break}"
}
$exp += "default {Start-Process `"$STR`"} } }"
Invoke-Expression $exp
function jlist() {
  $JList
}

$EList = @()
$exp = "function e(`$STR) {switch(`$STR){"
function elist() {
  $EList
}

$GList = @()
$glines = Import-Csv $GLIST_PATH -Encoding UTF8
Check-Alias g
$exp = "function g(`$STR) { if (`$STR -eq `"`") {Start-Process `"$BROWSER`"} else {switch(`$STR){"
foreach ($gline in $glines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $gline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $gline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $gline.Path
  $GList += $obj
  $exp += "$($gline.Alias) {Start-Process `"$BROWSER`" -ArgumentList `"$($gline.Path) --new-window`"; break}"
}
$exp += "default {Start-Process `"$BROWSER`" -ArgumentList `"`$STR --new-window`"} } } }"
Invoke-Expression $exp
function glist() {
  $GList
}

echo "MAP launched!!"
