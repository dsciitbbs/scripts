<#
.SYNOPSIS
  Shows current weather conditions in PowerShell console.
 
.DESCRIPTION
  This scirpt will show the current weather conditions for your area in your PowerShell console.
While you could use the script on its own, it is highly recommended to add it to your profile.
See https://technet.microsoft.com/en-us/library/ff461033.aspx for more info.
  You will need to get an OpenWeather API key from http://openweathermap.org/api - it's free.
Once you have your key, replace "YOUR_API_KEY" with your key.
 
  Note that weather results are displayed in metric (°C) units.
To switch to imperial (°F) change all instances of '&units=metric' to '&units=imperial'
as well as all instances of '°C' to '°F'. 
 
.EXAMPLE
  Get-Weather -City Toronto -Country CA
 
  In this example, we will get the weather for Toronto, CA.
If you do not live in a major city, select the closest one to you. Note that the
country code is the two-digit code for your country. For a list of country
codes, see https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
 
.NOTES
  Written by Nick Tamm, nicktamm.com.
  I am simply using his script and take no responsibility for any issues caused by this script.
 
.LINK
  https://github.com/obs0lete/Get-Weather
#>
function Get-Weather {
  param (
    [string]$City,
    
    [string]$Country)
  
  <# BEGIN VARIABLES #>
  
  <# Get your API Key (it's free) from http://openweathermap.org/api and change the value below with your key #>
  $API = "YOUR_API_KEY"
  
  <# Check if you have entered an API key and if not, exit the script.
  Do NOT change this value, only the one above! #>
  if ($API -eq "YOUR_API_KEY") {
    Write-Host ""
    Write-Warning "You have not set your API Key!"
    Write-Host "Please go to http://openweathermap.org/api to get your API key - it's free."
    Write-Host "Once you have your key, change the value in the $" -NoNewline; Write-Host "API variable with your key and re-run this script."
    Write-Host ""
    exit
  }
  
  $Url = "api.openweathermap.org/data/2.5/weather?q=$City,$Country&units=metric&appid=$API&type=accurate&mode=json"
  <#JSON request for sunrise/sunset #>
  $JSONResults = Invoke-WebRequest "api.openweathermap.org/data/2.5/weather?q=$City,$Country&units=metric&appid=$API&type=accurate&mode=json"
  <#Write-Host "Attempting URL $Url"#>
  $JSON = $JSONResults.Content
  $JSONData = ConvertFrom-Json $JSON
  $JSONSunrise = $JSONData.sys.sunrise
  $JSONSunset = $JSONData.sys.sunset
  $JSONLastUpdate = $JSONData.dt
  
  <# Convert UNIX UTC time to (human) readable format #>
  $Sunrise = [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($JSONSunrise))
  $Sunset = [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($JSONSunset))
  $LastUpdate = [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($JSONLastUpdate))
  $Sunrise = "{0:hh:mm:ss tt}" -f (Get-Date $Sunrise)
  $Sunset = "{0:hh:mm:ss tt}" -f (Get-Date $Sunset)
  $LastUpdate = "{0:hh:mm:ss tt}" -f (Get-Date $LastUpdate)
  
  <# XML request for everything else #>
  [xml]$XMLResults = Invoke-WebRequest "api.openweathermap.org/data/2.5/weather?q=$City,$Country&units=metric&appid=$API&type=accurate&mode=xml"
  $XMLData = $XMLResults.current
  
  <# Get current weather value. Needed to convert case of characters. #>
  $CurrentValue = $XMLData.weather.value
  
  <# Get precipitation mode (type of precipitation). Needed to convert case of characters. #>
  $PrecipitationValue = $XMLData.precipitation.mode
  
  <# Get precipitation amount (in mm). Needed to convert case of characters. #>
  $PrecipitationMM = $XMLData.precipitation.value
  
  <# Get precipitation unit (mm in last x hours). Needed to convert case of characters. #>
  $PrecipitationHRS = $XMLData.precipitation.unit
  
  <# Get wind speed value. Needed to convert case of characters. #>
  $WindValue = $XMLData.wind.speed.name
  
  <# Get the current time. This is for clear conditions at night time. #>
  $Time = Get-Date -DisplayHint Time
  
  <# Define the numbers for various weather conditions #>
  $Thunder = "200", "201", "202", "210", "211", "212", "221", "230", "231", "232"
  $Drizzle = "300", "301", "302", "310", "311", "312", "313", "314", "321", "500", "501", "502"
  $Rain = "503", "504", "520", "521", "522", "531"
  $LightSnow = "600", "601"
  $HeavySnow = "602", "622"
  $SnowAndRain = "611", "612", "615", "616", "620", "621"
  $Atmosphere = "701", "711", "721", "731", "741", "751", "761", "762", "771", "781"
  $Clear = "800"
  $PartlyCloudy = "801", "802", "803"
  $Cloudy = "804"
  $Windy = "900", "901", "902", "903", "904", "905", "906", "951", "952", "953", "954", "955", "956", "957", "958", "959", "960", "961", "962"
  
  <# Create the variables we will use to display weather information #>
  $Weather = (Get-Culture).textinfo.totitlecase($CurrentValue.tolower())
  $CurrentTemp = "Current Temp: " + [Math]::Round($XMLData.temperature.value, 0) + " C"
  $High = "Today's High: " + [Math]::Round($XMLData.temperature.max, 0) + " C"
  $Low = "Today's Low: " + [Math]::Round($XMLData.temperature.min, 0) + " C"
  $Humidity = "Humidity: " + $XMLData.humidity.value + $XMLData.humidity.unit
  $Precipitation = "Precipitation: " + (Get-Culture).textinfo.totitlecase($PrecipitationValue.tolower())
  
  <# Checking if there is precipitation and if so, display the values in $precipitationMM and $precipitationHRS #>
  if ($Precipitation -eq "Precipitation: No") {
    $PrecipitationData = "Precip. Data: No Precipitation"
  } else {
    $PrecipitationData = "Precip. Data: " + $PrecipitationMM + "mm in the last " + $PrecipitationHRS
  }
  
  $script:WindSpeed = "Wind Speed: " + ([math]::Round(([decimal]$XMLData.wind.speed.value * 1.609344), 1)) + " km/h" + " - Direction: " + $XMLData.wind.direction.code
  $WindCondition = "Wind Condition: " + (Get-Culture).TextInfo.ToTitleCase($WindValue.tolower())
  $Sunrise = "Sunrise: " + $Sunrise
  $Sunset = "Sunset: " + $Sunset
  
  <# END VARIABLES #>
  
  Write-Host ""
  Write-Host "Current weather conditions for" $XMLData.city.name -nonewline; Write-Host " -" $Weather -ForegroundColor yellow;
  Write-Host "Last Updated:" -nonewline; Write-Host "" $LastUpdate -ForegroundColor yellow;
  Write-Host ""
  
  Show-WeatherImage
}

function Show-WeatherImage {
  if ($Thunder.Contains($XMLData.weather.number)) {
    Write-Host "	    .--.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	 .-(    ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	(___.__)__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	  /_   /_  		" -ForegroundColor yellow -nonewline; Write-Host "$Sunrise		$WindSpeed" -ForegroundColor white;
    Write-Host "	   /    /  		" -ForegroundColor yellow -nonewline; Write-Host "$Sunset		$WindCondition" -ForegroundColor white;
    Write-Host ""
  } elseif ($Drizzle.Contains($XMLData.weather.number)) {
    Write-Host "	  .-.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	 (   ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	(___(__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	 / / / 			" -ForegroundColor cyan -nonewline; Write-Host "$Sunrise		$WindSpeed" -ForegroundColor white;
    Write-Host "	  /  			" -ForegroundColor cyan -nonewline; Write-Host "$Sunset		$WindCondition" -ForegroundColor white;
    Write-Host ""
  } elseif ($Rain.Contains($XMLData.weather.number)) {
    Write-Host "	    .-.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	   (   ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	  (___(__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	 //////// 		" -ForegroundColor cyan -nonewline; Write-Host "$Sunrise		$WindSpeed" -ForegroundColor white;
    Write-Host "	 /////// 		" -ForegroundColor cyan -nonewline; Write-Host "$Sunset		$WindCondition" -ForegroundColor white;
    Write-Host ""
  } elseif ($LightSnow.Contains($XMLData.weather.number)) {
    Write-Host "	  .-.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	 (   ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	(___(__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	 *  *  *		$Sunrise		$WindSpeed"
    Write-Host "	*  *  * 		$Sunset		$WindCondition"
    Write-Host ""
  } elseif ($HeavySnow.Contains($XMLData.weather.number)) {
    Write-Host "	    .-.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	   (   ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	  (___(__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	  * * * * 		$Sunrise		$WindSpeed"
    Write-Host "	 * * * *  		$Sunset		$WindCondition"
    Write-Host "	  * * * * "
    Write-Host ""
  } elseif ($SnowAndRain.Contains($XMLData.weather.number)) {
    Write-Host "	  .-.   		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	 (   ). 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	(___(__)		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	 */ */* 		$Sunrise		$WindSpeed"
    Write-Host "	* /* /* 		$Sunset		$WindCondition"
    Write-Host ""
  } elseif ($Atmosphere.Contains($XMLData.weather.number)) {
    Write-Host "	_ - _ - _ -		" -ForegroundColor gray -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	 _ - _ - _ 		" -ForegroundColor gray -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	_ - _ - _ -		" -ForegroundColor gray -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	 _ - _ - _ 		" -ForegroundColor gray -nonewline; Write-Host "$Sunrise		$WindSpeed" -ForegroundColor white;
    Write-Host "				$Sunset		$WindCondition"
    Write-Host ""
  }
    <#	
      The following will be displayed on clear evening conditions
      It is set to 18:00:00 (6:00PM). Change this to any value you want.
    #> elseif ($Clear.Contains($XMLData.weather.number) -and $Time -gt "18:00:00") {
    Write-Host "	    *  --.			$CurrentTemp		$Humidity"
    Write-Host "	        \  \   *		$High		$Precipitation"
    Write-Host "	         )  |    *		$Low		$PrecipitationData"
    Write-Host "	*       <   |			$Sunrise		$WindSpeed"
    Write-Host "	   *    ./ /	  		$Sunset		$WindCondition"
    Write-Host "	       ---'   *   "
    Write-Host ""
  } elseif ($Clear.Contains($XMLData.weather.number)) {
    Write-Host "	   \ | /  		" -ForegroundColor Yellow -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	    .-.   		" -ForegroundColor Yellow -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	-- (   ) --		" -ForegroundColor Yellow -nonewline; Write-Host "$Low		$PrecipitationData" -ForegroundColor white;
    Write-Host "	    ``'``   		" -ForegroundColor Yellow -nonewline; Write-Host "$Sunrise		$WindSpeed" -ForegroundColor white;
    Write-Host "	   / | \  		" -ForegroundColor yellow -nonewline; Write-Host "$Sunset		$WindCondition" -ForegroundColor white;
    Write-Host ""
  } elseif ($PartlyCloudy.Contains($XMLData.weather.number)) {
    Write-Host "	   \ | /   		" -ForegroundColor Yellow -nonewline; Write-Host "$CurrentTemp		$Humidity" -ForegroundColor white;
    Write-Host "	    .-.    		" -ForegroundColor Yellow -nonewline; Write-Host "$High		$Precipitation" -ForegroundColor white;
    Write-Host "	-- (  .--. 		$Low		$PrecipitationData"
    Write-Host "	   .-(    ). 		$Sunrise		$WindSpeed"
    Write-Host "	  (___.__)__)		$Sunset		$WindCondition"
    Write-Host ""
  } elseif ($Cloudy.Contains($XMLData.weather.number)) {
    Write-Host "	    .--.   		$CurrentTemp		$Humidity"
    Write-Host "	 .-(    ). 		$High		$Precipitation"
    Write-Host "	(___.__)__)		$Low		$PrecipitationData"
    Write-Host "	            		$Sunrise		$WindSpeed"
    Write-Host "				$Sunset		$WindCondition"
    Write-Host ""
  } elseif ($Windy.Contains($XMLData.weather.number)) {
    Write-Host "	~~~~      .--.   		$CurrentTemp		$Humidity"
    Write-Host "	 ~~~~~ .-(    ). 		$High		$Precipitation"
    Write-Host "	~~~~~ (___.__)__)		$Low		$PrecipitationData"
    Write-Host "	                 		$Sunrise		$WindSpeed"
    Write-Host "					$Sunset		$WindCondition"
  }
}