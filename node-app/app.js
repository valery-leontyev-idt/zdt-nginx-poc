const express = require('express');
const app = express();
var host = process.env.HOST || "localhost";
var port = process.env.PORT || 3000;
var deploymentEnvironmentName = process.env.DEPLOYMENT_ENVIRONMENT_NAME || "[DEPLOYMENT ENVIRONMENT NAME IS NOT SET]";

app.get('/', (req, res) => res.send(`Hello from ${deploymentEnvironmentName}!`));
app.get('/health', (req, res) => res.send('OK'));

app.listen(port, host, () => console.log(`Example app listening at http://${host}:${port}`));