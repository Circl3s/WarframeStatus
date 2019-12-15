function Get-VallisTemp {

    [CmdletBinding()]

    param (
        [ValidateSet("PC", "XB1", "PS4", "SWI")]
        [String]$Platform = "PC",
        [Switch]$DisableIcons,
        [Switch]$DebugWarm
    )

    $Response = ConvertFrom-Json $(Invoke-WebRequest -Method GET -Uri "https://api.warframestat.us/$($Platform.ToLower())/vallisCycle").Content

    $ColdIcon = if($DisableIcons) {} else {"$([char]0xe36f) "}
    $WarmIcon = if($DisableIcons) {} else {"$([char]0xfa62)"}
    $TimeIcon = if($DisableIcons) {} else {"$([char]0xf64f) "}

    if($DebugWarm) {$Response.isWarm = $true}

    if($Response.isWarm) {
        Write-Host "$($WarmIcon)It's warm." -ForegroundColor Yellow
    } else {
        Write-Host "$($ColdIcon)It's cold." -ForegroundColor Cyan
    }

    Write-Host "$TimeIcon$($Response.timeLeft) until it's $(if($Response.isWarm) {"cold"} else {"warm"}) again."
    
}

function Get-PlainsTime {

    [CmdletBinding()]

    param (
        [ValidateSet("PC", "XB1", "PS4", "SWI")]
        [String]$Platform = "PC",
        [Switch]$DisableIcons,
        [Switch]$DebugDay
    )

    $Response = ConvertFrom-Json $(Invoke-WebRequest -Method GET -Uri "https://api.warframestat.us/$($Platform.ToLower())/cetusCycle").Content

    $DayIcon = if($DisableIcons) {} else {"$([char]0xfaa7)"}
    $NightIcon = if($DisableIcons) {} else {"$([char]0xfa93)"}
    $TimeIcon = if($DisableIcons) {} else {"$([char]0xf64f) "}

    if($DebugDay) {$Response.isDay = $true}

    if($Response.isDay) {
        Write-Host "$($DayIcon)It's daytime." -ForegroundColor Yellow
    } else {
        Write-Host "$($NightIcon)It's nighttime." -ForegroundColor Cyan
    }

    Write-Host "$TimeIcon$($Response.timeLeft) until $(if($Response.isDay) {"sunset"} else {"sunrise"})."
}

function Get-Invasions {

    [CmdletBinding()]

    param (
        [ValidateSet("PC", "XB1", "PS4", "SWI")]
        [String]$Platform = "PC",
        [Switch]$DisableIcons
    )

    $Response = ConvertFrom-Json $(Invoke-WebRequest -Method GET -Uri "https://api.warframestat.us/$($Platform.ToLower())/invasions").Content

    [int]$BarWidth = $Host.UI.RawUI.WindowSize.Width / 2

    $NodeIcon = if($DisableIcons) {"Node: "} else {"$([char]0xf450) "}
    $InfestedIcon = if($DisableIcons) {"Type: "} else {"$([char]0xf5a6) "}
    $SiegeIcon = if($DisableIcons) {"Type: "} else {"$([char]0xfc85) "}
    $RewardIcon = if($DisableIcons) {"Reward: "} else {"$([char]0xfc24) "}

    foreach($Node in $Response) {
        $FirstHalf = ""
        $SecondHalf = ""
        [int]$FirstHalfLength = $BarWidth * ($Node.completion / 100)
        [int]$SecondHalfLength = $BarWidth - $FirstHalfLength

        $i = 0
        $e = 0
        while($i -lt $FirstHalfLength) {
            $FirstHalf = $FirstHalf + [char]0x2588
            $i++
        }
        while($e -lt $SecondHalfLength) {
            $SecondHalf = $SecondHalf + [char]0x2588
            $e++
        }

        $AttackerColor = switch ($Node.attackingFaction) {
            "Grineer" {"Red"}
            "Corpus" {"Blue"}
            "Infested" {"Green"}
            Default {"White"}
        }

        $DefenderColor = switch ($Node.defendingFaction) {
            "Grineer" {"Red"}
            "Corpus" {"Blue"}
            "Infested" {"Green"}
            Default {"White"}
        }

        Write-Host $("$NodeIcon" + $Node.node)
        Write-Host $("$(if($Node.vsInfestation) {$InfestedIcon} else {$SiegeIcon})" + $Node.desc)

        Write-Host " $($Node.attackingFaction) $FirstHalf" -ForegroundColor $AttackerColor -NoNewline
        Write-Host "$SecondHalf $($Node.defendingFaction)" -ForegroundColor $DefenderColor

        Write-Host "$RewardIcon" -NoNewline
        if($Node.vsInfestation -ne $true){
            Write-Host $Node.attackerReward.asString -ForegroundColor $AttackerColor -NoNewline
            Write-Host " vs " -NoNewline
        }
        Write-Host "$($Node.defenderReward.asString)`n" -ForegroundColor $DefenderColor
    }
}

function Get-Darvo {

    [CmdletBinding()]
    
    param (
        [ValidateSet("PC", "XB1", "PS4", "SWI")]
        [String]$Platform = "PC",
        [Switch]$DisableIcons
    )

    $Response = ConvertFrom-Json $(Invoke-WebRequest -Method GET -Uri "https://api.warframestat.us/$($Platform.ToLower())/dailyDeals").Content

    $DiscountIcon = if($DisableIcons) {} else {"$([char]0xf96e)"}
    $PriceIcon = if($DisableIcons) {"Price: "} else {"$([char]0xf155) "}
    $NameIcon = if($DisableIcons) {"Item: "} else {"$([char]0xf9f8)"}
    $Logo = if($DisableIcons) {"DARVO'S DAILY DEAL"} else {"$([char]0xfbbb) DARVO'S DAILY DEAL"}
    $StockIcon = if($DisableIcons) {} else {"$([char]0xf290) "}

    $OldPrice = ""
    foreach($char in "$($Response.originalPrice)".toCharArray()) {
        $OldPrice = $OldPrice + $char + [char]0x0336
    }

    Write-Host $Logo -ForegroundColor Yellow

    Write-Host $NameIcon$($($Response | Select-Object -ExpandProperty "item").ToUpper())

    Write-Host $PriceIcon"Only " -ForegroundColor Blue -NoNewline
    Write-Host $OldPrice" " -ForegroundColor DarkGray -NoNewline
    Write-Host $Response.salePrice"platinum!" -ForegroundColor Blue

    Write-Host $DiscountIcon"That's" $Response.discount"% off!" -ForegroundColor Cyan

    Write-Host $StockIcon"Only "$($Response.total - $Response.sold)" left in stock. Get 'em while you still can!" -ForegroundColor Red
}