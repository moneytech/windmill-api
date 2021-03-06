#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "$DIR/TestSuite.sh"

set -e

echo -e "\nendpoint: /account/{account}/device\n"
echo "Given device token; Assert device register 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -X POST http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/device?token=651743ecad5704a088ff54a0234f37a013bd17b3401d1612cb8ded8af1fa2225 -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs") 

set +x;assertTrue 200 "${HTTP_CODE}"

echo -e "\nendpoint: /account/{account}/export\n"
echo "Given valid subscription access; Assert publish 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs")

set +x;assertTrue 204 "${HTTP_CODE}"

echo "Given invalid subscription access; Assert POST /export 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.ZjrkDhtjH-sNmrerv8bk1zO7AH8rB3oImMSHuPNmSC4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given valid subscription access for a different account; Assert 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -F "plist=@$DIR/manifest.plist" http://192.168.1.2:8080/account/5804928c-dd67-4799-a6de-0a30b735f12c/export -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjEwMDAwMDA0OTc5MzE5OTMiLCJleHAiOjMzMTA4MTg4NTc0LCJ0eXAiOiJhdCIsInYiOjF9.ZjrkDhtjH-sNmrerv8bk1zO7AH8rB3oImMSHuPNmSC4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo -e "\nendpoint: /account/{account}/export/{export}\n"
echo "Given valid subscription access to PATCH export; Assert 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" -X PATCH http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/export/fefd9f84-a8d1-4842-855c-c446f5976e16 -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs" -d '{"configuration": "RELEASE","commit": {"shortSha": "e8fb1cf","branch": "master", "date":1540414800},"applicationProperties": {"bundleDisplayName": "Windmill","bundleVersion": "1.2"},"deployment": {"target": "12.2"},"distributionSummary": {"certificateExpiryDate": 1540414800}}' -H "Content-type: application/json")

set +x;assertTrue 200 "${HTTP_CODE}"

echo -e "\nendpoint: /account/{account}/exports\n"
echo "Given valid subscription access; Assert GET exports 200 OK"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs")

set +x;assertTrue 200 "${HTTP_CODE}"

echo "Given expired subscription access; Assert GET /exports 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MCwidHlwIjoiYXQiLCJ2IjoxfQ.P-ajI8U1I1sjlFuRNOpJctRDd9rgktiErhsnbbnVlwE")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given invalid subscription access; Assert GET /exports 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/14810686-4690-4900-ada5-8b0b7338aa39/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.glHTgS1hDWkvlJ06ts8Eu9aVmSjZhJJWkSa_JeCVkr4")

set +x;assertTrue 401 "${HTTP_CODE}"

echo "Given valid subscription access for a different account; Assert 401 Unauthorized"
HTTP_CODE=$(set -x;curl -s -o /dev/null -w "%{http_code}" http://192.168.1.2:8080/account/5804928c-dd67-4799-a6de-0a30b735f12c/exports -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey    JqdGkiOiJjMlZqY21WMCIsInN1YiI6IjU1ZmQyYWMzLTdkZTItNGM2Ny1iMGY4LTc5ZTdjZmEwMjBjMiIsImV4cCI6MzMxMDgxODg1NzQsInR5cCI6ImF0IiwidiI6MX0.yxmDN4QLq0eJeJ1D42ZoIb9HO67o8bRvYXFjDy9bLcs")

set +x;assertTrue 401 "${HTTP_CODE}"
