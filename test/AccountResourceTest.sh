#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "$DIR/TestSuite.sh"

set -e

echo "Given device token; Assert device register 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -X POST http://192.168.1.2:8080/account/24810686-4690-4900-ada5-8b0b7338aa40/device/register?token=651743ecad5704a088ff54a0234f37a013bd17b3401d1612cb8ded8af1fa2225)

set +x;assertTrue 200 "${HTTP_CODE}"

echo "Given valid subscription access; Assert publish 303 See Other"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "ipa=@$DIR/windmill.ipa" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.rzEzm5S0N0fxb2mp83aFwOXduHRjKPI3m18cwkPaiqY")

set +x;assertTrue 303 "${HTTP_CODE}"

echo "Given invalid subscription access; Assert POST /export 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "ipa=@$DIR/windmill.ipa" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.ZjrkDhtjH-sNmrerv8bk1zO7AH8rB3oImMSHuPNmSC4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given valid subscription access for a different account; Assert 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "ipa=@$DIR/windmill.ipa" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/24810686-4690-4900-ada5-8b0b7338aa40/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.ZjrkDhtjH-sNmrerv8bk1zO7AH8rB3oImMSHuPNmSC4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given valid subscription access; Assert GET exports 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.rzEzm5S0N0fxb2mp83aFwOXduHRjKPI3m18cwkPaiqY")

set +x;assertTrue 200 "${HTTP_CODE}"

echo "Given expired subscription access; Assert GET /exports 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjAsInR5cCI6ImF0IiwidiI6MX0.O1WL0ny5pneJLYTtQR6Qti-EHxmLpcmO6T_cY-JsjUw")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given invalid subscription access; Assert GET /exports 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.ZjrkDhtjH-sNmrerv8bk1zO7AH8rB3oImMSHuPNmSC4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given valid subscription access for a different account; Assert 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/24810686-4690-4900-ada5-8b0b7338aa40/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.rzEzm5S0N0fxb2mp83aFwOXduHRjKPI3m18cwkPaiqY")

set +x;assertTrue 401 "${HTTP_CODE}"