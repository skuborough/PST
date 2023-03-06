$RLIST_NAME = "rlist.csv"
$FLIST_NAME = "flist.csv"
$ELIST_NAME = "elist.csv"
$BLIST_NAME = "blist.csv"
$EDITOR = "C:\Users\XXX\AppData\Local\Programs\EmEditor\EmEditor.exe"
$BROWSER = "C:\Program Files\Mozilla Firefox\firefox.exe"
$BASE_PATH = Split-Path -Parent $MyInvocation.MyCommand.Path
$RLIST_PATH = Join-Path $BASE_PATH $RLIST_NAME
$FLIST_PATH = Join-Path $BASE_PATH $FLIST_NAME
$ELIST_PATH = Join-Path $BASE_PATH $ELIST_NAME
$BLIST_PATH = Join-Path $BASE_PATH $BLIST_NAME

function Check-Alias($STR) {
  if (Test-Path Alias:$STR) {
    Remove-Item Alias:$STR
  }
}

##RunList
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
  $RList | Sort-Object Alias
}

##FilerList
$FList = @()
$flines = Import-Csv $FLIST_PATH -Encoding UTF8
Check-Alias f
$exp = "function f(`$STR) {if (`$STR -eq `$null) {Start-Process shell:MyComputerFolder} else { switch(`$STR){"
foreach ($fline in $flines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $fline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $fline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $fline.Path
  $FList += $obj
  $exp += "$($fline.Alias) {Start-Process `"$($fline.Path)`"; break}"
}
$exp += "default {Start-Process `"$STR`"} } } }"
Invoke-Expression $exp
function flist() {
  $FList | Sort-Object Alias
}

##EditorList
$EList = @()
$elines = Import-Csv $ELIST_PATH -Encoding UTF8
Check-Alias e
$exp = "function e(`$STR) { if (`$STR -eq `$null) {Start-Process `"$EDITOR`"} else {switch(`$STR){"
foreach ($eline in $elines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $eline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $eline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $eline.Path
  $EList += $obj
  $exp += "$($gline.Alias) {Start-Process `"$EDITOR`" -ArgumentList `"$($eline.Path)`"; break}"
}
$exp += "} } }"
Invoke-Expression $exp
function elist() {
  $EList | Sort-Object Alias
}

##BrowserList
$BList = @()
$blines = Import-Csv $BLIST_PATH -Encoding UTF8
Check-Alias b
$exp = "function b(`$STR) { if (`$STR -eq `$null) {Start-Process `"$BROWSER`"} else {switch(`$STR){"
foreach ($bline in $blines) {
  $obj = New-Object PSCustomObject
  $obj | Add-Member -MemberType NoteProperty -Name Name -Value $bline.Name
  $obj | Add-Member -MemberType NoteProperty -Name Alias -Value $bline.Alias
  $obj | Add-Member -MemberType NoteProperty -Name Path -Value $bline.Path
  $BList += $obj
  $exp += "$($bline.Alias) {Start-Process `"$BROWSER`" -ArgumentList `"$($bline.Path) --new-window`"; break}"
}
$exp += "default {Start-Process `"$BROWSER`" -ArgumentList `"`$STR --new-window`"} } } }"
Invoke-Expression $exp
function blist() {
  $BList | Sort-Object Alias
}

echo "MAP launched!!"
