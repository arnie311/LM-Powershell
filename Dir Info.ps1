$path = "E:\Users"

$items = Get-ChildItem -Path $path -Directory
foreach ($item in $items) {
    $info = Get-ChildItem -Path "$path\$($item.Name)" -recurse | Measure-Object -Property length -Sum
    Write-Host "# of files in $($item.Name) Directory: $($info.Count)"
    Write-Host "Size of $($item.Name) Directory: $($info.Sum) bytes"
}


##Output

<#
# of files in Greyson Directory: 1
Size of Greyson Directory: 94 bytes
# of files in Jessica Directory: 236
Size of Jessica Directory: 49177200383 bytes
# of files in Jonathan Directory: 6073
Size of Jonathan Directory: 394061940632 bytes
#>
