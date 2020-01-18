// var request = require('request');
var YAML = require('js-yaml');
var request = require('request');
var fs = require('fs');
var path = require('path');
var shell = require('shelljs');
var roles = '';
var roleId = '';
var secreteID = '';
var vaultUrl = '';
// var dockerCLI = require('docker-cli-js');

try {
  roles = YAML.safeLoad(fs.readFileSync(path.join(__dirname, 'role.yml'), 'utf8'));
  roleId = roles.roleId;
  secreteID = roles.secretId;
  vaultUrl = roles.vaultUrl;
  console.log(roles);
} catch (e) {
  console.log(e);
}

function appLogin (vaultUrl, roleId, secreteID) {
  return new Promise(function (resolve, reject) {
    request.post(vaultUrl, {
      json: {
        'role_id': roleId,
        'secret_id': secreteID
      }
    }, (error, res, body) => {
      if (error) {
        reject(error);
        console.error(error);
      } else {
        console.log(`status Code App Login: ${res.statusCode}`);
        resolve(body);
      }
    });
  });
}

function getCredentials (data) {
  var options = {
    url: 'https://{{vault-url}}:8200/v1/secret/dtr',
    headers: {
      'X-Vault-Token': 'empty'

    }
  };

  return new Promise(function (resolve, reject) {
    options.headers['X-Vault-Token'] = data.auth.client_token;
    request.get(options, (error, res, body) => {
      if (error) {
        reject(error);
        console.error(error);
      } else {
        console.log(`status Code RoleLogin: ${res.statusCode}`);
        var output = JSON.parse(body);
        resolve(output);
      }
    });
  });
}

/* function getImages () {
  shell.exec('./kollaPull.sh');
}
*/
function dtrPush (data) {
  var username = data.data.user;
  var password = data.data.password;
  shell.exec(`./dtr.sh -u  ${username} -p  ${password}`);
}

// getImages();

appLogin(vaultUrl, roleId, secreteID).then(getCredentials).then(dtrPush);
