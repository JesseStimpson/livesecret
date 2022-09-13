
function importKey(rawkey) {
  return window.crypto.subtle.importKey(
    "raw",
    rawkey,
    {
      name: "AES-GCM",
    },
    false, // non-extractable
    ["encrypt", "decrypt"]
  );
}

function exportKey(key) {
  return window.crypto.subtle.exportKey("raw", key);
}

function generateKey() {
  return window.crypto.subtle.generateKey(
    {
      name: "AES-GCM",
      length: 256,
    },
    true, // extractable
    ["encrypt", "decrypt"]
  );
}

function encrypt(data, key, iv) {
  return window.crypto.subtle.encrypt(alg(iv), key, data);
}

function decrypt(data, key, iv) {
  return window.crypto.subtle.decrypt(alg(iv), key, data);
}

function alg(iv) {
  return {
    name: "AES-GCM",
    iv: iv,
    tagLength: 128,
  };
}

function sha256(buffer) {
  return window.crypto.subtle.digest("SHA-256", buffer);
}

function arrayBufferToBase64(buffer) {
  var binary = '';
  var bytes = new Uint8Array(buffer);
  var len = bytes.byteLength;
  for (var i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}

function base64ToArrayBuffer(base64) {
  var binary_string = window.atob(base64);
  var len = binary_string.length;
  var bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
    bytes[i] = binary_string.charCodeAt(i);
  }
  return bytes.buffer;
}

const GeneratePassphrase = async function() {
    var encryptionkey = await generateKey();
    var rawkey = await exportKey(encryptionkey);
    userkey = arrayBufferToBase64(rawkey);
    return userkey;
}

const EncryptSecret = async function(userkey, ivVal, burnkey, cleartextVal) {

  var encoder = new TextEncoder();

  var iv = base64ToArrayBuffer(ivVal);

  var userkeyBuffer = await sha256(encoder.encode(userkey));
  var encryptionkey = await importKey(userkeyBuffer);


  // Read and clear the input in the form
  var data = encoder.encode(burnkey + "\n" + cleartextVal);

  var ciphertextBuffer = await encrypt(data, encryptionkey, iv);
  var ciphertextVal = arrayBufferToBase64(ciphertextBuffer);
  return ciphertextVal;
}

const DecryptSecret = async function(userkey, ivVal, ciphertextVal) {
  var encoder = new TextEncoder();

  var iv = base64ToArrayBuffer(ivVal);

  var userkeyBuffer = await sha256(encoder.encode(userkey));
  var encryptionkey = await importKey(userkeyBuffer);
  var decryptedData = await decrypt(base64ToArrayBuffer(ciphertextVal), encryptionkey, iv);
  var decoder = new TextDecoder("utf-8");
  var res = decoder.decode(decryptedData)

  // The first line is the key that allows us to burn the message
  var burnkey = res.split('\n')[0].trim();
  var cleartext = res.substring(res.indexOf("\n") + 1);

  return {burnkey: burnkey, cleartext: cleartext}
}

let Encryption = {
    GeneratePassphrase: GeneratePassphrase,
    EncryptSecret: EncryptSecret,
    DecryptSecret: DecryptSecret
}

export default Encryption;
