$BASE_PATH = Split-Path -Parent $MyInvocation.MyCommand.Path
$FILE_NAME = "map-config.csv"
$CONF_PATH = Join-Path $BASE_PATH $FILE_NAME

$records = Import-Csv $CONF_PATH -Encoding UTF8

Remove-Item alias:r
function r($APP) {
  $exp = "switch (`$APP) {"
  foreach ($record in $records) {
	$exp += "$($record.Alias) {Start-Process `"$($record.Path)`""
	if ($record.Argument -ne "") {
	  $exp += " -ArgumentList `"$($record.Argument)`""
	}
	$exp += "; break}" 
  }
  $exp += "default {}}"
  Invoke-Expression $exp
}
echo "MAP launched!!"
