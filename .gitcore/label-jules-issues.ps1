$issues = @(1188,1189,1190,1191,1192,1193,1194,1195,1196,1197,1198,1199,1200,1201,1202,1203,1204)
foreach ($num in $issues) {
    Write-Output "Labeling issue $num..."
    gh issue edit $num --add-label jules --repo iberi22/OrionHealth 2>&1
}
Write-Output "Done."
