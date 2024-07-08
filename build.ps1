# Define variables
$cookieName = ".ROBLOSECURITY"
$cookieDomain = "roblox.com"
$firefoxCookiesPath = "C:\Users\Stayroh\AppData\Roaming\Mozilla\Firefox\Profiles\li6k5ooy.default-release\cookies.sqlite"

# Construct the SQLite query
$query = "SELECT name, value FROM moz_cookies WHERE host LIKE '%$cookieDomain%' AND name='$cookieName';"

# Run the query and capture the output
$result = & sqlite3 $firefoxCookiesPath $query

# Check if $result is empty
if ([string]::IsNullOrEmpty($result)) {
    Write-Warning "No result found. Exiting script."
    exit 1
}

# Remove the first 15 characters from $result
$result = $result.Substring(15)

# Display the modified result
remodel run Remodel.lua --auth $result

rojo build -o Train-System.rbxl